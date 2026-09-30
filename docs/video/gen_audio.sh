#!/usr/bin/env bash
# Generates one narration WAV per scene from scenes.json.
# Fully offline TTS - no cloud service is used.
#
# Usage: ./gen_audio.sh [kokoro|festival-hts|espeak] [kokoro-voice] [speed]
#   kokoro (default) - neural voice, far less robotic. Needs
#     `pip install kokoro-onnx soundfile`; downloads ~350 MB of model
#     files once into .models/. Voices: af_heart (default), af_nicole,
#     bf_emma, am_michael, bm_george, ...
#   festival-hts / espeak - older, clearly synthetic fallbacks.
set -euo pipefail

ENGINE="${1:-kokoro}"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUDIO_DIR="$DIR/audio"
mkdir -p "$AUDIO_DIR"

if [ "$ENGINE" = "kokoro" ]; then
  python3 "$DIR/kokoro_tts.py" "$DIR/scenes.json" "$AUDIO_DIR" "${2:-af_heart}" "${3:-1.0}"
  exit 0
fi

python3 - "$DIR/scenes.json" "$AUDIO_DIR" "$ENGINE" <<'PYEOF'
import json, subprocess, sys, os

scenes_path, audio_dir, engine = sys.argv[1], sys.argv[2], sys.argv[3]
scenes = json.load(open(scenes_path))

def gen_espeak(text, out_wav):
    subprocess.run(
        ["espeak-ng", "-v", "en-us", "-s", "158", "-p", "42", "-g", "6", "-w", out_wav, text],
        check=True,
    )

def scheme_escape(text):
    return text.replace("\\", "\\\\").replace('"', '\\"')

def gen_festival_hts(text, out_wav):
    script = (
        '(voice_cmu_us_slt_arctic_hts)\n'
        f'(utt.save.wave (SayText "{scheme_escape(text)}") "{out_wav}")\n'
    )
    subprocess.run(
        ["festival", "--pipe"],
        input=script, text=True, check=True,
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )

generator = gen_festival_hts if engine == "festival-hts" else gen_espeak

for scene in scenes:
    out_wav = os.path.join(audio_dir, f"{scene['id']}.wav")
    generator(scene["narration"], out_wav)
    print("generated", out_wav, f"[{engine}]")
PYEOF
