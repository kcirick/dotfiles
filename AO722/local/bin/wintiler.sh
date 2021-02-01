#!/bin/bash
# wintiler.sh 0x0 3 3 1 1 1 2 true
#                 | | | | | | |-> verbose  
#                 | | | | | |---> size y
#                 | | | | |-----> size x
#                 | | | |-------> position y
#                 | | |---------> position x
#                 | |-----------> grid size y
#                 |-------------> grid size x
#
# 
#  |-----------------------|  Example:
#  |       |       |       |  
#  |  0/0  |  1/0  |  2/0  |  -> Grid is divided into 3x3
#  |       |       |       |  -> Window is positioned at (x,y)=(1,1)
#  |-----------------------|  -> Window dimension is 1x2 multiple of grid size
#  |       ||-----||       |
#  |  0/1  || 1/1 ||  2/1  |
#  |       ||     ||       |
#  |--------|     |--------|
#  |       ||     ||       |
#  |  0/2  || 1/2 ||  2/2  |
#  |       ||-----||       |
#  |-----------------------|
#

#--- User configuration -----
mon_x=1366              # monitor width
mon_y=768               # monitor height
x_offset=0              # 
y_offset=24             # example status bar
titlebar_offset=0       # if there is a titlbar 
border_width=3          # window border
gap=10                  # gap between the windows
#--- User inputs ------------
user_window=${1:-"0x0"}
grid_size_x=${2:-1}
grid_size_y=${3:-1}
win_pos_x=${4:-0}
win_pos_y=${5:-0}
win_width=${6:-1}
win_height=${7:-1}
verbose=false
if [ "$8" == "true" ]; then verbose=true; fi
#----------------------------

if [ "$user_window" != "0x0" ]; then
   win=$user_window
else
   win=`xprop -root _NET_ACTIVE_WINDOW | awk '{print $5}'` 
fi

# Find out the x position of the winow to figure out which monitor
# Works only if the extra monitor is attached horizontally, not vertically
xpos=`xdotool getwindowgeometry $win | grep 'Position' | sed -e 's/.*: \(.*\)\,.*/\1/'`

#----
grid_width=$((($mon_x-$x_offset-($grid_size_x+1)*$gap)/$grid_size_x ))
grid_height=$((($mon_y-$y_offset-($grid_size_y+1)*$gap)/$grid_size_y ))

pos_x=$(($win_pos_x*$grid_width+$(($win_pos_x+1))*$gap + $x_offset))
pos_y=$(($win_pos_y*$grid_height+$(($win_pos_y+1))*$gap + $y_offset))

size_x=$(($win_width*$grid_width+$(($win_width-1))*$gap))
size_y=$(($win_height*$grid_height+$(($win_height-1))*$gap))
size_x=$(($size_x-2*border_width))
size_y=$(($size_y-2*border_width-$titlebar_offset))

if [ $xpos -ge $mon_x ]; then pos_x=$(($pos_x + $mon_x)); fi

if $verbose; then
   echo "Window         : $win"
   echo "Grid size      : $grid_size_x x $grid_size_y (dimension $grid_width x $grid_height)"
   echo "Win position   : x=$pos_x / y=$pos_y"
   echo "Win size       : width=$size_x / height=$size_y"
fi

wmctrl -i -r $win -e 0,$pos_x,$pos_y,$size_x,$size_y

