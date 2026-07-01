#!/usr/bin/env python3
"""Generate per-scene narration WAVs cloned to a reference voice, using
Coqui XTTS-v2. Run locally (see README.md in this folder) - not intended
for network-sandboxed environments, since the model downloads from
Hugging Face on first use.
"""

import argparse
import json
import os


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--reference", required=True, help="Path to a reference voice clip (wav/mp3), 15-30s of clean single-speaker audio.")
    parser.add_argument("--out-dir", required=True, help="Directory to write sceneNN.wav narration files into.")
    parser.add_argument("--language", default="en")
    parser.add_argument("--scenes", default=os.path.join(os.path.dirname(__file__), "..", "scenes.json"))
    parser.add_argument("--device", default=None, help="cuda, mps, or cpu (auto-detected if omitted)")
    args = parser.parse_args()

    from TTS.api import TTS
    import torch

    device = args.device or ("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Loading XTTS-v2 on {device} (first run downloads the model, ~1.8GB)...")
    tts = TTS("tts_models/multilingual/multi-dataset/xtts_v2").to(device)

    scenes = json.load(open(args.scenes))
    os.makedirs(args.out_dir, exist_ok=True)

    for scene in scenes:
        out_wav = os.path.join(args.out_dir, f"{scene['id']}.wav")
        tts.tts_to_file(
            text=scene["narration"],
            speaker_wav=args.reference,
            language=args.language,
            file_path=out_wav,
        )
        print("generated", out_wav)


if __name__ == "__main__":
    main()
