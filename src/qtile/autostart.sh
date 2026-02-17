#!/usr/bin/env bash

# Get passed variables.
BG_COLOR="$1"
XC="$2"
YC="$3"

# Set the background color depending on the variable passed.
hsetroot -solid "$BG_COLOR" &

# Move the cursor to the middle of the screen.
warpd --move "$XC $YC" || true

# Turn on NumLock.
numlockx on || true

# Set the volume of the selected sound sink to zero.
pulseaudio-ctl set 0.

# Configure monitors.
# For an additional display above.
# xrandr --output HDMI-1 --mode 2560x1440 --rate 120.00 --pos 0x0 --noprimary --above eDP-1
# xrandr --output eDP-1 --mode 1920x1200 --pos 320x1440 --primary

