// --- Clock module
import QtQuick
import Quickshell

Item {
   height: rootpanel.height
   width: time_text.implicitWidth

   SystemClock {
      id: clock
      precision: SystemClock.Minutes
   }

   MouseArea {
      anchors.fill: parent
      onClicked: root.calendarVisible = ! root.calendarVisible
   }

   Text {
      id: time_text

      anchors.centerIn: parent
      color: root.theme.fgNormal

      text: Qt.formatDateTime(clock.date, "ddd MMM d hh:mm")
   }
}
