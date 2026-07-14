import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

FloatingWindow {
    id: root

    title: "Kamalen Settings"
    visible: UIState.settingsVisible
    implicitWidth: Math.min(screen ? screen.width * 0.86 : Metrics.dp(1100), Metrics.dp(1100))
    implicitHeight: Math.min(screen ? screen.height * 0.86 : Metrics.dp(760), Metrics.dp(760))
    minimumSize: Qt.size(Metrics.dp(680), Metrics.dp(500))
    maximumSize: Qt.size(4096, 2160)
    color: "transparent"

    property int activeSection: 0
    property bool pfpPicker: false
    property var pfpList: []
    property bool compactNavigation: width < Metrics.dp(850)
    property var sections: [
        { icon: "󰏘", label: L10n.tr("appearance", "Appearance") },
        { icon: "󰍹", label: L10n.tr("monitors", "Monitors") },
        { icon: "󰒈", label: L10n.tr("mango", "Mango") },
        { icon: "󰌌", label: L10n.tr("binds", "Binds") },
        { icon: "󰁍", label: L10n.tr("rules", "Rules") }
    ]

    onVisibleChanged: {
        if (!visible && UIState.settingsVisible) UIState.closeSettings()
        if (visible) {
            pfpListProc.running = true
            focusDelay.restart()
        }
    }

    Timer {
        id: focusDelay
        interval: 40
        onTriggered: settingsSurface.forceActiveFocus()
    }

    function cycleBlur() {
        if (!UIState.transparencyEnabled) return
        var values = ["frosted", "balanced", "subtle", "none"]
        UIState.setBlurProfile(values[(values.indexOf(UIState.blurProfile) + 1) % values.length])
    }
    function getBlurIcon() {
        return UIState.blurProfile === "frosted" ? "󰂵" : UIState.blurProfile === "balanced" ? "󰂶" : UIState.blurProfile === "subtle" ? "󰂷" : "󰂸"
    }
    function getBlurLabel() {
        return UIState.blurProfile === "frosted" ? L10n.tr("frosted", "Strong") : UIState.blurProfile === "balanced" ? L10n.tr("balanced_blur", "Medium") : UIState.blurProfile === "subtle" ? L10n.tr("subtle", "Subtle") : L10n.tr("none", "None")
    }
    QtObject {
        id: settingsHelpers
        function cycleBlur() { root.cycleBlur() }
        function getBlurIcon() { return root.getBlurIcon() }
        function getBlurLabel() { return root.getBlurLabel() }
        function openPfpPicker() { root.pfpPicker = true }
    }

    Process {
        id: pfpListProc
        command: ["bash", "-c", "ls -1 ~/.config/quickshell/assets/pfps/*.{jpg,png} 2>/dev/null"]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => root.pfpList = data.trim().split("\n").filter(path => path.length > 0)
        }
    }

    MaterialSurface {
        id: settingsSurface
        anchors.fill: parent
        focus: root.visible
        role: "background"
        fillOpacity: UIState.transparencyEnabled ? 0.96 : 1
        Keys.priority: Keys.BeforeItem

        Keys.onPressed: event => {
            var control = (event.modifiers & Qt.ControlModifier) !== 0
            if (event.key === Qt.Key_Escape || (control && event.key === Qt.Key_W)) {
                if (root.pfpPicker) root.pfpPicker = false
                else UIState.closeSettings()
                event.accepted = true
                return
            }
            if (control && event.key >= Qt.Key_1 && event.key <= Qt.Key_5) {
                root.activeSection = event.key - Qt.Key_1
                event.accepted = true
                return
            }
            if (control && event.key === Qt.Key_Tab) {
                var direction = (event.modifiers & Qt.ShiftModifier) !== 0 ? -1 : 1
                root.activeSection = (root.activeSection + direction + root.sections.length) % root.sections.length
                event.accepted = true
                return
            }
            var shiftedLast = event.text === "G" && event.modifiers === Qt.ShiftModifier
            if (!UIState.vimNavigationEnabled || (event.modifiers !== Qt.NoModifier && !shiftedLast)) return
            if (event.text === "j" || event.text === "l") {
                root.activeSection = Math.min(root.sections.length - 1, root.activeSection + 1)
                event.accepted = true
            } else if (event.text === "k" || event.text === "h") {
                root.activeSection = Math.max(0, root.activeSection - 1)
                event.accepted = true
            } else if (event.text === "g") {
                root.activeSection = 0
                event.accepted = true
            } else if (event.text === "G") {
                root.activeSection = root.sections.length - 1
                event.accepted = true
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: Metrics.dp(16)
            spacing: Metrics.dp(16)

            MaterialSurface {
                Layout.fillHeight: true
                Layout.preferredWidth: root.compactNavigation ? Metrics.dp(72) : Metrics.dp(230)
                role: "panel"

                Column {
                    anchors.fill: parent
                    anchors.margins: Metrics.dp(12)
                    spacing: Metrics.dp(8)

                    Text {
                        text: "Kamalen Settings"
                        color: Colors.fg
                        visible: !root.compactNavigation
                        font { pixelSize: Metrics.sp(17); family: "JetBrainsMono Nerd Font"; bold: true }
                        bottomPadding: Metrics.dp(12)
                    }

                    Repeater {
                        model: root.sections
                        MaterialButton {
                            required property int index
                            required property var modelData
                            width: parent.width
                            height: Metrics.dp(52)
                            role: "control"
                            active: root.activeSection === index
                            accessibleName: modelData.label
                            onClicked: root.activeSection = index

                            Row {
                                anchors.centerIn: root.compactNavigation ? parent : undefined
                                anchors { left: root.compactNavigation ? undefined : parent.left; leftMargin: Metrics.dp(12); verticalCenter: parent.verticalCenter }
                                spacing: Metrics.dp(10)
                                Text { text: modelData.icon; color: root.activeSection === index ? Colors.accent : Colors.a(Colors.fg, 0.55); font { pixelSize: Metrics.sp(18); family: "JetBrainsMono Nerd Font" } }
                                Text { visible: !root.compactNavigation; text: modelData.label; color: root.activeSection === index ? Colors.accent : Colors.fg; font { pixelSize: Metrics.sp(12); family: "JetBrainsMono Nerd Font"; bold: root.activeSection === index } }
                            }
                        }
                    }
                }
            }

            MaterialSurface {
                Layout.fillWidth: true
                Layout.fillHeight: true
                role: "raised"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Metrics.dp(22)
                    spacing: Metrics.dp(14)

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: root.sections[root.activeSection].label
                            color: Colors.fg
                            font { pixelSize: Metrics.sp(22); family: "JetBrainsMono Nerd Font"; bold: true }
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: "Ctrl+" + (root.activeSection + 1) + "  ·  Esc"
                            color: Colors.a(Colors.fg, 0.42)
                            font { pixelSize: Metrics.sp(9); family: "JetBrainsMono Nerd Font" }
                        }
                    }

                    StackLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        currentIndex: root.activeSection
                        LookTab { helpers: settingsHelpers }
                        MonitorsTab { helpers: settingsHelpers }
                        MangoTab {}
                        BindsTab { helpers: settingsHelpers }
                        WindowRulesTab { helpers: settingsHelpers }
                    }
                }
            }
        }

        MaterialSurface {
            anchors.fill: parent
            visible: root.pfpPicker
            role: "background"
            fillOpacity: 0.97
            z: 10

            Column {
                anchors.fill: parent
                anchors.margins: Metrics.dp(28)
spacing: Metrics.dp(18)
Row {
                    width: parent.width
                    Text { text: L10n.tr("choose_avatar", "Choose profile picture"); color: Colors.fg; font { pixelSize: Metrics.sp(18); family: "JetBrainsMono Nerd Font"; bold: true } }
                    Item { width: parent.width - 260; height: 1 }
                    Text {
                        text: "󰅖"
                        color: Colors.fg
                        font { pixelSize: Metrics.sp(18); family: "JetBrainsMono Nerd Font" }
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: Metrics.dp(-8)
cursorShape: Qt.PointingHandCursor
                            onClicked: root.pfpPicker = false
                        }
                    }
                }
                GridView {
                    width: parent.width
                    height: parent.height - 50
                    cellWidth: 130
                    cellHeight: 130
                    model: root.pfpList
                    clip: true
                    delegate: Item {
                        required property int index
                        required property string modelData
                        width: 120; height: 120
                        Image { id: avatar; anchors.fill: parent; anchors.margins: 8; source: "file://" + modelData; fillMode: Image.PreserveAspectCrop; visible: false }
                        Rectangle { id: avatarMask; anchors.fill: avatar; radius: width / 2; visible: false }
                        OpacityMask { anchors.fill: avatar; source: avatar; maskSource: avatarMask }
                        Rectangle { anchors.fill: avatar; radius: width / 2; color: "transparent"; border.width: UIState.pfpIndex === index ? 3 : 1; border.color: UIState.pfpIndex === index ? Colors.accent : Colors.a(Colors.fg, 0.15) }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { UIState.setPfpIndex(index); root.pfpPicker = false } }
                    }
                }
            }
        }
    }
}
