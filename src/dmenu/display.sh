#!/usr/bin/env bash
LANG="en_US.utf8"

xrandr_out="$(xrandr --query)"

internal="$(
    printf "%s\n" "$xrandr_out" |
    awk '/ connected/ && $1 ~ /^(eDP|LVDS)/ { print $1; exit }'
)"

external="$(
    printf "%s\n" "$xrandr_out" |
    awk -v INT="$internal" '/ connected/ && $1 != INT { print $1; exit }'
)"

[ -z "$internal" ] && exit 1

if [ -z "${external:-}" ]; then
    notify-send -t 5000 -u low "No external display connected."
    xrandr --output "$internal" --auto --primary
    exit 0
fi

choices=$'extend\nclone\ninternal\nexternal'
selection="$(echo "$choices" | dmenu -i)"

[ -z "$selection" ] && exit 0

case "$selection" in
    internal)
        xrandr \
            --output "$internal" --auto --primary \
            --output "$external" --off &&
        notify-send -t 5000 -u low "Display: internal" &&
        exit 0
        ;;
    extend)
        xrandr \
            --output "$internal" --auto --primary \
            --output "$external" --auto \
            --right-of "$internal" &&
        notify-send -t 5000 -u low "Display: extend ($external)" &&
        exit 0
        ;;
    clone)
        xrandr \
            --output "$internal" --auto \
            --output "$external" --auto \
            --same-as "$internal" &&
        notify-send -t 5000 -u low "Display: clone" &&
        exit 0
        ;;
    external)
        xrandr \
            --output "$internal" --off \
            --output "$external" --auto --primary &&
        notify-send -t 5000 -u low "Display: external ($external)" &&
        exit 0
        ;;
esac

notify-send -t 5000 -u critical "Error applying display configuration."
exit 1
