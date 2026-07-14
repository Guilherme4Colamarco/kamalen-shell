import QtQuick
import ".."

FocusScope {
    id: root

    property string label: ""
    property real value: 0
    property real minValue: 0
    property real maxValue: 100
    property real stepSize: 1
    property string unit: ""

    property real currentValue: root.value
    signal valueModified(real v)

    height: Metrics.dp(54)
    width: parent.width
    activeFocusOnTab: true
    Accessible.role: Accessible.Slider
    Accessible.name: root.label
    Accessible.focusable: true

    onValueChanged: root.currentValue = root.value

    function _snap(v) {
        if (root.stepSize <= 0) return v
        return Math.round(v / root.stepSize) * root.stepSize
    }

    function _valueFromX(x) {
        var t = Math.max(0, Math.min(1, x / trackArea.width))
        return root._snap(root.minValue + t * (root.maxValue - root.minValue))
    }

    function _format(v) {
        var rounded = Math.round(v)
        if (Math.abs(v - rounded) < 0.0001) return rounded.toString()
        return v.toFixed(2)
    }

    function _commit(v) {
        root.currentValue = Math.max(root.minValue, Math.min(root.maxValue, root._snap(v)))
        root.valueModified(root.currentValue)
    }

    Keys.onPressed: event => {
        var delta = root.stepSize > 0 ? root.stepSize : (root.maxValue - root.minValue) / 100
        if (event.key === Qt.Key_Left || event.key === Qt.Key_Down) {
            root._commit(root.currentValue - delta)
        } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Up) {
            root._commit(root.currentValue + delta)
        } else if (event.key === Qt.Key_Home) {
            root._commit(root.minValue)
        } else if (event.key === Qt.Key_End) {
            root._commit(root.maxValue)
        } else if (event.key === Qt.Key_PageDown) {
            root._commit(root.currentValue - delta * 10)
        } else if (event.key === Qt.Key_PageUp) {
            root._commit(root.currentValue + delta * 10)
        } else {
            return
        }
        event.accepted = true
    }

    Text {
        id: labelText
        anchors.left: parent.left
        anchors.top: parent.top
        text: root.label
        color: Colors.a(Colors.fg, 0.8)
        font { pixelSize: Metrics.sp(11); family: "JetBrainsMono Nerd Font" }
    }

    Text {
        anchors.right: parent.right
        anchors.top: parent.top
        text: root._format(root.currentValue) + (root.unit ? " " + root.unit : "")
        color: Colors.accent
        font { pixelSize: Metrics.sp(10); family: "JetBrainsMono Nerd Font"; bold: true }
    }

    Item {
        id: trackArea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: labelText.bottom
        anchors.topMargin: Metrics.dp(12)
        height: Skins.sliderTrackHeight

        MaterialTrack {
            anchors.fill: parent
            value: {
                var range = root.maxValue - root.minValue
                if (range <= 0) return 0
                return Math.max(0, Math.min(1, (root.currentValue - root.minValue) / range))
            }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: -Metrics.dp(5)
            radius: Skins.radius(Skins.controlRadius, height)
            color: "transparent"
            border.width: root.activeFocus ? Metrics.dp(2) : 0
            border.color: Colors.accent
            opacity: root.activeFocus ? 0.8 : 0
            Behavior on opacity { NumberAnimation { duration: Animations.fast } }
        }

        MaterialSurface {
            x: {
                var range = root.maxValue - root.minValue
                if (range <= 0) return 0
                return Math.max(0, Math.min(parent.width - width,
                    parent.width * (root.currentValue - root.minValue) / range))
            }
            anchors.verticalCenter: parent.verticalCenter
            width: Skins.sliderThumbWidth
            height: Skins.sliderThumbSize
            role: "raised"
            active: true
            pressed: sliderMa.pressed
            hovered: sliderMa.containsMouse
            cornerRadius: Skins.radius(Skins.controlRadius, height)
            scale: Skins.currentId === "commonality" ? 1.0 : (sliderMa.containsMouse || sliderMa.pressed ? 1.2 : 1.0)

            Behavior on scale {
                NumberAnimation { duration: Animations.snap; easing.type: Easing.OutBack; easing.overshoot: Animations.springPower }
            }
        }

        MouseArea {
            id: sliderMa
            anchors.fill: parent
            anchors.margins: -Metrics.dp(10)
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            preventStealing: true

            onPressed: mouse => {
                root.forceActiveFocus()
                var point = sliderMa.mapToItem(trackArea, mouse.x, mouse.y)
                root.currentValue = root._valueFromX(point.x)
            }
            onPositionChanged: mouse => {
                if (!pressed) return
                var point = sliderMa.mapToItem(trackArea, mouse.x, mouse.y)
                root.currentValue = root._valueFromX(point.x)
            }
            onReleased: root.valueModified(root.currentValue)
        }
    }
}
