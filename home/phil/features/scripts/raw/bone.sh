#!/usr/bin/env bash

BONE_FILE=$HOME/.bone

bone_on() {
  notify bone on
  setxkbmap -layout de -variant bone
  touch $BONE_FILE
  open ~/usr/pics/misc/wallpapers/bone-aufsteller.jpg
}

bone_off() {
  notify bone off
  setxkbmap de
  rm -f $BONE_FILE
}

case $1 in
  0) test -f $BONE_FILE && bone_off ;;
  1) test -f $BONE_FILE || bone_on ;;
  t*) if [ -f $BONE_FILE ]; then bone_off; else bone_on; fi ;;
  rm) rm -f $BONE_FILE ;;
  *) test -f $BONE_FILE && echo 1 || echo 0 ;;
esac

