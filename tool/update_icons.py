import base64
import io
import os
from PIL import Image, ImageOps

BG_COLOR_RGB = (13, 13, 13)
BG_COLOR_RGBA = (13, 13, 13, 255)

def make_solid_icon(letter_img, size, scale=0.75):
    """Creates a square icon with dark background and centered letter."""
    w, h = size
    bg = Image.new('RGB', (w, h), BG_COLOR_RGB)
    pw = int(w * scale)
    ph = int(h * scale)
    scaled = letter_img.resize((pw, ph), Image.Resampling.LANCZOS)
    x = (w - pw) // 2
    y = (h - ph) // 2
    bg.paste(scaled, (x, y), scaled)
    return bg

def make_transparent_icon(letter_img, size, scale=0.88):
    """Creates a transparent icon with centered letter."""
    w, h = size
    canvas = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    pw = int(w * scale)
    ph = int(h * scale)
    scaled = letter_img.resize((pw, ph), Image.Resampling.LANCZOS)
    x = (w - pw) // 2
    y = (h - ph) // 2
    canvas.paste(scaled, (x, y), scaled)
    return canvas

def make_monochrome_icon(letter_img, size, scale=0.75):
    """Creates a monochrome white silhouette of the letter with detail cutouts."""
    w, h = size
    canvas = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    pw = int(w * scale)
    ph = int(h * scale)
    scaled = letter_img.resize((pw, ph), Image.Resampling.LANCZOS)
    alpha = scaled.split()[3]
    gray = ImageOps.grayscale(scaled)
    alpha_data = list(alpha.getdata())
    gray_data = list(gray.getdata())
    new_alpha = [0 if a < 20 or g < 90 else a for a, g in zip(alpha_data, gray_data)]
    mono_alpha = Image.new('L', (pw, ph))
    mono_alpha.putdata(new_alpha)
    white = Image.new('RGBA', (pw, ph), (255, 255, 255, 255))
    white.putalpha(mono_alpha)
    x = (w - pw) // 2
    y = (h - ph) // 2
    canvas.paste(white, (x, y), white)
    return canvas

def generate_svg(letter_img, output_path):
    """Generates an SVG version with dark squircle background and embedded high-res letter."""
    pw = int(1024 * 0.75)
    ph = int(1024 * 0.75)
    scaled = letter_img.resize((pw, ph), Image.Resampling.LANCZOS)
    x = (1024 - pw) // 2
    y = (1024 - ph) // 2
    buf = io.BytesIO()
    scaled.save(buf, format='PNG')
    b64_data = base64.b64encode(buf.getvalue()).decode('ascii')
    svg = f'''<svg width="1024" height="1024" viewBox="0 0 1024 1024" fill="none" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
  <!-- Background -->
  <rect width="1024" height="1024" rx="230" fill="#0D0D0D"/>
  <!-- Soul State Letter Logo -->
  <image href="data:image/png;base64,{b64_data}" xlink:href="data:image/png;base64,{b64_data}" x="{x}" y="{y}" width="{pw}" height="{ph}" preserveAspectRatio="xMidYMid meet"/>
</svg>
'''
    with open(output_path, 'w') as f:
        f.write(svg)
    print(f"Generated {output_path}")

def run():
    src_path = 'letter.png'
    if not os.path.exists(src_path):
        home = os.path.expanduser('~')
        alt_path = os.path.join(home, 'Downloads', 'letter.png')
        if os.path.exists(alt_path):
            src_path = alt_path
        elif os.path.exists('assets/icon_foreground.png'):
            src_path = 'assets/icon_foreground.png'
        elif os.path.exists('assets/icon.png'):
            src_path = 'assets/icon.png'

    raw_letter = Image.open(src_path).convert('RGBA')
    bbox = raw_letter.getbbox()
    cropped = raw_letter.crop(bbox)
    cw, ch = cropped.size
    dim = max(cw, ch)
    letter = Image.new('RGBA', (dim, dim), (0, 0, 0, 0))
    letter.paste(cropped, ((dim - cw) // 2, (dim - ch) // 2))

    print(f"Prepared square letter of size {dim}x{dim}")

    # 1. Assets
    make_transparent_icon(letter, (1024, 1024), 0.92).save('assets/icon.png', 'PNG')
    make_transparent_icon(letter, (1024, 1024), 0.65).save('assets/icon_foreground.png', 'PNG')
    generate_svg(letter, 'assets/icon.svg')
    print("Generated assets/icon.png, assets/icon_foreground.png, and assets/icon.svg")

    # 2. Web
    make_transparent_icon(letter, (32, 32), 0.95).save('web/favicon.png', 'PNG')
    make_transparent_icon(letter, (192, 192), 0.88).save('web/icons/Icon-192.png', 'PNG')
    make_transparent_icon(letter, (512, 512), 0.88).save('web/icons/Icon-512.png', 'PNG')
    make_solid_icon(letter, (192, 192), 0.70).save('web/icons/Icon-maskable-192.png', 'PNG')
    make_solid_icon(letter, (512, 512), 0.70).save('web/icons/Icon-maskable-512.png', 'PNG')
    print("Generated web icons")

    # 3. Windows .ico
    ico_sizes = [(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
    ico_imgs = [make_transparent_icon(letter, sz, 0.90) for sz in ico_sizes]
    ico_imgs[-1].save(
        'windows/runner/resources/app_icon.ico',
        format='ICO',
        sizes=ico_sizes,
        append_images=ico_imgs[:-1]
    )
    print("Generated windows/runner/resources/app_icon.ico")

    # 4. macOS
    macos_dir = 'macos/Runner/Assets.xcassets/AppIcon.appiconset'
    for sz in [16, 32, 64, 128, 256, 512, 1024]:
        make_transparent_icon(letter, (sz, sz), 0.90).save(f'{macos_dir}/app_icon_{sz}.png', 'PNG')
    print("Generated macOS icons")

    # 5. iOS
    ios_base = 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    ios_files = {
        'Icon-App-20x20@1x.png': (20, 20),
        'Icon-App-20x20@2x.png': (40, 40),
        'Icon-App-20x20@3x.png': (60, 60),
        'Icon-App-29x29@1x.png': (29, 29),
        'Icon-App-29x29@2x.png': (58, 58),
        'Icon-App-29x29@3x.png': (87, 87),
        'Icon-App-40x40@1x.png': (40, 40),
        'Icon-App-40x40@2x.png': (80, 80),
        'Icon-App-40x40@3x.png': (120, 120),
        'Icon-App-50x50@1x.png': (50, 50),
        'Icon-App-50x50@2x.png': (100, 100),
        'Icon-App-57x57@1x.png': (57, 57),
        'Icon-App-57x57@2x.png': (114, 114),
        'Icon-App-60x60@2x.png': (120, 120),
        'Icon-App-60x60@3x.png': (180, 180),
        'Icon-App-72x72@1x.png': (72, 72),
        'Icon-App-72x72@2x.png': (144, 144),
        'Icon-App-76x76@1x.png': (76, 76),
        'Icon-App-76x76@2x.png': (152, 152),
        'Icon-App-83.5x83.5@2x.png': (167, 167),
        'Icon-App-1024x1024@1x.png': (1024, 1024),
    }
    for fname, sz in ios_files.items():
        make_solid_icon(letter, sz, 0.75).save(f'{ios_base}/{fname}', 'PNG')

    make_solid_icon(letter, (1024, 1024), 0.75).save('ios/Runner/Assets.xcassets/AppIcon-accent.appiconset/icon.png', 'PNG')
    make_solid_icon(letter, (1024, 1024), 0.75).save('ios/Runner/Assets.xcassets/AppIcon-neutral.appiconset/icon.png', 'PNG')
    print("Generated iOS icons")

    # 6. Android
    densities = {
        'mdpi': (48, 108),
        'hdpi': (72, 162),
        'xhdpi': (96, 216),
        'xxhdpi': (144, 324),
        'xxxhdpi': (192, 432),
    }
    for dens, (legacy_sz, fg_sz) in densities.items():
        # Legacy launcher icon
        mip = f'android/app/src/main/res/mipmap-{dens}'
        make_solid_icon(letter, (legacy_sz, legacy_sz), 0.75).save(f'{mip}/ic_launcher.png', 'PNG')

        # Background
        bg = Image.new('RGB', (fg_sz, fg_sz), BG_COLOR_RGB)
        bg.save(f'{mip}/ic_launcher_background.png', 'PNG')
        
        # Adaptive foreground
        fg = make_transparent_icon(letter, (fg_sz, fg_sz), 0.65)
        fg.save(f'{mip}/ic_launcher_foreground.png', 'PNG')
        fg.save(f'{mip}/ic_launcher_fg_tri.png', 'PNG')
        fg.save(f'{mip}/ic_launcher_fg_green.png', 'PNG')

        # Adaptive monochrome
        mono = make_monochrome_icon(letter, (fg_sz, fg_sz), 0.65)
        mono.save(f'{mip}/ic_launcher_monochrome.png', 'PNG')

        # Drawables
        draw = f'android/app/src/main/res/drawable-{dens}'
        fg.save(f'{draw}/ic_launcher_foreground.png', 'PNG')
        mono.save(f'{draw}/ic_launcher_monochrome.png', 'PNG')

    print("Generated Android mipmap & drawable icons")
    print("ALL APP LOGOS GENERATED SUCCESSFULLY!")

if __name__ == '__main__':
    run()
