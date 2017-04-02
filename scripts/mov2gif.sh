#!/bin/bash

ffmpeg -i "$1.mov" -s 640x360  -pix_fmt rgb24  -r 10 -f gif - | gifsicle --optimize=3 --delay=10 > "$1.gif"
