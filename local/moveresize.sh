#!/bin/bash

tiling=$1
winid=`xprop -root _NET_ACTIVE_WINDOW | awk '{print $5}'`
has_title=`xprop -id $winid | grep "_PEKWM_FRAME_DECOR" | awk '{print $3}'`

monitor_x=1920
monitor_y=1080
bar_height=30
border_width=3
#title_height=$(($(xprop -id $winid _NET_FRAME_EXTENTS | awk '{print $5}' | cut -d, -f1) - $border_width ))
title_height=0
if [ "$has_title" != "" ]; then
   [ $has_title -eq 6 ] && title_height=18
fi

if [ $tiling -gt 100 ]; then
   
   # --- Folding/Unfolding   
   # 101 - fold from left   / 102 - unfold from left
   # 111 - fold from right  / 112 - unfold from right
   # 121 - fold from top    / 122 - unfold from top
   # 131 - fold from bottom / 132 - unfold from bottom

   old_pos=`xdotool getwindowgeometry $winid | grep Position | awk '{print $2}'`
   old_pos_x=`echo $old_pos | cut -d, -f1`
   old_pos_y=`echo $old_pos | cut -d, -f2`
   old_size=`xdotool getwindowgeometry $winid | grep Geometry | awk '{print $2}'`
   old_size_x=`echo $old_size | cut -dx -f1`
   old_size_y=`echo $old_size | cut -dx -f2`

   if [ $tiling -eq 101 -o $tiling -eq 111 ]; then
      size_x=$(echo "$old_size_x/2" | bc)
   elif [ $tiling -eq 102 -o $tiling -eq 112 ]; then
      size_x=$(echo "$old_size_x*2" | bc)
   else
      size_x=$old_size_x
   fi
   if [ $tiling -eq 121 -o $tiling -eq 131 ]; then
      size_y=$(echo "$old_size_y/2" | bc)
   elif [ $tiling -eq 122 -o $tiling -eq 132 ]; then
      size_y=$(echo "$old_size_y*2" | bc)
   else
      size_y=$old_size_y
   fi

   if [ $tiling -eq 101 ]; then
      pos_x=$(echo "$old_pos_x + $size_x - 2*$border_width" | bc)
   elif [ $tiling -eq 102 ]; then
      pos_x=$(echo "$old_pos_x - $old_size_x - 2*$border_width" | bc)
   else
      pos_x=$(echo "$old_pos_x - 2*$border_width" | bc)
   fi
   if [ $tiling -eq 121 ]; then
      pos_y=$(echo "$old_pos_y + $size_y - 2*($title_height+$border_width)" | bc)
   elif [ $tiling -eq 122 ]; then
      pos_y=$(echo "$old_pos_y - $old_size_y - 2*($title_height+$border_width)" | bc)
   else
      pos_y=$(echo "$old_pos_y - 2*($title_height+$border_width)" | bc)
   fi

   echo "wmctrl -r :ACTIVE: -e 0,$pos_x,$pos_y,$size_x,$size_y"
   wmctrl -r :ACTIVE: -e 0,$pos_x,$pos_y,$size_x,$size_y

else

   #--- Regular tiling

   if [ $tiling -eq 1 -o $tiling -eq 3 -o $tiling -eq 7 -o $tiling -eq 9 ]; then
      size_x=$(echo "$monitor_x/2 - 2*$border_width" | bc)
      size_y=$(echo "($monitor_y-$bar_height)/2 - 2*$border_width" | bc)
   elif [ $tiling -eq 4 -o $tiling -eq 6 ]; then
      size_x=$(echo "$monitor_x/2 - 2*$border_width" | bc)
      size_y=$(echo "$monitor_y - 2*$border_width - $bar_height" | bc )
   elif [ $tiling -eq 2 -o $tiling -eq 8 ]; then
      size_x=$(echo "$monitor_x - 2*$border_width" | bc)
      size_y=$(echo "($monitor_y-$bar_height)/2 - 2*$border_width" | bc)
   else # [ $tiling -eq 5 ]
      size_x=$(echo "$monitor_x - 2*$border_width" | bc )
      size_y=$(echo "$monitor_y - 2*$border_width - $bar_height" | bc )
   fi

   if [ $tiling -eq 1 -o $tiling -eq 2 ]; then
      pos_x=0
      pos_y=$(echo "($monitor_y+$bar_height)/2" | bc)
   elif [ $tiling -eq 3 ]; then
      pos_x=$(echo "$monitor_x/2" | bc )
      pos_y=$(echo "($monitor_y+$bar_height)/2" | bc)
   elif [ $tiling -eq 6 -o $tiling -eq 9 ]; then
      pos_x=$(echo "$monitor_x/2" | bc )
      pos_y=$bar_height
   else # [ $tiling -eq 4 -o $tiling -eq 5 -o $tiling -eq 7 -o $tiling -eq 8 ]
      pos_x=0
      pos_y=$bar_height
   fi

   echo "wmctrl -r :ACTIVE: -e 0,$pos_x,$pos_y,$size_x,$size_y"
   wmctrl -r :ACTIVE: -e 0,$pos_x,$pos_y,$size_x,$(($size_y-$title_height))

fi
