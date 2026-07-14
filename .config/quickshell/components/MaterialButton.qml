import QtQuick
import ".."

FocusScope {
    id: root
    property string role: "raised"
    property bool active: false
    property string skinId: ""
    property string materialVariant: ""
    property string accessibleName: ""
    default property alias content: contentHost.data
    signal clicked()

    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.name: accessibleName
    Accessible.focusable: true

    Keys.onPressed: event => {
        if (!root.enabled || event.isAutoRepeat) return
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            root.clicked()
            event.accepted = true
        }
    }

    MaterialSurface {
        anchors.fill: parent
        role: root.role
        hovered: mouse.containsMouse
        pressed: mouse.pressed
        active: root.active
        focused: root.activeFocus
        skinId: root.skinId
        materialVariant: root.materialVariant
        opacity: root.enabled ? 1 : 0.5
        Item { id: contentHost; anchors.fill: parent }
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: root.forceActiveFocus()
        onClicked: root.clicked()
    }
}
