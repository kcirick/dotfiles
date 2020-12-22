#!/bin/bash

ans=$(zenity --list --hide-header --column=OPTION \
   Lock \
   Suspend \
   Reboot \
   Shutdown)

if [ "$ans" == "Lock" ]; then
   xflock4
elif [ "$ans" == "Suspend" ]; then
   systemctl suspend
elif [ "$ans" == "Reboot" ]; then
   systemctl reboot
elif [ "$ans" == "Shutdown" ]; then
   systemctl halt
fi
