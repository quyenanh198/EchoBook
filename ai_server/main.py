"""
EchoBook AI Server - local FastAPI process, Windows only.

Runs standalone alongside the Flutter app (see
lib/services/voice_clone/ai_server_manager.dart) and does two things the
Flutter app itself cannot do offline on its own:

1. POST /voice/clone - extracts a real speaker embedding ("voice gene")
   from a recorded sample and saves it as a portable .echovoice file.
2. POST /tts/speak - reads text aloud offline with Piper, a neural TTS
   engine, giving EchoBook a real Vietnamese voice instead of relying on
   whatever (if any) Vietnamese voice pack the OS happens to have.

Nothing here talks to the network. Everything is localhost-only, single
user, single machine - see run(); binding to 127.0.0.1 is intentional.
"""

from __future__ import annotations

import logging
import re
from pathlib import Path

from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from fastapi.responses import FileResponse

from piper_engine import PiperEngine, PiperUnavailableError
from voice_embedding import EchoVoiceFile, extract_embedding, save_echovoice

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("echobook-ai-server")

app = FastAPI(title="EchoBook AI Server", version="0.1.0")

VOICES_DIR = Path.home() / "EchoBook" / "voices"
VOICES_DIR.mkdir(parents=True, exist_ok=True)

piper = PiperEngine()

_SAFE_NAME_RE = re.compile(r"[^A-Za-z0-9_-]+")


def _safe_filename(name: str) -> str:
    cleaned = _SAFE_NAME_RE.sub("_", name).strip("_")
    return cleaned or "voice"


@app.get("/health")
def health() -> dict:
    return {"status": "ok", "piper_ready": piper.is_ready()}


@app.post("/voice/clone")
async def clone_voice(name: str = Form(...), sample: UploadFile = File(...)) -> dict:
    """
    Accepts a recorded WAV sample, extracts a speaker embedding from it,
    and saves the result as `<name>.echovoice` under VOICES_DIR.
    """
    if not sample.filename:
        raise HTTPException(400, "No audio file uploaded.")
    raw = await sample.read()
    if not raw:
        raise HTTPException(400, "Uploaded audio file is empty.")

    tmp_path = VOICES_DIR / f"_tmp_{_safe_filename(name)}.wav"
    tmp_path.write_bytes(raw)
    try:
        embedding = extract_embedding(tmp_path)
    except Exception as exc:
        logger.exception("Embedding extraction failed for %s", name)
        raise HTTPException(500, f"Could not extract a voice embedding: {exc}") from exc
    finally:
        tmp_path.unlink(missing_ok=True)

    echovoice = EchoVoiceFile(name=name, embedding=embedding)
    out_path = VOICES_DIR / f"{_safe_filename(name)}.echovoice"
    save_echovoice(echovoice, out_path)
    logger.info("Saved %s (%d-dim embedding)", out_path, len(embedding))

    return {"name": name, "path": str(out_path), "embeddingDim": len(embedding)}


@app.get("/voice/{filename}")
def download_voice(filename: str) -> FileResponse:
    path = VOICES_DIR / filename
    if not path.exists() or path.suffix != ".echovoice":
        raise HTTPException(404, "Voice profile not found.")
    return FileResponse(path, media_type="application/json", filename=filename)


@app.post("/tts/speak")
def speak(text: str = Form(...), voice: str = Form("vi_VN"), speed: float = Form(1.0)) -> FileResponse:
    """
    Synthesizes `text` with Piper and returns a WAV file.

    NOTE: this reads with Piper's own base voice, not a caller's cloned
    timbre yet - genuine embedding-conditioned synthesis (e.g. Coqui XTTS)
    is a future upgrade. `.echovoice` files are captured now (see
    /voice/clone) so that upgrade only needs a new synthesis backend, not a
    new capture pipeline.
    """
    if not text.strip():
        raise HTTPException(400, "text must not be empty.")
    try:
        wav_path = piper.synthesize(text=text, voice=voice, speed=speed)
    except PiperUnavailableError as exc:
        raise HTTPException(503, str(exc)) from exc
    return FileResponse(wav_path, media_type="audio/wav", filename=wav_path.name)


def run() -> None:
    import uvicorn

    # 127.0.0.1 only: this server is never meant to be reachable from
    # outside the machine it runs on.
    uvicorn.run(app, host="127.0.0.1", port=8722, log_level="info")


if __name__ == "__main__":
    run()
