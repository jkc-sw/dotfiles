#!/usr/bin/env bash

# Set background
feh --bg-scale ~/.local/share/mydesktop/pure-black.png

# Enable compositor
pgrep compton || compton -b
