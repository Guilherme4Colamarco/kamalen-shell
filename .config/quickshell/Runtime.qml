pragma Singleton
import Quickshell
import QtQuick

Singleton {
    readonly property string basePath: Quickshell.env("HOME") + "/.config/quickshell"
    readonly property string supervisorPath: basePath + "/process_supervisor.py"
    readonly property string stateStorePath: basePath + "/state_store.py"

    function supervise(command) {
        var wrapped = ["python3", supervisorPath, "--"]
        for (var i = 0; i < command.length; i++) wrapped.push(command[i])
        return wrapped
    }

    function writeJsonCommand(path, value) {
        return ["python3", stateStorePath, "write-json", path, JSON.stringify(value)]
    }
}
