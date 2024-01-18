#!/usr/bin/env python3

import subprocess
from pyquery import PyQuery  # install using `pip install pyquery`
import json

# weather icons
#weather_icons = {
#    "sunnyDay": "\uf185",
#    "clearNight": "\uf186",
#    "cloudyFoggyDay": "\uf6c4",
#    "cloudyFoggyNight": "\uf6c3",
#    "rainyDay": "\uf743",
#    "rainyNight": "\uf73c",
#    "snowyIcyDay": "\uf2dc",
#    "snowyIcyNight": "\uf2dc",
#    "severe": "\uf76c",
#    "default": "?",
#}
weather_icons = {
    "Sunny": "\uf185",              "Clear Night": "\uf186",
    "Mostly Sunny": "\uf185",       "Mostly Clear Night": "\uf186",
    "Partly Cloudy": "\uf6c4",      "Partly Cloudy Night": "\uf6c3",
    "Mostly Cloudy": "\uf6c4",      "Mostly Cloudy Night": "\uf6c3",
    "Cloudy": "\uf0c2",
    "Wind": "\uf72e",
    "Scattered Showers": "\uf743",  "Scattered Showers Night": "\uf73c",
    "Rain": "\uf740",
    "Rain and Hail": "\uf7ad\uf740", 
    "Rain and Snow": "\uf2dc\uf740",
    "Scattered Snow": "\uf2dc",     "Scattered Snow Night": "\uf2dc",
    "Snow": "\uf2dc",
    "default": "?",
}

# get location_id
# to get your own location_id, go to https://weather.com & search your location.
# once you choose your location, you can see the location_id in the URL(64 chars long hex string)
# like this: https://weather.com/en-IN/weather/today/l/c3e96d6cc4965fc54f88296b54449571c4107c73b9638c16aafc83575b4ddf2e
location_id = "a312cdc838d6fd74551b09a5d163394c11c8e56d86ca0121a1809053d02c3c9a"

# priv_env_cmd = 'cat $PRIV_ENV_FILE | grep weather_location | cut -d "=" -f 2'
# location_id = subprocess.run(
#     priv_env_cmd, shell=True, capture_output=True).stdout.decode('utf8').strip()

# get html page
url = "https://weather.com/en-IN/weather/today/l/" + location_id
html_data = PyQuery(url=url)


#-----------------------
# hourly header
hpred_header = html_data("section[aria-label='Hourly Forecast']")(
    "h3 > span"
)
hpred_header = [i.text() for i in hpred_header.items()]
#hpred_header = f"\nT\t{hpred_header[0]}\t{hpred_header[1]}\t{hpred_header[2]}\t{hpred_header[3]}"
#print(hpred_header)

# hourly temp prediction
hpred_temp = html_data("section[aria-label='Hourly Forecast']")(
    "div[data-testid='SegmentHighTemp'] > span"
)
hpred_temp = [i.text() for i in hpred_temp.items()]
#hpred_temp = f"\n\t{hpred_temp[0]}\t{hpred_temp[1]}\t{hpred_temp[2]}\t{hpred_temp[3]}"
#print(hpred_temp)

# hourly weather prediction
hpred_weather = html_data("section[aria-label='Hourly Forecast']")(
    "svg[data-testid='Icon'] > title"
)
hpred_weather = [i.text() for i in hpred_weather.items()]
hpred_weather = hpred_weather[0:9:2]
hpred_weather_icon = [weather_icons[i] for i in hpred_weather]
#hpred_weather_icon = f"\n\t{hpred_weather_icon[0]}\t{hpred_weather_icon[1]}\t{hpred_weather_icon[2]}\t{hpred_weather_icon[3]}"
#print(hpred_weather_icon)

# hourly precipitation prediction
hpred_precip = html_data("section[aria-label='Hourly Forecast']")(
    "div[data-testid='SegmentPrecipPercentage'] > span"
)
hpred_precip = [i.text().replace("Chance of Rain", "")  for i in hpred_precip.items()]
#hpred_precip = f"\n\t{hpred_precip[0]}\t{hpred_precip[1]}\t{hpred_precip[2]}\t{hpred_precip[3]}" 
#print(hpred_precip)

next_hour_text = f"{hpred_weather_icon[1]}\t{hpred_temp[1]}\t{hpred_precip[1]}"

#-----------------------
# current temperature
temp = html_data("span[data-testid='TemperatureValue']").eq(0).text()
#print(temp)

# current status phrase
status = html_data("div[data-testid='wxPhrase']").text()
status = f"{status[:16]}.." if len(status) > 17 else status
#print(status)

# status code
status_code = hpred_weather[0];
#print(status_code)

# status icon
icon = (
    weather_icons[status_code]
    if status_code in weather_icons
    else weather_icons["default"]
)
#print(icon)

# temperature feels like
temp_feel = html_data(
    "div[data-testid='FeelsLikeSection'] > span > span[data-testid='TemperatureValue']"
).text()
temp_feel_text = f"{temp}c (feels like {temp_feel}c)"
#print(temp_feel_text)

# min-max temperature
temp_min = (
    html_data("div[data-testid='wxData'] > span[data-testid='TemperatureValue']")
    .eq(1)
    .text()
)
temp_max = (
    html_data("div[data-testid='wxData'] > span[data-testid='TemperatureValue']")
    .eq(0)
    .text()
)
temp_min_max = f"\uf2ca  {temp_min} / {temp_max}"
#print(temp_min_max)

# wind speed
wind_speed = html_data("span[data-testid='Wind']").text().split("\n")[1]
wind_text = f"\uf72e  {wind_speed}"
#print(wind_text)

# humidity
humidity = html_data("span[data-testid='PercentageValue']").text()
humidity_text = f"\uf773  {humidity}"
#print(humidity_text)

# visibility
visbility = html_data("span[data-testid='VisibilityValue']").text()
visbility_text = f"  {visbility}"
#print(visbility_text)

# air quality index
air_quality_index = html_data("text[data-testid='DonutChartValue']").text()
#print(air_quality_index)

# sunrise-sunset
sunrise = html_data("div[data-testid='SunriseValue']").text().split("\n")[1]
sunset  = html_data("div[data-testid='SunsetValue']").text().split("\n")[1]
sunrise_sunset = f"\uf185  {sunrise} / {sunset}"
#print(sunrise_sunset)

#-----------------------
# daily header
dpred_header = html_data("section[aria-label='Daily Forecast']")(
    "h3 > span"
)
dpred_header = [i.text() for i in dpred_header.items()]
#print(dpred_header)

# daily temp high/low prediction
dpred_templ = html_data("section[aria-label='Daily Forecast']")(
    "div[data-testid='SegmentLowTemp'] > span"
)
dpred_templ = [i.text() for i in dpred_templ.items()]
dpred_temph = html_data("section[aria-label='Daily Forecast']")(
    "div[data-testid='SegmentHighTemp'] > span"
)
dpred_temph = [i.text() for i in dpred_temph.items()]
#print(dpred_templ + " - " + dpred_temph)

# daily weather prediction
dpred_weather = html_data("section[aria-label='Daily Forecast']")(
    "svg[data-testid='Icon'] > title"
)
dpred_weather = [i.text() for i in dpred_weather.items()]
dpred_weather = dpred_weather[0:9:2]
dpred_weather_icon = [weather_icons[i] for i in dpred_weather]
#print(dpred_weather)

# daily precipitation prediction
dpred_precip = html_data("section[aria-label='Daily Forecast']")(
    "div[data-testid='SegmentPrecipPercentage'] > span"
)
dpred_precip = [i.text().replace("Chance of Rain", "") for i in dpred_precip.items()]
#print(dpred_precip)

#-----------------------
# tooltip text
tooltip_text = str.format(
        "{}  {}\n{}\n\n{}\n{}\n{}\n\n{}\n{}\n{}\n{}\n{}",
#    f'<span size="xx-large">{temp}</span>',
    f'<span size="xx-large">{icon}</span>',
    f"<big>{status}</big>",
    f"<big>{temp_feel_text}</big>",
    f"{temp_min_max}",
    f"{sunrise_sunset}",
    f"{wind_text} / {humidity_text}",
    f"<b>Forecast:</b>\t\t\uf2ca\t\uf0e9",
    f"{hpred_header[1]}\t{hpred_weather_icon[1]}\t{hpred_temp[1]}\t{hpred_precip[1]}",
    f"{dpred_header[1]}\t{dpred_weather_icon[1]}\t{dpred_templ[1]} / {dpred_temph[1]}\t{dpred_precip[1]}",
    f"{dpred_header[2]}\t{dpred_weather_icon[2]}\t{dpred_templ[2]} / {dpred_temph[2]}\t{dpred_precip[2]}",
    f"{dpred_header[3]}\t{dpred_weather_icon[3]}\t{dpred_templ[3]} / {dpred_temph[3]}\t{dpred_precip[3]}",
)

# print waybar module data
out_data = {
    "text": f" {icon} {temp} ",
    "alt": status,
    "tooltip": tooltip_text,
    "class": status_code.replace(" ", ""),
}
print(json.dumps(out_data))
