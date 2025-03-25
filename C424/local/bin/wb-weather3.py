#!/usr/bin/python3
from urllib.request import urlopen
from datetime import datetime
import pandas as pd
import numpy as np
import json

# --- Put in the information below ---
latitude = 45.4112
longitude = -75.6981
# ------------------------------------

url = "https://api.open-meteo.com/v1/forecast?"
url += "latitude=" + str(latitude) + "&longitude=" + str(longitude)
url += "&current=weather_code,temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m"
url += "&hourly=weather_code,temperature_2m,precipitation_probability"
url += "&daily=weather_code,temperature_2m_min,temperature_2m_max,sunrise,sunset,precipitation_probability_max"
url += "&timezone=America/New_York"
url += "&forecast_hours=12"
#print(url)

wmo_data = {
     #   description        night icon  day icon   
     0: ['Clear sky',       u'\uf186',  u'\uf185'],
     1: ['Mainly clear',    u'\uf6c3',  u'\uf6c4'],
     2: ['Partly cloudy',   u'\uf6c3',  u'\uf6c4'],
     3: ['Overcast',        u'\uf0c2',  u'\uf0c2'],
    45: ['Foggy',           u'\uf75f',  u'\uf75f'],
    48: ['Foggy',           u'\uf75f',  u'\uf75f'],     # Depositing rime fog
    51: ['Light drizzle',   u'\uf73c',  u'\uf743'],
    53: ['Drizzle',         u'\uf73c',  u'\uf743'],
    55: ['Heavy drizzle',   u'\uf73c',  u'\uf743'],
    56: ['Freezing drizzle',u'\uf7ad',  u'\uf7ad'],     # Freezing drizzle (light)
    57: ['Freezing drizzle',u'\uf7ad',  u'\uf7ad'],     # Freezing drizzle (moderate and heavy)
    61: ['Light rain',      u'\uf73d',  u'\uf73d'],
    63: ['Rain',            u'\uf740',  u'\uf740'],
    65: ['Heavy rain',      u'\uf740',  u'\uf740'],
    66: ['Freezing rain',   u'\uf7ad',  u'\uf7ad'],     # Freezing rain (light)
    67: ['Freezing rain',   u'\uf7ad',  u'\uf7ad'],     # Freezing rain (heavy)
    71: ['Light snow',      u'\uf2dc',  u'\uf2dc'],
    73: ['Snow',            u'\uf2dc',  u'\uf2dc'],
    75: ['Heavy snow',      u'\uf2dc',  u'\uf2dc'],
    77: ['Snow grains',     u'\uf73b',  u'\uf73b'],
    80: ['Rain showers',    u'\uf73d',  u'\uf73d'],     # Rain showers (light)
    81: ['Rain showers',    u'\uf740',  u'\uf740'],     # Rain showers (moderate)
    82: ['Rain showers',    u'\uf740',  u'\uf740'],     # Rain showers (heavy)
    85: ['Snow showers',    u'\uf2dc',  u'\uf2dc'],     # Snow showers (light)
    86: ['Snow showers',    u'\uf2dc',  u'\uf2dc'],     # Snow showers (heavy)
    95: ['Thunderstorm',    u'\uf76c',  u'\uf76c'],     # Thunderstorm (light or moderate)
    96: ['Thunderstorm',    u'\uf76c',  u'\uf76c'],     # Thunderstorm with light hail
    99: ['Thunderstorm',    u'\uf76c',  u'\uf76c']      # Thunderstorm with heavy hail
}


try:
    data_json = json.loads(urlopen(url).read())
except:
    print("ERROR")

cur_time = datetime.strptime(data_json['current']['time'], '%Y-%m-%dT%H:%M')
sunrise = datetime.strptime(data_json['daily']['sunrise'][0],'%Y-%m-%dT%H:%M') 
sunset = datetime.strptime(data_json['daily']['sunset'][0],'%Y-%m-%dT%H:%M')
cur_is_dt = 1 if (cur_time>sunrise) & (cur_time<sunset) else 0 


# Current values
cur_wc = data_json['current']['weather_code']
cur_temp = round(data_json['current']['temperature_2m'])
cur_apparent_temp = round(data_json['current']['apparent_temperature'])
cur_humidity = round(data_json['current']['relative_humidity_2m'])
cur_wind = round(data_json['current']['wind_speed_10m'])

# Hourly forecast
hourly_date = ['']*3
hourly_wc = [0]*3
hourly_temp = [0]*3
hourly_precipitation = [0]*3
hourly_is_dt = [0]*3
k=0

for i in range(12):
    this_time = datetime.strptime(data_json['hourly']['time'][i], '%Y-%m-%dT%H:%M')
    if (this_time>cur_time) & (k<3):
        hourly_date[k] = this_time.strftime("%H:%M")
        hourly_wc[k] = data_json['hourly']['weather_code'][i]
        hourly_temp[k] = round(data_json['hourly']['temperature_2m'][i])
        hourly_precipitation[k] = round(data_json['hourly']['precipitation_probability'][i])
        hourly_is_dt[k] = 1 if (this_time>sunrise) & (this_time<sunset) else 0
        k = k+1
    
# Daily forecast
daily_date = ['']*7
daily_wc = [0]*7
daily_temp_min = [0]*7
daily_temp_max = [0]*7
daily_precipitation = [0]*7

for i in range(7):
    daily_date[i] = datetime.strptime(data_json['daily']['time'][i], '%Y-%m-%d').strftime("%a %d")
    daily_wc[i] = data_json['daily']['weather_code'][i]
    daily_temp_min[i] = round(data_json['daily']['temperature_2m_min'][i])
    daily_temp_max[i] = round(data_json['daily']['temperature_2m_max'][i])
    daily_precipitation[i] = round(data_json['daily']['precipitation_probability_max'][i])

# Construct tooltip layout
#tooltip_text = str.format(
#    "{}\n{}\n\n{}\n{}\n{}\n\n{}\n{}\n{}\n=====\n{}\n{}\n{}\n{}",
#    f'<span size="xx-large">{wmo_data[cur_wc][cur_is_dt+1]}</span>  <big>{wmo_data[cur_wc][0]}</big>',
#    f'<big>{cur_temp}°c (feels like {cur_apparent_temp}°c)</big>',
#    f'\uf2ca {daily_temp_min[0]}°c / {daily_temp_max[0]}°c',
#    f'\uf185 {sunrise.strftime("%H:%M")} / {sunset.strftime("%H:%M")}',
#    f'\uf72e {cur_wind}km/h / \uf773 {cur_humidity}%',
#    f'<b>Forcast:</b>\t\t\uf2ca\t\uf0e9',
#    f'{hourly_date[0]}\t{wmo_data[hourly_wc[0]][hourly_is_dt[0]+1]}\t{hourly_temp[0]}°c\t{hourly_precipitation[0]}%',
#    f'{hourly_date[1]}\t{wmo_data[hourly_wc[1]][hourly_is_dt[1]+1]}\t{hourly_temp[1]}°c\t{hourly_precipitation[1]}%',
#    f'{daily_date[1]}\t{wmo_data[daily_wc[1]][2]}\t{daily_temp_min[1]} / {daily_temp_max[1]}\t{daily_precipitation[1]}%',
#    f'{daily_date[2]}\t{wmo_data[daily_wc[2]][2]}\t{daily_temp_min[2]} / {daily_temp_max[2]}\t{daily_precipitation[2]}%',
#    f'{daily_date[3]}\t{wmo_data[daily_wc[3]][2]}\t{daily_temp_min[3]} / {daily_temp_max[3]}\t{daily_precipitation[3]}%',
#    f'{daily_date[4]}\t{wmo_data[daily_wc[4]][2]}\t{daily_temp_min[4]} / {daily_temp_max[4]}\t{daily_precipitation[4]}%',
#)
tooltip_text = str.format(
    "{}\n{}\n\n{}\n{}\n{}\n\n{}\n{}\n\n{}\n{}\n{}\n{}\n{}",
    f'<span size="xx-large">{wmo_data[cur_wc][cur_is_dt+1]}</span>  <big>{wmo_data[cur_wc][0]}</big>',
    f'<big>{cur_temp}°c (feels like {cur_apparent_temp}°c)</big>',
    f'\uf2ca {daily_temp_min[0]}°c / {daily_temp_max[0]}°c',
    f'\uf185 {sunrise.strftime("%H:%M")} / {sunset.strftime("%H:%M")}',
    f'\uf72e {cur_wind}km/h / \uf773 {cur_humidity}%',
    f'{hourly_date[0]}\t{hourly_date[1]}\t{hourly_date[2]}',
    f'{wmo_data[hourly_wc[0]][hourly_is_dt[0]+1]} {hourly_temp[0]}°c\t{wmo_data[hourly_wc[1]][hourly_is_dt[1]+1]} {hourly_temp[1]}°c\t{wmo_data[hourly_wc[2]][hourly_is_dt[2]+1]} {hourly_temp[2]}°c\t',
    f'\t\t\uf2ca\t\uf0e9',
    f'{daily_date[1]}\t{wmo_data[daily_wc[1]][2]}\t{daily_temp_min[1]} / {daily_temp_max[1]}\t{daily_precipitation[1]}%',
    f'{daily_date[2]}\t{wmo_data[daily_wc[2]][2]}\t{daily_temp_min[2]} / {daily_temp_max[2]}\t{daily_precipitation[2]}%',
    f'{daily_date[3]}\t{wmo_data[daily_wc[3]][2]}\t{daily_temp_min[3]} / {daily_temp_max[3]}\t{daily_precipitation[3]}%',
    f'{daily_date[4]}\t{wmo_data[daily_wc[4]][2]}\t{daily_temp_min[4]} / {daily_temp_max[4]}\t{daily_precipitation[4]}%',
)

out_data = {
    "text": f" {wmo_data[cur_wc][cur_is_dt+1]} {cur_temp}°c ",
    "tooltip": tooltip_text,
}

print(json.dumps(out_data))
exit()
