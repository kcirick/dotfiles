pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
   id: processes

   //--- Niri Workspaces -----
   property var wsData: []

   Process {
      id: wsStream
      command: ["niri", "msg", "--json", "event-stream"]
      running: true
      stdout: SplitParser {
         onRead: data => {
            try {
               var e = JSON.parse(data)
               if (e.WorkspacesChanged)         parseWs(e.WorkspacesChanged.workspaces)
               else if (e.WorkspaceActivated)   wsQuery.running = true
            } catch(_) {}
         }
      }
      onRunningChanged: if (!running) running = true 
   }
   
   Process {
      id: wsQuery
      command: ["niri", "msg", "--json", "workspaces"]
      stdout: SplitParser {
         onRead: data => {
            try {
               var list = JSON.parse(data)
               if (list) parseWs(list)
            } catch (_) {}
         }
      }
   }
   
   function parseWs(list) {
      if(!Array.isArray(list)) return
      var a = []
      for (var i=0; i<list.length; i++) {
         var w = list[i]
            a.push({index: w.idx,
            output: w.output,
            isFocused: !!w.is_focused,
            isActive: !!w.is_active,
            isOccupied: w.active_window_id != null })
      }
      a.sort(function(x, y) {return x.index - y.index})
      wsData = a
   }

   //--- Weather data -----
   property var wData: QtObject { 
      id: weather_data

      property string current_weather_description: ""
      property string current_weather_icon: ""
      property int current_temp: 0
      property int current_apparent_temp: 0
      property int current_humidity: 0
      property int current_wind: 0
      property int today_temp_min: 0
      property int today_temp_max: 0
      property date today_sunrise: new Date()
      property date today_sunset: new Date()

      property list<date> hourly_date: []
      property list<string> hourly_weather_icon: []
      property list<int> hourly_temp: []
      property list<int> hourly_precipitation: []

      property list<date> daily_date: []
      property list<string> daily_weather_icon: []
      property list<int> daily_temp_min: []
      property list<int> daily_temp_max: []
      property list<int> daily_precipitation: []
   }

   function wc_to_data (code, index) {
      var wmo_data ={
         //  description         night icon day icon
         0:  ['Clear sky',       '\ue32b',  '\ue30d'],
         1:  ['Mainly clear',    '\ue32b',  '\ue30d'],
         2:  ['Partly cloudy',   '\ue32e',  '\ue302'],
         3:  ['Overcast',        '\ue312',  '\ue312'],
         45: ['Foggy',           '\ue313',  '\ue313'],
         48: ['Foggy',           '\ue313',  '\ue313'],     // Depositing rime fog
         51: ['Light drizzle',   '\ue326',  '\ue309'],
         53: ['Drizzle',         '\ue326',  '\ue309'],
         55: ['Heavy drizzle',   '\ue325',  '\ue308'],
         56: ['Freezing drizzle','\ue314',  '\ue314'],     // Freezing drizzle (light)
         57: ['Freezing drizzle','\ue314',  '\ue314'],     // Freezing drizzle (moderate and heavy)
         61: ['Light rain',      '\ue319',  '\ue319'],
         63: ['Rain',            '\ue318',  '\ue318'],
         65: ['Heavy rain',      '\ue318',  '\ue318'],
         66: ['Freezing rain',   '\ue314',  '\ue314'],     // Freezing rain (light)
         67: ['Freezing rain',   '\ue314',  '\ue314'],     // Freezing rain (heavy)
         71: ['Light snow',      '\ue327',  '\ue30a'],
         73: ['Snow',            '\ue327',  '\ue30a'],
         75: ['Heavy snow',      '\uf2dc',  '\uf2dc'],
         77: ['Snow grains',     '\uf2dc',  '\uf2dc'],
         80: ['Rain showers',    '\ue319',  '\ue319'],     // Rain showers (light)
         81: ['Rain showers',    '\ue318',  '\ue318'],     // Rain showers (moderate)
         82: ['Rain showers',    '\ue318',  '\ue318'],     // Rain showers (heavy)
         85: ['Snow showers',    '\uf2dc',  '\uf2dc'],     // Snow showers (light)
         86: ['Snow showers',    '\uf2dc',  '\uf2dc'],     // Snow showers (heavy)
         95: ['Thunderstorm',    '\ue322',  '\ue305'],     // Thunderstorm (light or moderate)
         96: ['Thunderstorm',    '\ue322',  '\ue305'],     // Thunderstorm with light hail
         99: ['Thunderstorm',    '\ue322',  '\ue305']      // Thunderstorm with heavy hail
      }
      return wmo_data[code][index];
   }

   function parse_weather_data(text) {
      try {

         // Init arrays
         wData.hourly_date = []
         wData.hourly_weather_icon = []
         wData.hourly_temp = []
         wData.hourly_precipitation = []

         wData.daily_date = []
         wData.daily_weather_icon = []
         wData.daily_temp_min = []
         wData.daily_temp_max = []
         wData.daily_precipitation = []

         var data_json = JSON.parse(text) 
         if(!data_json) return

         var current_time = new Date(data_json.current.time)
         wData.today_sunrise = new Date(data_json.daily.sunrise[0])
         wData.today_sunset = new Date(data_json.daily.sunset[0])
         var is_dt = ((current_time>wData.today_sunrise) && (current_time<wData.today_sunset)) ? 1 : 0

         // Current values
         var wc = data_json.current.weather_code
         wData.current_weather_description = wc_to_data(wc, 0) 
         wData.current_weather_icon = wc_to_data(wc, is_dt+1) 
         wData.current_temp = data_json.current.temperature_2m
         wData.current_apparent_temp = data_json.current.apparent_temperature
         wData.current_humidity = data_json.current.relative_humidity_2m
         wData.current_wind = data_json.current.wind_speed_10m
         //print("weather_code: " + data_json.current.weather_code)

         // Hourly forecasts
         var k = 0

         for (var i=0; i<12; i++) {
            var this_time = new Date(data_json.hourly.time[i]) 
            is_dt = ((this_time>wData.today_sunrise) && (this_time<wData.today_sunset)) ? 1 : 0
            if((this_time>current_time) && (k<5)) {
               wData.hourly_date.push(this_time)
               wc = data_json.hourly.weather_code[i]
               wData.hourly_weather_icon.push(wc_to_data(wc, is_dt+1))
               wData.hourly_temp.push(data_json.hourly.temperature_2m[i])
               wData.hourly_precipitation.push(data_json.hourly.precipitation_probability[i])
               k++
            }
         }

         // Daily forecast
         for (var i=0; i<7; i++) {
            wData.daily_date.push(Date.fromLocaleString(Qt.locale(), data_json.daily.time[i], "yyyy-MM-dd"))
            wc = data_json.daily.weather_code[i]
            wData.daily_weather_icon.push(wc_to_data(wc, 2))
            wData.daily_temp_min.push(data_json.daily.temperature_2m_min[i])
            wData.daily_temp_max.push(data_json.daily.temperature_2m_max[i])
            wData.daily_precipitation.push(data_json.daily.precipitation_probability_max[i])
         }
         wData.today_temp_min = wData.daily_temp_min[0]
         wData.today_temp_max = wData.daily_temp_max[0]
      } catch (_) { }

   }

   function get_weather() {

      const request = new XMLHttpRequest()
      request.timeout = 30000;   // 30s

      request.onreadystatechange = function () {
         if(request.readyState !== XMLHttpRequest.DONE) return;

         if(request.status === 200) {
            parse_weather_data(request.responseText)
         }
      }

      var latitude = "45.4112"
      var longitude = "-75.6981"
      var url = "https://api.open-meteo.com/v1/forecast?"
         + "latitude=" + latitude + "&longitude=" + longitude
         + "&current=weather_code,temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m"
         + "&hourly=weather_code,temperature_2m,precipitation_probability"
         + "&daily=weather_code,temperature_2m_min,temperature_2m_max,sunrise,sunset,precipitation_probability_max"
         + "&timezone=America/New_York"
         + "&forecast_hours=12"

      print(url)
      request.open("GET", url)
      request.send()
   }

   Timer {
      // 1000 = 1 second
      interval: 3600000    // 1 hour

      running: true
      repeat: true
      triggeredOnStart: true
      onTriggered: {
         get_weather()
      }
   }

   //--- Package updates -----
   property var suData: QtObject { 
      id: sysupdate_data

      property int xbps_counts: 0
      property int flatpak_counts: 0

      property list<string> xbps_updates: []
      property list<string> flatpak_updates: []
   }

   Process {
      id: xbpsUpdatesProc
      running: true
      command: ["sh", "-c", "xbps-install -un | grep update | awk '{print $1}'"]

      stdout: StdioCollector {
         onStreamFinished: {
            suData.xbps_updates = text.length>0 ? text.trim().split("\n") : []
            suData.xbps_counts = suData.xbps_updates.length
            //print("xbps: " + suData.xbps_counts)
         }
      }
      //Component.onCompleted: running = true 
   }
   function refresh_xbps() {
      xbpsUpdatesProc.running = true
   }

   Process {
      id: flatpakUpdatesProc
      running: true
      command: ["sh", "-c", "flatpak remote-ls --updates | awk -F'\t' '{print $1}'"]

      stdout: StdioCollector {
         onStreamFinished: {
            suData.flatpak_updates = text.length>0 ? text.trim().split("\n") : []
            suData.flatpak_counts = suData.flatpak_updates.length
            //print("flatpak: " + suData.flatpak_counts)
         }
      }
      //Component.onCompleted: running = true 
   }
   function refresh_flatpak() {
      flatpakUpdatesProc.running = true
   }

   Timer {
      // 1000 = 1 second
      interval: 3600000    // 1 hour

      running: true
      repeat: true
      onTriggered: {
         refresh_xbps()
         refresh_flatpak()
      }
   }

   //--- CPU and Memory -----
   property var sysData: QtObject { 
      id: system_data

      property int prevIdle: -1
      property int prevTotal: -1

      property real cpuPercent: 0
      property real memPercent: 0

      property bool wifi_powered: false
      property string wifi_ssid: ""
   }

   FileView { id: cpuStat; path: "/proc/stat" }
   FileView { id: memInfo; path: "/proc/meminfo" }

   Timer {
      interval: 2000
      running: true
      repeat: true

      onTriggered: {
         cpuStat.reload()
         memInfo.reload()

         //--- CPU Info -----
         const cpuLine = cpuStat.text().split("\n")[0].trim().split(/\s+/)

         const cpuUser = parseInt(cpuLine[1])
         const cpuNice = parseInt(cpuLine[2])
         const cpuSystem = parseInt(cpuLine[3])
         const cpuIdle = parseInt(cpuLine[4])
         const cpuIowait = parseInt(cpuLine[5])
         const cpuIrq = parseInt(cpuLine[6])
         const cpuSoftirq = parseInt(cpuLine[7])

         const cpuIdleAll = cpuIdle + cpuIowait
         const cpuTotal = cpuUser + cpuNice + cpuSystem + cpuIrq + cpuSoftirq + cpuIdleAll

         if (sysData.prevTotal >= 0) {
            var totalDiff = cpuTotal - sysData.prevTotal
            var idleDiff = cpuIdleAll - sysData.prevIdle
            
            if (totalDiff > 0)
               var cpuPerc = (totalDiff - idleDiff) / totalDiff
               sysData.cpuPercent = Math.round(cpuPerc * 100)
         }
         
         sysData.prevTotal = cpuTotal
         sysData.prevIdle = cpuIdleAll

         //--- Memory info -----
         const memLines = memInfo.text().split("\n")

         let memTotal = 0
         let memAvailable = 0

         for(let line of memLines) {
            if(line.startsWith("MemTotal"))     memTotal = parseInt(line.match(/\d+/)[0])
            if(line.startsWith("MemAvailable")) memAvailable = parseInt(line.match(/\d+/)[0])
         }

         if (memTotal>0) {
            var memUsed = memTotal - memAvailable
            var memPerc = memUsed / memTotal
            sysData.memPercent = Math.round(memPerc * 100)
         }
      }
   }

   //--- Wifi -----
   property bool state_changed: false
   Process {
      id: wifiStream
      command: ["sh", "-c", "dbus-monitor --system \"sender=net.connman.iwd\""]
      running: true
      stdout: SplitParser {
         onRead: data => {
            var data_string = data.trim()
            if(data_string.includes("State")) {
               state_changed = true
            }
            if(state_changed && data_string.includes("\"connected\"")) {
               print("connected")
               getWifiSSID()
               state_changed = false
            } else if(state_changed && data_string.includes("\"disconnected\"")) {
               print("disconnected")
               sysData.wifi_ssid = "n/a"
               state_changed = false
            }
            if(data_string.includes("Powered")) {
               print("Power changed")
               getWifiPower()
            }
         }
      }
   }

   Process {
      id: getWifiPowerProc
      running: true
      command: ["sh", "-c", "iwctl device wlp1s0 show | grep Powered | awk '{print $4}'"]

      stdout: StdioCollector {
         onStreamFinished: {
            sysData.wifi_powered = text.trim()==="on"
         }
      }
   }
   function getWifiPower() {
      getWifiPowerProc.running = true
   }

   Process {
      id: getSSIDProc
      running:true
      command: ["sh", "-c", "iwctl station wlp1s0 show | grep \"Connected network\" | awk '{print $3}'"]

      stdout: StdioCollector {
         onStreamFinished: {
            sysData.wifi_ssid = text.trim() || "n/a"
         }
      }
   }
   function getWifiSSID() {
      getSSIDProc.running = true
   }

}
