#!/bin/bash
load () {
frames=( "⣾" "⣽" "⣻" "⢿" "⡿" "⣟" "⣯" "⣷" )
eval "$1" &
pid=$!
while [ -n "$pid" ]; do
    printf "\r%s %s" "${frames[$((i % 8))]}" "$2"
    sleep 0.1
    if ! kill -0 "$pid" 2>/dev/null; then
        pid=
    fi
    ((i++))
done
echo -e "\r\033[K@ $2"
}