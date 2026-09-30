import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Mpris

ShellRoot {
    id: shared
    property var stats: ({cpu: 0, memory: 0, battery: -1, volume: -1, muted: false, charging: false, plugged: false, network: "…"})
    property bool sampled: false
    property string notice: ""
    property string feedback: "Choose a wallpaper to recolour your desktop."
    property var wallpapers: []
    property var availableThemes: []
    property string themeMode: {
        const value = themeState.text().trim();
        return value || "wallpaper";
    }
    FileView {
        id: themeState
        path: Quickshell.env("HOME") + "/.local/state/izzy-themes/mode"
        watchChanges: true
        blockLoading: true
        onFileChanged: reload()
    }
    property var player: {
        let players = Mpris.players.values;
        return players.find(p => p.isPlaying) || players[0] || null;
    }
    property var spectrum: [0,0,0,0,0,0,0,0]
    Process {
        id: cava
        command: ["cava", "-p", Quickshell.shellPath("cava.conf")]
        running: !!shared.player && shared.player.isPlaying && bars.instances.some(bar => bar.mediaHeader && !bar.tucked)
        onRunningChanged: { if (!running) shared.spectrum = [0,0,0,0,0,0,0,0]; }
        stdout: SplitParser {
            onRead: data => {
                const values = data.trim().split(";").filter(v => v !== "").map(Number);
                if (values.length === 8 && values.every(v => Number.isFinite(v)))
                    shared.spectrum = values.map(v => Math.max(0, Math.min(100, v)));
            }
        }
    }
    property string volumeText: stats.volume < 0 ? "Audio —" : stats.muted ? "Muted" : "Vol " + stats.volume + "%"
    property string batteryText: stats.battery < 0 ? "" : (stats.charging ? "ϟ " : stats.plugged ? "↯ " : "") + stats.battery + "%"
    property string helper: Quickshell.shellPath("backend.py")
    function toast(text) { notice = text; toastTimer.restart(); }
    function command(args) { Quickshell.execDetached(args); }
    function setVolume(delta) {
        command(["wpctl", "set-volume", "-l", "1.0", "@DEFAULT_AUDIO_SINK@", delta]);
    }
    function receive(data) {
        if (sampled) {
            if (data.volume !== stats.volume || data.muted !== stats.muted)
                toast(data.muted ? "Sound muted" : "Volume  ·  " + data.volume + "%");
            else if (data.plugged !== stats.plugged || data.charging !== stats.charging)
                toast((data.charging ? "Charging" : data.plugged ? "Plugged in" : "On battery") + "  ·  " + data.battery + "%");
        }
        stats = data;
        sampled = true;
    }
    Timer { id: toastTimer; interval: 3200; onTriggered: shared.notice = "" }
    SystemClock { id: clock; precision: SystemClock.Minutes }
    Connections {
        target: shared.player
        function onPostTrackChanged() {
            if (shared.player && shared.player.trackTitle) shared.toast(shared.player.trackTitle);
        }
    }
    Process {
        id: statusProcess
        command: ["python3", shared.helper, "status"]
        running: true
        stdout: SplitParser { onRead: data => { try { shared.receive(JSON.parse(data)); } catch (e) {} } }
    }
    Process {
        id: wallList
        command: ["python3", shared.helper, "list"]
        stdout: StdioCollector {
            onStreamFinished: { try { shared.wallpapers = JSON.parse(text); } catch (e) { shared.feedback = "Could not read wallpaper folder."; } }
        }
    }
    Process {
        id: applyWallpaper
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let response = JSON.parse(text);
                    shared.feedback = response.message;
                    shared.toast(response.ok ? "New wallpaper · new colours" : "Wallpaper update failed");
                } catch (e) { shared.feedback = "Wallpaper helper stopped unexpectedly."; }
            }
        }
    }
    Process {
        id: themeChange
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const response = JSON.parse(text);
                    shared.feedback = response.message;
                    shared.toast(response.ok ? "Theme changed" : response.message);
                } catch (e) { shared.toast("Could not change theme"); }
            }
        }
    }
    Process {
        id: themeList
        command: ["python3", shared.helper, "themes"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { shared.availableThemes = JSON.parse(text); }
                catch (e) { shared.availableThemes = []; }
            }
        }
    }
    Variants {
        id: bars
        model: Quickshell.screens
        Scope {
            id: root

            required property var modelData
            objectName: "monitor-" + modelData.name
            readonly property var stats: shared.stats
            readonly property var player: shared.player
            readonly property var spectrum: shared.spectrum
            readonly property string notice: shared.notice
            readonly property string feedback: shared.feedback
            readonly property var wallpapers: shared.wallpapers
            readonly property string helper: shared.helper
            readonly property bool mediaHeader: !!player && drawer === "" && notice === ""
            function command(args) { shared.command(args); }
            function setVolume(delta) { shared.setVolume(delta); }
    property bool islandOnly: false
    property bool peeking: false
    readonly property bool tucked: islandOnly && !peeking && drawer === "" && notice === ""
    function toggleMode() {
        islandOnly = !islandOnly;
        peeking = true;
        hideTimer.restart();
    }
    onDrawerChanged: { if (drawer === "") hideTimer.restart(); }
    Timer {
        id: hideTimer
        interval: 650
        onTriggered: { if (!islandHover.hovered && !modeMouse.containsMouse && root.drawer === "") root.peeking = false; }
    }
    property string drawer: ""
    function selectTheme(choice) {
        if (themeChange.running) return;
        shared.feedback = "Applying " + choice + "…";
        themeChange.command = ["python3", root.helper, "theme", choice];
        themeChange.running = true;
    }
    function toggle(name) {
        drawer = drawer === name ? "" : name;
        if (drawer === "walls" && !wallList.running) wallList.running = true;
        if (drawer === "themes" && !themeList.running) themeList.running = true;
    }
    PanelWindow {
        id: panel
        screen: root.modelData
        readonly property bool stacked: width < 1100
        readonly property int barHeight: stacked ? 86 : 46
        readonly property real drawerWidth: Math.min(560, width - 24)
        readonly property real islandTarget: root.drawer !== "" ? drawerWidth : Math.min(width - 24, root.player ? 420 : root.notice !== "" ? 350 : 260)
        readonly property real sideBudget: stacked ? (width - 36) / 2 : Math.max(0, (width - islandTarget) / 2 - 24)
        readonly property real islandTop: root.tucked ? 0 : !root.islandOnly && stacked ? 45 : 5
        anchors { top: true; left: true; right: true }
        // Keep the Wayland surface steady while its masked contents animate.
        implicitHeight: Math.min(panel.screen.height, Math.max(297, Math.min(460, panel.screen.height - 120) + 51))
        exclusiveZone: root.islandOnly ? 0 : panel.barHeight
        color: "transparent"
        focusable: root.drawer !== ""
        // Only the bar and expanded island take pointer input; the rest passes through.
        mask: Region {
            width: panel.width; height: root.islandOnly ? 0 : panel.barHeight
            Region { x: island.x; y: island.y; width: island.width; height: island.height; radius: root.tucked ? 4 : 22 }
        }
        Item {
            anchors.fill: parent
            focus: root.drawer !== ""
            Keys.onEscapePressed: root.drawer = ""
        }
        Row {
            id: leftGroup
            visible: !root.islandOnly
            x: 12; y: 5; spacing: 6
            Rectangle {
                width: 98; height: 34; radius: height / 2
                color: Theme.container; border.width: 1; border.color: Theme.outline
                Row {
                    anchors.centerIn: parent; spacing: 7
                    Icon { name: "clock"; anchors.verticalCenter: parent.verticalCenter }
                    Text {
                        text: Qt.formatDateTime(clock.date, "HH:mm")
                        color: Theme.text; font.family: Theme.font; font.pixelSize: 13
                    }
                }
            }
            Flickable {
                width: Math.max(0, Math.min(workspaceRow.width, panel.sideBudget - 104))
                height: 34; contentWidth: workspaceRow.width; contentHeight: 34
                clip: true; flickableDirection: Flickable.HorizontalFlick
                Row {
                    id: workspaceRow; spacing: 4
                Repeater {
                    model: Hyprland.workspaces
                    delegate: Chip { compact: true;
                        required property var modelData
                        visible: !modelData.name.startsWith("special:") && !!modelData.monitor && modelData.monitor.name === root.modelData.name
                        text: modelData.name
                        selected: modelData.active
                        width: selected ? 42 : 34
                        Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                        onClicked: modelData.activate()
                    }
                }
            }
            }
            Text {
                visible: panel.sideBudget - 116 - workspaceRow.width >= 90 && root.drawer === ""
                width: Math.max(0, Math.min(150, panel.sideBudget - 116 - workspaceRow.width)); height: 34
                verticalAlignment: Text.AlignVCenter
                text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : "izzychka"
                elide: Text.ElideRight
                color: Theme.muted; font.family: Theme.font; font.pixelSize: 12
                textFormat: Text.PlainText
            }
        }
        Row {
            id: rightGroup
            visible: !root.islandOnly
            anchors.right: parent.right; anchors.rightMargin: 12
            y: 5; spacing: 6
            Chip { compact: true;
                visible: panel.sideBudget >= 420 && root.drawer === ""
                iconName: "cpu"; text: root.stats.cpu + "%"
                onClicked: root.toggle("status")
            }
            Chip { compact: true;
                visible: panel.sideBudget >= 510 && root.drawer === ""
                iconName: "memory"; text: root.stats.memory + "%"
                onClicked: root.toggle("status")
            }
            Chip { compact: true;
                iconName: root.stats.muted ? "muted" : "volume"; text: panel.sideBudget < 340 ? "" : root.stats.volume < 0 ? "—" : root.stats.muted ? "" : root.stats.volume + "%"
                onClicked: root.command(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"])
                onRightClicked: root.command(["pavucontrol"])
                onScrolled: delta => root.setVolume(delta > 0 ? "5%+" : "5%-")
            }
            Chip { compact: true;
                visible: root.stats.battery >= 0 && panel.sideBudget >= 340
                iconName: root.stats.charging ? "charging" : root.stats.plugged ? "plug" : "battery"; text: root.stats.battery + "%"
                onClicked: root.toggle("status")
            }
            Chip { compact: true; iconName: "palette"; onClicked: root.toggle("themes") }
            Chip { compact: true; iconName: "controls"; onClicked: root.toggle("status") }
            Chip { compact: true; visible: panel.sideBudget >= 195; iconName: "network"; onClicked: root.command(["kitty", "nmtui"]) }
            Chip { compact: true; visible: panel.sideBudget >= 260; iconName: "bluetooth"; onClicked: root.command(["blueman-manager"]) }

        }
        Rectangle {
            id: island
            objectName: "island"
            anchors.horizontalCenter: parent.horizontalCenter
            y: panel.islandTop
            width: root.tucked ? 76 : panel.islandTarget
            height: root.tucked ? 8 : root.drawer === "walls" ? Math.min(460, panel.screen.height - 120) : root.drawer === "media" ? 284 : root.drawer === "themes" ? 277 : root.drawer === "status" ? 286 : 35
            radius: root.tucked ? 4 : 22
            color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.97)
            border.width: 1; border.color: root.drawer !== "" ? Theme.primary : Theme.outline
            clip: true
            Behavior on width { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
            Behavior on height { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
            Behavior on y { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
            Behavior on radius { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
            HoverHandler {
                id: islandHover
                onHoveredChanged: {
                    if (hovered) { root.peeking = true; hideTimer.stop(); }
                    else hideTimer.restart();
                }
            }
            Rectangle {
                visible: root.tucked
                anchors.centerIn: parent
                width: 30; height: 2; radius: 1; color: Theme.primary
            }
            MouseArea {
                anchors.fill: parent; visible: root.tucked
                onClicked: { root.peeking = true; root.toggle("media"); }
            }
            Rectangle {
                visible: !root.tucked && !root.mediaHeader
                x: 13; y: 14; width: 7; height: 7; radius: 4
                color: Theme.primary
            }
            Text {
                visible: !root.tucked
                x: root.mediaHeader ? 58 : 28; y: 0; width: Math.max(0, parent.width - (root.mediaHeader ? 238 : 116)); height: 35
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.family: Theme.font; font.pixelSize: 13; font.bold: true
                color: Theme.text; elide: Text.ElideRight; textFormat: Text.PlainText
                text: root.drawer === "walls" ? "WALLPAPERS" : root.drawer === "themes" ? "THEMES" : root.drawer === "status" ? "CONTROL ROOM" : root.drawer === "media" ? "NOW PLAYING" : root.notice !== "" ? root.notice : root.player ? (root.player.trackTitle || root.player.identity) : Qt.formatDateTime(clock.date, "ddd  ·  HH:mm")
            }
            MouseArea { visible: !root.tucked; x: 0; y: 0; width: parent.width - 86; height: 35; onClicked: root.toggle("media") }
            Row {
                visible: root.mediaHeader && !root.tucked
                x: 14; y: 7; height: 21; spacing: 2
                Repeater {
                    model: 8
                    Rectangle {
                        required property int index
                        width: 3; height: Math.max(2, root.spectrum[index] * 0.21)
                        anchors.verticalCenter: parent.verticalCenter
                        radius: 1.5; color: Theme.primary
                        Behavior on height { NumberAnimation { duration: 65; easing.type: Easing.OutQuad } }
                    }
                }
            }
            Row {
                visible: root.mediaHeader && !root.tucked
                anchors.right: parent.right; anchors.rightMargin: 82
                height: 35
                Repeater {
                    model: ["previous", "play", "next"]
                    Rectangle {
                        required property string modelData
                        width: 32; height: 35; radius: 12
                        enabled: !!root.player && (modelData === "previous" ? root.player.canGoPrevious : modelData === "next" ? root.player.canGoNext : root.player.canTogglePlaying)
                        opacity: enabled ? 1 : 0.35
                        color: transportMouse.containsMouse ? Theme.high : "transparent"
                        Icon { anchors.centerIn: parent; width: 16; height: 16; name: modelData === "play" && root.player && root.player.isPlaying ? "pause" : modelData }
                        MouseArea {
                            id: transportMouse
                            anchors.fill: parent; hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (modelData === "previous") root.player.previous();
                                else if (modelData === "next") root.player.next();
                                else root.player.togglePlaying();
                            }
                        }
                    }
                }
            }
            Icon {
                anchors.right: parent.right; anchors.rightMargin: 11; y: 8
                visible: !root.tucked; width: 18; height: 18
                name: root.drawer !== "" ? "close" : "down"
            }
            MouseArea {
                visible: !root.tucked
                anchors.right: parent.right; width: 40; height: 35
                onClicked: root.drawer !== "" ? root.drawer = "" : root.toggle("media")
            }
            Rectangle {
                id: modeButton
                objectName: "modeButton"
                visible: !root.tucked
                anchors.right: parent.right; anchors.rightMargin: 40
                z: 20
                y: 0; width: 40; height: 35; radius: 10
                color: root.islandOnly ? Theme.primary : modeMouse.containsMouse ? Theme.high : "transparent"
                Icon {
                    anchors.centerIn: parent
                    name: root.islandOnly ? "restore" : "island"
                    tint: root.islandOnly ? Theme.onPrimary : Theme.primary
                }
                MouseArea {
                    id: modeMouse; anchors.fill: parent; hoverEnabled: true
                    onEntered: { root.peeking = true; hideTimer.stop(); }
                    onExited: hideTimer.restart()
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.toggleMode()
                }
            }
            ColumnLayout {
                x: 20; y: 44; width: panel.drawerWidth - 40; spacing: 12
                visible: root.drawer === "media"
                RowLayout {
                    spacing: 16
                    Rectangle {
                        width: 90; height: 90; radius: 16; color: Theme.high; clip: true
                        Icon { anchors.centerIn: parent; name: "music"; width: 34; height: 34 }
                        Image {
                            anchors.fill: parent; source: root.player ? root.player.trackArtUrl : ""
                            fillMode: Image.PreserveAspectCrop; asynchronous: true; sourceSize.width: 180; sourceSize.height: 180
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Text {
                            Layout.fillWidth: true; text: root.player ? root.player.trackTitle || "Untitled track" : "A little quiet right now"
                            color: Theme.text; font.family: Theme.font; font.pixelSize: 17; elide: Text.ElideRight; textFormat: Text.PlainText
                        }
                        Text {
                            Layout.fillWidth: true; text: root.player ? root.player.trackArtist || root.player.identity : "Play something in Spotify or Firefox."
                            color: Theme.muted; font.family: Theme.font; font.pixelSize: 12; elide: Text.ElideRight; textFormat: Text.PlainText
                        }
                        Text { text: Qt.formatDateTime(clock.date, "dddd, d MMMM  ·  HH:mm"); color: Theme.primary; font.pixelSize: 12; font.family: Theme.font }
                    }
                }
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter; spacing: 10
                    Chip { iconName: "previous"; enabled: !!root.player && root.player.canGoPrevious; onClicked: root.player.previous() }
                    Chip { iconName: root.player && root.player.isPlaying ? "pause" : "play"; selected: true; enabled: !!root.player && root.player.canTogglePlaying; onClicked: root.player.togglePlaying() }
                    Chip { iconName: "next"; enabled: !!root.player && root.player.canGoNext; onClicked: root.player.next() }
                }
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Chip { iconName: "wallpaper"; text: "Wallpapers"; onClicked: root.toggle("walls") }
                    Chip { iconName: "palette"; text: "Themes"; onClicked: root.toggle("themes") }
                    Chip { iconName: "controls"; text: "Controls"; onClicked: root.toggle("status") }
                }
            }
            ColumnLayout {
                x: 20; y: 45; width: panel.drawerWidth - 40; spacing: 7
                visible: root.drawer === "themes"
                Text {
                    text: "Choose a palette for your whole desktop"
                    font.family: Theme.font; font.pixelSize: 12; color: Theme.muted
                }
                ListView {
                    id: themesList
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(165, (shared.availableThemes.length + 1) * 55)
                    clip: true; spacing: 4
                    ScrollBar.vertical: ScrollBar {}
                    model: [{key: "wallpaper", label: "Matugen", detail: "Colours from your last wallpaper", swatch: Theme.primary}].concat(shared.availableThemes)
                    delegate: Rectangle {
                        required property var modelData
                        width: themesList.width; height: 51; radius: 14
                        color: themeMouse.containsMouse || shared.themeMode === modelData.key ? Theme.high : Theme.container
                        border.width: 1
                        border.color: shared.themeMode === modelData.key ? Theme.primary : Theme.outline
                        Rectangle {
                            x: 13; anchors.verticalCenter: parent.verticalCenter
                            width: 20; height: 20; radius: 10; color: modelData.swatch
                        }
                        Column {
                            x: 45; width: Math.max(0, parent.width - 90)
                            anchors.verticalCenter: parent.verticalCenter; spacing: 2
                            Text { width: parent.width; text: modelData.label; color: Theme.text; font.family: Theme.font; font.pixelSize: 13; elide: Text.ElideRight; textFormat: Text.PlainText }
                            Text { width: parent.width; text: modelData.detail; color: Theme.muted; font.family: Theme.font; font.pixelSize: 10; elide: Text.ElideRight; textFormat: Text.PlainText }
                        }
                        Text {
                            anchors.right: parent.right; anchors.rightMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            text: "✓"; color: Theme.primary; font.family: Theme.font
                            visible: shared.themeMode === modelData.key
                        }
                        MouseArea {
                            id: themeMouse; anchors.fill: parent; hoverEnabled: true
                            enabled: !themeChange.running
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.selectTheme(modelData.key)
                        }
                    }
                }
                Text {
                    text: "Matugen uses your last selected wallpaper. Choose one in Wallpapers first."
                    font.family: Theme.font; font.pixelSize: 10; color: Theme.muted
                    wrapMode: Text.Wrap; Layout.fillWidth: true
                }
                Text {
                    text: root.feedback; visible: themeChange.running || root.feedback.indexOf("Theme") !== -1
                    font.family: Theme.font; font.pixelSize: 10; color: Theme.primary
                    wrapMode: Text.Wrap; Layout.fillWidth: true
                }
            }
            ColumnLayout {
                x: 20; y: 44; width: panel.drawerWidth - 40; height: Math.min(460, panel.screen.height - 120) - 64
                visible: root.drawer === "walls"; spacing: 10
                RowLayout {
                    Text { Layout.fillWidth: true; text: "Your collection  ·  " + root.wallpapers.length; color: Theme.muted; font.family: Theme.font; font.pixelSize: 12 }
                    Chip { iconName: "refresh"; text: "Refresh"; implicitHeight: 34; onClicked: { if (!wallList.running) wallList.running = true; } }
                }
                GridView {
                    id: gallery
                    Layout.fillWidth: true; Layout.fillHeight: true
                    clip: true; cellWidth: width / Math.max(1, Math.floor(width / 155)); cellHeight: 117
                    model: root.wallpapers
                    ScrollBar.vertical: ScrollBar {}
                    delegate: Item {
                        required property var modelData
                        width: gallery.cellWidth; height: gallery.cellHeight
                        Rectangle {
                            anchors.fill: parent; anchors.margins: 4; radius: 12; color: Theme.high; clip: true
                            Image {
                                anchors { left: parent.left; right: parent.right; top: parent.top }
                                id: thumbnail
                                height: 78; source: modelData.url; fillMode: Image.PreserveAspectCrop
                                asynchronous: true; sourceSize.width: 320; sourceSize.height: 180
                            }
                            Text {
                                visible: thumbnail.status === Image.Error
                                x: 8; y: 30; width: parent.width - 16
                                text: "Preview unavailable"; wrapMode: Text.Wrap
                                color: Theme.muted; font.family: Theme.font; font.pixelSize: 11
                            }
                            Text {
                                x: 8; y: 83; width: parent.width - 16
                                text: modelData.name; textFormat: Text.PlainText; elide: Text.ElideRight
                                color: Theme.text; font.family: Theme.font; font.pixelSize: 11
                            }
                            MouseArea {
                                anchors.fill: parent; enabled: !applyWallpaper.running
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    shared.feedback = "Applying " + modelData.name + "…";
                                    applyWallpaper.command = ["python3", root.helper, "apply", modelData.path];
                                    applyWallpaper.running = true;
                                }
                            }
                        }
                    }
                    Text {
                        anchors.centerIn: parent; visible: root.wallpapers.length === 0
                        text: "Add images to ~/Pictures/wallpapers/"; color: Theme.muted; font.family: Theme.font; font.pixelSize: 12
                    }
                }
                Text {
                    Layout.fillWidth: true; text: root.feedback; wrapMode: Text.Wrap; textFormat: Text.PlainText
                    color: Theme.primary; font.family: Theme.font; font.pixelSize: 11
                }
            }
            ColumnLayout {
                x: 24; y: 44; width: panel.drawerWidth - 48; spacing: 14
                visible: root.drawer === "status"
                Text {
                    text: "CPU " + root.stats.cpu + "%   ·   RAM " + root.stats.memory + "%   ·   " + root.stats.network
                    color: Theme.muted; font.family: Theme.font; font.pixelSize: 12
                }
                Text {
                    text: root.stats.battery < 0 ? "No battery reported" : "Battery " + root.stats.battery + "%  ·  " + (root.stats.charging ? "Charging" : root.stats.plugged ? "Plugged in" : "On battery")
                    color: Theme.text; font.family: Theme.font; font.pixelSize: 14
                }
                RowLayout {
                    Chip { iconName: "minus"; onClicked: root.setVolume("5%-") }
                    Chip { iconName: root.stats.muted ? "muted" : "volume"; text: root.stats.volume < 0 ? "—" : root.stats.muted ? "" : root.stats.volume + "%"; onClicked: root.command(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]) }
                    Chip { iconName: "plus"; onClicked: root.setVolume("5%+") }
                    Chip { iconName: "controls"; text: "Mixer"; onClicked: root.command(["pavucontrol"]) }
                }
                RowLayout {
                    Chip { iconName: "bluetooth"; text: "Bluetooth"; onClicked: root.command(["blueman-manager"]) }
                    Chip { iconName: "network"; text: "Network"; onClicked: root.command(["kitty", "nmtui"]) }
                    Chip { iconName: "wallpaper"; text: "Wallpapers"; onClicked: root.toggle("walls") }
                    Chip { iconName: "palette"; text: "Themes"; onClicked: root.toggle("themes") }
                }
                Text { text: Qt.formatDateTime(clock.date, "dddd, d MMMM yyyy  ·  HH:mm"); color: Theme.primary; font.family: Theme.font; font.pixelSize: 13 }
            }
        }
    }
        }
    }
}
