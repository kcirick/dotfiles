import QtQuick
import Quickshell

Item {
   height: rootpanel.height 
   width: su_text.implicitWidth + 10 

   property var suData: Processes.suData
   property var total_counts: (suData.xbps_counts + suData.flatpak_counts)
   
   MouseArea {
      anchors.fill: parent
      onClicked: root.updatesVisible = ! root.updatesVisible 
   }

   Text {
      id: su_text

      anchors.centerIn: parent
      color: total_counts ===0 ? root.theme.fgNormal : root.theme.fgUrgent
      font.family: nerdfont.name
      font.pixelSize: 12

      text: total_counts===0 ? "\uf00c 0" : "\uf2f1 " + total_counts
   }
}
