"""
Speaker embedding extraction and the `.echovoice` file format.

`.echovoice` is deliberately plain JSON (not a numpy/pickle blob) so a
device that only *imports* a profile — e.g. EchoBook mobile, per the
"Mobile version chi can import de su dung" requirement — never needs
Python, numpy, or any ML runtime to read one. It's just: metadata plus a
list of floats.
"""

from __future__ import annotations

import json
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path

ECHOVOICE_FORMAT = "echovoice"
ECHOVOICE_VERSION = 1
EMBEDDING_MODEL_NAME = "resemblyzer-ge2e"

# Resemblyzer's pretrained encoder always resamples/operates at 16kHz
# internally, regardless of the uploaded sample's original rate.
EMBEDDING_SAMPLE_RATE = 16_000


@dataclass
class EchoVoiceFile:
    name: str
    embedding: list[float]
    sample_rate: int = EMBEDDING_SAMPLE_RATE
    embedding_model: str = EMBEDDING_MODEL_NAME
    created_at: str = field(default_factory=lambda: datetime.now(timezone.utc).isoformat())

    def to_json(self) -> dict:
        return {
            "format": ECHOVOICE_FORMAT,
            "version": ECHOVOICE_VERSION,
            "name": self.name,
            "createdAt": self.created_at,
            "sampleRate": self.sample_rate,
            "embeddingModel": self.embedding_model,
            "embeddingDim": len(self.embedding),
            "embedding": self.embedding,
        }

    @staticmethod
    def from_json(data: dict) -> "EchoVoiceFile":
        if data.get("format") != ECHOVOICE_FORMAT:
            raise ValueError("not a valid .echovoice payload")
        return EchoVoiceFile(
            name=data["name"],
            embedding=list(data["embedding"]),
            sample_rate=data.get("sampleRate", EMBEDDING_SAMPLE_RATE),
            embedding_model=data.get("embeddingModel", "unknown"),
            created_at=data.get("createdAt", ""),
        )


_encoder = None


def _get_encoder():
    """
    Lazily constructs (and caches) the Resemblyzer voice encoder.

    Imported lazily on purpose: resemblyzer pulls in torch/librosa, which
    are only needed the first time someone actually clones a voice, not
    just to import this module or start the server — keeps `/health` and
    the Piper endpoints usable even before that heavier install step (or
    its model download) has finished.
    """
    global _encoder
    if _encoder is None:
        from resemblyzer import VoiceEncoder

        _encoder = VoiceEncoder()
    return _encoder


def extract_embedding(wav_path: Path) -> list[float]:
    """Extracts a 256-dim speaker embedding ("voice gene") from a WAV sample."""
    from resemblyzer import preprocess_wav

    wav = preprocess_wav(wav_path)
    embedding = _get_encoder().embed_utterance(wav)
    return embedding.astype(float).tolist()


def save_echovoice(echovoice: EchoVoiceFile, path: Path) -> None:
    path.write_text(json.dumps(echovoice.to_json(), indent=2), encoding="utf-8")


def load_echovoice(path: Path) -> EchoVoiceFile:
    return EchoVoiceFile.from_json(json.loads(path.read_text(encoding="utf-8")))
