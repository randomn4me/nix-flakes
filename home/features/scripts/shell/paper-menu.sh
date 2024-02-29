#!/usr/bin/env bash

cd "$HOME/usr/docs/zotero-paper" || exit
pdffile=$(fd 'pdf$' | $RUNNER)

test -z "$pdffile" && echo "no file selected" && exit 1

xdg-open "$pdffile" &
