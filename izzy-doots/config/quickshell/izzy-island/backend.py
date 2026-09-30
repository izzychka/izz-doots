#!/usr/bin/env python3
"""Small local helper: status sampling, wallpaper listing and safe argv execution."""
import json, os, re, subprocess, sys, time
from pathlib import Path

HOME = Path.home()
WALLPAPERS = HOME / 'Pictures/wallpapers'
STATE = HOME / '.local/state/izzy-island'
EXTENSIONS = {'.png', '.jpg', '.jpeg', '.webp', '.bmp'}

def emit(value):
    print(json.dumps(value), flush=True)

def read(path, default=''):
    try: return Path(path).read_text().strip()
    except OSError: return default

def run(args, timeout=3):
    try:
        p = subprocess.run(args, capture_output=True, text=True, timeout=timeout)
        return p.stdout.strip() if p.returncode == 0 else ''
    except (OSError, subprocess.TimeoutExpired): return ''

def cpu():
    values = [int(v) for v in read('/proc/stat', 'cpu 0 0 0 0').splitlines()[0].split()[1:9]]
    return sum(values), values[3] + (values[4] if len(values) > 4 else 0)

def sample(previous):
    current = cpu()
    total, idle = current[0] - previous[0], current[1] - previous[1]
    usage = max(0, min(100, round(100 * (1 - idle / total)))) if total > 0 else 0
    mem = {}
    for line in read('/proc/meminfo').splitlines():
        key, value = line.split(':', 1)
        mem[key] = int(value.split()[0])
    memory = round(100 * (1 - mem.get('MemAvailable', 0) / max(1, mem.get('MemTotal', 1))))
    batteries = [p for p in Path('/sys/class/power_supply').glob('*')
                 if read(p / 'type') == 'Battery' and read(p / 'scope') != 'Device']
    battery = batteries[0] if batteries else None
    capacity = read(battery / 'capacity') if battery else ''
    status = read(battery / 'status') if battery else ''
    power = any(read(p / 'online') == '1' for p in Path('/sys/class/power_supply').glob('*')
                if read(p / 'type') != 'Battery')
    volume_text = run(['wpctl', 'get-volume', '@DEFAULT_AUDIO_SINK@'])
    match = re.search(r'Volume:\s*([0-9.]+)', volume_text)
    interfaces = [p for p in Path('/sys/class/net').glob('*')
                  if p.name != 'lo' and read(p / 'operstate') == 'up']
    interfaces.sort(key=lambda p: (not (p / 'wireless').exists(), p.name))
    interface = interfaces[0] if interfaces else None
    result = {'cpu': usage, 'memory': memory,
              'battery': int(capacity) if capacity.isdigit() else -1,
              'charging': status == 'Charging', 'plugged': power,
              'volume': round(float(match[1]) * 100) if match else -1,
              'muted': '[MUTED]' in volume_text,
              'network': interface.name if interface else 'offline'}
    return result, current

def wallpaper_list():
    if not WALLPAPERS.is_dir(): return []
    return [{'name': p.stem, 'path': str(p.absolute()), 'url': p.absolute().as_uri()}
            for p in sorted(WALLPAPERS.rglob('*'), key=lambda p: str(p).lower())
            if p.is_file() and p.suffix.lower() in EXTENSIONS]

def apply_wallpaper(path):
    import fcntl
    path = Path(path).resolve()
    if not path.is_file() or path.suffix.lower() not in EXTENSIONS:
        raise ValueError('Choose an existing PNG, JPEG, WebP or BMP image.')
    STATE.mkdir(parents=True, exist_ok=True)
    with (STATE / 'wallpaper.lock').open('w') as lock:
        try: fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError: raise RuntimeError('A wallpaper change is already running.')
        with (STATE / 'wallpaper.log').open('w') as log:
            completed = subprocess.run([str(Path.home() / '.local/bin/izzy-theme'), 'wallpaper', str(path)],
                                       stdout=log, stderr=log, timeout=220)
            if completed.returncode:
                raise RuntimeError('Theme switch failed. See ~/.local/state/izzy-island/wallpaper.log')
        (STATE / 'wallpaper.txt').write_text(str(path))
    emit({'ok': True, 'message': 'Wallpaper and colours updated'})

def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else 'status'
    if mode == 'list': emit(wallpaper_list())
    elif mode == 'apply':
        try: apply_wallpaper(sys.argv[2])
        except Exception as error:
            emit({'ok': False, 'message': str(error)})
            return 1
    elif mode == 'theme':
        choice = sys.argv[2] if len(sys.argv) > 2 else ''
        if choice != 'wallpaper' and not re.fullmatch(r'[a-z0-9][a-z0-9-]*',choice):
            emit({'ok': False, 'message': 'Unknown theme'})
            return 1
        result = subprocess.run([str(HOME / '.local/bin/izzy-theme'), choice],
                                text=True, capture_output=True, timeout=240)
        message = (result.stderr if result.returncode else result.stdout).strip()
        emit({'ok': result.returncode == 0,
              'message': message.splitlines()[-1] if message else 'Theme changed'})
        return result.returncode
    elif mode == 'themes':
        result = subprocess.run([str(HOME / '.local/bin/izzy-theme'), 'list'],
                                text=True, capture_output=True, timeout=10)
        emit(json.loads(result.stdout) if result.returncode == 0 else [])
    elif mode == 'status':
        previous = cpu()
        while True:
            result, previous = sample(previous)
            emit(result)
            time.sleep(2)
    return 0

if __name__ == '__main__':
    try: sys.exit(main())
    except (BrokenPipeError, KeyboardInterrupt): pass
