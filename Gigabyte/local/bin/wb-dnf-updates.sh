#!/bin/bash

n_updates=`dnf check-update | grep -Ec ' updates$'`

class="none"
tt_text="no updates available"
if [ $n_updates -gt 0 ]; then
   class="available"
   tt_text="$n_updates updates available"
fi

printf '{"text": "%s", "tooltip": "%s", "class": "%s"}\n' "$n_updates" "$tt_text" "$class"
