#!/bin/bash
termux-wake-lock
# pkill -f com.termux.x11
stopserver
pkill -f virgl_test_server_android
pkill -f virgl_test_server
termux-x11 :0 &
virgl_test_server --use-egl-surfaceless --use-gles &
pulseaudio -k >/dev/null 2>&1
rm -rf ~/.config/pulse
# source ~/NumBox/container/$CONTAINER_NAME/device 2>&1 >/dev/null
source ~/NumBox/boot.conf
source /sdcard/NumBox/debug.conf
# source /sdcard/NumBox/container/$CONTAINER_NAME/*.conf
for conf_file in /sdcard/NumBox/container/$CONTAINER_NAME/*.conf; do
    if [[ -f "$conf_file" ]]; then
        source "$conf_file"
    fi
done
drive_type=$(cat /sdcard/NumBox/container/$CONTAINER_NAME/drive)
if [[ $drive_type == vulkan ]]; then
    source ~/NumBox/drive/vulkan.conf
elif [[ $drive_type == gl ]]; then
    source ~/NumBox/drive/virgl.conf
fi
export Exec="box64 wine explorer /desktop=shell,$screen Wine_Activity.exe"
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 &>/dev/null
export PIPEWIRE_LATENCY=128/48000
export PULSE_SERVER=127.0.0.1
export BOX64_MAXCPU=$CPU_CORE
# pgrep -x pulseaudio | xargs -I {} taskset -pc $USE_CORE {}
tmux new -d -s 0
if [[ $USE_CPU_CORE_CONF ==  true ]]; then
    tmux send -t 0 "echo 启用taskset核心锁定，日志记录功能已禁用 && taskset -c $USE_CORE nice -n -99 $Exec" Enter
elif [[ $USE_CPU_CORE_CONF == false ]]; then
    if [[ $write_logfile == on ]]; then
        tmux send -t 0 "script -a \"/sdcard/log/debug.log\" -c \"$Exec\"" Enter
    elif [[ $write_logfile == off ]]; then
        tmux send -t 0 "nice -n -99 $Exec /dev/null 2>&1 &" Enter
    else
        tmux send -t 0 "nice -n -99 $Exec /dev/null 2>&1 &" Enter
    fi
else
    tmux send -t 0 "nice -n -99 $Exec &>/dev/null" Enter
fi
# am start -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1
bash ~/NumBox/startup-menu.sh
