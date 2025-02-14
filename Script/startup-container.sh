#!/bin/bash
termux-wake-lock ; stopserver
rm -rf ~/.config/pulse
# pkill -f com.termux.x11
pkill -f virgl 
pulseaudio -k 2>&1 >/dev/null
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 &>/dev/null &
termux-x11 :0 &
# source ~/NumBox/container/$CONTAINER_NAME/device 2>&1 >/dev/null
source ~/NumBox/boot.conf
source /sdcard/NumBox/debug.conf 
source /sdcard/NumBox/container/$CONTAINER_NAME/box64.conf
source /sdcard/NumBox/container/$CONTAINER_NAME/cpu_core.conf 
export PIPEWIRE_LATENCY=128/48000
export PULSE_SERVER=127.0.0.1
export BOX64_MAXCPU=$CPU_CORE
export Exec="nice -n -99 box64 wine explorer /desktop=shell,$screen Wine_Activity.exe"
export drive_type=$(cat /sdcard/NumBox/container/$CONTAINER_NAME/drive)
service_statu=$(cat /sdcard/NumBox/container/$CONTAINER_NAME/service)
virgl_so=$(cat ~/NumBox/virgl_so)
source /sdcard/NumBox/container/$CONTAINER_NAME/default.conf
# source /sdcard/NumBox/container/$CONTAINER_NAME/*.conf
# for conf_file in /sdcard/NumBox/container/$CONTAINER_NAME/*.conf; do
#     if [[ -f "$conf_file" ]]; then
#         source "$conf_file"
#     fi
# done
if [[ $drive_type == Turnip ]]; then
    source ~/NumBox/drive/vulkan.conf
    cd /data/data/com.termux/files/home/NumBox/resource/drive/replace/ && tar cf - . | (cd /data/data/com.termux/files/usr/glibc/ && tar xvf -)
elif [[ $drive_type == VirGL ]]; then
    source ~/NumBox/drive/virgl.conf
    if [[ $virgl_so == glibc-zink ]]; then
        cp_so="cd /data/data/com.termux/files/home/NumBox/resource/drive/zink/ ; tar cf - . | (cd /data/data/com.termux/files/usr/glibc/lib/ ; tar xvf -)"
    elif [[ $virgl_so == winlator-virgl ]]; then
        cp_so="cd /data/data/com.termux/files/home/NumBox/resource/drive/virgl/ ; tar cf - . | (cd /data/data/com.termux/files/usr/glibc/lib/ ; tar xvf -)"
    else
        echo "未指定virgl动态链接库类型"
        exit 1
    fi
    if [[ $virgl_server_type == virgl ]]; then
        eval $cp_so
        virgl_test_server --use-egl-surfaceless --use-gles &
    elif [[ $virgl_server_type == android ]]; then
        eval $cp_so
        virgl_test_server_android &
    else
        echo "未指定或错误的virgl服务器类型"
        exit 1
    fi
else
    echo "未指定或错误的驱动类型"
    exit 1
fi
cd ~
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
kill_services () {
if [[ $service_statu == 3 ]]; then
    box64 wine cmd /c "taskkill /f /im services.exe" &>/dev/null
fi
}
kill_services &
# am start -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1
bash ~/NumBox/startup-menu.sh