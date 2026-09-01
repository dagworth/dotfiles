#!/bin/bash
while true; do
    curl -s 'wttr.in/?format=%C|%t' | tr -d '+'
    echo
    sleep 300
done
