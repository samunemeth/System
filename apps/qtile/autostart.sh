#!/bin/sh

# Get passed variables.
BG_COLOR="$1"
XC="$2"
YC="$3"

# Set the background color depending on the variable passed.
hsetroot -solid "$BG_COLOR" &

# Move the cursor to the middle of the screen.
warpd --move "$XC $YC"

# Turn on NumLock
numlockx on

# Start xss-lock in the background.
# xss-lock -l -- xsecurelock &

# Start a locker that has a password prompt already showing.
# xsecurelock &
# for i in {1..20}; do
#   pid=$(pgrep -xu "$USER" -n xsecurelock)
#   [ -n "$pid" ] && { kill -USR2 "$pid"; break; }
#   sleep 0.05
# done
