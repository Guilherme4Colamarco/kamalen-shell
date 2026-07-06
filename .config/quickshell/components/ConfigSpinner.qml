import QtQuick
import ".."

Item {
    id: root

    property string label: ""
    property var model: []
    property int currentIndex: 0
    signal activated(int index)

    height: 34
    width: parent.width

    readonly property string currentText: {
        if (!root.model || root.model.length === 0) return ""
        if (root.currentIndex < 0 || root.currentIndex >= root.model.length) return ""
        return root.model[root.currentIndex]
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: UIState.borderRadius * 0.625
        color: rowMa.containsMouse ? Colors.a(Colors.fg, 0.05) : "transparent"
        Behavior on color { ColorAnimation { duration: Animations.fast } }
    }

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 2
        anchors.verticalCenter: parent.verticalCenter
        text: root.label
        color: Colors.a(Colors.fg, 0.85)
        font { pixelSize: 11; family: "JetBrainsMono Nerd Font" }
    }

    MouseArea {
        id: rowMa
        anchors.fill: parent
        hoverEnabled: true
        z: -1
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: 2
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Rectangle {
            width: 22
            height: 22
            radius: UIState.borderRadius * 0.5
            color: leftMa.containsMouse ? Colors.a(Colors.fg, 0.12) : Colors.a(Colors.fg, 0.05)
            Behavior on color { ColorAnimation { duration: Animations.fast } }

            Text {
                anchors.centerIn: parent
                text: "󰅁"
                color: Colors.a(Colors.fg, 0.5)
                font { pixelSize: 10; family: "JetBrainsMono Nerd Font" }
            }

            MouseArea {
                id: leftMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (!root.model || root.model.length === 0) return
                    var idx = root.currentIndex - 1
                    if (idx < 0) idx = root.model.length - 1
                    root.activated(idx)
                }
            }
        }

        Rectangle {
            width: Math.max(64, valueText.implicitWidth + 16)
            height: 22
            radius: UIState.borderRadius * 0.5
            color: Colors.a(Colors.surface, 0.4)

            Text {
                id: valueText
                anchors.centerIn: parent
                text: root.currentText
                color: Colors.accent
                font { pixelSize: 10; family: "JetBrainsMono Nerd Font"; bold: true }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (!root.model || root.model.length === 0) return
                    var idx = (root.currentIndex + 1) % root.model.length
                    root.activated(idx)
                }
            }
        }

        Rectangle {
            width: 22
            height: 22
            radius: UIState.borderRadius * 0.5
            color: rightMa.containsMouse ? Colors.a(Colors.fg, 0.12) : Colors.a(Colors.fg, 0.05)
            Behavior on color { ColorAnimation { duration: Animations.fast } }

            Text {
                anchors.centerIn: parent
                text: "󰅃"
                color: Colors.a(Colors.fg, 0.5)
                font { pixelSize: 10; family: "JetBrainsMono Nerd Font" }
            }

            MouseArea {
                id: rightMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (!root.model || root.model.length === 0) return
                    var idx = (root.currentIndex + 1) % root.model.length
                    root.activated(idx)
                }
            }
        }
    }
}
