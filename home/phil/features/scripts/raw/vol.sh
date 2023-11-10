#!/usr/bin/env bash

shopt -s extglob

usage() {
    echo "usage : $(basename $0) [t-+]"
}

level() {
	LEVEL=$(pamixer --get-volume-human | tr -d '%')
	if [ $LEVEL = "muted" ]; then
        echo 'M'
    else
        echo $LEVEL
    fi
}

which pamixer > /dev/null 2>&1 \
    || ( echo "amixer not installed" && exit 1 )

test "$#" -eq 0 && echo "$(level)" && exit 0

case "$1" in
    t)              pamixer --toggle-mute > /dev/null ;;
    +)              pamixer --increase 5 > /dev/null ;;
    -)              pamixer --decrease 5 > /dev/null ;;
    +([[:digit:]])) pamixer --set-volume $1 ;;
    *)              usage ;;
esac
