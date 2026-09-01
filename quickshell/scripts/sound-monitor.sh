#!/bin/bash
pactl subscribe | grep --line-buffered 'sink' | while read -r _; do
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2 * 100}'
done
