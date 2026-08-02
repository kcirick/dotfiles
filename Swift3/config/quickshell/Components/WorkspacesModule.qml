import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
   height: rootpanel.height - 4
   implicitWidth: wsLayout.implicitWidth + 12
   radius: 12
   color: root.theme.bgModule

   property var wsData: Processes.wsData 

   RowLayout {
      id: wsLayout
      anchors.verticalCenter: parent.verticalCenter
      anchors.horizontalCenter: parent.horizontalCenter

      Repeater {
         model: wsData 

         Rectangle {
            required property var modelData

            readonly property bool focused: modelData.isFocused
            readonly property bool active: modelData.isActive
            readonly property bool occupied: modelData.isOccupied
            readonly property string output: modelData.output
            readonly property int index: modelData.index

            visible: output == rootpanel.screen.name
            width: (focused|active) ? 32:16
            height: 16
            radius: 8
            color: focused ? root.theme.hlNormal : (occupied ? root.theme.fgNormal : root.theme.fgDisabled)

            MouseArea {
               anchors.fill: parent
               onClicked: {
                  Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", index ])
               }
            }
         }
      }
   }
}
