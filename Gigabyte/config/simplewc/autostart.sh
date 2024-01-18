#!/bin/bash

gsettings set org.gnome.desktop.interface icon-theme 'Paper'

#swaybg -i ~/Pictures/Wallpapers/debian-blue.png &
swaybg -i ~/Pictures/Wallpapers/girl_hood_ears_1920x1080.jpg &

dunst >/dev/null 2>&1 &

swayidle -w timeout 900 'wlopm --off \*' resume 'wlopm --on \*' &

waybar &
