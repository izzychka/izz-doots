import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.Theme
import qs.services

PanelWindow {
    id: picker
    visible: false

    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "matushell-wallpaper-picker"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    ListModel { id: wallpaperModel }

    Connections {
        target: ShellState
        function onRequestWallpaperPicker() {
            picker.visible = true
            scanProc.running = true
        }
    }

    // Dismiss on click-outside / Escape.
    MouseArea {
        anchors.fill: parent
        onClicked: picker.visible = false
    }
    Item {
        anchors.fill: parent
        focus: picker.visible
        Keys.onEscapePressed: picker.visible = false
    }

    Process {
        id: scanProc
        command: ["find", Settings.wallpaperDir, "-maxdepth", "1", "-type", "f",
                  "(", "-iname", "*.jpg", "-o", "-iname", "*.jpeg",
                       "-o", "-iname", "*.png", "-o", "-iname", "*.webp", ")"]
        stdout: StdioCollector {
            onStreamFinished: {
                wallpaperModel.clear()
                text.trim().split("\n").filter(l => l.length > 0).forEach(p => {
                    wallpaperModel.append({ path: p })
                })
            }
        }
    }

    Process {
        id: applyProc
        command: [Quickshell.env("HOME") + "/.config/quickshell/matushell/scripts/apply-wallpaper.sh", ""]
    }

    function applyWallpaper(path) {
        applyProc.command = [Quickshell.env("HOME") + "/.config/quickshell/matushell/scripts/apply-wallpaper.sh", path]
        applyProc.running = true
        Settings.currentWallpaper = path
        picker.visible = false
    }

    // Stop the click-outside MouseArea from swallowing clicks meant for
    // the panel itself.
    Rectangle {
        id: panel
        anchors.centerIn: parent
        width: Math.min(parent.width - 120, 760)
        height: Math.min(parent.height - 160, 520)
        radius: 24
        color: Colors.surfaceContainer
        border.width: 1
        border.color: Colors.outline

        MouseArea { anchors.fill: parent; onClicked: {} /* eat the click */ }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14

            RowLayout {
                Text {
                    text: "Choose a wallpaper"
                    color: Colors.textOnSurface
                    font.pixelSize: 18
                    font.bold: true
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: wallpaperModel.count + " found in " + Settings.wallpaperDir
                    color: Colors.textOnSurfaceVariant
                    font.pixelSize: 12
                }
            }

            GridView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                cellWidth: 176
                cellHeight: 112
                model: wallpaperModel

                delegate: Item {
                    required property var modelData
                    width: 166
                    height: 102

                    Rectangle {
                        anchors.fill: parent
                        radius: 12
                        color: Colors.surfaceContainerHigh
                        border.width: modelData.path === Settings.currentWallpaper ? 3 : 0
                        border.color: Colors.primary

                        Image {
                            anchors.fill: parent
                            anchors.margins: 4
                            source: "file://" + modelData.path
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            smooth: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: picker.applyWallpaper(modelData.path)
                        }
                    }
                }

                // Shown if the wallpaper directory is empty / missing.
                Text {
                    visible: wallpaperModel.count === 0
                    anchors.centerIn: parent
                    color: Colors.textOnSurfaceVariant
                    text: "No images found.\nDrop some into " + Settings.wallpaperDir
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}
