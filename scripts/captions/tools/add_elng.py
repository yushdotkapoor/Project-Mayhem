#!/usr/bin/env python3
"""Insert an 'elng' (extended language tag) box into each subtitle track's mdia box.
usage: add_elng.py in.mp4 out.mp4 tag1,tag2,...   (one BCP-47 tag per subtitle track, in file order)
Requires moov to come after mdat (no faststart) so chunk offsets stay valid."""
import struct, sys

def boxes(buf, start, end):
    pos = start
    while pos + 8 <= end:
        size, typ = struct.unpack(">I4s", buf[pos:pos+8]); hdr = 8
        if size == 1:
            size = struct.unpack(">Q", buf[pos+8:pos+16])[0]; hdr = 16
        elif size == 0:
            size = end - pos
        yield pos, size, typ.decode("latin1"), hdr
        pos += size

def patch_mdia(buf, mstart, msize, mhdr, tag):
    body = buf[mstart:mstart+msize]
    # find mdhd inside mdia and insert elng right after it
    for pos, size, typ, hdr in boxes(buf, mstart+mhdr, mstart+msize):
        if typ == "mdhd":
            elng_payload = b"\x00\x00\x00\x00" + tag.encode("utf-8") + b"\x00"
            elng = struct.pack(">I4s", 8 + len(elng_payload), b"elng") + elng_payload
            insert_at = pos + size
            return buf[:insert_at] + elng + buf[insert_at:], len(elng), insert_at
    raise SystemExit("mdhd not found")

def handler(buf, mstart, msize, mhdr):
    for pos, size, typ, hdr in boxes(buf, mstart+mhdr, mstart+msize):
        if typ == "hdlr":
            return buf[pos+hdr+8:pos+hdr+12].decode("latin1")
    return "?"

def bump_size(buf, pos, delta):
    size = struct.unpack(">I", buf[pos:pos+4])[0]
    assert size != 1, "64-bit box sizes not handled"
    return buf[:pos] + struct.pack(">I", size + delta) + buf[pos+4:]

src, dst, tags = sys.argv[1], sys.argv[2], sys.argv[3].split(",")
buf = bytearray(open(src, "rb").read())
top = list(boxes(buf, 0, len(buf)))
moov = next(b for b in top if b[2] == "moov"); mdat = next(b for b in top if b[2] == "mdat")
assert moov[0] > mdat[0], "moov must follow mdat (mux without faststart)"

# Walk traks, patch subtitle tracks. Work back-to-front so earlier offsets stay valid.
traks = [b for b in boxes(buf, moov[0]+moov[3], moov[0]+moov[1]) if b[2] == "trak"]
sub_traks = []
for tpos, tsize, _, thdr in traks:
    for mpos, msize, mtyp, mhdr in boxes(buf, tpos+thdr, tpos+tsize):
        if mtyp == "mdia":
            h = handler(buf, mpos, msize, mhdr)
            if h in ("sbtl", "text", "subt"):
                sub_traks.append((tpos, tsize, thdr, mpos, msize, mhdr))
assert len(sub_traks) == len(tags), f"{len(sub_traks)} subtitle tracks but {len(tags)} tags"
total = 0
for (tpos, tsize, thdr, mpos, msize, mhdr), tag in reversed(list(zip(sub_traks, tags))):
    buf, delta, _ = patch_mdia(buf, mpos, msize, mhdr, tag)
    buf = bump_size(buf, mpos, delta); buf = bump_size(buf, tpos, delta); total += delta
buf = bump_size(buf, moov[0], total)
open(dst, "wb").write(buf)
print(f"patched {len(tags)} subtitle track(s): {tags}")
