// --- System tray module
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.DBusMenu

Item {
   implicitWidth: rowLayout.implicitWidth + 12

   Row{
      id: rowLayout
      spacing: 10
      anchors.centerIn: parent

      Repeater {
         model: SystemTray.items

         Item {
            id: trayItem
            width:20
            height:20

            required property var modelData


            Image {
               anchors.fill: parent
               source: modelData.icon
               fillMode: Image.PreserveAspectFit
            }

            // Menu opener handles nested menus provided by the app
            QsMenuAnchor {
               id:systrayMenu
               menu: modelData.menu
               anchor.window: trayArea.QsWindow.window 
               anchor.onAnchoring: {
                  const window = trayArea.QsWindow.window;
                  const widgetRect = window.contentItem.mapFromItem(
                     trayArea, 0, trayArea.height, trayArea.width, trayArea.height);
                     systrayMenu.anchor.rect = widgetRect;
               }
            }

            MouseArea {
               id: trayArea
               anchors.fill: parent 
               anchors.right: parent.right
               acceptedButtons: Qt.LeftButton | Qt.RightButton

               onClicked: mouse => {
                  // Right click action
                  if(mouse.button == Qt.RightButton) {
                     if (modelData.menu) {
                        systrayMenu.open()
                     }
                  }
                  //left click action
                  if(mouse.button == Qt.LeftButton) {
                     modelData.activate();
                  }
               }
            }
         }
      }
   }
}
