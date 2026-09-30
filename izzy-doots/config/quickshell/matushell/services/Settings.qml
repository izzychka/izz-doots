pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Persisted shell state: which layout mode is active, and the current
// wallpaper. Lives at data/settings.json so it survives restarts.
Singleton {
    id: root

    property string mode: "bar"          // "bar" | "island"
    property string wallpaperDir: Quickshell.env("HOME") + "/Pictures/Wallpapers"
    property string currentWallpaper: ""

    property bool _loaded: false

    FileView {
        id: settingsFile
        path: Quickshell.env("HOME") + "/.config/quickshell/matushell/data/settings.json"
        watchChanges: true
        printErrors: false

        onLoaded: {
            try {
                const data = JSON.parse(text())
                root.mode = data.mode ?? root.mode
                root.wallpaperDir = data.wallpaperDir ?? root.wallpaperDir
                root.currentWallpaper = data.currentWallpaper ?? root.currentWallpaper
            } catch (e) {
                console.log("Settings: could not parse settings.json, using defaults")
            }
            root._loaded = true
        }

        onLoadFailed: error => {
            // First run: file doesn't exist yet, write defaults.
            root._loaded = true
            root.save()
        }
    }

    function save() {
        if (!root._loaded) return
        settingsFile.setText(JSON.stringify({
            mode: root.mode,
            wallpaperDir: root.wallpaperDir,
            currentWallpaper: root.currentWallpaper
        }, null, 2))
    }

    onModeChanged: save()
    onWallpaperDirChanged: save()
    onCurrentWallpaperChanged: save()
}
