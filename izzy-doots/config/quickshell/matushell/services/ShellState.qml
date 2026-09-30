pragma Singleton

import QtQuick
import Quickshell

// A tiny signal bus so widgets anywhere in the tree (bar, island, tray
// buttons) can trigger things owned elsewhere (the wallpaper picker
// window, a mode switch) without passing references around by hand.
Singleton {
    signal requestWallpaperPicker()
    signal requestModeToggle()
}
