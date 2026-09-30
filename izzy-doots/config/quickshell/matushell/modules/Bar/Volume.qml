import QtQuick
import Quickshell.Services.Pipewire
import qs.Theme

Item {
    id: root
    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    readonly property PwNode sink: Pipewire.defaultAudioSink

    // Keep the sink's volume/mute state actually tracked by pipewire.
    PwObjectTracker { objects: [root.sink] }

    Text {
        id: label
        anchors.fill: parent
        color: Colors.textOnSurface
        font.pixelSize: 13
        text: {
            if (!root.sink || !root.sink.audio) return "--"
            const muted = root.sink.audio.muted
            const vol = Math.round(root.sink.audio.volume * 100)
            return (muted ? "Mute " : "Vol ") + vol + "%"
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.sink?.audio) root.sink.audio.muted = !root.sink.audio.muted
        }
        onWheel: wheel => {
            if (!root.sink?.audio) return
            const step = 0.05
            const delta = wheel.angleDelta.y > 0 ? step : -step
            root.sink.audio.volume = Math.max(0, Math.min(1, root.sink.audio.volume + delta))
        }
    }
}
