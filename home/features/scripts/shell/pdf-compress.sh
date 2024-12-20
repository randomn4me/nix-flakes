#!/bin/sh

usage() {
    echo "Usage: $(basename $0) <file> [level]"
    echo ""
    echo "Output as <filename>_compressed.pdf"
    echo "Quality settings are (low to high): screen, ebook, printer, prepress (default), default"
}

test $# -lt 1 -o ! -f $1 && usage && exit

filename="${1%.*}"
extension="${1##*.}"

gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/${2:-prepress} -dNOPAUSE -dQUIET -dBATCH -sOutputFile="${filename}_compressed.${extension}" "$1"
