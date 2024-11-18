#!/usr/bin/env bash

device='brother4:net1;dev0'
tmpdir="$(mktemp -d)"
tmpscan="$tmpdir/scan"
outdir="$HOME/var/scans"

usage() {
        echo "Usage: $(basename $0) [-h]"
        exit 1
}

test "$1" = "-h" && usage

mkdir -p $outdir
name_sanitized="$(echo $@ | tr [A-Z\ ] [a-z\-])"
if [ ! -z $name_sanitized ]; then
    name="_${name_sanitized}"
else
    name=""
fi

outfile="$outdir/$(date +%F_%Hh%Mm%Ss)${name}.pdf"

( scanimage -d "$device" -o "$tmpscan.png" > /dev/null && \
        magick "$tmpscan.png" "$outfile" && \
        rm -rf $tmpdir ) > /dev/null & disown
