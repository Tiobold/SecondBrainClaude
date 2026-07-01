#!/usr/bin/env bash
# Full pipeline: HTML slides -> PNG screenshots -> TTS narration -> final MP4.
#
# Usage: ./build.sh [--skip-audio]
#   --skip-audio   Reuse whatever's already in audio/ instead of regenerating
#                   it (e.g. after running voice-clone/clone_voice.py).
set -euo pipefail

SKIP_AUDIO=0
for arg in "$@"; do
  case "$arg" in
    --skip-audio) SKIP_AUDIO=1 ;;
    *) echo "Unknown argument: $arg" >&2; exit 1 ;;
  esac
done

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SLIDES_DIR="$DIR/slides"
AUDIO_DIR="$DIR/audio"
SEGMENTS_DIR="$DIR/.segments"
OUT="$DIR/obsidian-second-brain.mp4"
PAD_SECONDS=0.6

node "$DIR/render_slides.js"
"$DIR/render_pngs.sh"
if [ "$SKIP_AUDIO" -eq 1 ]; then
  echo "Skipping audio generation, reusing existing files in $AUDIO_DIR"
else
  "$DIR/gen_audio.sh"
fi

rm -rf "$SEGMENTS_DIR"
mkdir -p "$SEGMENTS_DIR"

concat_list="$SEGMENTS_DIR/concat.txt"
: > "$concat_list"

for wav in "$AUDIO_DIR"/scene*.wav; do
  id="$(basename "$wav" .wav)"
  png="$SLIDES_DIR/${id}.png"
  seg="$SEGMENTS_DIR/${id}.mp4"

  dur="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$wav")"
  total="$(python3 -c "print(float('$dur') + $PAD_SECONDS)")"

  ffmpeg -y -loop 1 -i "$png" -i "$wav" \
    -filter_complex "[1:a]apad=pad_dur=${PAD_SECONDS}[a]" \
    -map 0:v -map "[a]" \
    -t "$total" -r 30 -pix_fmt yuv420p -c:v libx264 -c:a aac -shortest \
    "$seg" -loglevel error

  echo "file '$seg'" >> "$concat_list"
  echo "built segment $id ($total s)"
done

ffmpeg -y -f concat -safe 0 -i "$concat_list" -c copy "$OUT" -loglevel error

echo ""
echo "Final video: $OUT"
ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT"
