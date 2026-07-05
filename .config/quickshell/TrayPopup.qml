import Quickshell
import Quickshell.DBusMenu
import QtQuick
import Quickshell._Window

// ── Styled tray menu popup ────────────────────────────────────────────────
// Renders the tray item's DBusMenu as a themed QuickShell popup instead of
// the native application menu. Uses QsMenuOpener to read entries from the
// StatusNotifier's menu property and renders them with the shell's colours
// and bubbly interaction style.
PopupWindow {
    id: root

    // ── config ──────────────────────────────────────────────────────────
    property int  padding:      12
    property int  itemHeight:   32
    property int  iconSize:     16
    property real itemRadius:   6

    // ── visibility & position ──────────────────────────────────────────
    visible:      TrayState.visible && TrayState.activeItem !== null
    parentWindow: TrayState.parentWindow
    relativeX:    TrayState.popupX
    relativeY:    TrayState.popupY

    width:  Math.max(minImplicit, popupLayout.implicitWidth  + padding * 2)
    height: popupLayout.implicitHeight + padding * 2
    readonly property int minImplicit: 180

    color:      "transparent"
    grabFocus:  true
    mask:       bgPanel

    // close via outside click or wm action
    function onClosed() { TrayState.hide() }

    // ── QsMenuOpener – reads the tray item's DBusMenu ──────────────────
    QsMenuOpener {
        id: menuOpener
        menu: TrayState.activeItem ? TrayState.activeItem.menu : null
    }

    // ── background panel ───────────────────────────────────────────────
    Rectangle {
        id: bgPanel
        anchors.fill: parent
        radius:       10
        color:        Colors.surface
        border.color: Qt.rgba(Colors.fg.r, Colors.fg.g, Colors.fg.b, 0.08)
        border.width: 1

        layer.enabled: true
        layer.samples: 4
    }

    // ── menu entries ───────────────────────────────────────────────────
    Column {
        id: popupLayout
        anchors {
            top: parent.top;    topMargin: padding
            left: parent.left;  leftMargin: padding
            right: parent.right; rightMargin: padding
        }
        spacing: 3

        // optional title row
        Text {
            id: titleText
            width: parent.width
            visible: Boolean(TrayState.activeItem?.title)
            text: TrayState.activeItem?.title ?? ""
            font { pixelSize: 11; weight: Font.Bold }
            color: Colors.dim
            bottomPadding: 6
            elide: Text.ElideRight
        }

        // menu entries from QsMenuOpener
        Instantiator {
            model: menuOpener.children
            asynchronous: false

            delegate: Item {
                id: entry
                required property var modelData
                required property int  index

                width:  parent.width
                height: modelData.isSeparator ? sepItem.height : itemHeight

                // ── separator ──────────────────────────────────────
                Rectangle {
                    id: sepItem
                    visible:       modelData.isSeparator
                    anchors.centerIn: parent
                    width:         parent.width - 8
                    height:        1
                    color:         Qt.rgba(Colors.fg.r, Colors.fg.g, Colors.fg.b, 0.08)
                    antialiasing:  true
                }

                // ── clickable row ──────────────────────────────────
                Rectangle {
                    id: bg
                    visible: !modelData.isSeparator
                    width:   parent.width
                    height:  itemHeight
                    radius:  itemRadius
                    color:   bgArea.containsMouse && modelData.enabled
                             ? Qt.rgba(Colors.fg.r, Colors.fg.g, Colors.fg.b, 0.08)
                             : "transparent"
                    opacity: modelData.enabled ? 1.0 : 0.4

                    Behavior on color {
                        ColorAnimation {
                            duration: Animations.fast
                            easing.type: Easing.OutCubic
                        }
                    }

                    // row: [indicator] [icon] [text]
                    Row {
                        anchors {
                            left: parent.left;    leftMargin: 10
                            right: parent.right;  rightMargin: 10
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 8

                        // checkmark / radio indicator
                        Text {
                            visible: modelData.buttonType !== QsMenuButtonType.None
                            text: {
                                if (modelData.buttonType === QsMenuButtonType.CheckBox)
                                    return "✓"
                                if (modelData.buttonType === QsMenuButtonType.RadioButton)
                                    return "●"
                                return ""
                            }
                            font.pixelSize: 13
                            color: Colors.accent
                            width: 16
                            horizontalAlignment: Text.AlignHCenter
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        // application icon
                        Image {
                            visible: Boolean(modelData.icon)
                            width:  iconSize
                            height: iconSize
                            source: modelData.icon || ""
                            sourceSize.width:  iconSize
                            sourceSize.height: iconSize
                            smooth:        true
                            mipmap:        true
                            asynchronous:  true
                            anchors.verticalCenter: parent.verticalCenter
                            fillMode: Image.PreserveAspectFit
                        }

                        // label
                        Text {
                            text: modelData.text || ""
                            font.pixelSize: 13
                            font.weight: Font.Bold
                            color: Colors.fg
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - x
                            elide: Text.ElideRight
                        }
                    }

                    // ── click ──────────────────────────────────────
                    MouseArea {
                        id: bgArea
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled:      modelData.enabled
                        cursorShape:  Qt.PointingHandCursor

                        onClicked: {
                            modelData.triggered()
                            // small delay so the triggered action registers
                            Qt.callLater(TrayState.hide)
                        }
                    }
                }
            }

            onObjectAdded:   (idx, obj) => obj.parent = popupLayout
            onObjectRemoved: (idx, obj) => {}
        }
    }
}
