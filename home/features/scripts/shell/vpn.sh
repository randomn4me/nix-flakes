#!/usr/bin/env bash

start() {
	[ $UID -ne 0 ] && echo "Not run as root" > /dev/stderr && exit 1
	if [ -f "${PID}" ]; then
		printf "%s\n" "vpn is already connected" > /dev/stderr
		exit 1
	fi
	printf "%s\n" "${PASS}" | openconnect --background --pid-file="${PID}" --authgroup=campus --user="${USER}" --passwd-on-stdin --quiet vpn.hrz.tu-darmstadt.de 2> /dev/null
	printf "%s\n" "vpn up"
}

stop() {
	[ $UID -ne 0 ] && echo "Not run as root" > /dev/stderr && exit 1
	if [ ! -f "${PID}" ]; then
		printf "%s\n" "vpn not connected" > /dev/stderr
		exit 1
	fi
	kill -TERM $(cat ${PID})
	rm ${PID}
	printf "%s\n" "vpn disconnected"
}


PID="/run/uni-vpn.pid"
USER="ba01viny"
PASS="$(sudo -u phil cat /home/phil/usr/misc/$USER)"

case "$1" in
	up|start|1)
		start ;;
	down|stop|0)
		stop ;;
	h)
		printf "%s\n" "Usage: $(basename $0) <1|0|s>" > /dev/stderr
		exit 1
		;;
    *)
        [ -f ${PID} ] && echo "1" || echo "0"
        ;;
esac
exit 0

