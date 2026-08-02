//@ pragma UseQApplication

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Components

ShellRoot {
   id: root

   // Theme colours
   property var theme: Theme{}

   FontLoader {
      id: nerdfont
      source: "/usr/share/fonts/NerdFonts/ttf/symbols/SymbolsNerdFontMono-Regular.ttf"
   }

   // Calendar Popup
   property bool calendarVisible: false 
   CalendarPopup {
      id: calendarPopup
      visible: root.calendarVisible
   }

   // Weather Popup
   property bool weatherVisible: false
   WeatherPopup {
      id: weatherPopup
      visible: root.weatherVisible
   }

   // Package Updates Popup
   property bool updatesVisible: false
   UpdatesPopup {
      id: updatesPopup
      visible: root.updatesVisible
   }

   // App launcher (to be opened vif IPC)
   // > qs ipc call launcher open
   AppLauncher { 
      id: appLauncher;
      screen: Quickshell.screens[0] 
   }

   IpcHandler {
      target: "launcher"
      function open(): void { appLauncher.visible = true }
      function close(): void { appLauncher.visible = false }
   }

   //--- The main bar -----
   Variants {
      model: Quickshell.screens

      PanelWindow {
         id: rootpanel
         required property var modelData

         screen: modelData

         anchors {
            top: true
            left: true
            right: true
         }

         implicitHeight: 30
         color: root.theme.bgBase

         //--- Left modules -----
         RowLayout {
            id: left_modules
            anchors.left: parent.left
            anchors.top: parent.top
            height: parent.height
            spacing: 0

            LogoModule {}

            WorkspacesModule {}
         }

         //--- Center modules -----
         RowLayout {
            id: center_modules
            anchors.centerIn: parent
            anchors.top: parent.top
            height: parent.height
            spacing: 5

            ClockModule { 
               id: clock_module 
            }

            Text {
               color: root.theme.fgNormal
               visible: modelData.name==="eDP-1"
               text: "::"
            }

            WeatherModule { 
               id: weather_module 
               visible: modelData.name==="eDP-1"
            }
         }

         //--- Right modules -----
         RowLayout {
            id: right_modules
            anchors.right: parent.right
            anchors.top: parent.top
            height: parent.height
            spacing: 5

            SystemMonitorModule { 
               id: system_module 
               visible: modelData.name==="eDP-1"
            }

            IdleInhibitorModule {
               id: inhibit_module
               visible: modelData.name==="eDP-1"
            }

            UpdatesModule { 
               id: updates_module 
               visible: modelData.name==="eDP-1"
            }

            SystemTrayModule {
               visible: modelData.name==="eDP-1"
            }
         }
      }
   }
}
