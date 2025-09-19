#!/bin/sh

case "$1" in
    # *.pdf) ls -l@ "$1";;
    *.pdf) printf "\033[30;47;1mpdf";;
    *.png | *.jpg | *.jpeg | *.webp) printf "\033[30;47;1mImage";;
    *.mp4 | *.mkv) printf "\033[30;47;1mVideo";;
    *.mp3 | *.wav) printf "\033[30;47;1mAudio";;
    *) cat "$1";;
esac
