import QtQuick
import ".."

Rectangle {
    property string icon
    property string label
    property string sublabel
    property bool active: false
    signal clicked()

    height: 50
    radius: UIState.borderRadius * 0.75
    color: active ? Colors.a(Colors.accent, 0.12) : tileMa.containsMouse ? Colors.a(Colors.fg, 0.06) : Colors.a(Colors.fg, 0.025)
    border.width: active ? 1 : 0
    border.color: Colors.a(Colors.accent, 0.2)

    Behavior on color  { ColorAnimation { duration: Animations.fast } }
    Behavior on radius { NumberAnimation { duration: Animations.medium; easing.type: Easing.OutCubic } }

    Row {
        anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
        spacing: 12

        Text {
            text:  icon
            color: active ? Colors.accent : Colors.a(Colors.fg, 0.45)
            font { pixelSize: 18; family: "JetBrainsMono Nerd Font" }
            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                text:  label
                color: active ? Colors.accent : Colors.fg
                font { pixelSize: 11; family: "JetBrainsMono Nerd Font"; bold: true }
            }

            Text {
                text:  sublabel
                color: Colors.a(Colors.fg, 0.3)
                font { pixelSize: 8; family: "JetBrainsMono Nerd Font" }
            }
        }
    }

    Text {
        anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
        text:  "󰅂"
        color: Colors.a(Colors.fg, 0.25)
        font { pixelSize: 11; family: "JetBrainsMono Nerd Font" }
    }

    MouseArea {
        id: tileMa
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: parent.clicked()
    }
}
