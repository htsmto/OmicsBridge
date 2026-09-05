@echo off
cd /d "%~dp0"

echo ============================================
echo   OmicsBridge - Setup ^& Launch
echo ============================================
echo.

rem Locate Rscript.exe. On Windows, R is not added to PATH by default,
rem so search common install locations if it isn't found on PATH.
set "RSCRIPT_BIN="

where Rscript >nul 2>nul
if %errorlevel%==0 set "RSCRIPT_BIN=Rscript"

if not defined RSCRIPT_BIN call :FindRscript

if not defined RSCRIPT_BIN (
    echo [!] Could not find R ^(Rscript^) on this computer.
    echo     Please install R first from https://cran.r-project.org/bin/windows/base/
    echo     then double-click this file again.
    echo.
    pause
    exit /b 1
)

echo Using R at: %RSCRIPT_BIN%
echo.

rem A marker file records that setup has completed, so re-launching the app
rem later doesn't reinstall everything from scratch every time.
set "SETUP_MARKER=.omicsbridge_packages_installed"

if not exist "%SETUP_MARKER%" (
    echo ------------------------------------------------------------
    echo   Step 1/2: Installing required R packages
    echo   ^(first run only - this can take around 10 minutes^)
    echo ------------------------------------------------------------
    echo.

    "%RSCRIPT_BIN%" install_packages.R
    if errorlevel 1 (
        echo.
        echo [!] install_packages.R exited with an error.
        echo     Review the messages above. You can re-run this file to retry.
        echo.
        pause
        exit /b 1
    )

    date /t > "%SETUP_MARKER%"
    echo.
    echo [OK] Package installation complete.
) else (
    echo [i] Packages already installed ^(found %SETUP_MARKER%^).
    echo     Delete this file if you want to re-run install_packages.R.
)

echo.
echo ------------------------------------------------------------
echo   Step 2/2: Launching OmicsBridge
echo ------------------------------------------------------------
echo.
echo Please wait. When you see a line like:
echo   Listening on http://127.0.0.1:4191
echo open this address in your web browser:
echo   http://localhost:4191
echo.
echo To stop OmicsBridge later, just close this window (or press Ctrl+C).
echo.

"%RSCRIPT_BIN%" -e "shiny::runApp('app.R', launch.browser = TRUE, port = 4191)"

echo.
echo OmicsBridge has stopped. You can close this window.
pause
goto :eof

:FindRscript
for /f "delims=" %%D in ('dir /b /ad /o-n "C:\Program Files\R\R-*" 2^>nul') do (
    if not defined RSCRIPT_BIN if exist "C:\Program Files\R\%%D\bin\Rscript.exe" set "RSCRIPT_BIN=C:\Program Files\R\%%D\bin\Rscript.exe"
)
exit /b
