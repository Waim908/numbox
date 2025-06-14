#!/bin/bash
load() {
    local frames=("⣾" "⣽" "⣻" "⢿" "⡿" "⣟" "⣯" "⣷")
    local i=0
    local pid
    local load_tip="@"
    if [[ "$load_strict" == "1" ]]; then
        eval "$1" &
        pid=$!
    else
        eval "$1" &
        pid=$!
    fi
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r%s %s" "${frames[$((i % 8))]}" "$2"
        sleep 0.1
        ((i++))
    done
    wait "$pid"
    local status=$?
    if [[ "$load_strict" == "1" ]]; then
        if [[ $status -eq 0 ]]; then
            load_tip="\e[32m✔\e[37m"
            return_code=$status
        else
            load_tip="\e[31m✘\e[37m=>返回值:\e[33m$status\e[37m;执行失败:"
            return_code=$status
        fi
    fi
    echo -e "\r\033[K${load_tip} $2"
    return $return_code
}