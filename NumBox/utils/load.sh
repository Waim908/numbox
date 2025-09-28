#!/bin/bash
load() {
    if [[ ! $loadDisplayColor == 1 ]]; then
    local colors=(
        "$(tput setaf 21)"
        "$(tput setaf 27)"
        "$(tput setaf 31)"
        "$(tput setaf 32)"
        "$(tput setaf 33)"
        "$(tput setaf 38)"
        "$(tput setaf 39)"
        "$(tput setaf 45)"
    )
        local frames=("⣾" "⣽" "⣻" "⢿" "⡿" "⣟" "⣯" "⣷")
        local reset_color=""
    else
        local frames=("$(tput setaf 39)⣾" "$(tput setaf 38)⣽" "$(tput setaf 33)⣻" "$(tput setaf 32)⢿" "$(tput setaf 31)⡿" "$(tput setaf 27)⣟" "$(tput setaf 26)⣯" "$(tput setaf 25)⣷")
        local reset_color=$(tput sgr0)
    fi
    local i=0
    local pid
    local load_tip="@"
    if [[ $loadDebugDisplay == 1 ]]; then
        eval "$1"
    else
        eval "$1" &
    fi
    pid=$!
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r%s%s %s" "${frames[$((i % 8))]}" "$reset_color" "$2"
        sleep 0.1
        ((i++))
    done
    wait "$pid"
    local status=$?
    if [[ "$loadStrict" == "1" ]]; then
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
utilsVar+=(
  "loadStrict"
  "loadDebugDisplay"
  "loadDisplayColor"
)