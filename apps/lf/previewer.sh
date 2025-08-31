#!/bin/sh

case "$1" in
    *.pdf) pdftotext -l 5 "$1" -;;
    *) highlight -O ansi "$1";;
esac
