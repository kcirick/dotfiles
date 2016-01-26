#!/bin/bash

if [ `xrandr | grep -c ' connected '` -eq 2 ]; then # dual-monitor
   if [ `xrandr | grep VGA-0 | grep -c ' connected '` -eq 1 ]; then
      xrandr --output LVDS --auto --primary --output VGA-0 --auto --right-of LVDS
   fi
else
   xrandr --output LVDS --auto --primary --output VGA-0 --off
fi

