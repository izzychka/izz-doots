import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Theme
import qs.modules.Bar as Bar

PanelWindow {
    id: bar

    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: 34
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "matushell-bar"
    exclusionMode: ExclusionMode.Auto // reserve screen space, like waybar

    Rectangle {
        anchors.fill: parent
        color: Colors.surface
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 16

        Bar.Workspaces {}

        Item { Layout.fillWidth: true }

        Bar.Clock {}

        Item { Layout.fillWidth: true }

        RowLayout {
            spacing: 12
            Bar.Network {}
            Bar.Volume {}
            Bar.Battery {}
            Bar.Actions {}
        }
    }
}
