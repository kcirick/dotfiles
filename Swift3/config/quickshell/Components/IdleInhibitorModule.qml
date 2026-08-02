import QtQuick
import Quickshell
import Quickshell.Wayland

Item {
   height: rootpanel.height 
   width: inhibit_text.implicitWidth + 10 

   IdleInhibitor {
      id:inhibitor

      window: rootpanel
      enabled: false
   }

   MouseArea {
      anchors.fill: parent
      onClicked: inhibitor.enabled = ! inhibitor.enabled 
   }

   Text {
      id: inhibit_text

      anchors.centerIn: parent
      color: inhibitor.enabled ? root.theme.fgEnabled : root.theme.fgNormal
      font.family: nerdfont.name
      font.pixelSize: 12

      text: "\uf1da"
   }
}
