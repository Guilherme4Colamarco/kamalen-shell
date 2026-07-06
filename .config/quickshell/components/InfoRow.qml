import QtQuick
import ".."

Item {
    property string icon
    property string label
    property string value

    height: 34

    Rectangle {
        anchors.fill: parent
        radius: UIState.borderRadius * 0.75
        color: Colors.a(Colors.fg, 0.025)
    }

    Row {
        anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
        spacing: 10

        Text {
            text:  icon
            color: Colors.a(Colors.fg, 0.45)
            font { pixelSize: 14; family: "JetBrainsMono Nerd Font" }
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text:  label
            color: Colors.a(Colors.fg, 0.55)
            font { pixelSize: 10; family: "JetBrainsMono Nerd Font" }
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Text {
        anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
        text:  value
        color: Colors.fg
        font { pixelSize: 10; family: "JetBrainsMono Nerd Font"; bold: true }
    }
}
