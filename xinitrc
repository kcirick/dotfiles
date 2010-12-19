#!/bin/sh
#
# ~/.xinitrc
# Executed by startx (run your window manager from here)


xset +fp /usr/share/fonts/misc &

#feh --bg-scale ~/Wallpapers/zebra.jpg &
#feh --bg-scale ~/Wallpapers/Kelly_Rick-31_Small.jpg &
feh --bg-center ~/Wallpapers/christmas.jpg &

xsetroot -cursor_name left_ptr

# Initialize Variables for getcpu() function
PREV_TOTAL=0
PREV_IDLE=0

getcpu(){
	CPU=(`cat /proc/stat | grep '^cpu '`) # Get the total CPU statistics.
	unset CPU[0]                          # Discard the "cpu" prefix.
	IDLE=${CPU[4]}                        # Get the idle CPU time.

	# Calculate the total CPU time.
	TOTAL=0
	for VALUE in "${CPU[@]}"; do
		let "TOTAL=$TOTAL+$VALUE"
	done

	# Calculate the CPU usage since we last checked.
	let "DIFF_IDLE=$IDLE-$PREV_IDLE"
   let "DIFF_TOTAL=$TOTAL-$PREV_TOTAL"
	let "DIFF_USAGE=100*($DIFF_TOTAL-$DIFF_IDLE)/$DIFF_TOTAL"

   echo "$TOTAL $IDLE $DIFF_USAGE"
}

getmem(){
   MEM=(`/usr/bin/free -m | grep 'Mem'`)
   let "FREE=${MEM[3]}+${MEM[5]}+${MEM[6]}"
   let "MEM_USAGE=(100*(${MEM[1]}-$FREE))/${MEM[1]}"

   echo "$MEM_USAGE%"
}

FULL=`cat /sys/class/power_supply/BAT1/energy_full`
battery(){
   CHARGE=`cat /sys/class/power_supply/BAT1/energy_now`
   STATUS=`cat /sys/class/power_supply/BAT1/status`
	let "CHARGE=${CHARGE}*100/${FULL}"
	case $STATUS in
		Full)
	   	SIGN="=";;
		Charging)
		   SIGN="+";;
		Discharging)
			SIGN="-";;
	esac
	echo "${CHARGE}%${SIGN}"
}

INDEX=25
while true; do
	cpuusage=(`getcpu`)
   PREV_TOTAL=${cpuusage[0]}
	PREV_IDLE=${cpuusage[1]}

	if [ "$INDEX" -gt 20 ] ; then
		GMAIL=`~/.local/scripts/gmail.py`
		INDEX=1
	fi
	xsetroot -name "CPU: ${cpuusage[2]}% | Mem: `getmem` | Mail: ${GMAIL} | Bat: `battery` | `date +'%A, %B %d %H:%M'`"

	let "INDEX=${INDEX}+1"
	sleep 5
done &

# Exec dwm
exec ~/dwm/dwm 

