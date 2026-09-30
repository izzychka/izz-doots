import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Theme
import qs.modules.Bar as Bar

PanelWindow {
    id: island

    anchors { top: true }
    margins.top: 8

    property bool expanded: false
    readonly property int collapsedWidth: 210
    // Wide enough for clock + divider + workspaces + network name +
    // volume + battery + the two action buttons without clipping.
    // Bump this further if you add more widgets to the expanded row.
    readonly property int expandedWidth: 720

    // The window itself stays a fixed size — only the visible pill
    // inside it resizes. Animating the real Wayland surface every frame
    // is what caused the glitchy/finicky resizing before.
    implicitWidth: expandedWidth
    implicitHeight: 34
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "matushell-island"
    exclusionMode: ExclusionMode.Ignore // floats over content, doesn't reserve space

    // Only the pill itself is clickable/tappable. Everywhere else in
    // this (otherwise full-width) transparent window passes clicks
    // straight through to whatever app is underneath — this is what
    // stops it "covering apps".
    mask: Region { item: pill }

    Rectangle {
        id: pill
        anchors.centerIn: parent
        width: island.expanded ? island.expandedWidth : island.collapsedWidth
        height: 34
        radius: height / 2
        color: Colors.surfaceContainer
        border.width: 1
        border.color: Colors.outline
        clip: true

        Behavior on width {
            NumberAnimation { duration: 180; easing.type: Easing.OutExpo }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            // Tap-to-toggle, not hover-to-expand: hover events don't
            // fire from touch input, so a touchscreen would never be
            // able to collapse an island that relied on hover-exit.
            // Click/tap works identically on mouse and touch.
            onClicked: island.expanded = !island.expanded
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            spacing: 12
            clip: true

            Bar.Clock {}

            RowLayout {
                spacing: 12
                opacity: island.expanded ? 1 : 0
                visible: opacity > 0.01

                Behavior on opacity { NumberAnimation { duration: 140 } }

                Rectangle { width: 1; height: 16; color: Colors.outline }

                Bar.Workspaces {}

                Item { Layout.fillWidth: true }

                Bar.Network {}
                Bar.Volume {}
                Bar.Battery {}
                Bar.Actions {}
            }
        }
    }
}
