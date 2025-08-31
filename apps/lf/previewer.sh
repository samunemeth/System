#!/bin/sh

case "$1" in
    *.pdf) pdftotext -l 5 "$1" -;;
    *.png | *.jpg | *.jpeg | *.webp) printf "\033[30;47;1mImage";;
    *.mp4 | *.mkv) printf "\033[30;47;1mVideo";;
    *.mp3 | *.wav) printf "\033[30;47;1mImage";;
    *) highlight -O ansi "$1";;
esac
