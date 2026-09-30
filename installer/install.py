#!/usr/bin/env python3
"""Izzy's rice installer. Build a portable staging tree before touching configs."""
import argparse
import datetime
import json
import os
from pathlib import Path
import pwd
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
import tomllib

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'izzy-doots'
HOME = Path(os.environ['HOME']).resolve()
CORE = '''hyprland hypridle hyprlock hyprpolkitagent quickshell awww matugen kitty
fish fastfetch rofi dunst dolphin ark breeze plasma-integration plasma-workspace
papirus-icon-theme qt6-wayland qt6-imageformats qt6-svg qt6-declarative
networkmanager network-manager-applet bluez bluez-utils blueman pipewire
pipewire-pulse wireplumber pavucontrol cava playerctl brightnessctl hyprshot
wl-clipboard xdg-desktop-portal-hyprland python python-pillow python-adblock
fontconfig ttf-nerd-fonts-symbols-mono ttf-jetbrains-mono-nerd git base-devel unzip'''.split()
APPS = 'qutebrowser firefox neovim zed obsidian yazi libreoffice-fresh ffmpegthumbs kdegraphics-thumbnailers kio-admin'.split()
AUR = ['maplemono-nf', 'vesktop', 'spotify', 'spicetify-cli', 'python-pywalfox']
DIRS = 'hypr kitty fish rofi fastfetch dunst gtk-3.0 matugen izzy-themes nvim zed'.split()
SKIP = {'__pycache__', '.git', 'qsettings', 'autoconfig.yml'}


def say(text):
    print(text, flush=True)


def run(argv):
    say('  > ' + shlex.join(map(str, argv)))
    subprocess.run(list(map(str, argv)), check=True)


def ask(text, yes):
    return yes or input(text + ' [y/N] ').strip().lower() in ('y', 'yes')


def copy_tree(src, dest):
    """Only regular source files; never copy machine-local symlinks or caches."""
    for path in sorted(src.rglob('*')):
        if path.is_symlink() or any(part in SKIP for part in path.relative_to(src).parts):
            continue
        if path.is_file():
            if '.before-' in path.name or path.name.endswith(('.save', '.pyc', '.log')):
                continue
            out = dest / path.relative_to(src)
            out.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, out)


def write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)


def portable(stage):
    # Rewrite only text configs in our staging tree; preserve binary images/fonts.
    for path in stage.rglob('*'):
        if not path.is_file():
            continue
        try:
            text = path.read_text()
        except (UnicodeError, OSError):
            continue
        updated = text.replace('/home/surfarch', str(HOME)).replace('/home/izzy', str(HOME))
        if updated != text:
            path.write_text(updated)


def build(stage, args):
    for name in DIRS:
        copy_tree(SOURCE / 'config' / name, stage / '.config' / name)
    for name in ['quickshell/izzy-island', 'qutebrowser/izzy']:
        copy_tree(SOURCE / 'config' / name, stage / '.config' / name)
    shutil.copy2(SOURCE / 'config/qutebrowser/config.py', stage / '.config/qutebrowser/config.py')
    for name in ['vesktop/themes', 'spicetify/Themes']:
        copy_tree(SOURCE / 'config' / name, stage / '.config' / name)
    import configparser
    spotify = configparser.ConfigParser()
    spotify.read(SOURCE / 'config/spicetify/config-xpui.ini')
    spotify.remove_section('Backup')
    spotify.set('Setting', 'prefs_path', str(HOME / '.config/spotify/prefs'))
    with (stage / '.config/spicetify/config-xpui.ini').open('w') as f:
        spotify.write(f)
    # Spotify/Vesktop session settings, application binaries and autoconfig are personal.
    for name in ['izzy-theme', 'terminal-rain', 'walset', 'waydroid-tablet', 'asciiquarium']:
        out = stage / '.local/bin' / name
        out.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(SOURCE / 'scripts' / name, out)
        out.chmod(0o755)
    copy_tree(SOURCE / 'assets/wallpapers', stage / 'Pictures/wallpapers')
    copy_tree(SOURCE / 'assets/color-schemes', stage / '.local/share/color-schemes')
    portable(stage)
    config = stage / '.config'
    theme_cli = stage / '.local/bin/izzy-theme'
    theme_cli.write_text(theme_cli.read_text().replace(
        "    (STATE/'mode').write_text(theme+'\\n')",
        "    (STATE/'mode').write_text(theme+'\\n')\n"
        "    island_state = HOME / '.local/state/izzy-island'\n"
        "    island_state.mkdir(parents=True, exist_ok=True)\n"
        "    (island_state / 'wallpaper.txt').write_text(str(wallpaper)+'\\n')"))
    theme_cli.write_text(theme_cli.read_text().replace(
        "        if name == 'waybar':",
        "        if name == 'nvim':\n"
        "            subprocess.run(['pkill', '-USR1', '-u', str(os.getuid()), '-x', 'nvim'], capture_output=True)\n"
        "        if name == 'waybar':"))
    if not args.surface_monitor:
        write(config / 'hypr/izzychka/monitor.lua',
              'hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })\n')
    # Remove the broken shortcut to a Waybar script not included in this rice.
    binding = config / 'hypr/izzychka/bindings.lua'
    binding.write_text('\n'.join(line for line in binding.read_text().splitlines()
                                 if '~/.config/waybar/scripts/launch.sh' not in line) + '\n')
    startup = config / 'hypr/izzychka/startup.lua'
    startup.write_text(startup.read_text().replace('    hl.exec_cmd("blueman-applet")',
        '    hl.exec_cmd("dunst")\n    hl.exec_cmd("~/.local/bin/izzy-wallpaper-restore")'))
    fish = config / 'fish/config.fish'
    write(fish, 'fish_add_path "$HOME/.local/bin"\nset -g fish_greeting ""\nif status is-interactive\n    fastfetch\nend\n')
    # Provide both spellings, including the executable path requested by Izzy.
    launcher = config / 'rofi/launchers/type-4/launcher.sh'
    launcher.chmod(0o755)
    copy_tree(config / 'rofi/launchers/type-4', config / 'rofi/launchers/type4')
    (config / 'rofi/launchers/type4/launcher.sh').chmod(0o755)
    matugen = config / 'matugen/config.toml'
    text = matugen.read_text()
    # Delete unused pre-v3 Vim template registration. Keep the Lua Neovim template.
    text = re.sub(r'\[\[config.templates\]\].*?(?=\[templates.zed\])', '', text, flags=re.S)
    text = text.replace("post_command = 'dunstctl reload'", "post_hook = 'dunstctl reload'")
    text = text.replace("post_hook = 'kill -SIGUSR1 $(pgrep kitty)'",
                        "post_hook = 'pkill -USR1 -u $(id -u) -x kitty || true'")
    text = text.replace("post_hook = 'pkill -USR1 nvim || true'",
                        "post_hook = 'pkill -USR1 -u $(id -u) -x nvim || true'")
    # The missing Pixie helper is supplied below and updates Hyprlock too.
    matugen.write_text(text)
    parsed = tomllib.loads(text)
    for name, entry in parsed['templates'].items():
        src = Path(entry['input_path'].replace('~', str(HOME), 1))
        relative = src.relative_to(HOME)
        if not (stage / relative).is_file():
            raise RuntimeError(f'Missing {name} template: {relative}')
    for name in ['refresh.py', 'sddm-sync.py']:
        shutil.copy2(ROOT / 'installer' / name, stage / '.local/bin' / ('izzy-' + name))
    helper = config / 'izzy-pixie/refresh.py'
    helper.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(ROOT / 'installer/refresh.py', helper)
    shutil.copy2(config / 'hypr/izzy-lock.conf', config / 'izzy-pixie/lock.template')
    # Refresh hook uses the distro spicetify executable; patching Spotify is separate.
    write(config / 'matugen/scripts/spicetify-refresh.sh',
          '#!/bin/sh\ncommand -v spicetify >/dev/null || exit 0\nspicetify refresh >> "$HOME/.local/state/izzy-spicetify.log" 2>&1\n')
    for path in [config / 'matugen/scripts/spicetify-refresh.sh', stage / '.local/bin/izzy-refresh.py']:
        path.chmod(0o755)
    restore = '''#!/usr/bin/env python3
from pathlib import Path
import subprocess,time
h=Path.home(); p=h/'.local/state/izzy-island/wallpaper.txt'
if p.exists():
    image=Path(p.read_text().strip())
    if image.is_file():
        for _ in range(30):
            r=subprocess.run(['awww','img',str(image)],capture_output=True)
            if r.returncode==0: break
            time.sleep(.2)
'''
    write(stage / '.local/bin/izzy-wallpaper-restore', restore)
    (stage / '.local/bin/izzy-wallpaper-restore').chmod(0o755)
    # Existing KDE globals are preserved; set just our theme keys during activation.
    return config


def install_files(stage):
    stamp = datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f')
    backup = HOME / '.local/state/izzy-rice/backups' / stamp
    backup.mkdir(parents=True)
    # Replace complete owned directories; merge only directories shared with other apps.
    targets = [Path('.config') / n for n in DIRS]
    targets += [Path('.config/quickshell/izzy-island'), Path('.config/izzy-pixie'),
                Path('.config/qutebrowser/izzy'), Path('.config/qutebrowser/config.py')]
    targets += [p.relative_to(stage) for p in stage.rglob('*') if p.is_file()
                and not any(p.relative_to(stage).is_relative_to(t) for t in targets)]
    installed = []
    try:
        for rel in targets:
            src, dst, old = stage / rel, HOME / rel, backup / rel
            if not src.exists(): continue
            if dst.exists() or dst.is_symlink():
                old.parent.mkdir(parents=True, exist_ok=True)
                shutil.move(str(dst), str(old))
            dst.parent.mkdir(parents=True, exist_ok=True)
            installed.append(rel)
            if src.is_dir(): shutil.copytree(src, dst)
            else: shutil.copy2(src, dst)
    except Exception:
        for rel in reversed(installed):
            dst, old = HOME / rel, backup / rel
            if dst.is_dir() and not dst.is_symlink(): shutil.rmtree(dst)
            elif dst.exists() or dst.is_symlink(): dst.unlink()
            if old.exists() or old.is_symlink(): shutil.move(str(old), str(dst))
        raise
    write(backup / 'manifest.json', json.dumps([str(p) for p in installed], indent=2))
    say(f'Your old configs are tucked away at {backup}')


def dependencies(args):
    packages = CORE + ([] if args.minimal else APPS)
    if args.sddm: packages += ['sddm']
    argv = ['sudo', 'pacman', '-Syu', '--needed']
    if args.yes: argv += ['--noconfirm']
    run(argv + packages)
    helper = shutil.which('paru') or shutil.which('yay')
    aur = ['maplemono-nf'] + ([] if args.minimal else AUR[1:])
    if args.skip_aur:
        say('AUR packages skipped: ' + ' '.join(aur))
        return
    if not helper and ask('Build yay from the AUR to install Maple Mono and the optional apps?', args.yes):
        with tempfile.TemporaryDirectory(prefix='izzy-yay-') as temp:
            repo = Path(temp) / 'yay'
            run(['git', 'clone', 'https://aur.archlinux.org/yay.git', repo])
            subprocess.run(['makepkg', '-si', '--needed'] + (['--noconfirm'] if args.yes else []),
                           cwd=repo, check=True)
        helper = shutil.which('yay')
    if helper:
        run([helper, '-S', '--needed'] + (['--noconfirm'] if args.yes else []) + aur)
    else:
        say('No paru/yay found. Official packages installed; optional AUR packages: ' + ' '.join(aur))
        say('Install an AUR helper separately, then rerun. The bar falls back to monospace meanwhile.')


def sddm(args):
    user = pwd.getpwuid(os.getuid())
    with tempfile.TemporaryDirectory() as tmp:
        tmp = Path(tmp)
        theme = tmp / 'pixie-izzy'
        copy_tree(SOURCE / 'assets/pixie', theme)
        # Always root-owned; no symlink into a user's home in the greeter theme.
        write(theme / 'theme.conf.user', '[General]\nautoColor=false\nfontFamily=Maple Mono\n')
        run(['sudo', 'mkdir', '-p', '/usr/share/sddm/themes'])
        target = Path('/usr/share/sddm/themes/pixie-izzy')
        # Back up a previous installation rather than silently overwrite it.
        run(['sudo', 'python3', '-c',
             'import pathlib,shutil,time; p=pathlib.Path("/usr/share/sddm/themes/pixie-izzy"); '
             'shutil.move(str(p),str(p)+".backup-"+str(time.time_ns())) if p.exists() else None'])
        run(['sudo', 'cp', '-a', str(theme), str(target)])
        run(['sudo', 'chown', '-R', 'root:root', str(target)])
        run(['sudo', 'chmod', '-R', 'go-w', str(target)])
        write(tmp / 'config.json', json.dumps({'home': str(HOME), 'uid': user.pw_uid, 'gid': user.pw_gid}))
        run(['sudo', 'install', '-Dm644', tmp / 'config.json', '/etc/izzy-rice-sddm.json'])
        run(['sudo', 'install', '-Dm755', ROOT / 'installer/sddm-sync.py', '/usr/local/libexec/izzy-sddm-sync'])
        write(tmp / 'theme.conf', '[Theme]\nCurrent=pixie-izzy\n')
        for f in ['/etc/sddm.conf', '/etc/sddm.conf.d/theme.conf', '/etc/sddm.conf.d/zz-izzy.conf']:
            if Path(f).is_file():
                run(['sudo', 'cp', '-a', f, f + '.izzy-backup-' + str(datetime.datetime.now().timestamp())])
        # /etc/sddm.conf has precedence over conf.d; update its Theme key if present.
        run(['sudo', 'python3', '-c',
             'import configparser,pathlib; p=pathlib.Path("/etc/sddm.conf"); '
             'c=configparser.ConfigParser(); c.read(p); '
             'c.add_section("Theme") if not c.has_section("Theme") else None; '
             'c.set("Theme","Current","pixie-izzy"); '
             'c.write(p.open("w")) if p.exists() else None'])
        run(['sudo', 'install', '-Dm644', tmp / 'theme.conf', '/etc/sddm.conf.d/zz-izzy.conf'])
        write(tmp / 'sync.service', '[Unit]\nDescription=Sync Izzy SDDM colours and wallpaper\n'
              '[Service]\nType=oneshot\nExecStart=/usr/local/libexec/izzy-sddm-sync\n')
        export = HOME / '.local/share/izzy-pixie/export'
        export.mkdir(parents=True, exist_ok=True)
        write(tmp / 'sync.path', '[Unit]\nDescription=Watch Izzy SDDM theme export\n'
              '[Path]\nPathChanged=' + str(export / 'ready') + '\nUnit=izzy-sddm-sync.service\n'
              '[Install]\nWantedBy=multi-user.target\n')
        for name in ['service', 'path']:
            run(['sudo', 'install', '-Dm644', tmp / ('sync.' + name), '/etc/systemd/system/izzy-sddm-sync.' + name])
        run(['sudo', 'systemctl', 'daemon-reload'])
        run(['sudo', 'systemctl', 'enable', '--now', 'izzy-sddm-sync.path'])
        if (export / 'ready').exists():
            run(['sudo', 'systemctl', 'start', 'izzy-sddm-sync.service'])
        say('Pixie colours/background will sync automatically. SDDM was not restarted or enabled.')


def main():
    p = argparse.ArgumentParser(description='A little rice, a lot of purple. Install Izzy Island on Arch.')
    p.add_argument('--yes', '-y', action='store_true', help='Skip installer and package confirmations')
    p.add_argument('--dry-run', action='store_true', help='Validate and show plan without modifying your system')
    p.add_argument('--skip-deps', action='store_true', help='Do not install packages')
    p.add_argument('--skip-aur', action='store_true', help='Skip AUR packages and AUR helper bootstrap')
    p.add_argument('--minimal', action='store_true', help='Skip optional editor/browser/Spotify/Vesktop packages')
    p.add_argument('--sddm', action='store_true', help='Install Pixie and automatic login-screen theme sync')
    p.add_argument('--surface-monitor', action='store_true', help='Keep eDP-1 at scale 2 instead of auto monitors')
    p.add_argument('--no-activate', action='store_true', help='Install files without rendering/reloading apps')
    args = p.parse_args()
    if not args.dry_run and os.geteuid() == 0:
        p.error('Run as your normal user. The installer asks sudo only for packages/system files.')
    if not args.dry_run and not shutil.which('pacman'):
        p.error('This installer targets Arch Linux and pacman-based systems.')
    if not SOURCE.is_dir(): p.error('Keep install.sh, installer/ and izzy-doots/ together in the cloned repo.')
    if not re.fullmatch(r'/[A-Za-z0-9_./-]+', str(HOME)):
        p.error('Home paths with spaces or shell metacharacters are not supported by the upstream hooks.')
    say('✦ Welcome to Izzy Island. Time to season your desktop :3')
    with tempfile.TemporaryDirectory(prefix='izzy-rice-') as temp:
        stage = Path(temp)
        build(stage, args)
        say('Plan: back up existing configs, install the island/apps, wallpapers and theme presets.')
        say('Monitor layout: ' + ('Surface eDP-1, scale 2' if args.surface_monitor else 'automatic across all outputs'))
        say('SDDM: ' + ('Pixie + automatic background/colour sync' if args.sddm else 'unchanged; use --sddm to include'))
        say('Dependencies: ' + ('skipped' if args.skip_deps else 'official Arch packages + AUR packages if paru/yay is available'))
        if args.dry_run:
            say(f'Dry run passed: {sum(p.is_file() for p in stage.rglob("*"))} staged files. Nothing installed.')
            return
        if not ask('Ready to install? Existing owned config directories will be backed up.', args.yes):
            say('Keeping the rice in the pantry.'); return
        if not args.skip_deps: dependencies(args)
        install_files(stage)
    if not args.no_activate:
        # Render via the existing preset renderer; it does not need a running compositor.
        presets = sorted((HOME / '.config/izzy-themes').glob('*.json'))
        selected = next((p for p in presets if p.stem == 'catppuccin-mocha'), presets[0] if presets else None)
        if selected:
            run([HOME / '.local/bin/izzy-theme', selected.stem])
        if shutil.which('kwriteconfig6'):
            run(['kwriteconfig6', '--file', 'kdeglobals', '--group', 'Icons', '--key', 'Theme', 'Papirus-Dark'])
            run(['kwriteconfig6', '--file', 'kdeglobals', '--group', 'KDE', '--key', 'widgetStyle', 'Breeze'])
        if shutil.which('fc-cache'): run(['fc-cache', '-f'])
    if args.sddm: sddm(args)
    say('✦ Rice served! Log out and select Hyprland. Super+D launcher; Super+L lock; Super+W browser.')
    say('Wi-Fi/Bluetooth services, login manager enabling and default shell are left for you to choose.')
    say('Spotify: launch/sign in once, install spicetify-cli, then run spicetify backup apply.')
    say('Firefox Dark Reader JSON still needs manual import; qutebrowser includes the bundled page theme.')

if __name__ == '__main__':
    try: main()
    except (OSError, ValueError, RuntimeError, subprocess.CalledProcessError) as e:
        say(f'Install stopped: {e}'); sys.exit(1)
