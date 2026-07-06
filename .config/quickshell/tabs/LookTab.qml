import QtQuick
import ".."

Item {
    property var helpers

    Column {
        anchors.fill: parent
        spacing: 10

        TileButton {
            width: parent.width
            icon: UIState.darkMode ? "󰖔" : "󰖕"
            label: UIState.darkMode ? L10n.tr("dark", "Dark") : L10n.tr("light", "Light")
            sublabel: L10n.tr("theme", "Theme")
            active: UIState.darkMode
            onClicked: UIState.toggleDarkMode()
        }

        TileButton {
            width: parent.width
            icon: UIState.transparencyEnabled ? "󱡔" : "󱡔"
            label: UIState.transparencyEnabled ? L10n.tr("transparent", "Glass") : L10n.tr("opaque", "Solid")
            sublabel: L10n.tr("transparency", "Transparency")
            active: UIState.transparencyEnabled
            onClicked: UIState.toggleTransparency()
        }

        TileButton {
            width: parent.width
            icon: "󰀄"
            label: L10n.tr("avatar", "Avatar")
            sublabel: L10n.tr("choose_avatar", "Choose profile picture")
            active: false
            onClicked: helpers && helpers.openPfpPicker()
        }
    }
}
