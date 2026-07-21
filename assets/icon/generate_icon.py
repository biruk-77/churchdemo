"""
Generates app_icon.png and app_icon_foreground.png using only Pillow.
No Cairo / libcairo needed.

Run:
    python assets/icon/generate_icon.py
Then:
    dart run flutter_launcher_icons
"""

import os
import math
from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
BLUE_BG   = (26,  35, 126)   # #1A237E  Orthodox blue
BLUE_DARK = (13,  18,  87)   # #0D1257
GOLD      = (201, 162, 39)   # #C9A227
GOLD_LITE = (232, 200, 74)   # #E8C84A
WHITE     = (255, 255, 255)

def round_rect(draw, xy, radius, fill):
    x0, y0, x1, y1 = xy
    draw.rectangle([x0+radius, y0, x1-radius, y1], fill=fill)
    draw.rectangle([x0, y0+radius, x1, y1-radius], fill=fill)
    draw.ellipse([x0, y0, x0+2*radius, y0+2*radius], fill=fill)
    draw.ellipse([x1-2*radius, y0, x1, y0+2*radius], fill=fill)
    draw.ellipse([x0, y1-2*radius, x0+2*radius, y1], fill=fill)
    draw.ellipse([x1-2*radius, y1-2*radius, x1, y1], fill=fill)

def diamond(draw, cx, cy, w, h, fill):
    draw.polygon([(cx, cy-h), (cx+w, cy), (cx, cy+h), (cx-w, cy)], fill=fill)

def draw_icon(transparent_bg=False):
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # ── Background ────────────────────────────────────────────────────────
    if not transparent_bg:
        round_rect(draw, [0, 0, SIZE, SIZE], 200, BLUE_DARK)
        # Gradient overlay illusion: draw concentric lighter rounds
        for i in range(30):
            alpha = int(40 * (1 - i/30))
            r = 200 - i*4
            draw.ellipse([SIZE//2 - r*2, SIZE//3 - r*2,
                          SIZE//2 + r*2, SIZE//3 + r*2],
                         fill=(*BLUE_BG, alpha))

    # ── Cross bars ────────────────────────────────────────────────────────
    bar_w = 84
    cx, cy = SIZE//2, SIZE//2 - 30  # slightly above centre

    # Vertical
    draw.rounded_rectangle([cx - bar_w//2, 155, cx + bar_w//2, 869],
                            radius=18, fill=GOLD)
    # Horizontal
    draw.rounded_rectangle([155, cy - bar_w//2, 869, cy + bar_w//2],
                            radius=18, fill=GOLD)

    # ── Arm terminal diamonds (Ethiopian cross style) ─────────────────────
    d_w, d_h = 52, 76
    diamond(draw, cx, 118, d_w, d_h, GOLD_LITE)    # top
    diamond(draw, cx, 906, d_w, d_h, GOLD_LITE)    # bottom
    diamond(draw, 118, cy, d_h, d_w, GOLD_LITE)    # left
    diamond(draw, 906, cy, d_h, d_w, GOLD_LITE)    # right

    # ── Halo rings ────────────────────────────────────────────────────────
    halo_c = (cx, cy)
    for r, w, a in [(118, 16, 220), (88, 10, 140)]:
        ring = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        rd = ImageDraw.Draw(ring)
        rd.ellipse([cx-r, cy-r, cx+r, cy+r], outline=(*GOLD_LITE, a), width=w)
        img = Image.alpha_composite(img, ring)

    draw = ImageDraw.Draw(img)

    # ── Centre dot ────────────────────────────────────────────────────────
    draw.ellipse([cx-26, cy-26, cx+26, cy+26], fill=GOLD_LITE)

    # ── Small decorative cross notches on each arm ────────────────────────
    notch_color = (*BLUE_DARK, 180)
    notch_w = 6
    for ny in [265, 282]:
        draw.rectangle([cx-32, ny, cx+32, ny+notch_w], fill=notch_color)
    for ny in [734, 751]:
        draw.rectangle([cx-32, ny, cx+32, ny+notch_w], fill=notch_color)
    for nx in [265, 282]:
        draw.rectangle([nx, cy-32, nx+notch_w, cy+32], fill=notch_color)
    for nx in [734, 751]:
        draw.rectangle([nx, cy-32, nx+notch_w, cy+32], fill=notch_color)

    # ── Subtle glow on cross (blur a gold layer underneath) ───────────────
    glow_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow_layer)
    gd.rounded_rectangle([cx - bar_w//2 - 8, 148, cx + bar_w//2 + 8, 876],
                          radius=22, fill=(*GOLD, 80))
    gd.rounded_rectangle([148, cy - bar_w//2 - 8, 876, cy + bar_w//2 + 8],
                          radius=22, fill=(*GOLD, 80))
    glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(14))
    img = Image.alpha_composite(img, glow_layer)

    # ── EOTC label ────────────────────────────────────────────────────────
    draw = ImageDraw.Draw(img)
    label_y = 838
    draw.rounded_rectangle([180, label_y, 844, label_y + 80],
                            radius=14, fill=(*GOLD, 38))
    # Letter-spaced EOTC text using individual chars
    letters = "E O T C"
    char_x = cx - 68
    try:
        from PIL import ImageFont
        font = ImageFont.truetype("arial.ttf", 48)
    except Exception:
        font = ImageFont.load_default(size=44)
    draw.text((cx, label_y + 40), letters, font=font,
              fill=(*GOLD_LITE, 210), anchor="mm")

    return img

# ── Full icon ──────────────────────────────────────────────────────────────
script_dir = os.path.dirname(os.path.abspath(__file__))

icon = draw_icon(transparent_bg=False)
png_path = os.path.join(script_dir, "app_icon.png")
icon.save(png_path, "PNG")
print(f"OK  {png_path}")

# ── Adaptive foreground (transparent bg, centred in 1024px canvas) ────────
fg_raw = draw_icon(transparent_bg=True).resize((768, 768), Image.LANCZOS)
canvas = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
canvas.paste(fg_raw, (128, 128), fg_raw)
fg_path = os.path.join(script_dir, "app_icon_foreground.png")
canvas.save(fg_path, "PNG")
print(f"OK  {fg_path}")

print("\nDone! Now run:")
print("    flutter pub get")
print("    dart run flutter_launcher_icons")
