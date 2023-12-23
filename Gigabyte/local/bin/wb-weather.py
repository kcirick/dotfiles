#!/usr/bin/python

from urllib.request import urlopen
from datetime import datetime
from json import loads

# --- Put in the information below ---
latitude = 45.2376
longitude = -75.69772
# ------------------------------------

url = 'https://api.open-meteo.com/v1/forecast?'
url += 'latitude=' + str(latitude) + '&longitude=' + str(longitude)
url += '&current=weather_code,temperature_2m'
url += '&daily=weather_code,temperature_2m_min,temperature_2m_max,sunrise,sunset'
url += '&timezone=auto'
url += '&windspeed_unit=' + str("kmh")
url += '&precipitation_unit=' + str("mm")
url += '&temperature_unit=' + str("celsius")

#print(url)

try:
    data_json = loads(urlopen(url).read())
except:
    print("ERROR")

current_time = datetime.now()
sunrise_time = datetime.strptime(data_json['daily']['sunrise'][0], '%Y-%m-%dT%H:%M')
sunset_time = datetime.strptime(data_json['daily']['sunset'][0], '%Y-%m-%dT%H:%M')
is_nighttime = 1 if (current_time >= sunset_time or current_time <= sunrise_time) else 0

tmp_unit = '°C'

wmo_to_icons = {
     0: [u'\uf185', u'\uf186'],     # Clear sky
     1: [u'\uf6c4', u'\uf6c3'],     # Mainly clear
     2: [u'\uf6c4', u'\uf6c3'],     # Partly cloudy
     3: [u'\uf0c2', u'\uf0c2'],     # Overcast
    45: [u'\uf75f', u'\uf75f'],     # Fog
    48: [u'\uf75f', u'\uf75f'],     # Depositing rime fog
    51: [u'\uf743', u'\uf73c'],     # Drizzle (light)
    53: [u'\uf743', u'\uf73c'],     # Drizzle (moderate)
    55: [u'\uf743', u'\uf73c'],     # Drizzle (heavy)
    56: [u'\uf7ad', u'\uf7ad'],     # Freezing drizzle (light)
    57: [u'\uf7ad', u'\uf7ad'],     # Freezing drizzle (moderate and heavy)
    61: [u'\uf73d', u'\uf73d'],     # Rain (light)
    63: [u'\uf740', u'\uf740'],     # Rain (moderate)
    65: [u'\uf740', u'\uf740'],     # Rain (heavy)
    66: [u'\uf7ad', u'\uf7ad'],     # Freezing rain (light)
    67: [u'\uf7ad', u'\uf7ad'],     # Freezing rain (heavy)
    71: [u'\uf2dc', u'\uf2dc'],     # Snow fall (light)
    73: [u'\uf2dc', u'\uf2dc'],     # Snow fall (moderate)
    75: [u'\uf2dc', u'\uf2dc'],     # Snow fall (heavy)
    77: [u'\uf73b', u'\uf73b'],     # Snow grains
    80: [u'\uf73d', u'\uf73d'],     # Rain showers (light)
    81: [u'\uf740', u'\uf740'],     # Rain showers (moderate)
    82: [u'\uf740', u'\uf740'],     # Rain showers (heavy)
    85: [u'\uf2dc', u'\uf2dc'],     # Snow showers (light)
    86: [u'\uf2dc', u'\uf2dc'],     # Snow showers (heavy)
    95: [u'\uf76c', u'\uf76c'],     # Thunderstorm (light or moderate)
    96: [u'\uf76c', u'\uf76c'],     # Thunderstorm with light hail
    99: [u'\uf76c', u'\uf76c']      # Thunderstorm with heavy hail
}

daily_forecast = []
daily_forecast = ["" for i in range(7)]
for i in range(0,7):
    if(i==0):
        date_string = "Today"
    else:
        date_string = (datetime.strptime(data_json['daily']['time'][i], '%Y-%m-%d').strftime("%a"))+"  "

    daily_forecast[i] = "%s\\t %s \\t %s / %s" % \
            ( date_string, \
            #(datetime.strptime(data_json['daily']['time'][i], '%Y-%m-%d').strftime("%a"), \
            wmo_to_icons[data_json['daily']['weather_code'][i]][0], \
            str(data_json['daily']['temperature_2m_min'][i])+tmp_unit, \
            str(data_json['daily']['temperature_2m_max'][i])+tmp_unit )

print(
        '{"text":"', wmo_to_icons[data_json['current']['weather_code']][is_nighttime], '', str(data_json['current']['temperature_2m']) + tmp_unit, '", ',
        '"tooltip": "', daily_forecast[0], '\\n', daily_forecast[1], '\\n', 
                        daily_forecast[2], '\\n', daily_forecast[3], '\\n', 
                        daily_forecast[4], '\\n', daily_forecast[5], '\\n', daily_forecast[6], '"}')
