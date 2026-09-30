import QtQuick
import Quickshell.Services.UPower
import qs.Theme

Text {
    id: root
    visible: UPower.displayDevice?.isLaptopBattery ?? false
    color: (UPower.displayDevice?.percentage ?? 1) < 0.15 ? Colors.error : Colors.textOnSurface
    font.pixelSize: 13

    text: {
        const d = UPower.displayDevice
        if (!d || !d.ready) return ""
        const pct = Math.round(d.percentage * 100)
        const charging = d.state === UPowerDeviceState.Charging
        return (charging ? "Chg " : "Bat ") + pct + "%"
    }
}
