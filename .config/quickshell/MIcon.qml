import QtQuick

Text {
    id: root

    property string name: ""
    property real size: 14
    property bool bold: false

    text: name
    color: "#f5f5f5"
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: size
    font.bold: bold
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    renderType: Text.QtRendering
    antialiasing: true
}
