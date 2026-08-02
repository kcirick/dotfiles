import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Bluetooth
import Quickshell.Services.UPower

Rectangle {
   height: rootpanel.height - 4
   implicitWidth: sysLayout.implicitWidth + 20
   radius: 12
   color: root.theme.bgModule

   property var sysData: Processes.sysData 

   readonly property var sink: Pipewire.defaultAudioSink

   readonly property var adapter: Bluetooth.defaultAdapter
   property list<BluetoothDevice> devices: adapter?.devices?.values ?? []
   property list<BluetoothDevice> connected_devices: {
      var list = []
      for (var i=0; i<devices.length; i++){
         if (devices[i].connected) {
            list.push(devices[i])
         }
      }
      return list
   }

   readonly property var battery: UPower.displayDevice
   property real bat_percent: Math.round(battery?.percentage * 100) ?? 0
   property bool bat_isCharging: battery?.state === UPowerDevice.Charging || battery?.state === UPowerDevice.FullyCharged
   property bool bat_isLow: bat_percent<30
   property bool bat_isCrit: bat_percent<15

   PwObjectTracker {
      objects: [ Pipewire.defaultAudioSink ]
   }
   property bool audio_isHeadphones: {
    if (!sink) return false;
    
    // Check node name for "headphone" (case-insensitive)
    const name = (sink.name || "").toLowerCase();
    return name.includes("headphone");
   }
   property bool audio_isBluetooth: {
      if (!sink) return false;

      const name = (sink.name || "").toLowerCase();
      return name.includes("bluez");
   }

   RowLayout {
      id: sysLayout
      anchors.verticalCenter: parent.verticalCneter
      anchors.horizontalCenter: parent.horizontalCenter
      height: parent.height
      spacing: 10

      Text {
         id: cpu_text
         color: root.theme.fgNormal
         font.pixelSize: 12

         text: "\uf4bc " + sysData.cpuPercent + "%"
      }

      Text {
         id: mem_text
         color: root.theme.fgNormal
         font.pixelSize: 12

         text: "\uefc5 " + sysData.memPercent + "%"
      }

      Rectangle {
         height: parent.height
         implicitWidth: pw_text.implicitWidth
         color: root.theme.bgModule

         MouseArea {
            anchors.fill: parent
            onClicked: {
               Quickshell.execDetached(["foot", "-e", "pulsemixer"])
            }
         }

         Text {
            id: pw_text
            anchors.centerIn: parent
            color: sink.audio.muted ? root.theme.fgDisabled : root.theme.fgNormal
            font.pixelSize: 12

            text: (sink.audio.muted ? "\ueee8 --" : (audio_isHeadphones ? "\uf025 " : "\uf027 ") + Math.round(sink.audio.volume*100) + "%") + (audio_isBluetooth ? " (\uf294)" : "")
         }
      }

      Rectangle {
         height: parent.height
         implicitWidth: network_text.implicitWidth
         color: root.theme.bgModule

         MouseArea {
            anchors.fill: parent
            onClicked: {
               Quickshell.execDetached(["foot", "-e", "impala"])
            }
         }

         Text {
            id: network_text
            anchors.centerIn: parent
            color: sysData.wifi_powered ? root.theme.fgNormal : root.theme.fgDisabled
            font.pixelSize: 12

            text: "\uf1eb " + sysData.wifi_ssid
         }
      }

      Rectangle {
         height: parent.height
         implicitWidth: bt_text.implicitWidth
         color: root.theme.bgModule

         MouseArea {
            anchors.fill: parent
            onClicked: {
               Quickshell.execDetached(["foot", "-e", "bluetui"])
            }
         }

         Text {
            id: bt_text
            anchors.centerIn: parent
            color: adapter.state===BluetoothAdapterState.Enabled ? root.theme.fgNormal : root.theme.fgDisabled
            font.pixelSize: 12

            text: "\uf294 " + connected_devices.length
         }
      }

      Text {
         id: battery_text
         color: (bat_isCrit ? root.theme.fgUrgent : (bat_isLow ? root.theme.fgWarn : root.theme.fgNormal))
         font.pixelSize: 12

         text: (bat_isCharging ? "\uf1e6 " : (bat_isLow ? "\uf243 " : "\uf241 ")) + bat_percent + "%"
      }
   }
}
