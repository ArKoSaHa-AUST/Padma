import os
from PIL import Image

res_base = 'android/app/src/main/res'
img_full = Image.open('assets/images/padma_logo.png')
img_fg = Image.open('assets/images/padma_icon_foreground.png')

densities = {
    'mipmap-mdpi': (48, 108),
    'mipmap-hdpi': (72, 162),
    'mipmap-xhdpi': (96, 216),
    'mipmap-xxhdpi': (144, 324),
    'mipmap-xxxhdpi': (192, 432),
}

for folder, (icon_size, adaptive_size) in densities.items():
    folder_path = os.path.join(res_base, folder)
    os.makedirs(folder_path, exist_ok=True)
    
    # 1. ic_launcher.png (legacy full icon)
    legacy = img_full.resize((icon_size, icon_size), Image.Resampling.LANCZOS)
    legacy.save(os.path.join(folder_path, 'ic_launcher.png'))
    
    # 2. ic_launcher_round.png
    legacy.save(os.path.join(folder_path, 'ic_launcher_round.png'))
    
    # 3. ic_launcher_foreground.png (for adaptive icons)
    fg = img_fg.resize((adaptive_size, adaptive_size), Image.Resampling.LANCZOS)
    fg.save(os.path.join(folder_path, 'ic_launcher_foreground.png'))

print('Generated all Android launcher mipmap icons successfully!')
