#!/usr/bin/env bash

which pdftoppm > /dev/null 2>&1 || (echo 'pdftoppm not installed' && exit 1)

usage() {
	echo "$(basename $0): <pdffile>"
	exit 1
}

test -f "$1" || (echo "no file given" && usage)

pdftoppm -png -f 1 -l 1 "$1" first_page.png
