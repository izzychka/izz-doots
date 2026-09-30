# matushell

A QuickShell-based replacement for waybar: matugen-driven theming, two
switchable layouts (full **Bar** / floating **Island**), and a built-in
wallpaper picker that regenerates the palette on every change.

```
matushell/
├── shell.qml                     entry point — picks Bar or Island
├── modules/
│   ├── Bar/
│   │   ├── Bar.qml               full-width top bar (waybar-style)
│   │   ├── Island.qml            centered pill, expands on hover
│   │   ├── Workspaces.qml        Hyprland workspace dots
│   │   ├── Clock.qml
│   │   ├── Network.qml           nmcli-polling status
│   │   ├── Volume.qml            Pipewire volume + scroll/click
│   │   ├── Battery.qml           UPower
│   │   └── Actions.qml           wallpaper picker + mode-toggle buttons
│   └── WallpaperSwitcher/
│       └── WallpaperPicker.qml   grid overlay, calls apply-wallpaper.sh
├── Theme/
│   ├── Colors.qml                singleton, watches data/colors.json live
│   └── matugen-templates/
│       └── colors.json.template  matugen template -> data/colors.json
├── services/
│   ├── Settings.qml              persists mode + current wallpaper
│   └── ShellState.qml            signal bus (open picker, etc.)
├── scripts/
│   └── apply-wallpaper.sh        awww img + matugen image, in one call
├── data/                         generated at runtime (settings/colors json)
└── matugen-config-snippet.toml   merge into ~/.config/matugen/config.toml
```

## Requirements

- **Hyprland**
- **quickshell** (`qs`) — Qt6/QML shell framework
- **matugen** — Material You color generation
- **awww** (the project formerly known as `swww`; the `swww` binary name
  still works as a compat symlink) — wallpaper daemon

On Arch:
```bash
sudo pacman -S quickshell matugen awww
```
If `awww` isn't packaged yet on your distro, grab it from
https://codeberg.org/LGFae/awww (installs `awww`/`awww-daemon` plus
`swww`/`swww-daemon` compat symlinks).

## Install

```bash
mkdir -p ~/.config/quickshell
cp -r matushell ~/.config/quickshell/matushell
```

Merge `matugen-config-snippet.toml` into `~/.config/matugen/config.toml`
(create it if it doesn't exist). This makes `matugen image <wallpaper>`
both set the wallpaper via `awww` *and* regenerate matushell's colors.

Generate an initial palette so `Colors.qml` has something to load:
```bash
awww-daemon &
matugen image ~/Pictures/Wallpapers/whatever.jpg
```

Add to `hyprland.conf`:
```
exec-once = qs -c matushell

# optional keybinds
bind = $mainMod, W, exec, qs -c matushell ipc call shell openWallpaperPicker
bind = $mainMod, B, exec, qs -c matushell ipc call shell toggleMode
```

(`qs -c matushell` looks for the config under `~/.config/quickshell/matushell`;
alternatively run `qs -p ~/.config/quickshell/matushell/shell.qml`.)

## Using it

- **Wallpaper button** (picture-frame icon) in the bar/island opens a
  thumbnail grid of everything in `~/Pictures/Wallpapers` (change the
  path in `services/Settings.qml` → `wallpaperDir`, or edit
  `data/settings.json` after first run). Click one to set it and
  re-theme instantly.
- **Mode button** (dot/bar icon) flips between the full bar and the
  dynamic island live — no restart needed, `Settings.mode` is persisted
  to `data/settings.json`.
- Hover the island to expand it and reveal workspaces/network/volume/
  battery; it collapses back to just the clock on mouse-out.

## Extending it

- **More widgets**: drop a new `.qml` into `modules/Bar/`, import it as
  `Bar.Foo` in `Bar.qml` / `Island.qml`.
- **More theme targets**: add another `[templates.*]` block to
  `matugen/config.toml` pointing at e.g. a GTK or kitty template — same
  trick matugen users apply for any other app.
- **Other compositors**: `Workspaces.qml` is the only Hyprland-specific
  piece; swap `Quickshell.Hyprland` for `Quickshell.I3` (Sway) or drive
  it over a `Socket`/`Process` for niri's IPC.

## A note on API stability

QuickShell is under active development and its QML API has shifted
between versions (service module names, `WlrLayershell` properties,
`FileView` signals). This scaffold targets the `0.2`/`0.3` API as
documented at https://quickshell.org/docs — if something doesn't load,
check `qs.qml` error output against the docs for your installed version
first; it's usually a renamed property rather than a logic bug.
