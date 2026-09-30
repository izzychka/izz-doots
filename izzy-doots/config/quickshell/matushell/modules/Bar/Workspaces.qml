import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.Theme

RowLayout {
    spacing: 6

    Repeater {
        model: Hyprland.workspaces

        delegate: Rectangle {
            id: dot
            required property var modelData

            width: modelData.active ? 22 : 10
            height: 10
            radius: 5
            color: modelData.active ? Colors.primary : Colors.outline

            Behavior on width { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: 200 } }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -3 // bigger hit target than the dot itself
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + dot.modelData.id)
            }
        }
    }
}
