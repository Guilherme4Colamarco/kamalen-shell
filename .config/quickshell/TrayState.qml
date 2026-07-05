pragma Singleton
import QtQuick

// ── Tray popup state coordinator ──────────────────────────────────────────
// Shared between TrayBar delegates and TrayPopup to open/close the styled
// popup menu rendered by QuickShell instead of the native application menu.
QtObject {
    id: state

    property bool  visible:      false
    property var   activeItem:   null   // StatusNotifierItem
    property var   parentWindow: null   // PanelWindow to anchor to
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
    }

    function toggle(item, win, x, y) {
        if (visible && activeItem === item) {
            hide()
        } else {
            show(item, win, x, y)
        }
    }
}
