#!/bin/sh

vol_step=5
br_step=10
notif_timeout=1000

function get_volume {
   volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]{1,3}(?=%)' | head -1)
   is_muted=$(pactl get-sink-mute @DEFAULT_SINK@ | cut -d' ' -f2)
   if [ "$is_muted" == "yes" ]; then
      volume=0
   fi
   echo $volume
}

function get_brightness {
   brightness=$(brightnessctl i | grep 'Current' | grep -Po '[0-9]{1,3}(?=%)')
   echo $brightness
}

function send_vol_notify {
   vol=$(get_volume)
   notify-send -t $notif_timeout \
      -h int:value:$vol \
      -i /usr/share/icons/Papirus/16x16/panel/audio-volume-high.svg \
      " $vol %"
}

function send_br_notify {
   br=$(get_brightness)
   notify-send -t $notif_timeout \
      -h int:value:$br \
      -i /usr/share/icons/Papirus/16x16/panel/brightness-symbolic.svg \
      " $br %"
}

case $1 in 
   volume)
      case $2 in
         up)
            pactl set-sink-volume @DEFAULT_SINK@ +${vol_step}%
            ;;
         down)
            pactl set-sink-volume @DEFAULT_SINK@ -${vol_step}%
            ;;
         mute)
            pactl set-sink-mute @DEFAULT_SINK@ toggle
            ;;
      esac
      send_vol_notify
      ;;
   brightness)
      case $2 in
         up)
            brightnessctl -q set +${br_step}%
            ;;
         down)
            brightnessctl -q set ${br_step}%-
            ;;
      esac
      send_br_notify
      ;;
esac
