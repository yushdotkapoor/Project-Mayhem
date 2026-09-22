#!/usr/bin/env python3
"""Manual caption timing edits.
  timings.py export            -> writes source/en.srt (edit start/end there, in any text or subtitle editor)
  timings.py import            -> reads source/en.srt back into source/en.json (cue count must match)
  timings.py shift VIDEO SECS  -> moves every cue of VIDEO by SECS (negative = earlier)
Then rebuild with tools/build_captions.py."""
import json, pathlib, re, sys
ROOT = pathlib.Path(__file__).resolve().parent.parent
SRC, SRT = ROOT / "source" / "en.json", ROOT / "source" / "en.srt"
en = json.load(open(SRC))
def ts(t):
    h, m, s = int(t // 3600), int(t % 3600 // 60), t % 60
    return f"{h:02d}:{m:02d}:{s:06.3f}".replace(".", ",")
def sec(t):
    h, m, s = t.strip().split(":"); return int(h) * 3600 + int(m) * 60 + float(s.replace(",", "."))
cmd = sys.argv[1] if len(sys.argv) > 1 else ""
if cmd == "export":
    with open(SRT, "w", encoding="utf-8") as f:
        n = 0
        for video, cues in en.items():
            f.write(f"# ===== {video} =====\n\n")
            for s, e, text in cues:
                n += 1; f.write(f"{n}\n{ts(s)} --> {ts(e)}\n{text}\n\n")
    print(f"wrote {SRT} ({n} cues). Lines starting with # mark each video.")
elif cmd == "import":
    text = open(SRT, encoding="utf-8").read()
    blocks = re.findall(r"(?:^|\n)(?:# ===== (\w+) =====|\d+\n([\d:,]+) --> ([\d:,]+)\n([^\n]*))", text)
    parsed, video = {}, None
    for name, s, e, line in blocks:
        if name: video = name; parsed[video] = []; continue
        parsed[video].append([round(sec(s), 3), round(sec(e), 3), line])
    for video, cues in parsed.items():
        if len(cues) != len(en[video]):
            print(f"NOTE: {video} now has {len(cues)} cues (was {len(en[video])}); translations must be updated to match")
        en[video] = cues
    json.dump(en, open(SRC, "w"), ensure_ascii=False, indent=0); print("timings imported into", SRC)
elif cmd == "shift" and len(sys.argv) == 4:
    video, d = sys.argv[2], float(sys.argv[3])
    for cue in en[video]: cue[0], cue[1] = round(max(0, cue[0] + d), 3), round(max(0, cue[1] + d), 3)
    json.dump(en, open(SRC, "w"), ensure_ascii=False, indent=0); print(f"shifted {video} by {d:+.2f}s")
else:
    print(__doc__)
