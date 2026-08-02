import QtQuick
import Quickshell

Item {
   height: rootpanel.height
   width: logo_text.implicitWidth + 20

   Text {
      id: logo_text

      anchors.centerIn: parent
      color: root.theme.fgNormal
      font.pixelSize: 18

      text: "\uf785"
   }
}
