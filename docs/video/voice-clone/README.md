# Optional: narrate the video in your own voice

The video's narration currently uses Festival's offline `cmu_us_slt_arctic_hts`
voice (see `../gen_audio.sh`). If you'd rather hear it in your own voice, this
folder has a script that uses [Coqui XTTS-v2](https://github.com/coqui-ai/TTS)
— a local voice-cloning model that needs only a short reference clip of you
speaking.

**This has to run on your own machine, not in a sandboxed CI/agent
environment** — XTTS-v2 downloads a ~1.8 GB model from Hugging Face on first
run, and many sandboxes (including the one this repo was originally built in)
block that host by policy. A normal laptop with internet access is fine.

## 1. Record a reference clip

- 15–30 seconds of clear, single-speaker audio (no music/background noise).
- Read anything naturally — it doesn't need to match the video script.
- Save it as `voice-clone/my-voice.wav` (or any path you'll pass to the script).
- `.gitignore` already excludes `voice-clone/*.wav` so your recording won't
  accidentally get committed.

## 2. Install dependencies

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r docs/video/voice-clone/requirements.txt
```

Requires Python 3.9–3.11. A GPU isn't required but makes this much faster.

## 3. Generate cloned narration

```bash
python docs/video/voice-clone/clone_voice.py \
  --reference docs/video/voice-clone/my-voice.wav \
  --out-dir docs/video/audio
```

This reads `docs/video/scenes.json` (the same narration script the offline
voices use) and writes `sceneNN.wav` files into `docs/video/audio/`,
cloned to your reference voice via XTTS-v2.

## 4. Rebuild the video with the cloned audio

```bash
docs/video/build.sh --skip-audio
```

`--skip-audio` tells the build to reuse whatever's already in `docs/video/audio/`
instead of regenerating it with Festival/espeak-ng.
