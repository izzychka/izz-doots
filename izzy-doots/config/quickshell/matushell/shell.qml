//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.Bar
import qs.modules.WallpaperSwitcher
import qs.services

ShellRoot {
    id: root

    // Only one of these is ever active at a time. LazyLoader means the
    // inactive layout isn't even instantiated, so toggling modes is cheap.
    LazyLoader {
        active: Settings.mode === "bar"
        component: Bar {}
    }

    LazyLoader {
        active: Settings.mode === "island"
        component: Island {}
    }

    WallpaperPicker {}

    // Drive matushell from the outside, e.g. a Hyprland keybind:
    //   bind = $mainMod, W, exec, qs -c matushell ipc call shell openWallpaperPicker
    //   bind = $mainMod, B, exec, qs -c matushell ipc call shell toggleMode
    IpcHandler {
        target: "shell"

        function toggleMode(): void {
            Settings.mode = Settings.mode === "bar" ? "island" : "bar"
        }

        function setMode(mode: string): void {
            if (mode === "bar" || mode === "island") Settings.mode = mode
        }

        function openWallpaperPicker(): void {
            ShellState.requestWallpaperPicker()
        }
    }
}
