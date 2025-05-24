#!/bin/bash

update_emerge=$(emerge -puDN @world | grep '\[ebuild' | cut -d ']' -f 2 | awk '{print $1}')
update_flatpak=$(flatpak remote-ls --updates | awk -F'\t' '{print $1}')

count_emerge=0
count_flatpak=0
[[ ! -z $update_emerge ]] && count_emerge=$(echo "$update_emerge" | wc -l)
[[ ! -z $update_flatpak ]] && count_flatpak=$(echo "$update_flatpak" | wc -l)
count_total=$((count_emerge + count_flatpak))

if [ $count_total -eq 0 ]; then
   alt="updated"
   tooltip="no updates!"
else
   [ $count_emerge ]  && emerge_tooltip="emerge:\n\t$(echo "$update_emerge" | perl -p -e 's/\n/\\n\\t/g')"
   [ $count_flatpak ] && flatpak_tooltip="flatpak:\n\t$(echo "$update_flatpak" | perl -p -e 's/\n/\\n\\t/g')"

   alt="has-updates"
   tooltip="$emerge_tooltip"
   [ $count_emerge ] && tooltip+="\n"
   tooltip+="$flatpak_tooltip"
fi

echo "{ \"text\": \"$count_total\", \"tooltip\": \"$tooltip\", \"class\": \"$alt\", \"alt\": \"$alt\" }"
