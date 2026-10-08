import os
import math
from PIL import Image, ImageDraw, ImageFont

os.makedirs('assets/images', exist_ok=True)

def generate_padma_branding():
    size = 1024
    
    # 1. Full Logo with Navy Background
    img_full = Image.new('RGBA', (size, size), '#0E1A24')
    draw_full = ImageDraw.Draw(img_full)
    
    # Draw decorative subtle background glow
    draw_full.ellipse([size*0.2, size*0.2, size*0.8, size*0.8], fill=(20, 184, 166, 30))
    
    # Draw Teal Wave (Padma river curve)
    wave_pts = []
    for x in range(int(size*0.1), int(size*0.9)+1, 5):
        # Sine wave curvature
        prog = (x - size*0.1) / (size*0.8)
        y = size*0.72 - math.sin(prog * math.pi) * 60 + math.sin(prog * 2 * math.pi) * 20
        wave_pts.append((x, y))
    
    # Draw thick wave stroke
    for i in range(len(wave_pts)-1):
        draw_full.line([wave_pts[i], wave_pts[i+1]], fill='#14B8A6', width=28)
        
    # Secondary lighter wave
    wave_pts2 = []
    for x in range(int(size*0.15), int(size*0.85)+1, 5):
        prog = (x - size*0.15) / (size*0.7)
        y = size*0.77 - math.sin(prog * math.pi) * 45 + math.sin(prog * 2 * math.pi) * 15
        wave_pts2.append((x, y))
    for i in range(len(wave_pts2)-1):
        draw_full.line([wave_pts2[i], wave_pts2[i+1]], fill='#0D9488', width=16)

    # Draw Bus Body (Amber / Gold)
    # Main rounded body
    bus_x0, bus_y0, bus_x1, bus_y1 = size*0.24, size*0.32, size*0.76, size*0.62
    draw_full.rounded_rectangle([bus_x0, bus_y0, bus_x1, bus_y1], radius=48, fill='#F59E0B')
    
    # Bus Roof highlight
    draw_full.rounded_rectangle([bus_x0+20, bus_y0+10, bus_x1-20, bus_y0+24], radius=6, fill='#FCD34D')
    
    # Bus Front Windshield & Windows
    # Front large window (slanted aesthetic)
    draw_full.rounded_rectangle([bus_x0+24, bus_y0+38, bus_x0+140, bus_y1-80], radius=16, fill='#0E1A24')
    # Passenger windows (3 windows)
    win_w = 70
    win_gap = 18
    w_start = bus_x0 + 175
    for i in range(3):
        wx = w_start + i * (win_w + win_gap)
        draw_full.rounded_rectangle([wx, bus_y0+38, wx+win_w, bus_y1-80], radius=12, fill='#1E293B')
        draw_full.rounded_rectangle([wx+6, bus_y0+44, wx+win_w-6, bus_y0+60], radius=4, fill='#38BDF8')

    # Headlight (front left)
    draw_full.rounded_rectangle([bus_x0+16, bus_y1-65, bus_x0+45, bus_y1-40], radius=8, fill='#FEF08A')
    # Taillight (rear right)
    draw_full.rounded_rectangle([bus_x1-35, bus_y1-65, bus_x1-16, bus_y1-40], radius=8, fill='#EF4444')

    # Wheels (Rubber & Amber Rim)
    w_y = bus_y1 - 10
    # Front wheel
    draw_full.ellipse([bus_x0+70, w_y-30, bus_x0+150, w_y+50], fill='#0F172A')
    draw_full.ellipse([bus_x0+90, w_y-10, bus_x0+130, w_y+30], fill='#F59E0B')
    draw_full.ellipse([bus_x0+100, w_y, bus_x0+120, w_y+20], fill='#FFFFFF')

    # Rear wheel
    draw_full.ellipse([bus_x1-150, w_y-30, bus_x1-70, w_y+50], fill='#0F172A')
    draw_full.ellipse([bus_x1-130, w_y-10, bus_x1-90, w_y+30], fill='#F59E0B')
    draw_full.ellipse([bus_x1-120, w_y, bus_x1-100, w_y+20], fill='#FFFFFF')

    # AUST Badge / Star on bus
    star_cx, star_cy = (bus_x0 + bus_x1)/2 + 40, (bus_y0 + bus_y1)/2 + 30
    draw_full.ellipse([star_cx-16, star_cy-16, star_cx+16, star_cy+16], fill='#0D9488')
    draw_full.ellipse([star_cx-8, star_cy-8, star_cx+8, star_cy+8], fill='#FCD34D')

    img_full.save('assets/images/padma_logo.png', 'PNG')
    img_full.save('assets/images/padma_splash.png', 'PNG')

    # 2. Adaptive Foreground (Transparent background)
    img_fg = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw_fg = ImageDraw.Draw(img_fg)
    
    # Scale slightly for safe zone in adaptive icon (0.72 center)
    # Same drawings
    for i in range(len(wave_pts)-1):
        draw_fg.line([wave_pts[i], wave_pts[i+1]], fill='#14B8A6', width=28)
    for i in range(len(wave_pts2)-1):
        draw_fg.line([wave_pts2[i], wave_pts2[i+1]], fill='#0D9488', width=16)
        
    draw_fg.rounded_rectangle([bus_x0, bus_y0, bus_x1, bus_y1], radius=48, fill='#F59E0B')
    draw_fg.rounded_rectangle([bus_x0+20, bus_y0+10, bus_x1-20, bus_y0+24], radius=6, fill='#FCD34D')
    draw_fg.rounded_rectangle([bus_x0+24, bus_y0+38, bus_x0+140, bus_y1-80], radius=16, fill='#0E1A24')
    for i in range(3):
        wx = w_start + i * (win_w + win_gap)
        draw_fg.rounded_rectangle([wx, bus_y0+38, wx+win_w, bus_y1-80], radius=12, fill='#1E293B')
        draw_fg.rounded_rectangle([wx+6, bus_y0+44, wx+win_w-6, bus_y0+60], radius=4, fill='#38BDF8')

    draw_fg.rounded_rectangle([bus_x0+16, bus_y1-65, bus_x0+45, bus_y1-40], radius=8, fill='#FEF08A')
    draw_fg.rounded_rectangle([bus_x1-35, bus_y1-65, bus_x1-16, bus_y1-40], radius=8, fill='#EF4444')

    draw_fg.ellipse([bus_x0+70, w_y-30, bus_x0+150, w_y+50], fill='#0F172A')
    draw_fg.ellipse([bus_x0+90, w_y-10, bus_x0+130, w_y+30], fill='#F59E0B')
    draw_fg.ellipse([bus_x0+100, w_y, bus_x0+120, w_y+20], fill='#FFFFFF')

    draw_fg.ellipse([bus_x1-150, w_y-30, bus_x1-70, w_y+50], fill='#0F172A')
    draw_fg.ellipse([bus_x1-130, w_y-10, bus_x1-90, w_y+30], fill='#F59E0B')
    draw_fg.ellipse([bus_x1-120, w_y, bus_x1-100, w_y+20], fill='#FFFFFF')

    draw_fg.ellipse([star_cx-16, star_cy-16, star_cx+16, star_cy+16], fill='#0D9488')
    draw_fg.ellipse([star_cx-8, star_cy-8, star_cx+8, star_cy+8], fill='#FCD34D')

    img_fg.save('assets/images/padma_icon_foreground.png', 'PNG')

    # 3. Adaptive Background
    img_bg = Image.new('RGBA', (size, size), '#0E1A24')
    img_bg.save('assets/images/padma_icon_background.png', 'PNG')
    
    print('Branding assets generated successfully.')

if __name__ == '__main__':
    generate_padma_branding()
