#!/bin/bash

n_updates=`apt list --upgradable 2> /dev/null | wc -l`
n_updates=$((n_updates-1))

if [[ $n_updates == 0 ]]; then
   echo '%{F#555}no updates available%{F-}'
elif [[ $n_updates == 1 ]]; then
   echo "$n_updates update available"
else
   echo "$n_updates updates available"
fi
