// --- Weather module
import QtQuick
import Quickshell

Item {
   height: rootpanel.height
   width: weather_text.implicitWidth  

   property var wData: Processes.wData 

   MouseArea {
      anchors.fill: parent
      onClicked: root.weatherVisible = ! root.weatherVisible
   }

   Text {
      id: weather_text

      anchors.centerIn: parent
      color: root.theme.fgNormal
      font.family: nerdfont.name
      font.pixelSize: 12

      text: wData.current_weather_icon + " " + wData.current_temp + "°c"
   }
}
