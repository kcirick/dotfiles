#!/bin/bash

# simple screen information script

wms=(berry fusionwm dwm openbox twobwm pekwm)

# define colors for color-echo
red="\e[31m"
grn="\e[32m"
ylw="\e[33m"
cyn="\e[36m"
blu="\e[34m"
prp="\e[35m"
rst="\e[0m"

color-echo() {  # print with colors
   printf "$red$1$cyn%10s : $rst$3\n" "$2"
}


print-kernel() {
   color-echo "$1" "Kernel" "$(uname -smr)"
}

print-uptime() {
   up=$(</proc/uptime)
   up=${up//.*}                # string before first . is seconds
   days=$((${up}/86400))       # seconds divided by 86400 is days
   hours=$((${up}/3600%24))    # seconds divided by 3600 mod 24 is hours
   mins=$((${up}/60%60))       # seconds divided by 60 mod 60 is mins
   
   color-echo "$1" "Uptime" "$(echo $days'd '$hours'h '$mins'm')"
}

print-shell() {
   color-echo "$1" "Shell" $SHELL
}

print-cpu() {
   cpu=$(grep -m1 -i 'model name' /proc/cpuinfo)

   color-echo "$1" "CPU" "${cpu#*: }" # everything after colon is processor name
}

print-disk() {
   # field 2 on line 2 is total, field 3 on line 2 is used
   disk=$(df -h / | awk 'NR==2 {total=$2; used=$3; print used" / "total}')
   
   color-echo "$1" "Disk" "$disk"
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

   color-echo "$1" "Mem" "$mem"
}

print-wm() {
   for wm in ${wms[@]}; do          # pgrep through wmname array
      pid=$(pgrep -x -u $USER $wm) # if found, this wmname has running process
   if [[ "$pid" ]]; then
      color-echo "$1" "WM" $wm
      break
   fi
done
}

print-distro() {
   [[ -e /etc/os-release ]] && source /etc/os-release
   if [[ -n "$PRETTY_NAME" ]]; then
      color-echo "$1" "OS" "$PRETTY_NAME"
   else
      color-echo "$1" "OS" "not found"
   fi
}

print-packages() {
   color-echo "$1"  "Packages" "$(ls -1 /var/log/packages/ | wc -l) (pfstool)"
}

print-resolution() {
   res=$(xwininfo -root | grep 'geometry' | awk '{print $2}' | cut -d+ -f1)
   
   color-echo "$1" "Resolution" $res
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
print-distro      '             '
print-kernel      '     _/\_    '
print-cpu         '   __\  /__  '
print-mem         '  <_      _> '
print-shell       '    |/ )\|   '
print-wm          '      /      '
print-resolution  '             '
print-packages    '             '
echo
#print-colors

