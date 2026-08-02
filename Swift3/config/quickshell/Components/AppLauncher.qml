import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

PanelWindow {
   id: launcher

   property ShellScreen screen

   anchors {
      top: false
      left: false
      right: false
      bottom: false
   }

   implicitWidth: 400
   implicitHeight: 240
   color: "transparent"
   visible: false 

   WlrLayershell.namespace:   "app-launcher"
   WlrLayershell.layer:       WlrLayer.Overlay
   WlrLayershell.keyboardFocus:  WlrKeyboardFocus.OnDemand
   WlrLayershell.exclusionMode:  ExclusionMode.Ignore
   WlrLayershell.margins.top:    Math.round(screen.height / 2 - implicitHeight / 2)
   WlrLayershell.margins.left:   Math.round(screen.width / 2 - imclieitWidth / 2)

   property string query: ""
   property int iSelection: 0

   ScriptModel {
      id: filtered
      values: {
         var all = [ ...DesktopEntries.applications.values ]
         .filter(function(d){ return d.name && !d.noDisplay })
         .sort(function(a,b) { return a.name.localeCompare(b.name) })
         var q = launcher.query.trim().toLowerCase()
         if (q==="") return all
         return all.filter(function(d) {
            return (d.name||"").toLowerCase().indexOf(q) !== -1 ||
            (d.genericName||"").toLowerCase().indexOf(q) !== -1
         })
      }
   }

   onVisibleChanged: {
      if (visible) {
         query = ""
         iSelection = 0
         searchBox.text = ""
         searchBox.forceActiveFocus()
      }
   }

   function launch(entry) {
      if (!entry) return
      entry.execute()
      visible = false
   }

   function moveSelection(dir) {
      var n = filtered.values.length
      if(n===0) return
      if(iSelection===0 && dir === -1) return
      if(iSelection===n-1 && dir === 1) return
      iSelection = ((iSelection + dir) % n + n) % n
      // keep selected item centered in view
      var cellH = 32
      var y0 = iSelection * cellH
      var target = y0 - (listFlick.height /2) + (cellH /2)
      target = Math.max(0, Math.min(target, listFlick.contentHeight - listFlick.height))
      scrollAnim.to = target
      scrollAnim.restart()
   }

   // Background
   Rectangle {
      anchors.fill: parent
      color: root.theme.bgBase 
      opacity: 0.9
      radius: 14
   }

   ColumnLayout {
      anchors.fill: parent
      anchors.margins: 8
      spacing: 5

      //--- Search bar -----
      Rectangle {
         Layout.fillWidth: true
         height: 32
         radius: 10
         color: root.theme.bgBase
         border.color: root.theme.fgRule 
         border.width:1

         Row {
            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Item {
               width: 16
               height: 16
               anchors.verticalCenter: parent.verticalCenter

               Text {
                  color: root.theme.fgNormal
                  anchors.verticalCenter: parent.verticalCenter
                  font.family: nerdfont.name
                  text: "\uf422"
               }
            }

            Item {
               width: launcher.implicitWidth - 100
               height: 32

               Text {
                  anchors.verticalCenter: parent.verticalCenter
                  text: "Search apps..."
                  color: root.theme.fgDisabled 
                  font.pixelSize: 14
                  visible: searchBox.text === ""
               }
               TextInput {
                  id: searchBox
                  anchors.left: parent.left
                  anchors.right: parent.right
                  anchors.verticalCenter: parent.verticalCenter
                  color: root.theme.fgNormal
                  font.pixelSize: 14
                  onTextChanged: {
                     launcher.query = text
                     launcher.iSelection = 0
                     listFlick.contentY = 0
                  }
                  Keys.onUpPressed:       launcher.moveSelection(-1)
                  Keys.onDownPressed:     launcher.moveSelection(1)
                  Keys.onReturnPressed:   launcher.launch(filtered.values[launcher.iSelection])
                  Keys.onEscapePressed:   launcher.visible = false
               }
            }
         }
         Text {
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            text: filtered.values.length + " apps"
            color: root.theme.fgDisabled 
            font.pixelSize: 12
            //visible: launcher.query === ""
         }
      }

      // -- App List -----
      Flickable {
         id: listFlick
         Layout.fillWidth: true
         Layout.fillHeight: true
         clip: true
         contentHeight: listCol.implicitHeight
         boundsBehavior: Flickable.StopAtBounds

         // Smooth scroll animation for keyboard nav
         NumberAnimation {
            id: scrollAnim
            target: listFlick
            property: "contentY"
            duration: 130
            easing.type: Easing.OutCubic
         }

         Column {
            id:listCol
            width: listFlick.width
            spacing: 3

            Repeater {
               model: filtered
               delegate: Item {
                  required property var modelData
                  required property int index
                  width: parent.width
                  height: 32

                  Rectangle {
                     anchors.fill: parent
                     anchors.leftMargin: 2
                     anchors.rightMargin: 2
                     radius: 10
                     color: index === launcher.iSelection ? root.theme.hlLauncher : "transparent"

                     Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        // App icon
                        IconImage {
                           width: 24
                           height: 24
                           implicitSize: 24
                           anchors.verticalCenter: parent.verticalCenter
                           source: Quickshell.iconPath(modelData.icon || "", true)
                           asynchronous: true
                           mipmap: true
                        }

                        // Name
                        Text {
                           width: parent.width - 24 - 12
                           text: modelData.name || ""
                           anchors.verticalCenter: parent.verticalCenter
                           color: root.theme.fgNormal 
                           font.pixelSize: 12
                           elide: Text.ElideRight
                        }

                     }
                  }

                  MouseArea {
                     id: hov
                     anchors.fill: parent
                     hoverEnabled: true
                     onEntered: launcher.iSelection = index
                     onClicked: launcher.launch(modelData)
                  }
               }
            }
         }
      }

      Rectangle {
         Layout.fillWidth: true
         height: 1
         color: root.theme.fgRule
      }

      //--- Footer -----
      Text {
         text: "↑↓ navigate :: ↵ open :: Esc close"
         color: root.theme.fgNormal 
         font.pixelSize: 12
         Layout.alignment: Qt.AlignHCenter
      }
   }
}
