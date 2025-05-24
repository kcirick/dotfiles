#!/bin/bash

# Set environment variable for thunar icon
gsettings set org.gnome.desktop.interface icon-theme "Papirus"

wbg ~/Pictures/Wallpapers/kiwi_bird-wallpaper-1920x1080.jpg & 

fcitx5 &

mako &

if thispid=$(pidof hypridle); then kill $thispid; fi
hypridle &

TERM=foot waybar &

