pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: state

    property bool  visible:      false
    property var   activeItem:   null
    property var   parentWindow: null
    property int   popupX:       0
    property int   popupY:       0

    function show(item, win, x, y) {
        activeItem = item
        parentWindow = win
        popupX = x
        popupY = y
        visible = true
    }

    function hide() {
        visible = false
        activeItem = null
        parentWindow = null
    }

    function toggle(item, win, x, y) {
        if (visible && activeItem === item) {
            hide()
        } else {
            show(item, win, x, y)
        }
    }

    function closeAll() {
        hide()
    }
}
