#!/usr/bin/env bash
LANG="en_US.utf8"

if ! codes="$(ykman oath accounts code)"; then
    notify-send -t 5000 "No YubiKey Inserted!" "Please plug in your security key to access TOTP codes."
    exit 1
fi

# NOTE: There is a small limitation here. The name of the TOTP code must have
# > a colon in it, and the part before it is considered as the short name.
# > Therefore a code named "Work:your.mail@example.com" just becomes "Work".
# > Not having this colon breaks the script.
selection="$(
    printf '%s\n' "$codes" |
    while IFS= read -r line; do
        name=${line%%:*}
        code=${line##* }
        printf '%s - %s\n' "$name" "$code"
    done |
    dmenu
)"

[ -z "$selection" ] && exit 0

name=${selection% -*}
code=${selection#*- }

setsid bash -c "printf %s '$code' | xclip -selection clipboard" &>/dev/null &
notify-send -t 10000 -u low "Copied the TOTP for $name to the clipboard." "The code is: $code"

exit 0
