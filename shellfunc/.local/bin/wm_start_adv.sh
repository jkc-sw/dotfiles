#!/usr/bin/env bash

# Use compositor with proper tear free option
pkill compton ; compton --backend glx --paint-on-overlay --vsync opengl-swc -b

# Start the xscreensaver if not started
pgrep xscreensaver || xscreensaver -no-splash &

# # Session manager
# pgrep lxsession || lxsession &

# Network
pgrep nm-applet || nm-applet &

# Show the volume
pgrep volumeicon || volumeicon &
