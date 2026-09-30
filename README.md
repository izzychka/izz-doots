# Izzychka's rice ✦

A wallpaper-coloured Arch/Hyprland desktop, with a Maple Mono Quickshell island,
Cava visualiser, media controls, a wallpaper picker and seven preset themes :3

## Install

Requires an existing Arch installation, working internet and sudo. This installs
a desktop rice, not an operating system. The Hyprland config uses the Lua API
(Hyprland 0.55+). Run as your normal user, never `sudo ./install.sh`.

```sh
git clone https://github.com/izzychka/izz-doots.git
cd izz-doots
bash install.sh --dry-run
bash install.sh
```

The payload stays in `izzy-doots/`; do not move it away from the installer.

To skip installer and package confirmations:

```sh
bash install.sh --yes
```

Sudo can still ask for your password. Network/build failures still stop the
installer. A full Arch upgrade runs before package installation. It uses paru
or yay for AUR dependencies; if neither exists, it offers to build yay from the
AUR. `--yes` accepts that offer too.

| Option | Effect |
| --- | --- |
| `--dry-run` | Build and validate a temporary staging tree; no packages/configs installed |
| `--yes` | Accept installer, pacman, yay/paru and bootstrap confirmations |
| `--skip-deps` | Use already-installed dependencies |
| `--skip-aur` | Install official packages only; skip AUR helper bootstrap |
| `--minimal` | Skip optional browser/editor/Spotify/Vesktop packages |
| `--sddm` | Install the modified Pixie numpad theme and automatic wallpaper/colour sync |
| `--surface-monitor` | Keep the original eDP-1 scale-2 layout; otherwise use automatic outputs |
| `--no-activate` | Copy configs without rendering colours or reloading apps |

Flags combine: `bash install.sh --yes --sddm --surface-monitor`.

## What it installs

- Hyprland Lua config, Hypridle and Hyprlock; automatic multi-monitor layout.
- Quickshell's existing multi-monitor island with waveform, media controls,
  clock, workspaces, system stats, Wi-Fi/Bluetooth shortcuts and wallpaper picker.
- Matugen templates, seven curated presets and their wallpapers.
- Kitty, Fish, Rofi, Fastfetch, Dunst, GTK CSS and KDE colour generation.
- Qutebrowser's homepage, Google search and bundled Dark Reader userscript.
- Neovim, Zed, Vesktop theme CSS and Spicetify theme files.
- Wallpapers in `~/Pictures/wallpapers/` and custom scripts in `~/.local/bin/`.

The initial rendered preset is Catppuccin Mocha. Use the island's theme menu to
switch to wallpaper-derived Matugen colours or another preset. Preset wallpapers
are paired by filename in `~/.config/izzy-themes/wallpapers/`.

Existing owned config directories are moved to timestamped backups in
`~/.local/state/izzy-rice/backups/`. Shared directories (wallpapers, scripts,
Vesktop themes, Spicetify themes) are merged and conflicting files are backed up.
Copy failures roll back the file installation. Package installation and later
app refreshes are not rolled back. Each backup includes an installed-file manifest.
Back up important work independently before installing any dotfiles.

Machine-specific paths are rewritten during staging. Both
`~/.config/rofi/launchers/type-4/launcher.sh` and
`~/.config/rofi/launchers/type4/launcher.sh` are installed executable.
The package reference lists are informational: the installer does not install
kernels, bootloaders, Surface firmware, VPN software or every package on the
original machine.

## First login

Log out and select Hyprland. This installer does not restart your session, switch
your default shell, enable NetworkManager/Bluetooth, enable a display manager,
or change the power button policy. If needed, enable your chosen services yourself:

```sh
sudo systemctl enable --now NetworkManager bluetooth
chsh -s /usr/bin/fish
```

Avoid enabling NetworkManager if you intentionally use a different network stack.
The uploaded power-key logind configuration was not included; locking before
sleep is provided through Hypridle, but the power-key action remains system policy.

Keybindings: Super+Return terminal; Super+D launcher; Super+E Dolphin;
Super+W qutebrowser; Super+L lock; Super+1..0 workspaces.

For Vesktop, sign in yourself and enable `matugen.css` in its themes settings.
For Spotify, launch/sign in once before applying Spicetify. Permission preparation
for a package-installed Spotify is a separate step; follow Spicetify's Linux
instructions, then run `spicetify backup apply`. The installer does not make
`/opt/spotify` world-writable.
Firefox extensions must be installed/configured separately. Dark Reader/Stylus
JSON files are generated but still need manual import. Qutebrowser's userscript
covers ordinary websites, subject to browser restrictions.

## SDDM and Hyprlock

`--sddm` installs a separate root-owned `pixie-izzy` theme, preserving the original
`pixie` directory. Existing SDDM configuration files are backed up beside themselves.
It selects the new theme without restarting or enabling SDDM.

The included missing Pixie refresh helper generates a bounded PNG and palette
as your user. Hyprlock uses that user-owned PNG. A systemd path unit observes
completed exports and starts a root-owned copier. The copier reads those exports
with your user's permissions, validates size/colour values, and writes only two
fixed SDDM theme files. It never runs a generated shell script as root.

After installing: `sudo systemctl status izzy-sddm-sync.path`.
Preview SDDM with `sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/pixie-izzy`
(if your package names the executable differently, use that greeter binary).
Hyprlock: `hyprlock --config ~/.config/hypr/izzy-lock.conf`.

## Repository hygiene — before making public

The original upload included Vesktop session/cookie files and Spotify account
state. The installer deliberately does not copy these. `.gitignore` prevents
future additions, but **does not remove already tracked files or their history**.
Keep the repository private while cleaning the history. Invalidate any exposed
sessions via the relevant account's device/session management. We have not
established whether any cookie in the upload is still valid.

Use GitHub's official sensitive-data-removal workflow:
https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository

Remove the entire Vesktop tree except `themes/`, all `config/spotify/`, and
qutebrowser's `qsettings/` from history. Do not push a history rewrite from a
stale clone or merge the old history back afterward. No history rewrite or
remote force-push is performed by this installer.

## Validation and credits

```sh
python3 -m unittest discover -s installer -p 'test_*.py' -v
```

Offline tests cover backup/install behaviour, portable paths and exclusions,
all seven presets through all configured templates, JSON parsing, executable
launchers and Hyprlock/background exports. Real Arch package installation,
Quickshell rendering and SDDM service execution need testing on an Arch machine;
the installer has not been run against the author's live desktop.

Pixie by xCaptaiN09: https://github.com/xCaptaiN09/pixie-sddm (modified with numpad).
Matugen: https://github.com/InioX/matugen.
Quickshell: https://quickshell.org/.
Dark Reader and the bundled theme assets retain their upstream licences.
No blanket licence is assigned to wallpapers or third-party assets.
