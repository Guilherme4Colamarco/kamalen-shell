pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: mangoConfig

    // -------------------------------------------------------------------------
    // Exposed properties (reactive, loaded from the Python backend on startup)
    // -------------------------------------------------------------------------

    // Gaps
    property int  mangoGappih: 6
    property int  mangoGappiv: 6
    property int  mangoGappoh: 8
    property int  mangoGappov: 8

    // Borders
    property int  mangoBorderPx: 1
    property int  mangoBorderRadius: 16
    property bool mangoNoBorderWhenSingle: true
    property bool mangoNoRadiusWhenSingle: false

    // Opacity
    property real mangoFocusedOpacity: 1.0
    property real mangoUnfocusedOpacity: 0.85

    // Blur
    property bool mangoBlur: true
    property bool mangoBlurLayer: true
    property bool mangoBlurOptimized: false
    property int  mangoBlurPasses: 4
    property int  mangoBlurRadius: 14

    // Shadows
    property bool mangoShadows: true
    property bool mangoShadowLayer: true
    property bool mangoShadowOnlyFloating: true
    property int  mangoShadowSize: 18
    property int  mangoShadowBlur: 15
    property int  mangoShadowPosX: 0
    property int  mangoShadowPosY: 6

    // Input
    property int  mangoRepeatRate: 50
    property int  mangoRepeatDelay: 300
    property bool mangoTapToClick: true
    property bool mangoTrackpadNaturalScroll: false

    // Focus
    property bool mangoSloppyFocus: true
    property bool mangoWarpCursor: true

    // -------------------------------------------------------------------------
    // Internal state
    // -------------------------------------------------------------------------

    property string _configPath: Quickshell.env("HOME") + "/.config/mango/mango_config.py"
    property var    _data: ({})        // grouped JSON payload from get-all
    property bool   _ready: false

    // Maps MangoWM config keys to QML property names.
    property var keyToProperty: ({
        // gaps
        "gappih": "mangoGappih",
        "gappiv": "mangoGappiv",
        "gappoh": "mangoGappoh",
        "gappov": "mangoGappov",

        // borders
        "borderpx": "mangoBorderPx",
        "border_radius": "mangoBorderRadius",
        "no_border_when_single": "mangoNoBorderWhenSingle",
        "no_radius_when_single": "mangoNoRadiusWhenSingle",

        // opacity
        "focused_opacity": "mangoFocusedOpacity",
        "unfocused_opacity": "mangoUnfocusedOpacity",

        // blur
        "blur": "mangoBlur",
        "blur_layer": "mangoBlurLayer",
        "blur_optimized": "mangoBlurOptimized",
        "blur_params_num_passes": "mangoBlurPasses",
        "blur_params_radius": "mangoBlurRadius",

        // shadows
        "shadows": "mangoShadows",
        "layer_shadows": "mangoShadowLayer",
        "shadow_only_floating": "mangoShadowOnlyFloating",
        "shadows_size": "mangoShadowSize",
        "shadows_blur": "mangoShadowBlur",
        "shadows_position_x": "mangoShadowPosX",
        "shadows_position_y": "mangoShadowPosY",

        // input-keyboard
        "repeat_rate": "mangoRepeatRate",
        "repeat_delay": "mangoRepeatDelay",

        // input-trackpad
        "tap_to_click": "mangoTapToClick",
        "trackpad_natural_scrolling": "mangoTrackpadNaturalScroll",

        // focus
        "sloppyfocus": "mangoSloppyFocus",
        "warpcursor": "mangoWarpCursor"
    })

    property var propertyToKey: ({
        "mangoGappih": "gappih",
        "mangoGappiv": "gappiv",
        "mangoGappoh": "gappoh",
        "mangoGappov": "gappov",

        "mangoBorderPx": "borderpx",
        "mangoBorderRadius": "border_radius",
        "mangoNoBorderWhenSingle": "no_border_when_single",
        "mangoNoRadiusWhenSingle": "no_radius_when_single",

        "mangoFocusedOpacity": "focused_opacity",
        "mangoUnfocusedOpacity": "unfocused_opacity",

        "mangoBlur": "blur",
        "mangoBlurLayer": "blur_layer",
        "mangoBlurOptimized": "blur_optimized",
        "mangoBlurPasses": "blur_params_num_passes",
        "mangoBlurRadius": "blur_params_radius",

        "mangoShadows": "shadows",
        "mangoShadowLayer": "layer_shadows",
        "mangoShadowOnlyFloating": "shadow_only_floating",
        "mangoShadowSize": "shadows_size",
        "mangoShadowBlur": "shadows_blur",
        "mangoShadowPosX": "shadows_position_x",
        "mangoShadowPosY": "shadows_position_y",

        "mangoRepeatRate": "repeat_rate",
        "mangoRepeatDelay": "repeat_delay",

        "mangoTapToClick": "tap_to_click",
        "mangoTrackpadNaturalScroll": "trackpad_natural_scrolling",

        "mangoSloppyFocus": "sloppyfocus",
        "mangoWarpCursor": "warpcursor"
    })

    property var keyToModule: ({
        "gappih": "gaps",
        "gappiv": "gaps",
        "gappoh": "gaps",
        "gappov": "gaps",

        "borderpx": "borders",
        "border_radius": "borders",
        "no_border_when_single": "borders",
        "no_radius_when_single": "borders",

        "focused_opacity": "opacity",
        "unfocused_opacity": "opacity",

        "blur": "blur",
        "blur_layer": "blur",
        "blur_optimized": "blur",
        "blur_params_num_passes": "blur",
        "blur_params_radius": "blur",

        "shadows": "shadows",
        "layer_shadows": "shadows",
        "shadow_only_floating": "shadows",
        "shadows_size": "shadows",
        "shadows_blur": "shadows",
        "shadows_position_x": "shadows",
        "shadows_position_y": "shadows",

        "repeat_rate": "input-keyboard",
        "repeat_delay": "input-keyboard",

        "tap_to_click": "input-trackpad",
        "trackpad_natural_scrolling": "input-trackpad",

        "sloppyfocus": "focus",
        "warpcursor": "focus"
    })

    property var _boolKeys: ({
        "no_border_when_single": true,
        "no_radius_when_single": true,
        "blur": true,
        "blur_layer": true,
        "blur_optimized": true,
        "shadows": true,
        "layer_shadows": true,
        "shadow_only_floating": true,
        "tap_to_click": true,
        "trackpad_natural_scrolling": true,
        "sloppyfocus": true,
        "warpcursor": true
    })

    // -------------------------------------------------------------------------
    // Public API
    // -------------------------------------------------------------------------

    function set(key, value) {
        runCmd(["set-apply", key, _toMangoValue(value)])
        _updateLocalProperty(key, value)
    }

    function setNoApply(key, value) {
        runCmd(["set", key, _toMangoValue(value)])
        _updateLocalProperty(key, value)
    }

    function apply(key, value) {
        runCmd(["apply", key, _toMangoValue(value)])
        _updateLocalProperty(key, value)
    }

    function get(key) {
        var module = keyToModule[key]
        if (!module || !_data[module]) return undefined
        return _data[module][key]
    }

    function getModule(module) {
        return _data[module] || {}
    }

    function reload() {
        runCmd(["reload"])
    }

    function setMany(pairs) {
        runCmd(["set-many", JSON.stringify(pairs)])
        for (var key in pairs) _updateLocalProperty(key, pairs[key])
    }

    function setModule(module, pairs) {
        runCmd(["set-module", module, JSON.stringify(pairs), "--reload"])
        for (var key in pairs) _updateLocalProperty(key, pairs[key])
    }

    function loadAll() {
        loadProc.running = false
        loadProc.running = true
    }

    // -------------------------------------------------------------------------
    // Process helpers
    // -------------------------------------------------------------------------

    function runCmd(args) {
        var cmd = ["python3", _configPath].concat(args)
        cmdProc.command = cmd
        cmdProc.running = false
        cmdProc.running = true
    }

    function _toMangoValue(value) {
        if (typeof value === "boolean") return value ? "1" : "0"
        return String(value)
    }

    function _toQmlValue(key, raw) {
        if (_boolKeys[key]) {
            if (typeof raw === "boolean") return raw
            return String(raw) === "1"
        }

        var propName = keyToProperty[key]
        if (!propName) return raw

        var propType = typeof mangoConfig[propName]
        if (propType === "number") {
            var n = Number(raw)
            return isNaN(n) ? raw : n
        }
        return raw
    }

    function _updateLocalProperty(key, value) {
        var propName = keyToProperty[key]
        if (!propName) return
        mangoConfig[propName] = _toQmlValue(key, value)

        var module = keyToModule[key]
        if (module && _data[module]) {
            _data[module][key] = _toQmlValue(key, value)
        }
    }

    function _applyAll(data) {
        try {
            var parsed = JSON.parse(data)
            _data = parsed

            for (var key in keyToProperty) {
                var module = keyToModule[key]
                if (!module || !parsed[module]) continue

                var raw = parsed[module][key]
                if (raw === undefined || raw === null) continue

                var propName = keyToProperty[key]
                mangoConfig[propName] = _toQmlValue(key, raw)
            }

            _ready = true
        } catch (e) {
            console.log("MangoConfig: failed to parse get-all output:", e)
        }
    }

    // -------------------------------------------------------------------------
    // Processes
    // -------------------------------------------------------------------------

    Process {
        id: loadProc
        command: ["python3", mangoConfig._configPath, "get-all"]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => mangoConfig._applyAll(data)
        }
        onExited: exitCode => {
            if (exitCode !== 0) {
                console.log("MangoConfig: get-all exited with code", exitCode)
            }
        }
    }

    Process {
        id: cmdProc
        onExited: exitCode => {
            if (exitCode !== 0) {
                console.log("MangoConfig: command exited with code", exitCode,
                            "command:", JSON.stringify(command))
            }
        }
    }

    // -------------------------------------------------------------------------
    // Lifecycle
    // -------------------------------------------------------------------------

    Component.onCompleted: loadAll()
}
