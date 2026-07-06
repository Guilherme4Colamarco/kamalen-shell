import Quickshell
import Quickshell.Io
import QtQuick
import ".."

Item {
    id: root
    property var helpers

    property var monitorList: []
    property string addName: ""
    property string addWidth: "1920"
    property string addHeight: "1080"
    property string addRefresh: "60"
    property string addScale: "1.0"
    property int addX: 0
    property int addY: 0

    function loadMonitors() {
        MangoConfig.listDirectives("monitors", function(data) {
            monitorList = data
        })
    }

    function deleteMonitor(index) {
        MangoConfig.removeDirective("monitors", index)
        loadMonitors()
    }

    function parseMonitor(value) {
        var parts = {}
        value.split(",").forEach(function(pair) {
            var kv = pair.split(":", 2)
            if (kv.length === 2) parts[kv[0].trim()] = kv[1].trim()
        })
        return parts
    }

    function formatMonitor(item) {
        var p = parseMonitor(item.value)
        var label = p.name || "?"
        var res = (p.width || "?") + "x" + (p.height || "?")
        if (p.refresh) res += " @" + p.refresh + "Hz"
        if (p.scale) res += " (" + p.scale + "x)"
        return label + "  —  " + res
    }

    function addMonitorFn() {
        if (!addName.trim()) return
        var value = "name:" + addName.trim()
            + ",width:" + addWidth.trim()
            + ",height:" + addHeight.trim()
            + ",refresh:" + addRefresh.trim()
            + ",x:" + addX
            + ",y:" + addY
            + ",scale:" + addScale.trim()
        MangoConfig.addDirective("monitors", "monitorrule", value)
        addName = ""
        loadMonitors()
    }

    onVisibleChanged: { if (visible) loadMonitors() }

    Flickable {
        width: parent.width
        height: parent.height
        contentHeight: col.height + 40
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: col
            width: parent.width
            spacing: 10
            topPadding: 6

            ConfigSection {
                title: L10n.tr("monitors", "Monitors")
                icon: "󰍹"
                expanded: true
                width: parent.width

                Repeater {
                    model: monitorList

                    Item {
                        required property int index
                        required property var modelData
                        width: parent.width
                        height: 32

                        Rectangle {
                            anchors.fill: parent
                            radius: UIState.borderRadius * 0.5
                            color: delMa.containsMouse ? Colors.a(Colors.red, 0.12) : Colors.a(Colors.fg, 0.04)
                            Behavior on color { ColorAnimation { duration: Animations.fast } }
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: formatMonitor(modelData)
                            color: Colors.a(Colors.fg, 0.8)
                            font { pixelSize: 10; family: "JetBrainsMono Nerd Font" }
                            elide: Text.ElideRight
                            width: parent.width - 50
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            text: "󰅖"
                            color: delMa.containsMouse ? Colors.red : Colors.a(Colors.fg, 0.25)
                            font { pixelSize: 13; family: "JetBrainsMono Nerd Font" }
                            Behavior on color { ColorAnimation { duration: Animations.fast } }

                            MouseArea {
                                id: delMa
                                anchors.fill: parent; anchors.margins: -4
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: deleteMonitor(modelData.index)
                            }
                        }
                    }
                }
            }

            // ── Add monitor form ──────────────────────────────────────────────
            ConfigSection {
                title: L10n.tr("add_monitor", "Add Monitor")
                icon: "󰐕"
                expanded: true
                width: parent.width

                Column {
                    width: parent.width
                    spacing: 8

                    Row {
                        width: parent.width
                        spacing: 6

                        Item {
                            width: (parent.width - 6) * 0.5
                            height: 30

                            Rectangle {
                                anchors.fill: parent
                                radius: UIState.borderRadius * 0.625
                                color: Colors.a(Colors.fg, 0.06)
                                border.width: 1
                                border.color: Colors.a(Colors.fg, 0.1)

                                TextInput {
                                    id: nameInput
                                    anchors.fill: parent; anchors.margins: 8
                                    text: root.addName
                                    color: Colors.fg
                                    font { pixelSize: 11; family: "JetBrainsMono Nerd Font" }
                                    verticalAlignment: TextInput.AlignVCenter
                                    onTextChanged: root.addName = text
                                }
                            }
                        }

                        Item {
                            width: (parent.width - 6) * 0.25
                            height: 30

                            Rectangle {
                                anchors.fill: parent
                                radius: UIState.borderRadius * 0.625
                                color: Colors.a(Colors.fg, 0.06)
                                border.width: 1
                                border.color: Colors.a(Colors.fg, 0.1)

                                TextInput {
                                    id: widthInput
                                    anchors.fill: parent; anchors.margins: 8
                                    text: root.addWidth
                                    color: Colors.fg
                                    font { pixelSize: 11; family: "JetBrainsMono Nerd Font" }
                                    verticalAlignment: TextInput.AlignVCenter
                                    onTextChanged: root.addWidth = text
                                }
                            }
                        }

                        Item {
                            width: (parent.width - 6) * 0.25
                            height: 30

                            Rectangle {
                                anchors.fill: parent
                                radius: UIState.borderRadius * 0.625
                                color: Colors.a(Colors.fg, 0.06)
                                border.width: 1
                                border.color: Colors.a(Colors.fg, 0.1)

                                TextInput {
                                    id: heightInput
                                    anchors.fill: parent; anchors.margins: 8
                                    text: root.addHeight
                                    color: Colors.fg
                                    font { pixelSize: 11; family: "JetBrainsMono Nerd Font" }
                                    verticalAlignment: TextInput.AlignVCenter
                                    onTextChanged: root.addHeight = text
                                }
                            }
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: 6

                        Item {
                            width: (parent.width - 18) * 0.25
                            height: 30

                            Rectangle {
                                anchors.fill: parent
                                radius: UIState.borderRadius * 0.625
                                color: Colors.a(Colors.fg, 0.06)
                                border.width: 1
                                border.color: Colors.a(Colors.fg, 0.1)

                                TextInput {
                                    id: refreshInput
                                    anchors.fill: parent; anchors.margins: 8
                                    text: root.addRefresh
                                    color: Colors.fg
                                    font { pixelSize: 11; family: "JetBrainsMono Nerd Font" }
                                    verticalAlignment: TextInput.AlignVCenter
                                    onTextChanged: root.addRefresh = text
                                }
                            }
                        }

                        Item {
                            width: (parent.width - 18) * 0.25
                            height: 30

                            Rectangle {
                                anchors.fill: parent
                                radius: UIState.borderRadius * 0.625
                                color: Colors.a(Colors.fg, 0.06)
                                border.width: 1
                                border.color: Colors.a(Colors.fg, 0.1)

                                TextInput {
                                    id: scaleInput
                                    anchors.fill: parent; anchors.margins: 8
                                    text: root.addScale
                                    color: Colors.fg
                                    font { pixelSize: 11; family: "JetBrainsMono Nerd Font" }
                                    verticalAlignment: TextInput.AlignVCenter
                                    onTextChanged: root.addScale = text
                                }
                            }
                        }

                        Item {
                            width: (parent.width - 18) * 0.25
                            height: 30

                            Rectangle {
                                anchors.fill: parent
                                radius: UIState.borderRadius * 0.625
                                color: Colors.a(Colors.fg, 0.06)
                                border.width: 1
                                border.color: Colors.a(Colors.fg, 0.1)

                                TextInput {
                                    id: xInput
                                    anchors.fill: parent; anchors.margins: 8
                                    text: String(root.addX)
                                    color: Colors.fg
                                    font { pixelSize: 11; family: "JetBrainsMono Nerd Font" }
                                    verticalAlignment: TextInput.AlignVCenter
                                    onTextChanged: root.addX = parseInt(text) || 0
                                }
                            }
                        }

                        Item {
                            width: (parent.width - 18) * 0.25
                            height: 30

                            Rectangle {
                                anchors.fill: parent
                                radius: UIState.borderRadius * 0.625
                                color: Colors.a(Colors.fg, 0.06)
                                border.width: 1
                                border.color: Colors.a(Colors.fg, 0.1)

                                TextInput {
                                    id: yInput
                                    anchors.fill: parent; anchors.margins: 8
                                    text: String(root.addY)
                                    color: Colors.fg
                                    font { pixelSize: 11; family: "JetBrainsMono Nerd Font" }
                                    verticalAlignment: TextInput.AlignVCenter
                                    onTextChanged: root.addY = parseInt(text) || 0
                                }
                            }
                        }

                        Item {
                            width: 64
                            height: 30

                            Rectangle {
                                anchors.fill: parent
                                radius: UIState.borderRadius * 0.625
                                color: addBtnMa.containsMouse ? Colors.a(Colors.accent, 0.25) : Colors.a(Colors.accent, 0.12)
                                Behavior on color { ColorAnimation { duration: Animations.fast } }

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰐕"
                                    color: Colors.accent
                                    font { pixelSize: 14; family: "JetBrainsMono Nerd Font" }
                                }

                                MouseArea {
                                    id: addBtnMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: addMonitorFn()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
