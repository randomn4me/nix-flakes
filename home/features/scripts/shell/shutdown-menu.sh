#!/usr/bin/env bash

res=$(printf "logout\nreboot\nsuspend\nshutdown" | $RUNNER)

case "$res" in
    "logout")   loginctl terminate-user "$USER" ;;
    "reboot")   systemctl reboot ;;
    "suspend")  systemctl suspend ;;
    "shutdown") systemctl poweroff ;;
esac

exit 0
