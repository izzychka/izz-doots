import QtQuick
import qs.Theme

Text {
    id: clock
    color: Colors.textOnSurface
    font.pixelSize: 13
    font.bold: true
    text: Qt.formatDateTime(timer.now, "ddd d MMM  hh:mm")

    Timer {
        id: timer
        property date now: new Date()
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: now = new Date()
    }
}
