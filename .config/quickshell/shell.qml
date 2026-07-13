//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
    Bar {}
    SettingsWindow {}

    Variants {
        model: Quickshell.screens
        Dashboard { property var modelData; screen: modelData }
    }

    Variants {
        model: Quickshell.screens
        Launcher { property var modelData; screen: modelData }
    }

    Variants {
        model: Quickshell.screens
        Wallpaper { property var modelData; screen: modelData }
    }

    Variants {
        model: Quickshell.screens
        Music { property var modelData; screen: modelData }
    }

    Variants {
        model: Quickshell.screens
        Calendar { property var modelData; screen: modelData }
    }

    Variants {
        model: Quickshell.screens
        NotificationPopup { property var modelData; screen: modelData }
    }

    Variants {
        model: Quickshell.screens
        Lockscreen { property var modelData; screen: modelData }
    }

    Variants {
        model: Quickshell.screens
        PowerMenu { property var modelData; screen: modelData }
    }

    Variants {
        model: Quickshell.screens
        LayoutMenu { property var modelData; screen: modelData }
    }

    Variants {
        model: Quickshell.screens
        ClipboardMenu { property var modelData; screen: modelData }
    }

    Process {
        id: ipcBridge
        command: Runtime.supervise([
            "python3", Quickshell.env("HOME") + "/.config/quickshell/ipc_bridge.py",
            "launcher=/tmp/qs-launcher-toggle",
            "lock=" + Quickshell.env("HOME") + "/.cache/qs/lock",
            "power=/tmp/qs-power-menu",
            "layout=/tmp/qs-layout-menu",
            "clipboard=/tmp/qs-clipboard-toggle",
            "wallpaper=/tmp/qs-wallpaper-toggle",
            "media=/tmp/qs-media-toggle",
            "dashboard=/tmp/qs-dashboard-toggle",
            "settings=/tmp/qs-settings-toggle",
            "shortcuts=/tmp/qs-shortcuts-toggle"
        ])
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                var route = data.trim()
                if (!route || route === "READY") return
                if (route !== "lock" && UIState.locked) return
                switch (route) {
                case "launcher": UIState.toggleDropdown("launcher"); break
                case "lock": UIState.lock(); break
                case "power": UIState.togglePowerMenu(); break
                case "layout": UIState.toggleLayoutMenu(); break
                case "clipboard": UIState.toggleClipboardMenu(); break
                case "wallpaper": UIState.toggleDropdown("wallpaper"); break
                case "media": UIState.toggleDropdown("media"); break
                case "dashboard": UIState.toggleDropdown("dashboard"); break
                case "settings": UIState.toggleSettings(); break
                case "shortcuts": UIState.showShortcutHelp(); break
                }
            }
        }
        onExited: ipcBridgeRestart.start()
    }

    Timer { id: ipcBridgeRestart; interval: 1000; onTriggered: ipcBridge.running = true }

    Process {
        id: tiramisu
        command: Runtime.supervise([Quickshell.env("HOME") + "/.config/quickshell/dbus-notifier.py"])
        running: true
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim()
                if (line.length === 0) return

                var parts = line.split("\t")
                if (parts.length < 3) return

                var app = parts[0] || "Unknown"
                var title = parts[1] || ""
                var body = parts.slice(2).join(" ")

                UIState.addNotification(app, title, body)
            }
        }
        onExited: tiramisuRestart.start()
    }

    Timer { id: tiramisuRestart; interval: 2000; onTriggered: tiramisu.running = true }

    Timer {
        id: wallPregenDelay
        interval: 5000
        running: true
        onTriggered: wallPregenProc.running = true
    }

    Process {
        id: wallPregenProc
        command: ["bash", "-c", [
            "shopt -s nullglob",
            "CACHE=\"$HOME/.cache/wallpaper-thumbs\"",
            "mkdir -p \"$CACHE\"",
            "touch \"$CACHE/colors.tsv\"",
            "",
            "for f in \"$HOME\"/wallpapers/*.{jpg,jpeg,png,gif,webp}; do",
            "  [ -L \"$f\" ] && continue",
            "  name=$(basename \"$f\")",
            "  thumb=\"$CACHE/${name}.thumb.jpg\"",
            "  [ -f \"$thumb\" ] && continue",
            "  magick \"${f}[0]\" -resize 600x -quality 85 \"$thumb\" 2>/dev/null",
            "done",
            "",
            "for f in \"$HOME\"/wallpapers/*.{jpg,jpeg,png,gif,webp}; do",
            "  [ -L \"$f\" ] && continue",
            "  name=$(basename \"$f\")",
            "  grep -qF \"$name\" \"$CACHE/colors.tsv\" 2>/dev/null && continue",
            "  best='' best_c=0",
            "  while IFS= read -r line; do",
            "    hex=$(echo \"$line\" | grep -oP '#[0-9A-Fa-f]{6}' | head -1)",
            "    [ -z \"$hex\" ] && continue",
            "    h=\"${hex#\\#}\"",
            "    r=$((16#${h:0:2})) g=$((16#${h:2:2})) b=$((16#${h:4:2}))",
            "    mx=$r; [ $g -gt $mx ] && mx=$g; [ $b -gt $mx ] && mx=$b",
            "    mn=$r; [ $g -lt $mn ] && mn=$g; [ $b -lt $mn ] && mn=$b",
            "    c=$((mx-mn))",
            "    if [ $c -gt $best_c ]; then best_c=$c; best=\"$hex\"; fi",
            "  done < <(magick \"${f}[0]\" -resize 50x50! -colors 5 -depth 8 -format '%c' histogram:info: 2>/dev/null)",
            "  [ -z \"$best\" ] && best=$(magick \"${f}[0]\" -resize 1x1! -format '#%[hex:u.p{0,0}]' info: 2>/dev/null)",
            "  [ -z \"$best\" ] && continue",
            "  printf '%s\\t%s\\n' \"$name\" \"$best\" >> \"$CACHE/colors.tsv\"",
            "done",
            "",
            "json='['",
            "first=1",
            "for f in \"$HOME\"/wallpapers/*.{jpg,jpeg,png,gif,webp}; do",
            "  [ -L \"$f\" ] && continue",
            "  name=$(basename \"$f\")",
            "  color=$(grep -F \"$name\" \"$CACHE/colors.tsv\" 2>/dev/null | head -1 | cut -f2)",
            "  [ $first -eq 0 ] && json=\"${json},\"",
            "  first=0",
            "  json=\"${json}{\\\"name\\\":\\\"${name}\\\",\\\"color\\\":\\\"${color}\\\"}\"",
            "done",
            "json=\"${json}]\"",
            "echo \"$json\" > \"$CACHE/walls.json\""
        ].join("\n")]
    }

    Timer {
        id: wallpaperApplyDelay
        interval: 1500
        running: true
        onTriggered: wallpaperApplyProc.running = true
    }

    Process {
        id: wallpaperApplyProc
        command: ["bash", "-c", [
            "current=\"$HOME/wallpapers/current\"",
            "[ -L \"$current\" ] || exit 0",
            "wall=$(readlink -f \"$current\")",
            "[ -f \"$wall\" ] || exit 0",
            "ext=\"${wall##*.}\"",
            "ext=$(echo \"$ext\" | tr '[:upper:]' '[:lower:]')",
            "",
            "case \"$ext\" in",
            "  mp4|webm|mkv)",
            "    frame=\"/tmp/wall-frame-$$.jpg\"",
            "    ffmpeg -i \"$wall\" -vframes 1 -q:v 2 \"$frame\" -y 2>/dev/null",
            "    awww img --transition-type wipe \"$frame\" 2>/dev/null",
            "    sleep 1.5",
            "    pkill -f \"mpvpaper.*$wall\" 2>/dev/null",
            "    mpvpaper --fork -o 'no-audio loop-file=inf hwdec=auto-safe panscan=1.0' '*' \"$wall\" 2>/dev/null",
            "    rm -f \"$frame\"",
            "    ;;",
            "  *)",
            "    awww img --transition-type wipe \"$wall\" 2>/dev/null",
            "    ;;",
            "esac"
        ].join("\n")]
    }

    Connections {
        target: UIState
        function onLockedChanged() {
            videoWallpaperControl.command = [
                "pkill", UIState.locked ? "-STOP" : "-CONT", "mpvpaper"
            ]
            videoWallpaperControl.running = true
        }
    }

    Process { id: videoWallpaperControl }

    PolkitDialog {}
}
