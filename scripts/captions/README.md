# Video captions

Caption tracks for the CloudKit "Videos" assets. Chap1Intro has no dialogue and ships without captions.

- `source/en.json` — English cues with start/end seconds. This is the timing master.
- `translations/<lang>.json` — one line per cue, same order and count as `source/en.json`.
- `tools/build_captions.py` — muxes every language into each mp4 and verifies that each app
  language code (the `localeArr` list in `globalFunctions.swift`) resolves to a caption track.

Build:

    python3 scripts/captions/tools/build_captions.py <dir with plain mp4s> <output dir>

Requires ffmpeg (Homebrew) and Xcode's `swift` on the PATH. Then upload the output files to the
CloudKit Dashboard, replacing the `video` asset on each Videos record in Production.
