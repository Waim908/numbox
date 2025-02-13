#!/bin/bash
termux-wake-lock ; stopserver
# pkill -f com.termux.x11
pkill -f virgl ; pulseaudio -k 2>&1 >/dev/null
termux-x11 :0 &
rm -rf ~/.config/pulse
# source ~/NumBox/container/$CONTAINER_NAME/device 2>&1 >/dev/null
source ~/NumBox/boot.conf
source /sdcard/NumBox/debug.conf 
source /sdcard/NumBox/container/$CONTAINER_NAME/box64.conf
source /sdcard/NumBox/container/$CONTAINER_NAME/cpu_core.conf 
export PIPEWIRE_LATENCY=128/48000
export PULSE_SERVER=127.0.0.1
export BOX64_MAXCPU=$CPU_CORE
export Exec="nice -n -99 box64 wine explorer /desktop=shell,$screen Wine_Activity.exe"
drive_type=$(cat /sdcard/NumBox/container/$CONTAINER_NAME/drive)
service_statu=(cat /sdcard/NumBox/container/$CONTAINER_NAME/service)
source /sdcard/NumBox/container/$CONTAINER_NAME/default.conf
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 &>/dev/null &
# source /sdcard/NumBox/container/$CONTAINER_NAME/*.conf
# for conf_file in /sdcard/NumBox/container/$CONTAINER_NAME/*.conf; do
#     if [[ -f "$conf_file" ]]; then
#         source "$conf_file"
#     fi
# done
if [[ $drive_type == Turnip ]]; then
    source ~/NumBox/drive/vulkan.conf
    cd ~/NumBox/resource/drive/replace/; tar cf - . | (cd $PREFIX/glibc/; tar xvf -)
elif [[ $drive_type == VirGL ]]; then
    source ~/NumBox/drive/virgl.conf
    if [[ $virgl_server_type == virgl ]]; then
        cd ~/NumBox/drive/virgl/; tar cf - . | (cd $PREFIX/glibc/lib/; tar xvf -)
        virgl_test_server --use-egl-surfaceless --use-gles &
    elif [[ $virgl_server_type == android ]]; then
        virgl_test_server_android &
    else
        echo "未指定或错误的virgl服务器类型"
        exit 1
    fi
else
    echo "未指定或错误的驱动类型"
    exit 1
fi
# pgrep -x pulseaudio | xargs -I {} taskset -pc $USE_CORE {}
tmux new -d -s 0
if [[ $USE_CPU_CORE_CONF ==  true ]]; then
    export Exec="taskset -c $USE_CORE $Exec"
    if [[ $write_logfile == on ]]; then
        tmux send -t 0 "script -a \"/sdcard/NumBox/log/debug.log\" -c \"$Exec\"" Enter
    elif [[ $write_logfile == off ]]; then
        tmux send -t 0 "$Exec /dev/null 2>&1 &" Enter
    else
        tmux send -t 0 "$Exec /dev/null 2>&1 &" Enter
    fi
elif [[ $USE_CPU_CORE_CONF == false ]]; then
    if [[ $write_logfile == on ]]; then
        tmux send -t 0 "script -a \"/sdcard/NumBox/log/debug.log\" -c \"$Exec\"" Enter
    elif [[ $write_logfile == off ]]; then
        tmux send -t 0 "$Exec /dev/null 2>&1 &" Enter
    else
        tmux send -t 0 "$Exec /dev/null 2>&1 &" Enter
    fi
else
    tmux send -t 0 "nice -n -99 $Exec &>/dev/null" Enter
fi
if [[ $service_statu == 3 ]]; then
    box64 wine cmd /c "taskkill /f /im service.exe" &>/dev/null
fi
# am start -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1
bash ~/NumBox/startup-menu.sh