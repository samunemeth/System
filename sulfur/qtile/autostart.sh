#!/bin/sh

# Get passed variables.
BG_COLOR="$1"
XC="$2"
YC="$3"

# Set the background color depending on the variable passed.
hsetroot -solid "$BG_COLOR" &

# Move the cursor to the middle of the screen.
warpd --move "$XC $YC"
