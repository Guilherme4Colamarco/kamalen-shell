import QtQuick
import ".."

Item {
    id: root
    property string role: "panel"
    property bool hovered: false
    property bool pressed: false
    property bool active: false
    property bool focused: false
    property bool materialEnabled: true
    property real fillOpacity: 1
    property real outlineWidth: -1
    property color outlineColor: "transparent"
    property string skinId: ""
    property string materialVariant: ""
    readonly property string resolvedSkinId: skinId !== "" ? skinId : Skins.currentId
    readonly property string resolvedMaterialRole:
        Skins.materialRole(resolvedSkinId, role, materialVariant)
    readonly property var skinRecipe: Skins.recipe(resolvedSkinId)
    readonly property real materialGlossOpacity: root.skinRecipe.glossOpacity > 0
        ? Skins.glossOpacityForRole(resolvedSkinId, resolvedMaterialRole) : 0
    readonly property real recipeRadius: Metrics.dp(
        role === "control" ? skinRecipe.controlRadius
        : role === "raised" ? skinRecipe.cardRadius
        : skinRecipe.containerRadius)
    property real cornerRadius: Skins.radius(recipeRadius, height)
    default property alias content: contentHost.data

    Rectangle {
        anchors.fill: parent
        radius: root.cornerRadius
        color: Skins.roleBase(root.resolvedMaterialRole, root.active, root.resolvedSkinId)
        border.width: root.outlineWidth >= 0
            ? root.outlineWidth
            : (root.materialEnabled ? Metrics.dp(root.skinRecipe.borderWidth) : 0)
        border.color: root.outlineWidth >= 0
            ? root.outlineColor
            : (root.active ? Colors.accent : Skins.bevelDark(root.pressed, root.resolvedSkinId))
        gradient: Gradient {
            GradientStop { position: 0; color: Skins.materialTop(root.resolvedMaterialRole, root.pressed, root.active, root.resolvedSkinId) }
            GradientStop { position: 1; color: Skins.materialBottom(root.resolvedMaterialRole, root.pressed, root.active, root.resolvedSkinId) }
        }
        opacity: root.fillOpacity
        Behavior on color { ColorAnimation { duration: Animations.fast } }
    }

    Image {
        anchors.fill: parent
        source: Skins.textureForRole(root.resolvedSkinId, root.resolvedMaterialRole)
        fillMode: Image.Tile
        opacity: root.materialEnabled
            ? Skins.textureOpacityForRole(root.resolvedSkinId, root.resolvedMaterialRole) * root.fillOpacity : 0
        visible: opacity > 0 && source !== ""
        asynchronous: true
    }

    Rectangle {
        anchors.fill: parent
        radius: root.cornerRadius
        visible: root.materialEnabled && root.materialGlossOpacity > 0
        opacity: root.fillOpacity
        gradient: Gradient {
            GradientStop {
                position: 0
                color: Colors.a(Skins.bevelLight(false, root.resolvedSkinId), root.materialGlossOpacity)
            }
            GradientStop {
                position: 0.46
                color: Colors.a(Skins.bevelLight(false, root.resolvedSkinId), root.materialGlossOpacity * 0.3)
            }
            GradientStop { position: 0.52; color: "transparent" }
            GradientStop {
                position: 1
                color: Colors.a(Skins.bevelDark(false, root.resolvedSkinId), root.materialGlossOpacity * 0.18)
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: Metrics.dp(root.skinRecipe.innerLineWidth)
        radius: Math.max(0, root.cornerRadius - Metrics.dp(root.skinRecipe.innerLineWidth))
        visible: root.materialEnabled && root.skinRecipe.innerLineWidth > 0
        color: "transparent"
        border.width: Metrics.dp(root.skinRecipe.innerLineWidth)
        border.color: Colors.a(Skins.bevelLight(root.pressed, root.resolvedSkinId), 0.42 * root.fillOpacity)
    }

    Rectangle {
        visible: root.materialEnabled && root.skinRecipe.bevelWidth > 0
        anchors { left: parent.left; right: parent.right; top: parent.top }
        height: Metrics.dp(root.skinRecipe.bevelWidth)
        color: Skins.bevelLight(root.pressed, root.resolvedSkinId)
        opacity: root.fillOpacity
    }
    Rectangle {
        visible: root.materialEnabled && root.skinRecipe.bevelWidth > 0
        anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
        width: Metrics.dp(root.skinRecipe.bevelWidth)
        color: Skins.bevelLight(root.pressed, root.resolvedSkinId)
        opacity: root.fillOpacity
    }
    Rectangle {
        visible: root.materialEnabled && root.skinRecipe.bevelWidth > 0
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: Metrics.dp(root.skinRecipe.bevelWidth)
        color: Skins.bevelDark(root.pressed, root.resolvedSkinId)
        opacity: root.fillOpacity
    }
    Rectangle {
        visible: root.materialEnabled && root.skinRecipe.bevelWidth > 0
        anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
        width: Metrics.dp(root.skinRecipe.bevelWidth)
        color: Skins.bevelDark(root.pressed, root.resolvedSkinId)
        opacity: root.fillOpacity
    }

    Repeater {
        model: root.materialEnabled
            && root.skinRecipe.hardwareSize > 0
            && root.resolvedMaterialRole === "wood"
            && root.width >= Metrics.dp(120) && root.height >= Metrics.dp(72) ? 4 : 0

        Rectangle {
            required property int index
            readonly property real inset: Metrics.dp(7)
            width: Metrics.dp(root.skinRecipe.hardwareSize)
            height: width
            radius: width / 2
            x: index % 2 === 0 ? inset : root.width - width - inset
            y: index < 2 ? inset : root.height - height - inset
            opacity: root.skinRecipe.hardwareOpacity * root.fillOpacity
            border.width: Metrics.dp(1)
            border.color: Skins.bevelDark(false, root.resolvedSkinId)
            gradient: Gradient {
                GradientStop { position: 0; color: Skins.bevelLight(false, root.resolvedSkinId) }
                GradientStop { position: 0.48; color: Colors.dim }
                GradientStop { position: 1; color: Skins.bevelDark(false, root.resolvedSkinId) }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: root.cornerRadius
        color: root.hovered ? Colors.a(Colors.fg, 0.05) : "transparent"
        Behavior on color { ColorAnimation { duration: Animations.fast } }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: Metrics.dp(2)
        radius: Math.max(0, root.cornerRadius - Metrics.dp(2))
        color: "transparent"
        border.width: root.focused ? Metrics.dp(2) : 0
        border.color: Colors.accent
        opacity: root.focused ? 0.9 : 0
        Behavior on opacity { NumberAnimation { duration: Animations.fast } }
    }

    Item { id: contentHost; anchors.fill: parent }
}
