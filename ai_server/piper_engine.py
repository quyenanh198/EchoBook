"""
Wraps the `piper` CLI (https://github.com/rhasspy/piper) for offline,
neural-quality text-to-speech — this is EchoBook's baseline Vietnamese
reader ("bo doc tieng Viet offline chuan"), used before real
embedding-conditioned voice cloning is wired up.

Piper is driven as a subprocess, not a Python binding, mirroring how
EchoBook's Flutter side shells out to espeak-ng/SAPI5: the engine binary
and voice model can be swapped or upgraded without touching this server's
code.
"""

from __future__ import annotations

import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path


def _app_root() -> Path:
    """
    Directory the binary/models are expected to live next to.

    When packaged (`sys.frozen` — see package_windows.bat, which builds
    this with PyInstaller's `--onefile`), that's the folder containing
    `EchoBookAIServer.exe` itself (NOT PyInstaller's temp extraction dir —
    piper.exe and the voice models are copied in as loose files alongside
    the packaged exe, not embedded into the onefile bundle, so a voice can
    be swapped/upgraded without rebuilding it). In development, it's this
    source file's own directory.
    """
    if getattr(sys, "frozen", False):
        return Path(sys.executable).parent
    return Path(__file__).parent


MODELS_DIR = _app_root() / "models" / "piper"

# Maps a friendly voice id (what EchoBook's UI/API uses) to the Piper
# model filename (without extension) under MODELS_DIR. Download matching
# <name>.onnx + <name>.onnx.json pairs from
# https://huggingface.co/rhasspy/piper-voices/tree/main/vi/vi_VN
DEFAULT_VOICES = {
    "vi_VN": "vi_VN-vais1000-medium",
    "vi_VN-25hours": "vi_VN-25hours_single-low",
}


class PiperUnavailableError(RuntimeError):
    """Raised when the piper binary or the requested voice model isn't available."""


class PiperEngine:
    def __init__(self) -> None:
        self._piper_bin = self._find_piper_binary()

    def _find_piper_binary(self) -> str | None:
        on_path = shutil.which("piper") or shutil.which("piper.exe")
        if on_path:
            return on_path
        # Bundled next to EchoBookAIServer.exe by package_windows.bat.
        for candidate in (
            _app_root() / "piper" / "piper.exe",
            _app_root() / "piper" / "piper",
            _app_root() / "piper.exe",
        ):
            if candidate.exists():
                return str(candidate)
        return None

    def is_ready(self) -> bool:
        return self._piper_bin is not None

    def synthesize(self, *, text: str, voice: str = "vi_VN", speed: float = 1.0) -> Path:
        """Synthesizes `text` and returns the path to a rendered WAV file."""
        if not self._piper_bin:
            raise PiperUnavailableError(
                "piper binary not found. Download it from "
                "https://github.com/rhasspy/piper/releases, either add it to PATH "
                "or place it at ai_server/piper/piper.exe."
            )

        model_name = DEFAULT_VOICES.get(voice, voice)
        model_path = MODELS_DIR / f"{model_name}.onnx"
        if not model_path.exists():
            raise PiperUnavailableError(
                f"Piper voice model '{model_name}.onnx' not found in {MODELS_DIR}. "
                "Download it (and its matching .onnx.json config) from "
                "https://huggingface.co/rhasspy/piper-voices and place both files there."
            )

        # Piper's --length_scale is inverse of speed: bigger = slower speech.
        length_scale = 1.0 / max(0.25, speed)

        out_path = Path(tempfile.gettempdir()) / f"echobook_tts_{int(time.time() * 1000)}.wav"
        result = subprocess.run(
            [
                str(self._piper_bin),
                "--model", str(model_path),
                "--output_file", str(out_path),
                "--length_scale", str(length_scale),
            ],
            input=text,
            text=True,
            capture_output=True,
        )
        if result.returncode != 0 or not out_path.exists():
            raise PiperUnavailableError(f"Piper synthesis failed: {result.stderr.strip()}")
        return out_path
