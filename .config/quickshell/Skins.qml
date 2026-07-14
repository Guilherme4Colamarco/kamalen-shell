pragma Singleton
import QtQuick

QtObject {
    readonly property var profiles: [
        { id: "kamalen", label: "Kamalen", icon: "󰌪", description: "Leve, arredondado e translúcido", recommendedMode: "auto", recommendedPreset: "catppuccin" },
        { id: "commonality", label: "Commonality", icon: "󰇀", description: "CDE/Motif compacto, físico e modular", recommendedMode: "adaptive-preset", recommendedPreset: "solarized" },
        { id: "aqua-2009", label: "Aqua 2009", icon: "󰀵", description: "Metal escovado, vidro e controles glossy", recommendedMode: "adaptive-preset", recommendedPreset: "nord" },
        { id: "skeuos-workshop", label: "Skeuos Workshop", icon: "󰛥", description: "Madeira, papel, metal e relevo físico", recommendedMode: "adaptive-preset", recommendedPreset: "gruvbox" }
    ]

    readonly property var _recipes: ({
        "kamalen": {
            containerRadius: 20, cardRadius: 16, controlRadius: 999, buttonRadius: 999, fieldRadius: 999,
            sliderTrackHeight: 8, sliderThumbSize: 18, sliderThumbWidth: 18, progressHeight: 8,
            switchWidth: 44, switchHeight: 24, switchThumbSize: 18, controlHeight: 44, rowHeight: 52,
            borderWidth: 0, bevelWidth: 0, gap: 8,
            textureSource: "", textureOpacity: 0, controlTextureSource: "", controlTextureOpacity: 0,
            metalTextureSource: "", metalTextureOpacity: 0,
            glossOpacity: 0, innerLineWidth: 0, hardwareSize: 0, hardwareOpacity: 0,
            rowMaterial: false, mangoRadius: 16
        },
        "commonality": {
            containerRadius: 0, cardRadius: 0, controlRadius: 0, buttonRadius: 0, fieldRadius: 0,
            sliderTrackHeight: 8, sliderThumbSize: 18, sliderThumbWidth: 12, progressHeight: 8,
            switchWidth: 42, switchHeight: 24, switchThumbSize: 16, controlHeight: 40, rowHeight: 44,
            borderWidth: 1, bevelWidth: 2, gap: 6,
            textureSource: Qt.resolvedUrl("assets/materials/commonality-grid.svg"), textureOpacity: 0.09,
            controlTextureSource: "", controlTextureOpacity: 0,
            metalTextureSource: "", metalTextureOpacity: 0,
            glossOpacity: 0, innerLineWidth: 0, hardwareSize: 0, hardwareOpacity: 0,
            rowMaterial: true, mangoRadius: 0
        },
        "aqua-2009": {
            containerRadius: 12, cardRadius: 10, controlRadius: 10, buttonRadius: 10, fieldRadius: 8,
            sliderTrackHeight: 9, sliderThumbSize: 19, sliderThumbWidth: 19, progressHeight: 9,
            switchWidth: 46, switchHeight: 25, switchThumbSize: 19, controlHeight: 44, rowHeight: 50,
            borderWidth: 1, bevelWidth: 0, gap: 8,
            textureSource: Qt.resolvedUrl("assets/materials/aqua-brushed.svg"), textureOpacity: 0.13,
            controlTextureSource: Qt.resolvedUrl("assets/materials/aqua-brushed.svg"), controlTextureOpacity: 0.08,
            metalTextureSource: Qt.resolvedUrl("assets/materials/aqua-brushed.svg"), metalTextureOpacity: 0.08,
            glossOpacity: 0.34, innerLineWidth: 1, hardwareSize: 0, hardwareOpacity: 0,
            rowMaterial: true, mangoRadius: 12
        },
        "skeuos-workshop": {
            containerRadius: 8, cardRadius: 6, controlRadius: 5, buttonRadius: 5, fieldRadius: 4,
            sliderTrackHeight: 10, sliderThumbSize: 20, sliderThumbWidth: 16, progressHeight: 10,
            switchWidth: 46, switchHeight: 26, switchThumbSize: 18, controlHeight: 44, rowHeight: 50,
            borderWidth: 1, bevelWidth: 1, gap: 8,
            textureSource: Qt.resolvedUrl("assets/materials/skeuos-wood.svg"), textureOpacity: 0.34,
            controlTextureSource: Qt.resolvedUrl("assets/materials/skeuos-fiber.svg"), controlTextureOpacity: 0.18,
            metalTextureSource: Qt.resolvedUrl("assets/materials/skeuos-metal.svg"), metalTextureOpacity: 0.14,
            glossOpacity: 0.32, innerLineWidth: 1, hardwareSize: 5, hardwareOpacity: 0.46,
            rowMaterial: true, mangoRadius: 7
        }
    })

    function recipe(id) { return _recipes[id] || _recipes.kamalen }
    function profile(id) {
        for (var i = 0; i < profiles.length; i++) if (profiles[i].id === id) return profiles[i]
        return profiles[0]
    }
    function valid(id) { return _recipes[id] !== undefined }
    function radius(value, height) { return Math.min(value, height / 2) }
    function mix(a, b, amount) {
        var t = Math.max(0, Math.min(1, amount))
        return Qt.rgba(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t,
                       a.b + (b.b - a.b) * t, a.a + (b.a - a.a) * t)
    }
    function materialRole(skinId, role, variant) {
        var id = skinId || currentId
        var selected = variant || role
        if (id === "skeuos-workshop") {
            if (selected === "wood" || selected === "paper" || selected === "metal") return selected
            if (selected === "background" || selected === "panel") return "wood"
            if (selected === "raised") return "paper"
            if (selected === "control") return "metal"
            return selected
        }
        if (selected === "wood" || selected === "paper" || selected === "metal") return role
        return selected
    }
    function roleBase(role, active, skinId) {
        var id = skinId || currentId
        var base
        if (id === "skeuos-workshop" && role === "wood") {
            base = mix(mix(Colors.bg, Colors.yellow, 0.42), Colors.red, 0.08)
        } else if (id === "skeuos-workshop" && role === "paper") {
            base = mix(mix(Colors.surface, Colors.fg, 0.26), Colors.yellow, 0.12)
        } else if (id === "skeuos-workshop" && role === "metal") {
            base = mix(Colors.surface, Colors.dim, 0.38)
            if (active) base = mix(base, Colors.accent, 0.28)
        } else if (role === "background") base = Colors.bg
        else if (role === "sunken") base = mix(Colors.bg, Colors.surface, 0.42)
        else if (role === "accent") base = Colors.accent
        else if (role === "separator") base = Colors.dim
        else if (role === "control") base = active ? mix(Colors.surface, Colors.accent, 0.34) : Colors.surface
        else if (role === "raised") base = active ? mix(Colors.surface, Colors.accent, 0.24) : Colors.surface
        else base = Colors.surface

        if (id === "aqua-2009") {
            if (role === "background") return mix(base, Colors.dim, 0.08)
            if (role === "sunken") return mix(base, Colors.bg, 0.14)
            if (role !== "accent" && role !== "separator") return mix(base, Colors.fg, 0.04)
        } else if (id === "skeuos-workshop" && role !== "wood" && role !== "paper" && role !== "metal") {
            if (role === "sunken") return mix(base, Colors.bg, 0.16)
            if (role !== "accent" && role !== "separator") return mix(base, Colors.yellow, 0.07)
        }
        return base
    }
    function materialTop(role, pressed, active, skinId) {
        var id = skinId || currentId
        var base = roleBase(role, active, id)
        if (id === "commonality")
            return pressed ? mix(base, Colors.bg, 0.16) : mix(base, Colors.fg, 0.13)
        if (id === "aqua-2009")
            return pressed ? mix(base, Colors.bg, 0.14) : mix(base, Colors.fg, role === "accent" ? 0.2 : 0.18)
        if (id === "skeuos-workshop") {
            if (pressed) return mix(base, Colors.bg, role === "metal" ? 0.28 : 0.16)
            if (role === "metal") return mix(base, Colors.fg, 0.3)
            if (role === "paper") return mix(base, Colors.fg, 0.08)
            if (role === "wood") return mix(base, Colors.fg, 0.06)
            return mix(base, Colors.fg, role === "sunken" ? 0.08 : 0.16)
        }
        return base
    }
    function materialBottom(role, pressed, active, skinId) {
        var id = skinId || currentId
        var base = roleBase(role, active, id)
        if (id === "commonality")
            return pressed ? mix(base, Colors.fg, 0.13) : mix(base, Colors.bg, 0.18)
        if (id === "aqua-2009")
            return pressed ? mix(base, Colors.fg, 0.08) : mix(base, Colors.bg, 0.22)
        if (id === "skeuos-workshop") {
            if (pressed) return mix(base, Colors.fg, 0.12)
            if (role === "metal") return mix(base, Colors.bg, 0.34)
            if (role === "paper") return mix(base, Colors.bg, 0.07)
            if (role === "wood") return mix(base, Colors.bg, 0.12)
            return mix(base, Colors.bg, 0.24)
        }
        return base
    }
    function bevelLight(pressed, skinId) {
        var amount = (skinId || currentId) === "skeuos-workshop" ? 0.48 : 0.38
        return pressed ? mix(Colors.bg, Colors.dim, amount) : mix(Colors.fg, Colors.surface, amount)
    }
    function bevelDark(pressed, skinId) {
        var amount = (skinId || currentId) === "skeuos-workshop" ? 0.48 : 0.35
        return pressed ? mix(Colors.fg, Colors.surface, amount) : mix(Colors.bg, Colors.dim, amount)
    }
    function textureForRole(skinId, role) {
        var selected = recipe(skinId || currentId)
        if ((skinId || currentId) === "skeuos-workshop") {
            if (role === "wood") return selected.textureSource
            if (role === "paper") return selected.controlTextureSource
            if (role === "metal") return selected.metalTextureSource
        }
        if (role === "background" || role === "panel") return selected.textureSource
        if (role === "control" || role === "raised" || role === "sunken") return selected.controlTextureSource
        return ""
    }
    function textureOpacityForRole(skinId, role) {
        var selected = recipe(skinId || currentId)
        if ((skinId || currentId) === "skeuos-workshop") {
            if (role === "wood") return selected.textureOpacity
            if (role === "paper") return selected.controlTextureOpacity
            if (role === "metal") return selected.metalTextureOpacity
        }
        if (role === "background" || role === "panel") return selected.textureOpacity
        if (role === "control" || role === "raised" || role === "sunken") return selected.controlTextureOpacity
        return 0
    }
    function glossOpacityForRole(skinId, role) {
        var selected = recipe(skinId || currentId)
        if ((skinId || currentId) !== "skeuos-workshop") return selected.glossOpacity
        if (role === "metal") return selected.glossOpacity
        if (role === "wood") return selected.glossOpacity * 0.18
        if (role === "paper") return selected.glossOpacity * 0.08
        if (role === "accent") return selected.glossOpacity * 0.55
        return selected.glossOpacity * 0.14
    }

    readonly property string currentId: UIState.skinProfile
    readonly property var current: recipe(currentId)
    readonly property real containerRadius: Metrics.dp(current.containerRadius)
    readonly property real cardRadius: Metrics.dp(current.cardRadius)
    readonly property real controlRadius: Metrics.dp(current.controlRadius)
    readonly property real buttonRadius: Metrics.dp(current.buttonRadius)
    readonly property real fieldRadius: Metrics.dp(current.fieldRadius)
    readonly property real sliderTrackHeight: Metrics.dp(current.sliderTrackHeight)
    readonly property real sliderThumbSize: Metrics.dp(current.sliderThumbSize)
    readonly property real sliderThumbWidth: Metrics.dp(current.sliderThumbWidth)
    readonly property real progressHeight: Metrics.dp(current.progressHeight)
    readonly property real switchWidth: Metrics.dp(current.switchWidth)
    readonly property real switchHeight: Metrics.dp(current.switchHeight)
    readonly property real switchThumbSize: Metrics.dp(current.switchThumbSize)
    readonly property real controlHeight: Metrics.dp(current.controlHeight)
    readonly property real rowHeight: Metrics.dp(current.rowHeight)
    readonly property real borderWidth: Metrics.dp(current.borderWidth)
    readonly property real bevelWidth: Metrics.dp(current.bevelWidth)
    readonly property real gap: Metrics.dp(current.gap)
    readonly property url textureSource: current.textureSource
    readonly property real textureOpacity: current.textureOpacity
    readonly property url controlTextureSource: current.controlTextureSource
    readonly property real controlTextureOpacity: current.controlTextureOpacity
    readonly property url metalTextureSource: current.metalTextureSource
    readonly property real metalTextureOpacity: current.metalTextureOpacity
    readonly property real glossOpacity: current.glossOpacity
    readonly property real innerLineWidth: Metrics.dp(current.innerLineWidth)
    readonly property real hardwareSize: Metrics.dp(current.hardwareSize)
    readonly property real hardwareOpacity: current.hardwareOpacity
    readonly property bool rowMaterial: current.rowMaterial
    readonly property int mangoRadius: current.mangoRadius
}
