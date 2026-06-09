from PIL import Image, ImageDraw, ImageFont
import os

NAVY = (13, 27, 42)
GOLD = (201, 168, 76)

size = 1024
img = Image.new('RGBA', (size, size), (0, 0, 0, 0))  # transparent
draw = ImageDraw.Draw(img)

font_path = "/root/adhkar-app/assets/fonts/Amiri-Bold.ttf"
font_main = ImageFont.truetype(font_path, 300)

text = "أذكاري"
bbox = draw.textbbox((0, 0), text, font=font_main)
x = (size - (bbox[2] - bbox[0])) // 2
y = (size - (bbox[3] - bbox[1])) // 2
draw.text((x, y), text, font=font_main, fill=GOLD)

os.makedirs("/root/adhkar-app/assets/icons", exist_ok=True)
img.save("/root/adhkar-app/assets/icons/splash_icon.png")
print("✅ Splash icon created")
