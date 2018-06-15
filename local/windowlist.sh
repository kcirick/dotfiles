#!/bin/bash

cur_dt=`xprop -root _NET_CURRENT_DESKTOP | awk '{ print $3}'`

win_list_all=`xprop -root _NET_CLIENT_LIST | cut -d' ' -f5- | sed 's/,//g'`

declare -a win_list=()
for win in ${win_list_all}; do
   win_dt=`xprop -id $win _NET_WM_DESKTOP | awk '{print $3}'`
   if [ $win_dt -eq $cur_dt ]; then
      win_list+=($win)
      win_list+=("`xprop -id $win _NET_WM_NAME | cut -d'"' -f2`")
   fi
done

echo $(printf "'%s' " "${win_list[@]}")

ans=$(zenity --hide-header --list --column "ID" --column "Name" "${win_list[@]}")

xdotool windowraise $ans
