@echo off
setlocal enabledelayedexpansion
REM EchoBook Windows packaging: builds the AI Server (EchoBookAIServer.exe),
REM builds the Flutter app, bundles them together, then builds an installer
REM (Inno Setup) plus a portable .zip fallback.
REM
REM Run from the repo root on Windows: package_windows.bat
REM Requires: Flutter SDK, Python 3.10-3.12, and (optionally, for the
REM installer) Inno Setup - https://jrsoftware.org/isdl.php

set ROOT=%~dp0
set AI_SERVER_DIR=%ROOT%ai_server
set RELEASE_DIR=%ROOT%build\windows\x64\runner\Release
set DIST_DIR=%ROOT%dist

echo.
echo === 1/5: Setting up the AI Server's Python environment ===
pushd "%AI_SERVER_DIR%"
if not exist .venv (
    python -m venv .venv || goto :error
)
call .venv\Scripts\activate.bat
pip install -q -r requirements.txt || goto :error

echo.
echo === 2/5: Fetching Piper (binary + Vietnamese voice) if not already present ===
if not exist piper mkdir piper
if not exist piper\piper.exe (
    echo Downloading piper.exe...
    powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://github.com/rhasspy/piper/releases/latest/download/piper_windows_amd64.zip' -OutFile 'piper_dl.zip'" || goto :error
    powershell -NoProfile -Command "Expand-Archive -Path 'piper_dl.zip' -DestinationPath 'piper_dl' -Force" || goto :error
    xcopy /Y /E "piper_dl\piper\*" "piper\" >nul
    rmdir /S /Q piper_dl
    del piper_dl.zip
) else (
    echo piper.exe already present, skipping download.
)

if not exist models\piper mkdir models\piper
if not exist models\piper\vi_VN-vais1000-medium.onnx (
    echo Downloading the Vietnamese voice model ^(vi_VN-vais1000-medium^)...
    echo This is a one-time ~60MB download from huggingface.co.
    powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://huggingface.co/rhasspy/piper-voices/resolve/main/vi/vi_VN/vais1000/medium/vi_VN-vais1000-medium.onnx' -OutFile 'models\piper\vi_VN-vais1000-medium.onnx'"
    powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://huggingface.co/rhasspy/piper-voices/resolve/main/vi/vi_VN/vais1000/medium/vi_VN-vais1000-medium.onnx.json' -OutFile 'models\piper\vi_VN-vais1000-medium.onnx.json'"
    if not exist models\piper\vi_VN-vais1000-medium.onnx (
        echo WARNING: could not download the voice model automatically ^(offline, or huggingface.co unreachable^).
        echo          Piper reading will be unavailable until you place it manually - see ai_server\README.md.
    )
) else (
    echo Vietnamese voice model already present, skipping download.
)

echo.
echo === 3/5: Building EchoBookAIServer.exe ===
pyinstaller --noconfirm --onefile --name EchoBookAIServer main.py || goto :error
call .venv\Scripts\deactivate.bat
popd

echo.
echo === 4/5: Building the Flutter app ^(release^) ===
call flutter build windows --release || goto :error

echo Bundling the AI Server + Piper into the Flutter release folder...
copy /Y "%AI_SERVER_DIR%\dist\EchoBookAIServer.exe" "%RELEASE_DIR%\" >nul || goto :error
xcopy /Y /I /E "%AI_SERVER_DIR%\piper" "%RELEASE_DIR%\piper\" >nul || goto :error
xcopy /Y /I /E "%AI_SERVER_DIR%\models" "%RELEASE_DIR%\models\" >nul || goto :error

echo.
echo === 5/5: Packaging ===
if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"

where ISCC >nul 2>nul
if %errorlevel%==0 (
    ISCC "%ROOT%installer\echobook.iss" || goto :error
    echo Installer: installer\output\EchoBook-Setup-*.exe
) else (
    echo Inno Setup ^(ISCC^) not found on PATH - skipping the installer.
    echo Install it from https://jrsoftware.org/isdl.php, then re-run this
    echo script, or compile installer\echobook.iss manually.
)

echo Zipping the release folder as a portable fallback...
powershell -NoProfile -Command "Compress-Archive -Path '%RELEASE_DIR%\*' -DestinationPath '%DIST_DIR%\EchoBook_Windows.zip' -Force" || goto :error

echo.
echo Done.
echo   Portable zip: dist\EchoBook_Windows.zip
echo   Installer:    installer\output\EchoBook-Setup-*.exe ^(if Inno Setup ran^)
goto :eof

:error
echo.
echo Build FAILED - see the error above.
exit /b 1
