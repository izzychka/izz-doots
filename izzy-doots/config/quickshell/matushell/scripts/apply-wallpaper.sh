#!/usr/bin/env bash
# Sets the wallpaper with awww and regenerates matugen colors from it.
# Called by the WallpaperPicker window; safe to call by hand too:
#   ./apply-wallpaper.sh ~/Pictures/Wallpapers/something.jpg
set -euo pipefail

if [ $# -lt 1 ]; then
    echo "usage: apply-wallpaper.sh <image>" >&2
    exit 1
fi

WALLPAPER="$1"

if ! pgrep -x awww-daemon > /dev/null 2>&1; then
    awww-daemon &
    sleep 0.3
fi

awww img "$WALLPAPER" --transition-type wipe --transition-fps 60
matugen image "$WALLPAPER"
