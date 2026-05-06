"""Generate a 1024x500 Play Store feature graphic.

One-off script. Re-run if you tweak colors/layout. Output is a PNG that should
be uploaded to Play Console under Main store listing → Feature graphic.
"""

from PIL import Image, ImageDraw, ImageFont

W, H = 1024, 500
BG_TOP = (12, 22, 38)        # near-black blue
BG_BOTTOM = (28, 50, 84)      # slate blue
ACCENT = (255, 200, 60)       # amber, like the LCD on the device
TEXT = (240, 240, 240)
SUBTEXT = (180, 195, 215)

ICON_SRC = "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png"
OUT = "play_store_assets/feature_graphic_1024x500.png"

title_font = ImageFont.truetype("C:/Windows/Fonts/segoeuib.ttf", 80)
sub_font = ImageFont.truetype("C:/Windows/Fonts/segoeuib.ttf", 56)
regular = ImageFont.truetype("C:/Windows/Fonts/segoeui.ttf", 28)
small = ImageFont.truetype("C:/Windows/Fonts/segoeui.ttf", 22)

img = Image.new("RGB", (W, H), BG_TOP)
for y in range(H):
    t = y / (H - 1)
    r = int(BG_TOP[0] + (BG_BOTTOM[0] - BG_TOP[0]) * t)
    g = int(BG_TOP[1] + (BG_BOTTOM[1] - BG_TOP[1]) * t)
    b = int(BG_TOP[2] + (BG_BOTTOM[2] - BG_TOP[2]) * t)
    ImageDraw.Draw(img).line([(0, y), (W, y)], fill=(r, g, b))

icon = Image.open(ICON_SRC).convert("RGBA")
icon_size = 360
icon = icon.resize((icon_size, icon_size), Image.LANCZOS)

# Round the corners of the (white-background) icon so it reads as a card.
mask = Image.new("L", (icon_size, icon_size), 0)
ImageDraw.Draw(mask).rounded_rectangle((0, 0, icon_size, icon_size), radius=48, fill=255)
icon.putalpha(mask)

# Soft drop shadow.
shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
icon_x = 70
icon_y = (H - icon_size) // 2
ImageDraw.Draw(shadow).rounded_rectangle(
    (icon_x + 6, icon_y + 10, icon_x + icon_size + 6, icon_y + icon_size + 10),
    radius=48,
    fill=(0, 0, 0, 110),
)
from PIL import ImageFilter
shadow = shadow.filter(ImageFilter.GaussianBlur(radius=14))
img.paste(shadow, (0, 0), shadow)
img.paste(icon, (icon_x, icon_y), icon)

draw = ImageDraw.Draw(img)
text_x = icon_x + icon_size + 60
draw.text((text_x, 130), "Mini60", fill=TEXT, font=title_font)
draw.text((text_x, 230), "Antenna Analyzer", fill=ACCENT, font=sub_font)
draw.text((text_x, 320), "HF sweeps over Bluetooth", fill=SUBTEXT, font=regular)
draw.text((text_x, 360), "1 - 60 MHz   .   SWR / R / X / Z   .   offline", fill=SUBTEXT, font=small)

img.save(OUT, "PNG", optimize=True)
print(f"saved {OUT} {img.size}")
