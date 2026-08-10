# EchoBook

Offline-first ebook reader with text-to-speech listening, voice customization, and audio export — built with Flutter for Windows, Android, iOS and Linux from one codebase.

## Why Flutter

A single Dart codebase covers Windows desktop (the primary target for this build), Android, iOS and Linux with one native-compiled UI, one state management layer, and one local database schema — no separate "web view wrapper" or duplicated business logic per platform. Flutter's desktop support is production-grade as of 2026, and every core feature EchoBook needs (SQLite via `drift`, native TTS via platform channels, file system access, background-capable audio) has mature, actively maintained packages.

## Architecture

| Concern | Choice |
|---|---|
| State management | Riverpod (`flutter_riverpod`) |
| Local database | `drift` over SQLite — `Book`, `ReadingProgress`, `Bookmark`, `VoiceProfile`, `ExportJob` tables |
| Ebook parsing | `epubx` (EPUB), `syncfusion_flutter_pdf` (PDF text/outline extraction), built-in TXT parser |
| Live TTS (Listen Mode) | `flutter_tts` on Windows/Android/iOS/macOS, wrapping each platform's native offline engine (SAPI5/OneCore on Windows, `AVSpeechSynthesizer` on iOS, `TextToSpeech` on Android). **Linux** has no `flutter_tts` implementation at all, so it gets a dedicated offline engine backed by the `espeak-ng` CLI instead (see [Linux TTS](#linux-tts-and-vietnamese-support) below) |
| Offline audio export | Platform-specific file synthesizers (see below) + a pure-Dart WAV concatenator, optionally piped through a system `ffmpeg` for MP3/M4A |
| Voice cloning | Beta: pitch-calibrates a real system voice from a recorded sample (see [Voice cloning](#voice-cloning-beta)) |

Everything above runs fully offline. Nothing in the app calls out to the network.

### Project structure

```
lib/
  core/            # theme (dark + teal accent), shared utils (sentence splitting, progress math, file paths)
  data/            # Drift schema + repositories
  services/        # parsing, TTS engines, export pipeline, voice cloning — all UI-agnostic
  features/
    shell/         # bottom nav (mobile) / rail (desktop) + tab state
    library/       # import flow, grid/list, search/sort
    reader/        # scroll + paginated reading, TOC, bookmarks, appearance settings
    tts_player/    # Listen Mode controller + mini player
    voices/        # voice profiles, cloning flow
    export/        # export scope/options UI + job tracking
test/
  unit/            # parsing, TTS/export logic, pure math — no platform plugins required
  db/              # Drift CRUD against an in-memory database
  widget/          # key widgets (mini player, book/voice cards, empty states)
```

### Why a `VoiceEngine` / `TtsFileSynthesizer` split

Listen Mode ("speak this out loud right now") and Audio Export ("render this to a file I can keep") turn out to need different native APIs on every platform — most notably on Windows, where `flutter_tts` can drive live speech but has **no** file-export support at all. `VoiceEngine` (`lib/services/tts/`) handles live playback; `TtsFileSynthesizer` handles offline rendering-to-file, with a platform-specific implementation per OS:

- **Windows** — shells out to a short PowerShell script using `System.Speech.Synthesis` (SAPI5), the only offline API on Windows that can render TTS straight to a `.wav` file. This is a different, smaller voice set than the WinRT/OneCore voices `flutter_tts` lists for live playback, and it has no pitch API — so cloned-voice pitch shaping applies to Listen Mode but not to exported audio on Windows. Speed/rate applies to both.
- **Android / iOS** — uses `flutter_tts`'s native `synthesizeToFile`, which both platforms support directly.
- **Linux** — shells out to `espeak-ng`, mirroring the Windows approach (see below).

Chapters are rendered to WAV per-chapter, concatenated with a small pure-Dart WAV stitcher (`services/export/wav_tools.dart`), then converted to the requested format.

### Linux TTS (and Vietnamese support)

`flutter_tts` has no Linux implementation — it's simply absent from `linux/flutter/generated_plugin_registrant.cc`, unlike every other TTS-adjacent plugin this project uses (`record_linux`, `sqlite3_flutter_libs`, ...). Before this was fixed, every call into it on Linux threw an unhandled `MissingPluginException`; because Listen Mode drives playback from a fire-and-forget loop, that exception had nowhere to go and took the whole app down — which is why only the plugin-free features (reading, import/extraction) worked, while Listen Mode, voice switching and voice cloning all crashed.

`lib/services/tts/linux_espeak_engine.dart` and `lib/services/tts/linux_espeak_file_synthesizer.dart` fill that gap with [`espeak-ng`](https://github.com/espeak-ng/espeak-ng), a small, offline, everywhere-packaged synthesizer, driven the same way the Windows SAPI5 synthesizer is (a subprocess, not a Flutter plugin — no native build changes needed). `VoiceEngineFactory`/`TtsFileSynthesizerFactory` route to it automatically on Linux; every other platform is unaffected.

Install it once per machine:
```bash
sudo apt install espeak-ng      # Debian/Ubuntu
sudo dnf install espeak-ng      # Fedora
sudo pacman -S espeak-ng        # Arch
```

This is also EchoBook's answer to **Vietnamese TTS**: `espeak-ng` ships three genuine Vietnamese voices out of the box (Northern, Central, Southern — `vi`, `vi-vn-x-central`, `vi-vn-x-south`), fully offline, with nothing extra to download. They show up in Voices → "Add system voice" like any other voice, and on first run EchoBook picks a default voice matching the OS's own language (so a `vi_VN` system locale gets a Vietnamese default automatically). On Windows/Android/iOS, Vietnamese still depends on an OS-level voice pack (see Known limitations below) since those platforms have no offline third-party fallback wired in.

### MP3/M4A export and ffmpeg

There is no bundled MP3/AAC encoder — `ffmpeg_kit_flutter` (the usual Flutter choice) is Android/iOS-only and no longer maintained upstream, and a pure-Dart encoder isn't something worth trusting for production audio. Instead:

- If a system **`ffmpeg`** binary is on `PATH`, EchoBook shells out to it for MP3/M4A conversion.
- If not, export **falls back to WAV** and tells the user why in the Export screen.

This keeps the offline-first promise honest — it's an optional local tool, never a network call. Install `ffmpeg` and add it to `PATH` for compressed export formats:
- Windows: `winget install ffmpeg` (or download from ffmpeg.org and add the `bin` folder to `PATH`)
- macOS: `brew install ffmpeg`
- Linux: your package manager's `ffmpeg` package

### Voice cloning (Beta)

Real neural voice cloning (e.g. Coqui XTTS) needs a multi-hundred-MB model and realistically a GPU to run at usable speed — not something that can be bundled or run offline on an average phone or laptop today. EchoBook's cloning flow is deliberately labeled **Beta** and works differently: you record or upload a sample, pick a base system voice, and the app estimates your sample's rough pitch (a lightweight zero-crossing-rate analysis, `services/voice_clone/wav_pitch_estimator.dart`) to nudge that system voice's pitch toward yours. It is a real, if modest, personalization — not a synthesis of your actual voice or timbre.

The architecture keeps the upgrade path open: `VoiceProfile.sampleAudioPath` is already stored for a future real cloning model to train/embed from, and every caller depends only on the resulting `VoiceProfile` row — swapping in a heavier model later means replacing `VoiceCloneService`'s internals, not any of its callers.

### Known limitations

- **MOBI / AZW3** — no maintained pure-Dart decoder exists for these formats. Convert to EPUB first with [Calibre](https://calibre-ebook.com/) (free); EchoBook will tell you this if you try to import one directly.
- **Windows export voice set** differs from the Listen Mode voice list, and pitch shaping doesn't apply to exported audio (see above).
- **Vietnamese (or other non-English) TTS voices on Windows/Android/iOS** depend on OS-level language packs, not on EchoBook itself — install them via Windows Settings → Time & Language → Speech → Add voices (or the Android/iOS equivalent). The app lists whatever the OS reports. **On Linux**, Vietnamese works out of the box via the bundled-dependency `espeak-ng` backend — see [Linux TTS](#linux-tts-and-vietnamese-support) above.
- **Background audio on mobile** — Listen Mode keeps playing while you switch tabs inside the app (it's one process), but continuing playback while the app is fully backgrounded/screen-locked on Android/iOS needs a foreground audio service entitlement this build doesn't configure yet.
- **PDF chapters** without a bookmark/outline fall back to fixed-size page groups (e.g. "Pages 1-12") rather than true chapter titles — PDFs don't have a structural concept of "chapter" without one.

## Getting started (development)

Requires Flutter 3.32+ (stable channel) and Dart 3.8+.

```bash
flutter pub get
flutter run -d windows   # or: chrome / any connected device
```

### Running tests

```bash
flutter analyze
flutter test
```

The test suite covers ebook parsing (EPUB built from a real in-memory zip, TXT heading/fallback splitting), reading-progress save/restore, Drift database CRUD, the Listen Mode player's state machine (play/pause/skip/speed via a fake `VoiceEngine`, no real TTS needed), the voice cloning flow, and the export pipeline (via a fake file synthesizer that produces fixture WAV bytes, so orchestration is tested deterministically without needing a real native TTS engine).

## Building for each platform

### Windows (verified — this is the primary target for this build)

```bash
flutter build windows --release
```

Output: `build\windows\x64\runner\Release\echobook.exe` (plus its required DLLs in the same folder — copy the whole folder to distribute as a portable app).

**If you hit a CMake error about `nuget.exe not found`:** the `flutter_tts` Windows plugin needs NuGet at build time. Download `nuget.exe` from [nuget.org](https://www.nuget.org/downloads) and put it on `PATH`.

**If you hit a CMake install error about `native_assets` or a missing directory under `build\native_assets\windows`:** this is a known Flutter/CMake ordering quirk on some 3.32.x installs — create the folder once (`mkdir build\native_assets\windows`) and rebuild.

#### Windows installer (Inno Setup)

`installer/echobook.iss` packages the Release build into a proper `Setup.exe` — Start Menu shortcut, optional desktop icon, clean uninstaller, no admin rights required (installs per-user by default).

```bash
flutter build windows --release
# Install Inno Setup once: winget install JRSoftware.InnoSetup
"C:\Users\<you>\AppData\Local\Programs\Inno Setup 6\ISCC.exe" installer\echobook.iss
```

Output: `installer\output\EchoBook-Setup-<version>.exe`. Verified end-to-end in this build: silent install, launch, and clean uninstall (including Start Menu shortcuts) all confirmed working.

### Android

Requires Android Studio / the Android SDK (not installed in this environment, so this path is written but unverified here):

```bash
flutter build apk --release      # single APK
flutter build appbundle --release # for Play Store
```

Microphone permission (for voice cloning) and storage/media permissions are declared in `android/app/src/main/AndroidManifest.xml` — review them for your target SDK version before release.

### iOS

Requires macOS with Xcode (not available in this environment, so also unverified here):

```bash
flutter build ios --release
```

Then archive and export from Xcode as usual. `NSMicrophoneUsageDescription` is set in `ios/Runner/Info.plist` for voice cloning's recording permission — review/update the copy before shipping.

### Linux

```bash
sudo apt install espeak-ng   # or dnf/pacman equivalent — see "Linux TTS" above
flutter build linux --release
```

Output: `build/linux/x64/release/bundle/echobook` (copy the whole `bundle/` folder to distribute). `espeak-ng` is a runtime dependency, not bundled — Listen Mode, voice switching, and audio export all fall back to a clear in-app error message (instead of crashing) if it isn't installed.

## Deliverables checklist

- [x] Library: import (file picker + drag-and-drop on desktop), metadata/cover extraction, search/sort, delete, floating import button
- [x] Reader: scroll + paginated modes, font/theme/line-height/margin controls, TOC, bookmarks, auto-saved position, progress + time-left estimate
- [x] Listen Mode: sentence-level playback and highlighting, ±1 sentence skip, 0.5x-3.0x speed, sleep timer, mini player, persistent across tabs
- [x] Voices: system + cloned profiles, per-profile speed/pitch, default voice, Beta cloning flow (record/upload → save profile)
- [x] Export: current/selected/whole-book/custom-range scope, voice + speed + format choice, size/time estimate, progress, share/open-folder
- [x] Automated tests passing (`flutter test`)
- [x] Windows build verified end-to-end (built, launched, and used to import/read/listen against real EPUBs)
- [ ] Android/iOS binaries — code is cross-platform-ready; not buildable in this environment (no Android SDK / no macOS+Xcode here). Build on a machine with the respective SDK using the commands above.
