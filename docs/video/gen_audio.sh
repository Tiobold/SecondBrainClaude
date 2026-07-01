#!/usr/bin/env bash
# Generates one narration WAV per scene from scenes.json using espeak-ng
# (fully offline TTS - no cloud service is used).
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUDIO_DIR="$DIR/audio"
mkdir -p "$AUDIO_DIR"

python3 - "$DIR/scenes.json" "$AUDIO_DIR" <<'PYEOF'
import json, subprocess, sys, os

scenes_path, audio_dir = sys.argv[1], sys.argv[2]
scenes = json.load(open(scenes_path))

for scene in scenes:
    out_wav = os.path.join(audio_dir, f"{scene['id']}.wav")
    subprocess.run(
        [
            "espeak-ng", "-v", "en-us", "-s", "158", "-p", "42", "-g", "6",
            "-w", out_wav, scene["narration"],
        ],
        check=True,
    )
    print("generated", out_wav)
PYEOF
