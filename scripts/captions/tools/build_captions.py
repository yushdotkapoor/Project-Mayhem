#!/usr/bin/env python3
"""Mux every language's captions into the compressed videos.
usage: build_captions.py <input_dir_with_mp4s> <output_dir>"""
import json, pathlib, subprocess, sys, shutil
ROOT = pathlib.Path(__file__).resolve().parent.parent
IN, OUT = pathlib.Path(sys.argv[1]).expanduser(), pathlib.Path(sys.argv[2]).expanduser()
SRT, TMP = ROOT / "build" / "srt", ROOT / "build" / "tmp"
for d in (SRT, TMP, OUT): d.mkdir(parents=True, exist_ok=True)

# Same order as localeArr in globalFunctions.swift, English first so it is the first option.
LANGS = ["en","ar","ca","zh-Hans","zh-Hant","hr","cs","da","nl","fi","fr","de","el","he","hi","hu",
         "id","it","ja","ko","ms","nb","pl","pt","ro","ru","sk","es","sv","th","tr","uk","vi"]
ISO3 = {"en":"eng","ar":"ara","ca":"cat","zh-Hans":"zho","zh-Hant":"zho","hr":"hrv","cs":"ces","da":"dan",
        "nl":"nld","fi":"fin","fr":"fra","de":"deu","el":"ell","he":"heb","hi":"hin","hu":"hun","id":"ind",
        "it":"ita","ja":"jpn","ko":"kor","ms":"msa","nb":"nob","pl":"pol","pt":"por","ro":"ron","ru":"rus",
        "sk":"slk","es":"spa","sv":"swe","th":"tha","tr":"tur","uk":"ukr","vi":"vie"}

def ts(t):
    h, m, s = int(t // 3600), int(t % 3600 // 60), t % 60
    return f"{h:02d}:{m:02d}:{s:06.3f}".replace(".", ",")

source = json.load(open(ROOT / "source" / "en.json"))
translations = {l: json.load(open(ROOT / "translations" / f"{l}.json")) for l in LANGS if l != "en"}

failures = []
for video, cues in source.items():
    srt_paths = []
    for lang in LANGS:
        texts = [c[2] for c in cues] if lang == "en" else translations[lang][video]
        assert len(texts) == len(cues), f"{lang}/{video}: {len(texts)} lines, expected {len(cues)}"
        p = SRT / f"{video}.{lang}.srt"
        with open(p, "w", encoding="utf-8") as f:
            for i, ((start, end, _), text) in enumerate(zip(cues, texts), 1):
                f.write(f"{i}\n{ts(start)} --> {ts(end)}\n{text}\n\n")
        srt_paths.append(p)

    cmd = ["ffmpeg", "-v", "error", "-y", "-i", str(IN / f"{video}.mp4")]
    for p in srt_paths: cmd += ["-i", str(p)]
    cmd += ["-map", "0:v", "-map", "0:a"]
    for i in range(len(srt_paths)): cmd += ["-map", str(i + 1)]
    cmd += ["-c:v", "copy", "-c:a", "copy", "-c:s", "mov_text"]
    for i, lang in enumerate(LANGS): cmd += [f"-metadata:s:s:{i}", f"language={ISO3[lang]}"]
    tmp = TMP / f"{video}.mp4"
    cmd.append(str(tmp))
    subprocess.run(cmd, check=True)
    subprocess.run([sys.executable, str(ROOT / "tools" / "add_elng.py"), str(tmp), str(OUT / f"{video}.mp4"), ",".join(LANGS)], check=True)
    r = subprocess.run(["swift", str(ROOT / "tools" / "verify.swift"), str(OUT / f"{video}.mp4"), ",".join(LANGS)], capture_output=True, text=True)
    status = [l for l in r.stdout.splitlines() if l.startswith(("OK", "FAIL", "  MISMATCH"))]
    print(f"{video}: {' | '.join(status)}")
    if r.returncode != 0: failures.append(video)

# No dialogue in the intro, so it ships without caption tracks.
shutil.copy2(IN / "Chap1Intro.mp4", OUT / "Chap1Intro.mp4")
print("Chap1Intro: copied (no dialogue)")
sys.exit(1 if failures else 0)
