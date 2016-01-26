#!/bin/bash


~/.local/bin/update_monitors.sh

xsetroot -solid \#222222

wpa_gui &
gatotray &
gbatticon &
pnmixer &
tint2 & 
#conky | while read -r; do xsetroot -name "`echo -e $REPLY`"; done &

exec openbox-session
#exec ~/.local/bin/fusionwm
#exec ~/.local/bin/simplewm 2> ~/log.out
#exec ~/.local/bin/evilwm 
#exec ~/.local/bin/simplewm_backup 2> ~/log.out
