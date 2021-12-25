#!/usr/bin/env bash

# Use compositor with proper tear free option
if lspci | grep -q -i 'vga.*controller.*intel'; then
    pkill compton ; compton --backend glx --paint-on-overlay --vsync opengl-swc -b
fi

# Start the xscreensaver if not started
pgrep xscreensaver || xscreensaver -no-splash &

# # Session manager
# pgrep lxsession || lxsession &

# Network
pgrep nm-applet || nm-applet &

# Show the volume
pgrep volumeicon || volumeicon &

# Show the bluetooth icon
pgrep blueman-applet || blueman-applet &
