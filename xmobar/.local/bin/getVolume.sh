#!/bin/sh

out=$(amixer -D pulse get Master | grep '\[' | tr ']%' '[ ')
onoff=$(echo -n "$out" | cut -d '[' -f 4 | head -n 1)
vol=$(echo -n "$out" | cut -d '[' -f 2 | head -n 1)
if [ "$onoff" = 'on' ]; then
    echo -n "$vol"
else
    echo -n "$onoff"
fi
