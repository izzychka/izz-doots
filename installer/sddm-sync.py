#!/usr/bin/env python3
"""Root-owned copier: read user exports as that user; write only fixed targets."""
import json
import os
from pathlib import Path
import re

DEST = Path('/usr/share/sddm/themes/pixie-izzy')
KEYS = {'primary': 'accentColor', 'surface': 'backgroundColor',
        'surface_container': 'surfaceColor', 'surface_container_high': 'surfaceVariantColor',
        'on_surface': 'textColor'}


def sync():
    config = json.loads(Path('/etc/izzy-rice-sddm.json').read_text())
    source = Path(config['home']) / '.local/share/izzy-pixie/export'
    # No user-provided pathname is ever read with root privileges.
    os.setgroups([])
    os.setegid(config['gid'])
    os.seteuid(config['uid'])
    try:
        with (source / 'palette.json').open('rb') as f: raw = f.read(8193)
        if len(raw) > 8192: raise ValueError('Palette exceeds size limit')
        palette = json.loads(raw)
        for key in KEYS:
            if not re.fullmatch(r'#[0-9a-fA-F]{6}', palette.get(key, '')):
                raise ValueError('Invalid colour')
        with (source / 'background.png').open('rb') as f: image = f.read(50_000_001)
        if len(image) > 50_000_000 or not image.startswith(b'\x89PNG\r\n\x1a\n'):
            raise ValueError('Invalid PNG or size limit exceeded')
    finally:
        os.seteuid(0)
        os.setegid(0)
    if not DEST.is_dir() or DEST.is_symlink(): raise ValueError('Missing root-owned Pixie theme')
    text = '[General]\nautoColor=false\nfontFamily=Maple Mono\nbackground=assets/izzy-background.png\n'
    text += ''.join(name + '=' + palette[key] + '\n' for key, name in KEYS.items())
    for target, data in [(DEST / 'assets/izzy-background.png', image),
                         (DEST / 'theme.conf.user', text.encode())]:
        tmp = target.with_name(target.name + '.new')
        # No follow: an unexpected symlink must stop this service.
        fd = os.open(tmp, os.O_WRONLY | os.O_CREAT | os.O_TRUNC | os.O_NOFOLLOW, 0o644)
        with os.fdopen(fd, 'wb') as f: f.write(data)
        os.chmod(tmp, 0o644)
        tmp.replace(target)

if __name__ == '__main__': sync()
