#!/bin/bash
cd "$(dirname "$0")"

echo "============================================"
echo "  OmicsBridge - Setup & Launch"
echo "============================================"
echo ""

# Locate Rscript. On macOS, R installed from the CRAN .pkg is usually on
# PATH already; if not, fall back to the standard framework location.
RSCRIPT_BIN="Rscript"
if ! command -v Rscript >/dev/null 2>&1; then
  if [ -x "/usr/local/bin/Rscript" ]; then
    RSCRIPT_BIN="/usr/local/bin/Rscript"
  elif [ -x "/Library/Frameworks/R.framework/Resources/bin/Rscript" ]; then
    RSCRIPT_BIN="/Library/Frameworks/R.framework/Resources/bin/Rscript"
  else
    echo "[!] Could not find R (Rscript) on this Mac."
    echo "    Please install R first from https://cran.r-project.org/bin/macosx/"
    echo "    then double-click this file again."
    echo ""
    read -n 1 -s -r -p "Press any key to close..."
    exit 1
  fi
fi

echo "Using R at: $($RSCRIPT_BIN -e 'cat(R.home())' --vanilla 2>/dev/null)"
echo ""

# A marker file records that setup has completed, so re-launching the app
# later doesn't reinstall everything from scratch every time.
SETUP_MARKER=".omicsbridge_packages_installed"

if [ ! -f "$SETUP_MARKER" ]; then
  echo "------------------------------------------------------------"
  echo "  Step 1/2: Installing required R packages"
  echo "  (first run only - this can take around 10 minutes)"
  echo "------------------------------------------------------------"
  echo ""

  "$RSCRIPT_BIN" install_packages.R
  INSTALL_STATUS=$?

  if [ $INSTALL_STATUS -ne 0 ]; then
    echo ""
    echo "[!] install_packages.R exited with an error (status $INSTALL_STATUS)."
    echo "    Review the messages above. You can re-run this file to retry."
    echo ""
    read -n 1 -s -r -p "Press any key to close..."
    exit 1
  fi

  date > "$SETUP_MARKER"
  echo ""
  echo "[OK] Package installation complete."
else
  echo "[i] Packages already installed (found $SETUP_MARKER)."
  echo "    Delete this file if you want to re-run install_packages.R."
fi

echo ""
echo "------------------------------------------------------------"
echo "  Step 2/2: Launching OmicsBridge"
echo "------------------------------------------------------------"
echo ""
echo "Please wait. When you see a line like:"
echo "  Listening on http://127.0.0.1:4191"
echo "open this address in your web browser:"
echo "  http://localhost:4191"
echo ""
echo "To stop OmicsBridge later, just close this window (or press Ctrl+C)."
echo ""

"$RSCRIPT_BIN" -e "shiny::runApp('app.R', launch.browser = TRUE, port = 4191)"

echo ""
echo "OmicsBridge has stopped. You can close this window."
read -n 1 -s -r -p "Press any key to close..."
