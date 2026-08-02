import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
   id: updates 

   anchors.top: true
   anchors.right: true
   margins.top: 30

   implicitWidth: 320
   implicitHeight: updateLayout.implicitHeight + 40 
   color: "transparent"

   WlrLayershell.namespace: "updates-popup"
   WlrLayershell.layer: WlrLayer.Overlay
   WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
   WlrLayershell.exclusionMode: ExclusionMode.Ignore

   property var suData: Processes.suData 

   // Background - top straight, bottom rounded
   Item {
      anchors.fill: parent
      Rectangle {
         anchors.fill: parent
         color: root.theme.bgBase 
         radius: 10
         Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 10;
            color: root.theme.bgBase
         }

         MouseArea {
            anchors.fill: parent
            onClicked: root.updatesVisible = false
         }
      }
   }

   ColumnLayout {
      id: updateLayout
      anchors.fill: parent
      anchors.margins: 10
      spacing: 5


      // XBPS Updates 
      Rectangle {
         Layout.fillWidth: true
         implicitHeight: xbps_updates_list.implicitHeight + 35
         anchors.margins: 10
         radius: 8
         color: root.theme.bgPopup 

         ColumnLayout {
            anchors.fill: parent;
            anchors.margins: 5
            spacing: 3
            
            RowLayout {
               Layout.fillWidth: true
               
               Text {
                  text: "XBPS: " + suData.xbps_counts 
                  color: root.theme.fgNormal
                  font.pixelSize: 12
                  font.weight: Font.Medium
               }

               // Spacer
               Rectangle {
                  Layout.fillWidth: true
                  height: 0
               }

               Item {
                  implicitWidth: refresh_xbps_text.implicitWidth
                  implicitHeight: refresh_xbps_text.implicitHeight

                  MouseArea {
                     id:xbps_refresh
                     anchors.fill: parent
                     hoverEnabled: true
                     onClicked: Processes.refresh_xbps()
                  }

                  Text {
                     id: refresh_xbps_text
                     text: "\uf021"
                     color: xbps_refresh.containsMouse ? root.theme.hlNormal : root.theme.fgNormal
                     font.pixelSize: 12
                     font.weight: Font.Medium
                  }
               }
            }

            // H rule
            Rectangle {
               Layout.fillWidth: true
               height: 1
               color: root.theme.fgRule
            }

            Column {
               id: xbps_updates_list
               Layout.fillWidth: true
               spacing: 1
               Repeater {
                  model: suData.xbps_updates
                  Text {
                     required property var modelData
                     text: modelData
                     color: root.theme.fgNormal 
                  }
               }
            }
         }
      }

      // Flatpak updates
      Rectangle {
         Layout.fillWidth: true
         implicitHeight: flatpak_updates_list.implicitHeight + 35
         anchors.margins: 10
         radius: 8
         color: root.theme.bgPopup

         ColumnLayout {
            anchors.fill: parent;
            anchors.margins: 5
            spacing: 3

            RowLayout {
               Layout.fillWidth: true

               Text {
                  text: "Flatpak: " + suData.flatpak_counts 
                  color: root.theme.fgNormal
                  font.pixelSize: 12
                  font.weight: Font.Medium
               }

               // Spacer
               Rectangle {
                  Layout.fillWidth: true
                  height: 0
               }

               Item {
                  implicitWidth: refresh_flatpak_text.implicitWidth
                  implicitHeight: refresh_flatpak_text.implicitHeight

                  MouseArea {
                     id:flatpak_refresh
                     anchors.fill: parent
                     hoverEnabled: true
                     onClicked: Processes.refresh_flatpak()
                  }

                  Text {
                     id: refresh_flatpak_text
                     text: "\uf021"
                     color: flatpak_refresh.containsMouse ? root.theme.hlNormal : root.theme.fgNormal
                     font.pixelSize: 12
                     font.weight: Font.Medium
                  }
               }
            }

            // H rule
            Rectangle {
               Layout.fillWidth: true
               height: 1
               color: root.theme.fgRule
            }

            Column {
               id: flatpak_updates_list
               Layout.fillWidth: true
               spacing: 1
               Repeater {
                  model: suData.flatpak_updates
                  Text {
                     required property var modelData
                     text: modelData
                     color: root.theme.fgNormal
                  }
               }
            }
         }
      }
   }
}
