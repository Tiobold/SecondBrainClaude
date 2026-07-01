#!/usr/bin/env bash
# Screenshots each slides/sceneNN.html into slides/sceneNN.png at 1920x1080.
# Headless Chromium's --window-size includes ~87px of chrome overhead even
# in headless=new mode, so we render taller and crop to the target size.
set -euo pipefail

CHROME="/opt/pw-browsers/chromium-1194/chrome-linux/chrome"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SLIDES_DIR="$DIR/slides"

for f in "$SLIDES_DIR"/scene*.html; do
  name="$(basename "$f" .html)"
  raw="$SLIDES_DIR/${name}.raw.png"
  out="$SLIDES_DIR/${name}.png"

  "$CHROME" --headless=new --disable-gpu --no-sandbox --hide-scrollbars \
    --force-device-scale-factor=1 --window-size=1920,1167 \
    --screenshot="$raw" "file://$f" >/dev/null 2>&1

  python3 -c "
from PIL import Image
Image.open('$raw').crop((0, 0, 1920, 1080)).save('$out')
"
  rm -f "$raw"
  echo "rendered $out"
done
