import QtQuick
Rectangle {
    id: chip
    property string text: ""
    property string iconName: ""
    property bool selected: false
    property bool compact: false
    property int textSize: 13
    signal clicked()
    signal rightClicked()
    signal scrolled(real delta)
    implicitWidth: contents.width + 26
    implicitHeight: compact ? 34 : 42
    radius: height / 2
    color: selected ? Theme.primary : (mouse.containsMouse ? Theme.high : Theme.container)
    border.width: selected ? 0 : 1
    border.color: Theme.outline
    opacity: enabled ? 1 : 0.45
    Behavior on color { ColorAnimation { duration: 180 } }
    Row {
        id: contents
        anchors.centerIn: parent
        spacing: chip.iconName && chip.text ? 7 : 0
        Icon {
            visible: chip.iconName !== ""
            width: visible ? 18 : 0; height: 18
            anchors.verticalCenter: parent.verticalCenter
            name: chip.iconName
            tint: chip.selected ? Theme.onPrimary : Theme.primary
        }
        Text {
            text: chip.text
            font.family: Theme.font
            font.pixelSize: chip.textSize
            color: chip.selected ? Theme.onPrimary : Theme.text
            textFormat: Text.PlainText
        }
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => event.button === Qt.RightButton ? chip.rightClicked() : chip.clicked()
        onWheel: event => chip.scrolled(event.angleDelta.y)
    }
}
