import QtQuick
import ".."

Flickable {
    width: parent.width
    height: parent.height
    contentHeight: col.height + 20
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    property var animationTypes: ["slide", "zoom", "fade", "none"]
    property var directionLabels: ["Vertical", "Horizontal"]

    Column {
        id: col
        width: parent.width
        spacing: 10

        // ── Tiling ───────────────────────────────────────────────────────────
        ConfigSection {
            title: "Tiling"
            icon: "󰙀"
            expanded: false
            width: parent.width

            ConfigSlider {
                label: "Inner gap (horizontal)"
                value: MangoConfig.mangoGappih
                minValue: 0; maxValue: 64; stepSize: 1; unit: "px"
                onValueModified: v => MangoConfig.set("gappih", v)
            }
            ConfigSlider {
                label: "Inner gap (vertical)"
                value: MangoConfig.mangoGappiv
                minValue: 0; maxValue: 64; stepSize: 1; unit: "px"
                onValueModified: v => MangoConfig.set("gappiv", v)
            }
            ConfigSlider {
                label: "Outer gap (horizontal)"
                value: MangoConfig.mangoGappoh
                minValue: 0; maxValue: 64; stepSize: 1; unit: "px"
                onValueModified: v => MangoConfig.set("gappoh", v)
            }
            ConfigSlider {
                label: "Outer gap (vertical)"
                value: MangoConfig.mangoGappov
                minValue: 0; maxValue: 64; stepSize: 1; unit: "px"
                onValueModified: v => MangoConfig.set("gappov", v)
            }
            ConfigSlider {
                label: "Border width"
                value: MangoConfig.mangoBorderPx
                minValue: 0; maxValue: 8; stepSize: 1; unit: "px"
                onValueModified: v => MangoConfig.set("borderpx", v)
            }
            ConfigSlider {
                label: "Border radius"
                value: MangoConfig.mangoBorderRadius
                minValue: 0; maxValue: 32; stepSize: 1; unit: "px"
                onValueModified: v => MangoConfig.set("border_radius", v)
            }
            ConfigToggle {
                label: "No border when single"
                checked: MangoConfig.mangoNoBorderWhenSingle
                onToggled: c => MangoConfig.set("no_border_when_single", c)
            }
            ConfigToggle {
                label: "No radius when single"
                checked: MangoConfig.mangoNoRadiusWhenSingle
                onToggled: c => MangoConfig.set("no_radius_when_single", c)
            }
            ConfigToggle {
                label: "Smart gaps"
                checked: MangoConfig.mangoSmartGaps
                onToggled: c => MangoConfig.set("smartgaps", c)
            }
            ConfigSlider {
                label: "Master factor"
                value: MangoConfig.mangoDefaultMfact
                minValue: 0.1; maxValue: 0.9; stepSize: 0.05
                onValueModified: v => MangoConfig.set("default_mfact", v)
            }
            ConfigSlider {
                label: "Master count"
                value: MangoConfig.mangoDefaultNmaster
                minValue: 1; maxValue: 5; stepSize: 1
                onValueModified: v => MangoConfig.set("default_nmaster", v)
            }
        }

        // ── Blur ─────────────────────────────────────────────────────────────
        ConfigSection {
            title: "Blur"
            icon: "󰂵"
            expanded: false
            width: parent.width

            ConfigToggle {
                label: "Blur"
                checked: MangoConfig.mangoBlur
                onToggled: c => MangoConfig.set("blur", c)
            }
            ConfigToggle {
                label: "Blur layer surfaces"
                checked: MangoConfig.mangoBlurLayer
                onToggled: c => MangoConfig.set("blur_layer", c)
            }
            ConfigToggle {
                label: "Optimized blur"
                checked: MangoConfig.mangoBlurOptimized
                onToggled: c => MangoConfig.set("blur_optimized", c)
            }
            ConfigSlider {
                label: "Blur passes"
                value: MangoConfig.mangoBlurPasses
                minValue: 0; maxValue: 8; stepSize: 1
                onValueModified: v => MangoConfig.set("blur_params_num_passes", v)
            }
            ConfigSlider {
                label: "Blur radius"
                value: MangoConfig.mangoBlurRadius
                minValue: 0; maxValue: 30; stepSize: 1; unit: "px"
                onValueModified: v => MangoConfig.set("blur_params_radius", v)
            }
        }

        // ── Shadows ──────────────────────────────────────────────────────────
        ConfigSection {
            title: "Shadows"
            icon: "󰧑"
            expanded: false
            width: parent.width

            ConfigToggle {
                label: "Shadows"
                checked: MangoConfig.mangoShadows
                onToggled: c => MangoConfig.set("shadows", c)
            }
            ConfigToggle {
                label: "Layer shadows"
                checked: MangoConfig.mangoShadowLayer
                onToggled: c => MangoConfig.set("layer_shadows", c)
            }
            ConfigToggle {
                label: "Shadow only on floating"
                checked: MangoConfig.mangoShadowOnlyFloating
                onToggled: c => MangoConfig.set("shadow_only_floating", c)
            }
            ConfigSlider {
                label: "Shadow size"
                value: MangoConfig.mangoShadowSize
                minValue: 0; maxValue: 48; stepSize: 1; unit: "px"
                onValueModified: v => MangoConfig.set("shadows_size", v)
            }
            ConfigSlider {
                label: "Shadow blur"
                value: MangoConfig.mangoShadowBlur
                minValue: 0; maxValue: 40; stepSize: 1; unit: "px"
                onValueModified: v => MangoConfig.set("shadows_blur", v)
            }
            ConfigSlider {
                label: "Shadow offset X"
                value: MangoConfig.mangoShadowPosX
                minValue: -20; maxValue: 20; stepSize: 1; unit: "px"
                onValueModified: v => MangoConfig.set("shadows_position_x", v)
            }
            ConfigSlider {
                label: "Shadow offset Y"
                value: MangoConfig.mangoShadowPosY
                minValue: -20; maxValue: 20; stepSize: 1; unit: "px"
                onValueModified: v => MangoConfig.set("shadows_position_y", v)
            }
        }

        // ── Opacity ──────────────────────────────────────────────────────────
        ConfigSection {
            title: "Opacity"
            icon: "󰌁"
            expanded: false
            width: parent.width

            ConfigSlider {
                label: "Focused opacity"
                value: MangoConfig.mangoFocusedOpacity
                minValue: 0.2; maxValue: 1.0; stepSize: 0.05
                onValueModified: v => MangoConfig.set("focused_opacity", v)
            }
            ConfigSlider {
                label: "Unfocused opacity"
                value: MangoConfig.mangoUnfocusedOpacity
                minValue: 0.2; maxValue: 1.0; stepSize: 0.05
                onValueModified: v => MangoConfig.set("unfocused_opacity", v)
            }
        }

        // ── Input ────────────────────────────────────────────────────────────
        ConfigSection {
            title: "Input"
            icon: "󰌌"
            expanded: false
            width: parent.width

            ConfigSlider {
                label: "Repeat rate"
                value: MangoConfig.mangoRepeatRate
                minValue: 10; maxValue: 100; stepSize: 5
                onValueModified: v => MangoConfig.set("repeat_rate", v)
            }
            ConfigSlider {
                label: "Repeat delay"
                value: MangoConfig.mangoRepeatDelay
                minValue: 100; maxValue: 1000; stepSize: 50; unit: "ms"
                onValueModified: v => MangoConfig.set("repeat_delay", v)
            }
            ConfigToggle {
                label: "Tap to click"
                checked: MangoConfig.mangoTapToClick
                onToggled: c => MangoConfig.set("tap_to_click", c)
            }
            ConfigToggle {
                label: "Natural scrolling"
                checked: MangoConfig.mangoTrackpadNaturalScroll
                onToggled: c => MangoConfig.set("trackpad_natural_scrolling", c)
            }
        }

        // ── Focus ────────────────────────────────────────────────────────────
        ConfigSection {
            title: "Focus"
            icon: "󰁥"
            expanded: false
            width: parent.width

            ConfigToggle {
                label: "Focus on activate"
                checked: MangoConfig.mangoFocusOnActivate
                onToggled: c => MangoConfig.set("focus_on_activate", c)
            }
            ConfigToggle {
                label: "Sloppy focus"
                checked: MangoConfig.mangoSloppyFocus
                onToggled: c => MangoConfig.set("sloppyfocus", c)
            }
            ConfigToggle {
                label: "Warp cursor"
                checked: MangoConfig.mangoWarpCursor
                onToggled: c => MangoConfig.set("warpcursor", c)
            }
            ConfigToggle {
                label: "Focus cross monitor"
                checked: MangoConfig.mangoFocusCrossMonitor
                onToggled: c => MangoConfig.set("focus_cross_monitor", c)
            }
            ConfigToggle {
                label: "Focus cross tag"
                checked: MangoConfig.mangoFocusCrossTag
                onToggled: c => MangoConfig.set("focus_cross_tag", c)
            }
            ConfigToggle {
                label: "Floating snap"
                checked: MangoConfig.mangoEnableFloatingSnap
                onToggled: c => MangoConfig.set("enable_floating_snap", c)
            }
            ConfigToggle {
                label: "Drag tile to tile"
                checked: MangoConfig.mangoDragTileToTile
                onToggled: c => MangoConfig.set("drag_tile_to_tile", c)
            }
            ConfigSlider {
                label: "Snap distance"
                value: MangoConfig.mangoSnapDistance
                minValue: 0; maxValue: 100; stepSize: 1; unit: "px"
                onValueModified: v => MangoConfig.set("snap_distance", v)
            }
        }

        // ── Animations ───────────────────────────────────────────────────────
        ConfigSection {
            title: "Animations"
            icon: "󰔵"
            expanded: false
            width: parent.width

            ConfigToggle {
                label: "Animations"
                checked: MangoConfig.mangoAnimations
                onToggled: c => MangoConfig.set("animations", c)
            }
            ConfigToggle {
                label: "Layer animations"
                checked: MangoConfig.mangoLayerAnimations
                onToggled: c => MangoConfig.set("layer_animations", c)
            }
            ConfigToggle {
                label: "Fade in"
                checked: MangoConfig.mangoAnimationFadeIn
                onToggled: c => MangoConfig.set("animation_fade_in", c)
            }
            ConfigToggle {
                label: "Fade out"
                checked: MangoConfig.mangoAnimationFadeOut
                onToggled: c => MangoConfig.set("animation_fade_out", c)
            }
            ConfigSpinner {
                label: "Open animation"
                model: animationTypes
                currentIndex: animationTypes.indexOf(MangoConfig.mangoAnimationTypeOpen)
                onActivated: idx => MangoConfig.set("animation_type_open", animationTypes[idx])
            }
            ConfigSpinner {
                label: "Close animation"
                model: animationTypes
                currentIndex: animationTypes.indexOf(MangoConfig.mangoAnimationTypeClose)
                onActivated: idx => MangoConfig.set("animation_type_close", animationTypes[idx])
            }
            ConfigSpinner {
                label: "Layer open animation"
                model: animationTypes
                currentIndex: animationTypes.indexOf(MangoConfig.mangoLayerAnimationTypeOpen)
                onActivated: idx => MangoConfig.set("layer_animation_type_open", animationTypes[idx])
            }
            ConfigSpinner {
                label: "Layer close animation"
                model: animationTypes
                currentIndex: animationTypes.indexOf(MangoConfig.mangoLayerAnimationTypeClose)
                onActivated: idx => MangoConfig.set("layer_animation_type_close", animationTypes[idx])
            }
            ConfigSpinner {
                label: "Tag animation direction"
                model: directionLabels
                currentIndex: MangoConfig.mangoAnimationDirection
                onActivated: idx => MangoConfig.set("tag_animation_direction", idx)
            }
            ConfigSlider {
                label: "Open duration"
                value: MangoConfig.mangoAnimationDurationOpen
                minValue: 0; maxValue: 1000; stepSize: 20; unit: "ms"
                onValueModified: v => MangoConfig.set("animation_duration_open", v)
            }
            ConfigSlider {
                label: "Close duration"
                value: MangoConfig.mangoAnimationDurationClose
                minValue: 0; maxValue: 1000; stepSize: 20; unit: "ms"
                onValueModified: v => MangoConfig.set("animation_duration_close", v)
            }
            ConfigSlider {
                label: "Move duration"
                value: MangoConfig.mangoAnimationDurationMove
                minValue: 0; maxValue: 1000; stepSize: 20; unit: "ms"
                onValueModified: v => MangoConfig.set("animation_duration_move", v)
            }
            ConfigSlider {
                label: "Tag duration"
                value: MangoConfig.mangoAnimationDurationTag
                minValue: 0; maxValue: 1000; stepSize: 20; unit: "ms"
                onValueModified: v => MangoConfig.set("animation_duration_tag", v)
            }
            ConfigSlider {
                label: "Focus duration"
                value: MangoConfig.mangoAnimationDurationFocus
                minValue: 0; maxValue: 1000; stepSize: 20; unit: "ms"
                onValueModified: v => MangoConfig.set("animation_duration_focus", v)
            }
            ConfigSlider {
                label: "Zoom initial ratio"
                value: MangoConfig.mangoZoomInitialRatio
                minValue: 0.1; maxValue: 1.0; stepSize: 0.02
                onValueModified: v => MangoConfig.set("zoom_initial_ratio", v)
            }
            ConfigSlider {
                label: "Zoom end ratio"
                value: MangoConfig.mangoZoomEndRatio
                minValue: 1.0; maxValue: 1.2; stepSize: 0.02
                onValueModified: v => MangoConfig.set("zoom_end_ratio", v)
            }
            ConfigSlider {
                label: "Fade-in begin opacity"
                value: MangoConfig.mangoFadeinBeginOpacity
                minValue: 0.0; maxValue: 1.0; stepSize: 0.05
                onValueModified: v => MangoConfig.set("fadein_begin_opacity", v)
            }
            ConfigSlider {
                label: "Fade-out begin opacity"
                value: MangoConfig.mangoFadeoutBeginOpacity
                minValue: 0.0; maxValue: 1.0; stepSize: 0.05
                onValueModified: v => MangoConfig.set("fadeout_begin_opacity", v)
            }
        }

        // ── Colors ───────────────────────────────────────────────────────────
        ConfigSection {
            title: "Colors"
            icon: "󰏘"
            expanded: false
            width: parent.width

            ConfigColorRow {
                label: "Root"
                colorValue: MangoConfig.mangoRootColor
                onColorChanged: c => MangoConfig.set("rootcolor", c)
            }
            ConfigColorRow {
                label: "Border"
                colorValue: MangoConfig.mangoBorderColor
                onColorChanged: c => MangoConfig.set("bordercolor", c)
            }
            ConfigColorRow {
                label: "Focus"
                colorValue: MangoConfig.mangoFocusColor
                onColorChanged: c => MangoConfig.set("focuscolor", c)
            }
            ConfigColorRow {
                label: "Urgent"
                colorValue: MangoConfig.mangoUrgentColor
                onColorChanged: c => MangoConfig.set("urgentcolor", c)
            }
            ConfigColorRow {
                label: "Scratchpad"
                colorValue: MangoConfig.mangoScratchpadColor
                onColorChanged: c => MangoConfig.set("scratchpadcolor", c)
            }
            ConfigColorRow {
                label: "Global"
                colorValue: MangoConfig.mangoGlobalColor
                onColorChanged: c => MangoConfig.set("globalcolor", c)
            }
            ConfigColorRow {
                label: "Overlay"
                colorValue: MangoConfig.mangoOverlayColor
                onColorChanged: c => MangoConfig.set("overlaycolor", c)
            }
            ConfigColorRow {
                label: "Maximized screen"
                colorValue: MangoConfig.mangoMaximizescreenColor
                onColorChanged: c => MangoConfig.set("maximizescreencolor", c)
            }
            ConfigColorRow {
                label: "Shadows"
                colorValue: MangoConfig.mangoShadowColor
                onColorChanged: c => MangoConfig.set("shadowscolor", c)
            }
        }
    }
}
