#!/usr/bin/env bash

# Set background
feh --bg-scale ~/.local/share/mydesktop/pure-black.png

# Enable compositor
if lspci | grep -q -i 'vga.*controller.*intel'; then
    pgrep compton || compton -b
fi
