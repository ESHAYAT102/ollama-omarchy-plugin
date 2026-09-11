pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui

BarWidget {
  id: root

  moduleName: "esh.ollama"

  property string endpoint: "http://127.0.0.1:11434"
  property string remoteEndpoint: ""
  property bool firstRunPromptPending: false

  readonly property string scriptPath: Quickshell.env("HOME") + "/.config/omarchy/plugins/esh.ollama/set-endpoint.sh"
  readonly property string installScriptPath: Quickshell.env("HOME") + "/.config/omarchy/plugins/esh.ollama/install.sh"
  readonly property bool usingRemote: remoteEndpoint !== "" && endpoint === remoteEndpoint
  readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false
  readonly property bool popoutSwitchClosing: panelLoader.item ? panelLoader.item.popoutSwitchClosing === true : false

  function open() {
    if (panelLoader.item) panelLoader.item.open()
  }

  function close() {
    if (panelLoader.item) panelLoader.item.close()
  }

  function toggle() {
    if (panelLoader.item) panelLoader.item.toggle()
  }

  function closeForPopoutSwitch() {
    if (panelLoader.item) panelLoader.item.closeForPopoutSwitch()
  }

  function injectPanel() {
    if (!panelLoader.item) return
    panelLoader.item.bar = root.bar
    panelLoader.item.anchorItem = button
    panelLoader.item.hostWidget = root
  }

  function scheduleFirstRunPrompt() {
    firstRunPromptPending = true
    firstRunTimer.restart()
  }

  function writeEndpoint(value, rememberRemote) {
    var normalized = String(value || "").trim()
    if (normalized.indexOf("http://") !== 0 && normalized.indexOf("https://") !== 0)
      normalized = "http://" + normalized

    writer.command = rememberRemote
      ? [root.scriptPath, normalized, "remote"]
      : [root.scriptPath, normalized]
    writer.running = true
    root.endpoint = normalized
    if (rememberRemote) root.remoteEndpoint = normalized
  }

  function saveRemoteEndpoint(value) {
    writeEndpoint(value, true)
  }

  function switchInstance() {
    if (remoteEndpoint === "") {
      open()
      return
    }
    writeEndpoint(usingRemote ? "http://127.0.0.1:11434" : remoteEndpoint, false)
  }

  Process {
    id: activeReader
    command: ["bash", "-c", "cat \"$HOME/.config/omarchy/esh.ollama/active-endpoint\" 2>/dev/null"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var value = String(text || "").trim()
        if (value !== "") root.endpoint = value
      }
    }
  }

  Process {
    id: remoteReader
    command: ["bash", "-c", "cat \"$HOME/.config/omarchy/esh.ollama/remote-endpoint\" 2>/dev/null"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.remoteEndpoint = String(text || "").trim()
    }
    onExited: function(exitCode) {
      if (exitCode !== 0) root.scheduleFirstRunPrompt()
    }
  }

  Process { id: writer }

  Process {
    id: wrapperInstaller
    command: [root.installScriptPath]
  }

  Timer {
    id: firstRunTimer
    interval: 500
    repeat: false
    onTriggered: {
      root.injectPanel()
      if (!root.firstRunPromptPending) return
      if (!root.bar || !panelLoader.item || button.width <= 0) {
        firstRunTimer.restart()
        return
      }
      root.firstRunPromptPending = false
      root.open()
    }
  }

  Component.onCompleted: {
    wrapperInstaller.running = true
    activeReader.running = true
    remoteReader.running = true
  }

  onBarChanged: {
    injectPanel()
    if (firstRunPromptPending) firstRunTimer.restart()
  }

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
      if (root.firstRunPromptPending) firstRunTimer.restart()
    }
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "\uf4f2"
    active: root.usingRemote
    tooltipText: root.remoteEndpoint === ""
      ? "Ollama: configure remote endpoint"
      : (root.usingRemote
        ? "Ollama: remote (click for local)"
        : "Ollama: local (click for remote)")

    onPressed: function(buttonCode) {
      if (buttonCode === Qt.RightButton) root.open()
      else if (buttonCode === Qt.LeftButton) root.switchInstance()
    }
  }
}
