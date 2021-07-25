#!/bin/sh

# # Find all the displays
# out=$(cd /tmp/.X11-unix && for x in X*; do if test "${x#X}" -lt 10; then echo "${x#X}"; fi; done)
#
# # return if none found
# if test -z "$out"; then
#     exit 0
# fi
#
# # Restart xmobar and stalonetray
# pkill xmobar
# pkill stalonetray
# for each in $out; do
#     echo "$each"
#
#     xmobar -x "$each" ~/.config/xmobar/xmobarrc
#     # stalonetray -display "$each" --config ~/.config/stalonetray/stalonetrayrc
# done
