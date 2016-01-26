#!/bin/bash

# simple screen information script
# similar to archey and screenfetch without annoying ASCII graphics

#wms=( 2bwm 2wm 9wm aewm afterstep ahwm alopex amiwm antiwm awesome blackbox bspwm catwm clfswm ctwm cwm dminiwm dragonflywm dwm echinus \
#   euclid-wm evilpoison evilwm fluxbox flwm fvwm-crystal goomwwm hcwm herbstluftwm i3 icewm jwm karmen larswm lwm matwm2 mcwm monsterwm \
#   musca notion nwm olwm openbox oroborus pekwm ratpoison sapphire sawfish sscrotwm sithwm smallwm snapwm spectrwm stumpwm subtle tfwm tinywm tritium twm \
#   uwm vtwm w9wm weewm wind windowlab wm2 wmaker wmfs wmii wmx xfwm4 xmonad xoat yeahwm fusionwm )

wms=(fusionwm dwm openbox)

# define colors for color-echo
red="\e[31m"
grn="\e[32m"
ylw="\e[33m"
cyn="\e[36m"
blu="\e[34m"
prp="\e[35m"
rst="\e[0m"

color-echo() {  # print with colors
   echo -e "$cyn$1: $rst$2"
}

print-kernel() {
   color-echo 'Kernel' "$(uname -smr)"
}

print-uptime() {
   up=$(</proc/uptime)
   up=${up//.*}                # string before first . is seconds
   days=$((${up}/86400))       # seconds divided by 86400 is days
   hours=$((${up}/3600%24))    # seconds divided by 3600 mod 24 is hours
   mins=$((${up}/60%60))       # seconds divided by 60 mod 60 is mins
   color-echo "Uptime" $days'd '$hours'h '$mins'm'
}

print-shell() {
   color-echo 'Shell' $SHELL
}

print-cpu() {
   cpu=$(grep -m1 -i 'model name' /proc/cpuinfo)
   color-echo 'CPU' "${cpu#*: }" # everything after colon is processor name
}

print-disk() {
   # field 2 on line 2 is total, field 3 on line 2 is used
   disk=$(df -h / | awk 'NR==2 {total=$2; used=$3; print used" / "total}')
   color-echo 'Disk' "$disk"
}

print-mem() {
   # field 2 on line 2 is total, field 3 on line 2 is used (in new format)
   # field 2 on line 2 is total, field 3 on line 3 is used (in old format)
   # use -m because slackware does not have -h

   if [[ $(free -m) =~ "buffers" ]]; then # using old format
      mem=$(free -m | awk 'NR==2 {total=$2} NR==3 {used=$3; print used"M / "total"M"}')
   else # using new format
      mem=$(free -m | awk 'NR==2 {total=$2} NR==2 {used=$3; print used"M / "total"M"}')
   fi
   color-echo 'Mem' "$mem"
}

print-wm() {
   for wm in ${wms[@]}; do          # pgrep through wmname array
      pid=$(pgrep -x -u $USER $wm) # if found, this wmname has running process
   if [[ "$pid" ]]; then
      color-echo 'WM' $wm
      break
   fi
done
}

print-distro() {
   [[ -e /etc/os-release ]] && source /etc/os-release
   if [[ -n "$PRETTY_NAME" ]]; then
      color-echo 'OS' "$PRETTY_NAME"
   else
      color-echo 'OS' "not found"
   fi
}

print-colors() {
   xrdb -load $HOME/.Xdefaults

   colors=($(xrdb -query | sed -n 's/.*color\([0-9]\)/\1/p' | sort -nu | cut -f2))

   echo -e "\e[1;37m
 Black      Red        Green      Yellow     Blue       Magenta    Cyan       White
 ───────────────────────────────────────────────────────────────────────────────────────\e[0m"
   for i in {0..7}; do echo -en "\e[$((30+$i))m █ ${colors[i]} \e[0m"; done
   echo
   for i in {8..15}; do echo -en "\e[1;$((22+$i))m █ ${colors[i]} \e[0m"; done
   echo -e "\n"

#   NAMES=('black' 'red' 'green' 'yellow' 'blue' 'magenta' 'cyan' 'white')
#   for f in {0..7}; do
#      echo -en "\033[m\033[$(($f+30))m ${NAMES[$f]} " # normal colors
#   done
#   echo
#   for f in {0..7}; do
#      echo -en "\033[m\033[1;$(($f+30))m ${NAMES[$f]} " # bold colors
#   done
#   echo -e "$rst\n"
}

echo -e "\n$prp$USER@$HOSTNAME$rst\n"
print-distro
print-uptime
print-shell
print-wm
print-disk
print-mem
print-kernel
print-cpu
echo
print-colors

