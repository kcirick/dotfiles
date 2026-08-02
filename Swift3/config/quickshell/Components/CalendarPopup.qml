import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
   id: calendar

   anchors.top: true
   margins.top: 30 

   implicitWidth: 280
   implicitHeight: 280
   color: "transparent"

   WlrLayershell.namespace: "calendar-popup"
   WlrLayershell.layer: WlrLayer.Overlay
   WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
   WlrLayershell.exclusionMode: ExclusionMode.Ignore

   property var now: new Date()
   property int viewYear: 0
   property int viewMonth: 0

   readonly property var days: [ "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" ]
   readonly property var months: [ "January" , "February", "March", "April", "May", "June",
                                   "July", "August", "September", "October", "November", "December" ]

   // days in month
   function daysInMonth(y, m) {
      return new Date(y, m, 0).getDate()
   }

   //weekday of first (Mon=0 .. Sun=6)
   function firstWeekday(y, m) {
      var d = new Date(y, m-1, 1).getDay()
      return (d+7) % 7
   }

   function prevMonth() {
      if (calendar.viewMonth === 1) {
         calendar.viewMonth = 12;
         calendar.viewYear--
      } else {
         calendar.viewMonth--
      }
   }

   function nextMonth() {
      if(calendar.viewMonth === 12) {
         calendar.viewMonth = 1;
         calendar.viewYear++
      } else {
         calendar.viewMonth++
      }
   }

   onVisibleChanged: {
      if (visible) {
         now = new Date()
         viewYear = now.getFullYear()
         viewMonth = now.getMonth() + 1
      }
   }

   // Background - top straight, bottom rounded
   Item {
      anchors.fill: parent
      Rectangle {
         anchors.fill: parent
         color: root.theme.bgBase;
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
            onClicked: root.calendarVisible = false
         }
      }
   }

   // Calendar card
   ColumnLayout {
      anchors.fill: parent
      anchors.margins: 12
      spacing: 6

      Rectangle {
         id: card

         Layout.fillWidth: true
         Layout.fillHeight: true
         radius: 8
         color: root.theme.bgPopup 

         ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 6

            //month nav
            RowLayout {
               Layout.fillWidth: true

               Item {
                  width: 28
                  height: 28

                  Text {
                     anchors.centerIn: parent;
                     text: "<"
                     color: arL.containsMouse ? root.theme.hlNormal : root.theme.fgNormal
                     font.pixelSize: 14
                     font.weight: Font.Medium
                  }
                  MouseArea {
                     id: arL;
                     anchors.fill: parent
                     hoverEnabled: true
                     onClicked: calendar.prevMonth() 
                  }
               }

               Text {
                  Layout.fillWidth: true
                  text: calendar.months[calendar.viewMonth-1] + " " + calendar.viewYear
                  color: root.theme.fgNormal
                  font.pixelSize: 14
                  font.weight: Font.Medium
                  horizontalAlignment: Text.AlignHCenter
               }

               Item {
                  width: 28
                  height: 28

                  Text {
                     anchors.centerIn: parent;
                     text: ">"
                     color: arR.containsMouse ? root.theme.hlNormal : root.theme.fgNormal
                     font.pixelSize: 14
                     font.weight: Font.Medium
                  }
                  MouseArea {
                     id: arR;
                     anchors.fill: parent
                     hoverEnabled: true
                     onClicked: calendar.nextMonth() 
                  }
               }
            }

            // day headers
            Row {
               Layout.fillWidth: true
               spacing: 0
               Repeater {
                  model: calendar.days
                  Text {
                     required property var modelData
                     width: Math.floor((card.width - 24) / 7)
                     text: modelData
                     color: root.theme.fgNormal 
                     font.pixelSize: 12;
                     horizontalAlignment: Text.AlignHCenter
                  }
               }
            }

            // H rule
            Rectangle {
               Layout.fillWidth: true
               height: 1
               color: root.theme.fgRule
            }

            // Calender grid
            Grid {
               Layout.fillWidth: true
               columns: 7
               spacing: 0
               horizontalItemAlignment: Grid.AlignHCenter

               property int totalDays:    calendar.daysInMonth(calendar.viewYear, calendar.viewMonth)
               property int startOffset:  calendar.firstWeekday(calendar.viewYear, calendar.viewMonth)
               //property var now:          new Date()
               property int todayDay:     now.getDate()
               property int todayMonth:   now.getMonth() + 1
               property int todayYear:    now.getFullYear()
               property int cellWidth:    Math.floor((card.width - 24) / 7)

               Repeater {
                  model: 42
                  delegate: Item {
                     required property int index
                     width: parent.cellWidth
                     height: 30

                     property int dayNum: index - parent.startOffset + 1
                     property bool valid: dayNum >= 1 && dayNum <= parent.totalDays
                     property bool isToday: valid &&
                     dayNum === parent.todayDay &&
                     calendar.viewMonth === parent.todayMonth &&
                     calendar.viewYear === parent.todayYear

                     Rectangle {
                        anchors.centerIn: parent
                        width: 24
                        height: 24
                        radius: 12
                        color: isToday ? root.theme.hlCalendar : root.theme.bgPopup 
                     }

                     Text {
                        anchors.centerIn: parent
                        text: valid ? dayNum.toString() : ""
                        color: isToday ? root.theme.bgBase : root.theme.fgNormal
                        font.pixelSize: 12
                        font.weight: isToday ? Font.Medium : Font.Normal
                     }
                  }
               }
            }
         }
      }
   }

}
