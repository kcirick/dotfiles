#!/bin/bash

# wintiler_v2.sh win_id pos_x pos_y size_x size_y verbose
#   -> pos_x/y  : resulting position of the window from top-left, values <1 is percentage
#   -> size_x/y : result size of the window, values <1 is percentage
#   -> verbose  : verbose output
#
# Example: wintiler_v2.sh 0x0 0 0.5 0.5 0.5 true
#

#--- User configuration -----
mon_x=1920              # monitor width
mon_y=1080              # monitor height
x_offset=0              # 
y_offset=27             # example status bar
titlebar_offset=0       # if there is a titlbar 
border_width=3          # window border
gap=10                  # gap between the windows
#--- User inputs ------------
user_window=${1:-"0x0"}
user_posx=${2:-0}
user_posy=${3:-0}
user_width=${4:-0}
user_height=${5:-0}
verbose=false
if [ "$6" == "true" ]; then verbose=true; fi
#----------------------------

if [ "$user_window" != "0x0" ]; then
   win=$user_window
else
   win=`xprop -root _NET_ACTIVE_WINDOW | awk '{print $5}'` 
fi


# Find out the x position of the winow to figure out which monitor
# Works only if the extra monitor is attached horizontally, not vertically
#xpos=`xdotool getwindowgeometry $win | grep 'Position' | sed -e 's/.*: \(.*\)\,.*/\1/'`

#----
half_gap=$(( $gap/2 ))

if [[ $user_posx == *"%" ]]; then
   posx_pct=${user_posx::-1} 
   new_posx=$(( ($mon_x-$x_offset)*$posx_pct/100 ))
else
   new_posx=$user_posx
fi
if [[ $new_posx == 0 ]]; then
   new_posx=$(( $new_posx + $half_gap ))
fi
if [[ $user_posy == *"%" ]]; then
   posy_pct=${user_posy::-1}
   new_posy=$(( ($mon_y-$y_offset)*$posy_pct/100 ))
else
   new_posy=$user_posy
fi
if [[ $new_posy == 0 ]]; then
   new_posy=$(( $new_posy + $half_gap ))
fi
# Adjust for gap and offset
new_posx=$(($new_posx+$half_gap+$x_offset))
new_posy=$(($new_posy+$half_gap+$y_offset))


if [[ $user_width == *"%" ]]; then
   width_pct=${user_width::-1}
   new_width=$(( ($mon_x-$x_offset)*$width_pct/100 ))
   new_width=$(( $new_width-$gap ))
else
   new_width=$user_width
fi
if [[ $user_height == *"%" ]]; then
   height_pct=${user_height::-1}
   new_height=$(( ($mon_y-$y_offset)*$height_pct/100 ))
   new_height=$(( $new_height-$gap ))
else
   new_height=$user_height
fi
# Adjust for border width and titlebar offset
new_width=$(($new_width-2*border_width-$half_gap))
new_height=$(($new_height-2*border_width-$half_gap-$titlebar_offset))

#if [ $xpos -ge $mon_x ]; then pos_x=$(($pos_x + $mon_x)); fi

if $verbose; then
   echo "Window         : $win"
   echo "Win position   : x=$new_posx / y=$new_posy"
   echo "Win size       : width=$new_width / height=$new_height"
fi

wmctrl -i -r $win -e 0,$new_posx,$new_posy,$new_width,$new_height

