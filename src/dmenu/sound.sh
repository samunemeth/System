#!/usr/bin/env bash
LANG="en_US.utf8"

IFS=$'\n'

selection="$(
    pactl list sinks |
    grep -i "description:" |
    cut -d: -f2 |
    xargs -I{} echo "{}" |
    sort |
    dmenu
)"

[ -z "$selection" ] && exit 0

desc="$selection"
device=$(pactl list sinks | grep -C2 -F "Description: $desc" | grep "Name" | cut -d: -f2 | xargs)

if pactl set-default-sink "$device"; then
    notify-send -t 5000 -r 2 -u low "Activated: $desc"
    exit 0
else
    notify-send -t 5000 -r 2 -u critical "Error activating $desc"
    exit 1
fi
