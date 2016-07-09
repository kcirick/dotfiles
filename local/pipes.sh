#!/bin/bash
# pipes.sh: Animated pipes terminal screensaver.
#
# Original:
#   https://github.com/pipeseroni/pipes.sh


f=35     # Framerate
s=20     # Prob of straight fitting
r=2500   # Reset after x characters / 0 for no limit

set="┃┏ ┓┛━┓  ┗┃┛┗ ┏━"
#set="│┌ ┐┘─┐  └│┘└ ┌─"
#set="║╔ ╗╝═╗  ╚║╝╚ ╔═"

w=$(tput cols) h=$(tput lines)

cleanup() {
    # clear up standard input
    read -t 0.001 && cat </dev/stdin>/dev/null

    tput rmcup
    tput cnorm
    stty echo
    tput clear
    exit 0
}

trap cleanup HUP TERM
trap 'break 2' INT

c=1
n=0 
l=0
x=w/2 y=h/2

stty -echo
tput smcup
tput civis
tput clear

# any key press exits the loop and this script
while REPLY=; read -t 0.0$((1000/f)) -n 1 2>/dev/null; [[ -z $REPLY ]] ; do
     # New position:
     (($l%2)) && ((x+=-$l+2,1)) || ((y+=$l-1))

     # Loop on edges (change color on loop):
     (($x>=w||$x<0||$y>=h||$y<0)) && ((c=(c%6+1)))
     ((x=(x+w)%w))
     ((y=(y+h)%h))

     # New random direction:
     ((n=RANDOM%s-1))
     ((n=($n>1||$n==0)?$l:$l+$n))
     ((n=($n<0)?3:$n%4))

     # Print:
     tput cup $y $x
     echo -ne "\e[1m"
     echo -ne "\e[3${c}m"
     echo -n "${set:l*4+n:1}"
     l=$n

    ((r>0 && t*p>=r)) && tput reset && tput civis && t=0 || ((t++))
done

cleanup
