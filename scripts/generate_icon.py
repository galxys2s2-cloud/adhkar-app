from PIL import Image, ImageDraw, ImageFont
import os

NAVY = (13, 27, 42)
GOLD = (201, 168, 76)

size = 1024
img = Image.new('RGBA', (size, size), NAVY)
draw = ImageDraw.Draw(img)

# Rounded border
for i in range(3):
    draw.rounded_rectangle(
        [i, i, size-1-i, size-1-i],
        radius=180,
        outline=GOLD,
        width=2
    )

# Inner rounded rect
inner_margin = 60
draw.rounded_rectangle(
    [inner_margin, inner_margin, size-inner_margin, size-inner_margin],
    radius=140,
    outline=GOLD,
    width=3
)

# Decorative gold dots at corners
dot_positions = [(110, 110), (914, 110), (110, 914), (914, 914)]
for dx, dy in dot_positions:
    draw.ellipse([dx-6, dy-6, dx+6, dy+6], fill=GOLD)

# "أذكاري" in large Amiri Bold
font_path = "/root/adhkar-app/assets/fonts/Amiri-Bold.ttf"
font_main = ImageFont.truetype(font_path, 220)
text = "أذكاري"
bbox = draw.textbbox((0, 0), text, font=font_main)
tw = bbox[2] - bbox[0]
th = bbox[3] - bbox[1]
x = (size - tw) // 2
y = (size - th) // 2 - 5
draw.text((x, y), text, font=font_main, fill=GOLD)

# Save
os.makedirs("/root/adhkar-app/assets/icons", exist_ok=True)
img.save("/root/adhkar-app/assets/icons/app_icon.png")
print("✅ Icon created: assets/icons/app_icon.png")
