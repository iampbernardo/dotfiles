import struct, zlib, math

W, H = 3840, 2160

def hx(h):
    h = h.lstrip('#')
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))

bg_top = hx("1a1b26")
bg_bot = hx("16161e")
glow = hx("2b2f52")   # blue/purple glow
glow2 = hx("2a2140")  # subtle magenta undertone

cx, cy = W * 0.78, H * 0.22
max_r = math.hypot(W, H) * 0.55

def lerp(a, b, t):
    return a + (b - a) * t

def pixel(x, y):
    t = y / H
    r = lerp(bg_top[0], bg_bot[0], t)
    g = lerp(bg_top[1], bg_bot[1], t)
    b = lerp(bg_top[2], bg_bot[2], t)

    d = math.hypot(x - cx, y - cy) / max_r
    glow_t = max(0.0, 1.0 - d)
    glow_t = glow_t ** 2.2 * 0.55

    r = lerp(r, glow[0], glow_t)
    g = lerp(g, glow[1], glow_t)
    b = lerp(b, glow[2], glow_t)

    cx2, cy2 = W * 0.12, H * 0.92
    d2 = math.hypot(x - cx2, y - cy2) / (max_r * 0.9)
    glow2_t = max(0.0, 1.0 - d2)
    glow2_t = glow2_t ** 2.5 * 0.35
    r = lerp(r, glow2[0], glow2_t)
    g = lerp(g, glow2[1], glow2_t)
    b = lerp(b, glow2[2], glow2_t)

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

import os
out_path = os.path.expanduser("~/Pictures/tokyo-night-wallpaper.png")
with open(out_path, "wb") as f:
    f.write(sig)
    f.write(chunk(b"IHDR", ihdr))
    f.write(chunk(b"IDAT", compressed))
    f.write(chunk(b"IEND", b""))

print(f"wallpaper written to {out_path}")
