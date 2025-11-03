#!/bin/bash

case "$1" in

  *.pdf)
    printf "\033[30;47;1mPDF\033[0m "
    data=$(exiftool "$1")
    author=$(echo "$data" | rg 'Author\s*:\s(\w.*)$' -r '$1' -o --color=never)
    title=$(echo "$data" | rg 'Title\s*:\s(\w.*)$' -r '$1' -o --color=never)
    if [[ -n "$author" && -n "$title" ]]; then
      printf "\033[39;49;3;4m$author: \033[0m\033[39;49;4;1m$title\033[0m\n\n"
    elif [[ -n "$author" ]]; then
      printf "\033[39;49;3;4m$author\033[0m\n\n"
    elif [[ -n "$title" ]]; then
      printf "\033[39;49;4;1m$title\033[0m\n\n"
    else
      printf "\n\n"
    fi
    pdftotext -l 5 "$1" -;;

  *.png | *.jpg | *.jpeg | *.webp)
    printf "\033[30;47;1mIMAGE\033[0m";;

  *.mp4 | *.mkv)
    printf "\033[30;47;1mVIDEO\033[0m";;

  *.zip)
    printf "\033[30;47;1mZIP\033[0m \033[39;49;3;4mOpen to Extract\033[0m\n\n"
    unzip -l "$1" | tail -n +2;;

  *.tar*)
    printf "\033[30;47;1mTAR\033[0m";;

  *.mp3 | *.wav)
    printf "\033[30;47;1mAUDIO\033[0m\n\n"
    exiftool "$1" | rg '^(Audio Bitrate|Sample Rate|Channel Mode|Artist|Album|Title|Year|Comment|Genre|Duration)\s*:\s(\w.*)$' --color=never;;

  *) highlight -O ansi "$1";;

esac
