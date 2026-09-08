pragma ComponentBehavior: Bound

import QtQuick
import qs.Commons
import qs.Ui

Panel {
  id: root

  moduleName: "esh.ollama"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null

  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color dim: Qt.darker(foreground, 1.5)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family

  function open() {
    root.controller.show()
    endpointField.text = hostWidget && hostWidget.remoteEndpoint !== ""
      ? hostWidget.remoteEndpoint
      : ""
    Qt.callLater(function() {
      endpointField.forceActiveFocus()
      endpointField.selectAll()
    })
  }

  function close() {
    root.controller.hide()
  }

  function toggle() {
    root.opened ? close() : open()
  }

  function closeForPopoutSwitch() {
    root.popoutSwitchClosing = true
    close()
    Qt.callLater(function() { root.popoutSwitchClosing = false })
  }

  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.hostWidget || root, direction)
    return false
  }

  function save() {
    var value = endpointField.text.trim()
    if (value === "" || !hostWidget) return
    hostWidget.saveRemoteEndpoint(value)
    close()
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.hostWidget || root
    bar: root.bar
    open: root.opened
    focusTarget: endpointField
    contentWidth: panel.fittedContentWidth(Style.space(380))
    contentHeight: panel.fittedContentHeight(content.implicitHeight)

    PanelKeyCatcher {
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: content
        width: parent.width
        spacing: Style.space(14)

        PanelHero {
          width: parent.width
          title: "OLLAMA"
          meta: root.hostWidget && root.hostWidget.remoteEndpoint !== ""
            ? "REMOTE INSTANCE"
            : "CONNECT A MACHINE"
          foreground: root.foreground
          fontFamily: root.fontFamily
          iconComponent: Component {
            Text {
              text: "󰚩"
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.display
            }
          }
        }

        PanelSeparator {
          width: parent.width
          foreground: root.foreground
        }

        PanelSectionHeader {
          text: "REMOTE ENDPOINT"
          foreground: root.foreground
          fontFamily: root.fontFamily
        }

        Text {
          width: parent.width
          text: "Enter the Tailscale hostname and Ollama port."
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.bodySmall
          wrapMode: Text.WordWrap
        }

        TextField {
          id: endpointField
          width: parent.width
          placeholderText: "pc:11434"
          foreground: root.foreground
          font.family: root.fontFamily
          selectByMouse: true
          onAccepted: root.save()
          Keys.onEscapePressed: root.close()
        }

        Button {
          width: parent.width
          text: "Save endpoint"
          iconText: "󰆓"
          foreground: root.foreground
          fontFamily: root.fontFamily
          bordered: true
          focusable: true
          onClicked: root.save()
        }
      }
    }
  }
}
