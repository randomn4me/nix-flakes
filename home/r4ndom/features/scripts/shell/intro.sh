#!/usr/bin/env bash

out() {
    printf "%53s\n" "$1"
}

test -f $HOME/var/misc/r4ndom && cat $HOME/var/misc/r4ndom
out
out "Hi $USER"
out "----"
out "$(task minimal | tail -n1)"
