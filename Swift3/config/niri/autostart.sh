#!/bin/bash

#TERM=foot waybar -c ~/.config/waybar/config_niri.jsonc &

quickshell &

wbg ~/Pictures/Wallpapers/portal_poster-1920x1080.png &

swayidle -C ~/.config/swayidle/config_niri &

dbus-update-activation-environment --all

pipewire &

#fcitx5 &

