#!/usr/bin/env bash
# One-shot setup for rebuilding docs/video/obsidian-second-brain.mp4.
# Creates ./.venv, installs requirements.txt into it, and checks for the
# system tools pip can't provide (node, ffmpeg, Chrome/Chromium), installing
# them with Homebrew or apt where it can.
#
# Usage: ./scripts/install-video-deps.sh      (run from anywhere)
# Then:  docs/video/build.sh                  (auto-uses ./.venv)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

command -v python3 >/dev/null || { echo "python3 is required (3.9+)" >&2; exit 1; }
python3 -m venv "$ROOT/.venv"
"$ROOT/.venv/bin/pip" install -q --upgrade pip
"$ROOT/.venv/bin/pip" install -q -r "$ROOT/requirements.txt"
echo "Python deps installed into $ROOT/.venv"

pkg_install() { # $1 = brew formula/cask flag+name, $2 = apt package
  if command -v brew >/dev/null; then brew install $1
  elif command -v apt-get >/dev/null; then sudo apt-get install -y "$2"
  else return 1; fi
}

command -v node   >/dev/null || pkg_install node nodejs     || echo "MISSING: install Node.js from https://nodejs.org" >&2
command -v ffmpeg >/dev/null || pkg_install ffmpeg ffmpeg   || echo "MISSING: install ffmpeg from https://ffmpeg.org" >&2

if ! "$ROOT/docs/video/find_chrome.sh" >/dev/null 2>&1; then
  pkg_install "--cask chromium" chromium-browser \
    || echo "MISSING: install Google Chrome or Chromium, or set CHROME=/path/to/binary" >&2
fi

echo
echo "Done. Build the video with: docs/video/build.sh"
echo "(First build also downloads ~350 MB of voice model into docs/video/.models/.)"
