#!/bin/bash

# simple screen information script

wms=(berry dwm openbox twobwm pekwm simplewm labwc simplewc)
bars=(waybar polybar)

# define colors for color-echo
red="\e[31m"
grn="\e[32m"
ylw="\e[33m"
cyn="\e[36m"
blu="\e[34m"
prp="\e[35m"
rst="\e[0m"
#set="│┌ ┐┘─┐  └│┘└ ┌─ ├"

color-echo() {  # print with colors
      printf "\e[23C%s$cyn%-12s  $rst%s\n" "$1" "$2" "$3"
}

print-kernel() {
   color-echo "├ " "Kernel" "$(uname -smr)"
}

print-uptime() {
   up=$(</proc/uptime)
   up=${up//.*}                # string before first . is seconds
   days=$((${up}/86400))       # seconds divided by 86400 is days
   hours=$((${up}/3600%24))    # seconds divided by 3600 mod 24 is hours
   mins=$((${up}/60%60))       # seconds divided by 60 mod 60 is mins
   
   color-echo "├ " "Uptime" "$(echo $days'd '$hours'h '$mins'm')"
}

print-shell() {
   color-echo "└ "  "Shell" $SHELL
}

print-term() {
   color-echo "├ " "Terminal" $TERM
}

print-cpu() {
   cpu=$(grep -m1 -i 'model name' /proc/cpuinfo)

   color-echo "├ " "CPU" "${cpu#*: }" # everything after colon is processor name
}

print-disk() {
   # field 2 on line 2 is total, field 3 on line 2 is used
   disk=$(df -h / | awk 'NR==2 {total=$2; used=$3; print used" / "total}')
   
   color-echo "Disk" "$disk"
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

   color-echo "├ " "Mem" "$mem"
}

print-wm() {
   for wm in ${wms[@]}; do          # pgrep through wmname array
      pid=$(pgrep -x -u $USER $wm) # if found, this wmname has running process
   if [[ "$pid" ]]; then
      color-echo "├ " "WM" $wm
      break
   fi
done
}

print-bar() {
   for bar in ${bars[@]}; do
      pid=$(pgrep -x -u $USER $bar)
   if [[ "$pid" ]]; then
      color-echo "├ " "Bar" $bar
      break
   fi
   done
}

print-distro() {
   [[ -e /etc/os-release ]] && source /etc/os-release
   if [[ -n "$PRETTY_NAME" ]]; then
      color-echo "├ " "OS" "$PRETTY_NAME" 
   else
      color-echo "├ " "OS" "not found"
   fi
}

print-packages() {
   #color-echo "└ " "Packages" "$(dpkg -l | grep -c '^ii') (dpkg)"
   #color-echo "└ " "Packages" "$(sqlite3 /var/cache/dnf/packages.db 'SELECT count(pkg) FROM installed') (dnf) / $(flatpak list | wc -l) (flatpak)"
   color-echo "└ " "Packages" "$(sqlite3 /var/log/packages/pfs_packages.db 'SELECT count(package_name) FROM installed') (pfstool) / $(flatpak list | wc -l) (flatpak)"
}

print-resolution() {
   if [[ $DISPLAY ]]; then
      res=$(xwininfo -root | grep 'geometry' | awk '{print $2}' | cut -d+ -f1)
   else
      for dev in /sys/class/drm/*/modes; do
         read -r single_res _ < "$dev"

         [[ $single_res ]] && res="${single_res}"
      done
   fi

   color-echo "├ " "Resolution" $res
}

print-colors() {
   #colors=($(xrdb -query | sed -n 's/.*color\([0-9]\)/\1/p' | sort -nu | cut -f2))

   printf "\e[%bC" "31" 
   for i in {0..7}; do echo -en "\e[$((30+$i))m\uf111 ${colors[i]} \e[0m"; done
   echo
   #printf "\e[%bC" "31" 
   #for i in {8..15}; do echo -en "\e[$((82+$i))m\uf111 ${colors[i]} \e[0m"; done
}

print-image() {
   if [ -z $1 ]; then
      printf "$red%10s$rst\n" '                 '
      printf "$red%10s$rst\n" '        _/\_     '
      printf "$red%10s$rst\n" '      __\  /__   '
      printf "$red%10s$rst\n" '     <_      _>  '
      printf "$red%10s$rst\n" '       |/ )\|    '
      printf "$red%10s$rst\n" '         /       '
      printf "$red%10s$rst\n" '                 '
      printf '\e[%sA\e[9999999D' "${lines:-9}"
   elif [ $TERM = "xterm-kitty" ]; then
      kitty +kitten icat --align left --place 20x20@0x3 $1
      printf '\e[%sA\e[9999999D' "-11"
   elif [ $TERM = "foot" ]; then
      echo -n "  " && img2sixel -w 140 $1
      printf '\e[%sA\e[9999999D' "${lines:-13}"
   fi
}

# Main function
echo -e "$prp$USER@$HOSTNAME$rst\n\n"

print-image $1

printf "\e[21C%s\n" "System:"
print-distro
print-kernel
print-cpu
print-uptime
print-mem
print-packages

printf "\e[21C%s\n" "Session:"
print-wm
print-bar
print-resolution
print-term
print-shell
echo
print-colors
echo
