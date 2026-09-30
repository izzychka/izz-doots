import QtQuick
import QtQuick.Layouts
import qs.Theme
import qs.services

RowLayout {
    spacing: 8

    Rectangle {
        implicitWidth: wallText.implicitWidth + 14
        implicitHeight: 26
        radius: 8
        color: wallArea.containsMouse ? Colors.surfaceContainerHigh : "transparent"

        Text {
            id: wallText
            anchors.centerIn: parent
            text: "\uf03e" // nf-fa-picture_o
            font.family: "Symbols Nerd Font"
            font.pixelSize: 14
            color: Colors.textOnSurface
        }

        MouseArea {
            id: wallArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: ShellState.requestWallpaperPicker()
        }
    }

    Rectangle {
        implicitWidth: 26
        implicitHeight: 26
        radius: 8
        color: modeArea.containsMouse ? Colors.surfaceContainerHigh : "transparent"

        Text {
            anchors.centerIn: parent
            text: Settings.mode === "bar" ? "\u{25CF}" : "\u{25AC}" // dot vs bar glyph
            font.pixelSize: 14
            color: Colors.textOnSurface
        }

        MouseArea {
            id: modeArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Settings.mode = Settings.mode === "bar" ? "island" : "bar"
        }
    }
}
