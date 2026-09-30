#!/usr/bin/env python3
"""Render Hyprlock and export a strictly bounded Pixie theme for the root copier."""
from pathlib import Path
import json
import re
import time
from PIL import Image, ImageOps

HOME = Path.home()
PALETTE = HOME / '.config/matugen/generated/izzy-pixie.palette'
EXPORT = HOME / '.local/share/izzy-pixie/export'
KEYS = ('primary', 'surface', 'surface_container', 'surface_container_high',
        'on_surface', 'on_surface_variant', 'outline', 'error')


def atomic(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_name(path.name + '.tmp')
    if isinstance(data, bytes): tmp.write_bytes(data)
    else: tmp.write_text(data)
    tmp.replace(path)


def refresh():
    palette = dict(line.split('=', 1) for line in PALETTE.read_text().splitlines() if '=' in line)
    for key in KEYS:
        if not re.fullmatch(r'#[0-9a-fA-F]{6}', palette.get(key, '')):
            raise ValueError('Invalid or missing palette colour: ' + key)
    image = Path(palette['image']).expanduser()
    EXPORT.mkdir(parents=True, exist_ok=True)
    if image.is_file():
        # Decode as the logged-in user, constrain dimensions and produce a PNG.
        with Image.open(image) as original:
            rendered = ImageOps.exif_transpose(original).convert('RGB')
            rendered.thumbnail((3840, 2160))
            tmp = EXPORT / 'background.tmp'
            rendered.save(tmp, format='PNG')
            tmp.replace(EXPORT / 'background.png')
    elif not (EXPORT / 'background.png').exists():
        raise FileNotFoundError('Wallpaper does not exist: ' + str(image))
    atomic(EXPORT / 'palette.json', json.dumps({key: palette[key] for key in KEYS}))
    template = HOME / '.config/izzy-pixie/lock.template'
    lock = template.read_text()
    lock = lock.replace('/var/cache/izzy-pixie/background.png', str(EXPORT / 'background.png'))
    def rgb(key):
        value = palette[key][1:]
        return 'rgb(' + ', '.join(str(int(value[i:i+2], 16)) for i in (0, 2, 4)) + ')'
    defaults = {'rgb(30, 30, 46)': 'surface', 'rgb(203, 166, 247)': 'primary',
                'rgb(205, 214, 244)': 'on_surface', 'rgb(49, 50, 68)': 'surface_container',
                'rgb(127, 132, 156)': 'outline', 'rgb(243, 139, 168)': 'error'}
    pattern = re.compile('|'.join(re.escape(k) for k in defaults))
    lock = pattern.sub(lambda m: rgb(defaults[m.group()]), lock)
    atomic(HOME / '.config/hypr/izzy-lock.conf', lock)
    # Change the trigger only after both exports have finished.
    atomic(EXPORT / 'ready', str(time.time_ns()))

if __name__ == '__main__':
    refresh()
