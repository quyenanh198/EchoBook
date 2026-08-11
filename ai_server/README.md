# EchoBook AI Server

A standalone local FastAPI process — the "AI Engine" side of EchoBook's
voice cloning, currently Windows-only (see
`lib/services/voice_clone/ai_server_manager.dart`, which spawns/stops it
alongside the Flutter app). It never talks to the network: everything
binds to `127.0.0.1:8722` and runs fully offline once set up.

It does two things:

1. **`POST /voice/clone`** — takes a recorded WAV sample, runs it through
   [Resemblyzer](https://github.com/resemble-ai/Resemblyzer)'s pretrained
   GE2E speaker encoder, and saves the resulting 256-dim embedding ("voice
   gene") as a portable `<name>.echovoice` JSON file. `VoiceCloneService`
   on the Flutter side calls this automatically after a recording is
   saved; if the server isn't running (or isn't Windows), cloning falls
   back to the existing offline pitch-shift approximation instead of
   failing.
2. **`POST /tts/speak`** — reads text aloud with
   [Piper](https://github.com/rhasspy/piper), a small, fast, genuinely
   offline neural TTS engine. This is EchoBook's answer to "a standard
   offline Vietnamese reader" — much higher quality than relying on
   whatever (if any) Vietnamese voice pack the OS has installed.

## What `/tts/speak` does *not* do yet

Piper synthesizes with its own built-in voice, not the caller's cloned
timbre. Real embedding-conditioned synthesis (feeding the `.echovoice`
vector into the model so it actually sounds like the recorded sample —
e.g. via Coqui XTTS/YourTTS) is a deliberately separate, future upgrade.
Capturing and storing the embedding now means that upgrade only needs a
new synthesis backend swapped into this server — not a new capture
pipeline, and not any change to how `.echovoice` files are produced,
stored, or imported on other platforms.

## Setup (Windows)

```powershell
cd ai_server
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

**Piper** (binary + Vietnamese voice model, both required for `/tts/speak`):

1. Download the Windows build from
   [github.com/rhasspy/piper/releases](https://github.com/rhasspy/piper/releases)
   and put `piper.exe` on `PATH` (or next to this server's executable).
2. Download a Vietnamese voice from
   [huggingface.co/rhasspy/piper-voices](https://huggingface.co/rhasspy/piper-voices/tree/main/vi/vi_VN)
   — you need both the `.onnx` model and its matching `.onnx.json` config.
   Recommended: `vi_VN-vais1000-medium` (better quality) or
   `vi_VN-25hours_single-low` (smaller/faster).
3. Place both files under `ai_server/models/piper/`, e.g.:
   ```
   ai_server/models/piper/vi_VN-vais1000-medium.onnx
   ai_server/models/piper/vi_VN-vais1000-medium.onnx.json
   ```

## Running

```powershell
python main.py
# or: uvicorn main:app --host 127.0.0.1 --port 8722
```

`GET /health` reports `{"status": "ok", "piper_ready": true|false}` —
`piper_ready` is false until both the binary and a voice model above are
in place; `/voice/clone` works independently of Piper.

## The `.echovoice` format

Plain JSON, deliberately — so a device that only *imports* a profile (see
"mobile just imports it to use") never needs Python, numpy, or any ML
runtime, just a JSON parser:

```json
{
  "format": "echovoice",
  "version": 1,
  "name": "My Voice",
  "createdAt": "2026-08-11T06:00:00+00:00",
  "sampleRate": 16000,
  "embeddingModel": "resemblyzer-ge2e",
  "embeddingDim": 256,
  "embedding": [0.0123, -0.0456, "... 256 floats total"]
}
```

## Packaging into `EchoBookAIServer.exe`

Referenced by `package_windows.bat` (see the top-level packaging plan):

```powershell
pyinstaller --onefile --name EchoBookAIServer main.py
```

Copy the resulting `dist/EchoBookAIServer.exe` next to `echobook.exe` in
the Flutter Windows release build — `AiServerManager` looks for it right
there, alongside the Flutter binary.
