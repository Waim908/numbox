#!/bin/bash
clear
# box64 wineserver -k >/dev/null 2>&1
pulseaudio -k >/dev/null 2>&1
pkill -f virgl_test_server_android
pkill -f virgl_test_server
stopserver
tmux kill-session -t 0
tmux kill-session -t 1
pkill -f -9 wine
termux-wake-unlock
echo "结束"