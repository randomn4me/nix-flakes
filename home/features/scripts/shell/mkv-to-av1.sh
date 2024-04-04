#!/bin/bash

usager() {
    echo "Usage: $(basename $0) <file>"
}

file="$1"

if [ ! -f "$file" ]; then
    usage
fi

if [ ! -d av1 ]; then
    mkdir av1
fi

extension="${file##*.}"
filename="${file%.*}"

nice -n 19 ffmpeg -i "$file" -c:v libsvtav1 -preset 6 -crf 31 av1/$filename-av1.$extension
