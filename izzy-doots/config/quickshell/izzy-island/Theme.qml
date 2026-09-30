pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
Singleton {
    id: theme
    readonly property string font: {
        const families = Qt.fontFamilies();
        const preferred = ["Maple Mono", "Maple Mono NF", "Maple Mono NF CN", "Maple Mono Normal", "Maple Mono Normal NF"];
        for (const name of preferred) if (families.indexOf(name) !== -1) return name;
        for (const name of families) if (name.toLowerCase().startsWith("maple mono")) return name;
        console.warn("Maple Mono is not installed or visible to Qt; using monospace.");
        return "monospace";
    }
    property var palette: {
        try { return JSON.parse(colours.text()); } catch (e) { return {}; }
    }
    property color surface: palette.surface || "#151217"
    property color container: palette.surface_container || "#221e24"
    property color high: palette.surface_container_high || "#2d292e"
    property color primary: palette.primary || "#ddb9f7"
    property color onPrimary: palette.on_primary || "#402357"
    property color text: palette.on_surface || "#e8e0e8"
    property color muted: palette.on_surface_variant || "#cdc3ce"
    property color outline: palette.outline_variant || "#4b454d"
    property color error: palette.error || "#ffb4ab"
    FileView {
        id: colours
        path: Quickshell.env("HOME") + "/.config/izzy-island/colors.json"
        watchChanges: true
        blockLoading: true
        onFileChanged: reload()
    }
}
