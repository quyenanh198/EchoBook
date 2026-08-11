@echo off
setlocal
REM Builds the Android release APK and copies it to dist\EchoBook_Android.apk.
REM Run from the repo root: package_android.bat
REM Requires: Flutter SDK + Android SDK.

set ROOT=%~dp0
set DIST_DIR=%ROOT%dist
set APK_SRC=%ROOT%build\app\outputs\flutter-apk\app-release.apk

echo Building Android release APK...
call flutter build apk --release || goto :error

if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"
copy /Y "%APK_SRC%" "%DIST_DIR%\EchoBook_Android.apk" >nul || goto :error

echo.
echo Done: dist\EchoBook_Android.apk
goto :eof

:error
echo Build FAILED - see the error above.
exit /b 1
