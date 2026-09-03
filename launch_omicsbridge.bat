@echo off
setlocal
cd /d "%~dp0"

echo ============================================
echo   Starting OmicsBridge
echo ============================================
echo.
echo Please wait. When you see a line like:
echo   Listening on http://0.0.0.0:4191
echo open this address in your web browser:
echo   http://localhost:4191
echo.
echo To stop OmicsBridge later, just close this window
echo (or press Ctrl+C).
echo.

docker run -it --rm -v "%cd%":/app -w /app -p 4191:4191 htsmto/omicsbridge Rscript -e "shiny::runApp('app.R', host='0.0.0.0', port=4191)"

echo.
echo OmicsBridge has stopped. You can close this window.
pause
