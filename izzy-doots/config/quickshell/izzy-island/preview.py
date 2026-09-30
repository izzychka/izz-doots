#!/usr/bin/env python3
"""Temporarily preview the island and restore Waybar on exit."""
import fcntl, os, shutil, subprocess, sys
from pathlib import Path

base = Path(__file__).resolve().parent
state = Path.home() / '.local/state/izzy-island'
state.mkdir(parents=True, exist_ok=True)
lock = (state / 'preview.lock').open('w')
try: fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
except BlockingIOError: sys.exit('A preview is already running. Close it with Ctrl+C first.')
for name in ['quickshell', 'pgrep', 'pkill']:
    if not shutil.which(name): sys.exit('Missing command: ' + name)
uid = str(os.getuid())
was_running = subprocess.run(['pgrep', '-u', uid, '-x', 'waybar'], stdout=subprocess.DEVNULL).returncode == 0
child = None
try:
    if was_running:
        subprocess.run(['pkill', '-u', uid, '-x', 'waybar'], check=False)
    print('Preview running. Click the centre island for media and the Wallpapers button.\nPress Ctrl+C here to close it and restore Waybar.', flush=True)
    child = subprocess.Popen(['quickshell', '-p', str(base / 'shell.qml')])
    child.wait()
except KeyboardInterrupt:
    pass
finally:
    if child and child.poll() is None:
        child.terminate()
        try: child.wait(timeout=5)
        except subprocess.TimeoutExpired:
            child.kill(); child.wait()
    if was_running and subprocess.run(['pgrep', '-u', uid, '-x', 'waybar'], stdout=subprocess.DEVNULL).returncode != 0:
        with (state / 'waybar.log').open('a') as log:
            subprocess.Popen(['waybar'], stdin=subprocess.DEVNULL, stdout=log, stderr=log, start_new_session=True)
        print('Waybar restored.')
