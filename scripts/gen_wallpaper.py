import struct, zlib, math, os

W, H = 3840, 2160

def hx(h):
    h = h.lstrip('#')
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))

# Noticeably colored dark navy/purple base — not near-black
bg_tl = hx("2a2b4a")
bg_br = hx("1f2335")

blue = hx("7aa2f7")
purple = hx("bb9af7")

cx1, cy1 = W * 0.82, H * 0.15    # blue glow, top-right
cx2, cy2 = W * 0.10, H * 0.95    # purple glow, bottom-left
max_r = math.hypot(W, H) * 0.75

def lerp(a, b, t):
    return a + (b - a) * t

def pixel(x, y):
    t = (x / W + y / H) / 2
    r = lerp(bg_tl[0], bg_br[0], t)
    g = lerp(bg_tl[1], bg_br[1], t)
    b = lerp(bg_tl[2], bg_br[2], t)

    d1 = math.hypot(x - cx1, y - cy1) / max_r
    g1 = max(0.0, 1.0 - d1) ** 1.6 * 0.5
    r = lerp(r, blue[0], g1)
    g = lerp(g, blue[1], g1)
    b = lerp(b, blue[2], g1)

    d2 = math.hypot(x - cx2, y - cy2) / max_r
    g2 = max(0.0, 1.0 - d2) ** 1.6 * 0.4
    r = lerp(r, purple[0], g2)
    g = lerp(g, purple[1], g2)
    b = lerp(b, purple[2], g2)

    return int(r), int(g), int(b)

rows = []
for y in range(H):
    row = bytearray()
    row.append(0)  # filter type 0
    for x in range(0, W, 4):
        r, g, b = pixel(x, y)
        for _ in range(min(4, W - x)):
            row += bytes((r, g, b))
    rows.append(bytes(row))

raw = b"".join(rows)
compressed = zlib.compress(raw, 6)

def chunk(tag, data):
    return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data))

sig = b"\x89PNG\r\n\x1a\n"
ihdr = struct.pack(">IIBBBBB", W, H, 8, 2, 0, 0, 0)

out_path = os.path.expanduser("~/Pictures/tokyo-night-wallpaper.png")
with open(out_path, "wb") as f:
    f.write(sig)
    f.write(chunk(b"IHDR", ihdr))
    f.write(chunk(b"IDAT", compressed))
    f.write(chunk(b"IEND", b""))

print(f"wallpaper written to {out_path}")
