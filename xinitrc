#!/bin/sh
#
# ~/.xinitrc

if [ `xrandr | grep -c ' connected '` -eq 2 ]; then #dual-monitor
	if [ `xrandr | grep VGA1 | grep -c ' connected '` -eq 1 ]; then
		xrandr --output LVDS1 --auto --primary --output VGA1 --auto --right-of LVDS1
	fi
	if [ `xrandr | grep DVI1 | grep -c ' connected '` -eq 1 ]; then
		xrandr --output LVDS1 --auto --primary --output DVI1 --auto --right-of LVDS1
	fi
	xsetroot -solid \#333333
else
	xrandr --output LVDS1 --auto --primary --output VGA1 --off --output DVI1 --off
	feh --bg-center ~/SnowLeopard/Wallpapers/hummingbird.jpg
#	feh --bg-center ~/SnowLeopard/Wallpapers/wood_wallpaper.jpg
fi

xbacklight -set 50
xsetroot -cursor_name left_ptr
xmodmap -e "keycode 134 = Multi_key"

# SCIM Setup
export XMODIFIERS=@im=SCIM
export GTK_IM_MODULE="scim"

ck-launch-session nm-applet --sm-disable &
mpd ~/.mpd/mpd.conf 
stalonetray &

# dwm
conky | while read -r; do xsetroot -name "`echo -e $REPLY`"; done &
exec ~/dwm/dwm

# i3
#(sleep 1s && conky -c ~/.conkyrc_i3 | dzen2 -bg black -fg white -fn -*-clean-medium-r-*-*-12-*-*-*-*-*-*-* -p -w 450 -h 16 -x 750 -y 0 -ta r) &
#exec ~/i3/i3
