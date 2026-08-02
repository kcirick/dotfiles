import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
   id: weather

   anchors.top: true
   margins.top: 30

   implicitWidth: 380
   implicitHeight: weather_layout.implicitHeight + 25 
   color: "transparent"

   WlrLayershell.namespace: "weather-popup"
   WlrLayershell.layer: WlrLayer.Overlay
   WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
   WlrLayershell.exclusionMode: ExclusionMode.Ignore
   WlrLayershell.margins.top: 30

   property var wData: Processes.wData 

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
            onClicked: root.weatherVisible = false
         }
      }
   }

   ColumnLayout {
      id: weather_layout
      anchors.fill: parent
      anchors.margins: 10
      implicitHeight: card_current.implicitHeight + card_hourly.implicitHeight + card_daily.implicitHeight
      spacing: 8

      //--- Current condition -----
      Rectangle {
         Layout.fillWidth: true
         id: card_current
         implicitHeight: current_card.implicitHeight+10
         radius: 8
         color: root.theme.bgPopup 

         ColumnLayout {
            id: current_card
            anchors.fill: parent;
            anchors.margins: 5
            //anchors.rightMargin: 5
            spacing: 5

            RowLayout {
               Item{
                  width: 50
                  Text {
                     anchors.centerIn: parent
                     text: wData.current_weather_icon || "\uea6c"
                     color: root.theme.fgNormal 
                     font.pixelSize: 40
                     font.weight: Font.Medium
                  }
               }

               ColumnLayout {
                  RowLayout{
                     Layout.fillWidth: true
                     
                     Text {
                        text: wData.current_weather_description
                        color: root.theme.fgNormal
                        font.pixelSize: 18
                        font.weight: Font.Medium
                     }

                     // Spacer
                     Rectangle {
                        Layout.fillWidth: true
                        height: 0
                     }

                     Item {
                        implicitWidth: refresh_weather_text.implicitWidth
                        implicitHeight: refresh_weather_text.implicitHeight

                        MouseArea {
                           id: weather_refresh
                           anchors.fill: parent
                           hoverEnabled: true
                           onClicked: Processes.get_weather()
                        }
                        Text {
                           id: refresh_weather_text
                           text: "\uf021"
                           color: weather_refresh.containsMouse ? root.theme.hlNormal : root.theme.fgNormal
                           font.pixelSize: 12
                           font.weight: Font.Medium
                        }
                     }
                  }
                  Text {
                     text: wData.current_temp + "°c (feels like " + wData.current_apparent_temp + "°c)"
                     color: root.theme.fgNormal
                     font.pixelSize: 14
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

            Text {
               text: "\uf2ca : " + wData.today_temp_min + "°c - " + wData.today_temp_max + "°c \n" + 
               "\uf185 : " + Qt.formatDateTime(wData.today_sunrise, "hh:mm") + " / " + Qt.formatDateTime(wData.today_sunset, "hh:mm") + " \n" + 
               "\uef16 : " + wData.current_wind + "km/h / \uef30 : " + wData.current_humidity + "%"  
               color: root.theme.fgNormal
               font.family: nerdfont.name
               font.pixelSize: 14
            }
         }
      }

      //--- Hourly forecast -----
      Rectangle {
         Layout.fillWidth: true
         id: card_hourly
         implicitHeight: hourly_card.implicitHeight + 10
         radius: 8
         color: root.theme.bgPopup

         ColumnLayout{
            id: hourly_card
            anchors.fill: parent;
            anchors.margins: 5
            //anchors.rightMargin: 5
            spacing: 2

            Row {
               Layout.fillWidth: true
               spacing: 0
               Repeater {
                  model: 5
                  Text {
                     required property int index
                     width: Math.floor((card_hourly.width - 20) / 5)
                     text: wData.hourly_date[index] ? Qt.formatDateTime(wData.hourly_date[index], "hh:mm") : ""
                     color: root.theme.fgNormal
                     font.pixelSize: 14
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

            Row {
               Layout.fillWidth: true
               spacing: 0
               Repeater {
                  model: 5
                  Text {
                     required property int index
                     width: Math.floor((card_hourly.width - 20) /5)
                     text: wData.hourly_weather_icon[index] ? wData.hourly_weather_icon[index] : ""
                     color: root.theme.fgNormal 
                     font.pixelSize: 20
                     horizontalAlignment: Text.AlignHCenter
                  }
               }
            }
            // Graph
            Item {
               width: card_hourly.width - 20
               height: 50

               Canvas {
                  width: card_hourly.width - 20
                  height: 50

                  property color lineColor: "#10b981"
                  property var dataPoints: wData.hourly_temp

                  onDataPointsChanged: requestPaint()

                  onPaint: {
                     var ctx = getContext("2d")
                     ctx.reset()

                     if (dataPoints.length===0) return

                     ctx.clearRect(0, 0, width, height)
                     ctx.lineWidth = 2;
                     ctx.strokeStyle = root.theme.fgNormal 
                     ctx.fillStyle = ctx.strokeStyle
                     ctx.beginPath()
                     
                     // Calculate dynamic spacing between points
                     var stepX = width / 5 
                     var maxValue = wData.today_temp_max+3
                     var minValue = wData.today_temp_min-3

                     // Add line
                     for (var i=0; i<5; i++) {
                        // Invert y because (0,0) starts at top-left
                        var normY = (dataPoints[i]-minValue) / (maxValue-minValue) 
                        var pointX = i * stepX + (stepX/2)
                        var pointY = height - (normY * height);

                        i===0 ? ctx.moveTo(pointX, pointY) : ctx.lineTo(pointX, pointY)
                     }
                     ctx.stroke()

                     // Add data points
                     for (var i=0; i<5; i++) {
                        var normY = (dataPoints[i]-minValue) / (maxValue-minValue) 
                        var pointX = i * stepX + (stepX/2)
                        var pointY = height - (normY * height);

                        // Draw point
                        ctx.beginPath();
                        ctx.arc(pointX, pointY, 3, 0, 2*Math.PI)
                        ctx.fill()
                     }

                     // Add precipitation bar
                     for (var i=0; i<5; i++){
                        var barWidth = 20
                        var barHeight = (wData.hourly_precipitation[i] / 100) * height
                        var x = i * stepX + (stepX/2) - 10
                        var y = height - barHeight;

                        ctx.fillStyle = root.theme.weatherPrecipBar
                        ctx.fillRect(x, y, barWidth, barHeight)
                     }
                  }
               }
            }

            Row {
               Layout.fillWidth: true
               spacing: 0
               Repeater {
                  model: 5
                  Text {
                     required property int index
                     width: Math.floor((card_hourly.width - 20) /5)
                     text: wData.hourly_temp[index] ? wData.hourly_temp[index] + "°c" : ""
                     color: root.theme.fgNormal 
                     font.pixelSize: 12
                     horizontalAlignment: Text.AlignHCenter
                  }
               }
            }
            Row {
               Layout.fillWidth: true
               spacing: 0
               Repeater {
                  model: 5
                  Text {
                     required property int index
                     width: Math.floor((card_hourly.width - 20) /5)
                     text: wData.hourly_precipitation[index] ? wData.hourly_precipitation[index] + "%" : ""
                     color: root.theme.fgNormal
                     font.pixelSize: 12
                     horizontalAlignment: Text.AlignHCenter
                  }
               }
            }
         }
      }

      //--- Daily forecast -----
      Rectangle {
         Layout.fillWidth: true
         id: card_daily
         implicitHeight: daily_card.implicitHeight + 10
         radius: 8
         color: root.theme.bgPopup 

         ColumnLayout{ 
            id: daily_card
            anchors.fill: parent;
            anchors.margins: 5
            spacing: 2

            Row {
               Layout.fillWidth: true
               Repeater {
                  model: 5
                  Text {
                     required property int index
                     width: Math.floor((card_daily.width - 20) / 5)
                     text: wData.daily_date[index+1] ? Qt.formatDateTime(wData.daily_date[index+1], "ddd") : ""
                     color: root.theme.fgNormal 
                     font.pixelSize: 14
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

            Row {
               Layout.fillWidth: true
               spacing: 0
               Repeater {
                  model: 5
                  Text {
                     required property int index
                     width: Math.floor((card_daily.width - 20) /5)
                     text: wData.daily_weather_icon[index+1] ? wData.daily_weather_icon[index+1] : ""
                     color: root.theme.fgNormal 
                     font.pixelSize: 20
                     horizontalAlignment: Text.AlignHCenter
                  }
               }
            }
            // Graph
            Item {
               width: card_daily.width - 20
               height: 50

               Canvas {
                  width: card_daily.width - 20
                  height: 50

                  property color lineColor1: root.theme.weatherTempMin 
                  property var dataPoints1: wData.daily_temp_min

                  property color lineColor2: root.theme.weatherTempMax
                  property var dataPoints2: wData.daily_temp_max

                  property int minValue: Math.min(...wData.daily_temp_min) - 3
                  property int maxValue: Math.max(...wData.daily_temp_max) + 3

                  onDataPoints1Changed: requestPaint()
                  onDataPoints2Changed: requestPaint()

                  function drawLine(ctx, dataPoints, strokeColor) {
                     if(dataPoints.length===0) return

                     ctx.lineWidth = 2;
                     ctx.strokeStyle = strokeColor 
                     ctx.fillStyle = strokeColor

                     ctx.beginPath()

                     // Calculate dynamic spacing between points
                     var stepX = width / 5 

                     for (var i=0; i<5; i++) {
                        // Invert y because (0,0) starts at top-left
                        var normY = (dataPoints[i+1]-minValue) / (maxValue - minValue) 
                        var pointX = i * stepX + (stepX/2)
                        var pointY = height - (normY * height);

                        i===0 ? ctx.moveTo(pointX, pointY) : ctx.lineTo(pointX, pointY)
                     }
                     ctx.stroke()

                     // draw points
                     for (var i=0; i<5; i++) {
                        var normY = (dataPoints[i+1]-minValue) / (maxValue - minValue) 
                        var pointX = i * stepX + (stepX/2)
                        var pointY = height - (normY * height);

                        ctx.beginPath()
                        ctx.arc(pointX, pointY, 3, 0, 2*Math.PI);
                        ctx.fill()
                     }
                  }

                  onPaint: {
                     var ctx = getContext("2d")
                     ctx.reset()
                     ctx.clearRect(0, 0, width, height)
                     
                     var stepX = width / 5 

                     drawLine(ctx, dataPoints1, lineColor1)
                     drawLine(ctx, dataPoints2, lineColor2)

                     // Add precipitation bar
                     for (var i=0; i<5; i++){
                        var barWidth = 20
                        var barHeight = (wData.daily_precipitation[i+1] / 100) * height
                        var x = i * stepX + (stepX/2) - 10
                        var y = height - barHeight;

                        ctx.fillStyle = root.theme.weatherPrecipBar 
                        ctx.fillRect(x, y, barWidth, barHeight)
                     }
                  }
               }
            }

            Row {
               Layout.fillWidth: true
               spacing: 0
               Repeater {
                  model: 5
                  Text {
                     required property int index
                     width: Math.floor((card_daily.width - 20) /5)
                     //text: wData.daily_temp_min[index+1] ? wData.daily_temp_min[index+1] + " - " + wData.daily_temp_max[index+1] + "°c"  : ""
                     text: wData.daily_temp_min[index+1] ? wData.daily_temp_min[index+1] + " - " + wData.daily_temp_max[index+1]  : ""
                     color: root.theme.fgNormal 
                     font.pixelSize: 12
                     horizontalAlignment: Text.AlignHCenter
                  }
               }
            }
            Row {
               Layout.fillWidth: true
               spacing: 0
               Repeater {
                  model: 5
                  Text {
                     required property int index
                     width: Math.floor((card_daily.width - 20) /5)
                     text: wData.daily_precipitation[index+1] ? wData.daily_precipitation[index+1] + "%" : ""
                     color: root.theme.fgNormal 
                     font.pixelSize: 12
                     horizontalAlignment: Text.AlignHCenter
                  }
               }
            }

         }
      }
   }
}
