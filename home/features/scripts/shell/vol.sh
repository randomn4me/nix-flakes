#!/usr/bin/env bash

shopt -s extglob

usage() {
    echo "usage : $(basename $0) [t-+] [int]"
}

level() {
	LEVEL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | cut -d" " -f2)
	if echo "$LEVEL" | grep -i muted; then
        echo 'M'
    else
        echo "$LEVEL" | bc
    fi
}

case "$1" in
    t)              wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle > /dev/null ;;
    +)              wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ > /dev/null ;;
    -)              wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%- > /dev/null ;;
    +([[:digit:]])) wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ "$1"%+ ;;
    *)              level ;;
esac
