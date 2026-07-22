#!/bin/bash
PIPE="/tmp/qs-notif.pipe"
[ -p "$PIPE" ] || mkfifo "$PIPE"
[ "$1" = "discord" ] && echo "$2\x1f$3" > "$PIPE"