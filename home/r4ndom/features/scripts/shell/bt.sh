#!/usr/bin/env bash

unknown() {
	echo "Unknown device. Only [b]ose, [f]airphone, [r]evolve allowed."
	exit 1
}

usage() {
	echo "Usage: $(basename $0) [h] <b|f|r> <c|d|0|1>"
	exit 1
}

connected() {
	bluetoothctl devices | cut -f2 -d' '|
		while read -r uuid
		do
    	info=`bluetoothctl info $uuid`
    	if echo "$info" | grep -q "Connected: yes"; then
       	echo "$info" | grep "Name"
    	fi
		done | cut -d':' -f2 | cut -d' ' -f2-
}

if [ $# -lt 2 ]; then
	case $1 in
		h) usage ;;
		0) bluetoothctl power off; exit 1 ;;
		1) bluetoothctl power on; exit 1 ;;
		*) connected; exit 1 ;;
	esac
fi

case $1 in
	b) DEVICEID=2C:41:A1:09:48:75 ;;
	f) DEVICEID=00:00:AB:BD:B2:6B ;;
	r) DEVICEID=04:52:C7:FB:3A:3F ;;
	*) unknown ;;
esac

case $2 in
	c|1) bluetoothctl connect $DEVICEID ;;
	d|0) bluetoothctl disconnect $DEVICEID ;;
	*) usage ;;
esac
