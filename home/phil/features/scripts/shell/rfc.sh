#!/usr/bin/env bash

usage() {
	printf "%s\n" "Usage: $(basename $0) <rfcnum>"
}

test $# -ne 1 && usage && exit 1

curl -s https://www.rfc-editor.org/rfc/rfc$1.txt | less
