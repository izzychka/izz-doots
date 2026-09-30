import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Theme

// Simple nmcli-polling network indicator. Swap for Quickshell.Networking
// if your installed version has it (added recently); this version works
// anywhere nmcli is installed.
Text {
    id: root
    color: Colors.textOnSurface
    font.pixelSize: 13
    text: "..."
    elide: Text.ElideRight
    Layout.maximumWidth: 160

    Process {
        id: nmcli
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")
                const wifi = lines.find(l => l.startsWith("wifi:connected"))
                const eth = lines.find(l => l.startsWith("ethernet:connected"))
                if (eth) root.text = "LAN " + eth.split(":")[2]
                else if (wifi) root.text = "WiFi " + wifi.split(":")[2]
                else root.text = "Offline"
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: nmcli.running = true
    }
}
