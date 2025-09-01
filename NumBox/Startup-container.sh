#!/bin/bash
. ~/NumBox/utils/dialog.conf
if [[ ! -z $1 ]]; then
    export CONTAINER_NAME=$1
    if [[ ! -d ~/NumBox/data/container/${CONTAINER_NAME} ]]; then
      echo -e "容器 \e[33m ${CONTAINER_NAME} \e[0m 不存在"
      exit 1
    fi
else
    exit_exec () { . ~/NumBox/Numbox;}
    . ~/NumBox/utils/file_list.sh
    file_list "$HOME/NumBox/data/container/" "选择一个容器"
    if [[ -z $BACK_NAME ]]; then
      . ~/NumBox/Numbox
    else
      export CONTAINER_NAME="${BACK_NAME}"
    fi
fi
eventName=()
. ~/NumBox/data/config/debug.cfg
parallel ::: "tmux kill-session -t _Ctr &" "rm -rf $PREFIX/glibc/wine" "rm -rf ~/.config/pulse/* &" "rm -rf $TMPDIR/pulse-* &" "rm -rf $TMPDIR/wine-* &" "pkill -f com.termux.x11 &" "pulseaudio -k &" "ln -sf /data/data/com.termux/files/home/NumBox/opt /data/data/com.termux/files/opt"
# 补丁适配 #1
ln -sf /data/data/container/"${CONTAINER_NAME}"/wine $PREFIX/glibc/wine
# "echo \"$runCmdPre\" > $HOME/NumBox/data/container/"${CONTAINER_NAME}"/disk/drive_c/.numbox_startfile"
export USER="steamuser"
. ~/NumBox/utils/boot.conf
. ~/NumBox/data/container/"${CONTAINER_NAME}"/config/box64.conf
. ~/NumBox/data/container/"${CONTAINER_NAME}"/config/default.conf
. ~/NumBox/data/container/"${CONTAINER_NAME}"/config/ctr.conf
if [[ $WINEESYNC == 1 ]]; then
  #补丁适配 #2
  eventName+=("esync启用")
  export WINEESYNC_TERMUX=1
else
  unset $WINEESYNC_TERMUX
fi
if [[ $WINEFSYNC == 1 ]]; then
  eventName+=("fsync启用")
fi
# 提高
if [[ $ulimitEnabled == true ]]; then
  eventName+=("ulimit上限提高")
  limit_num="$(ulimit -Hn)"
  ulimit -s $limit_num
  ulimit -c unlimited
fi
. ~/NumBox/utils/openx11.sh
if [[ $midiSupport == true ]]; then
  # need soundfonts *.sf2  file path
  eventName+=("midi音频支持")
  pkill -f -9 fluidsynth
  # pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 &>/dev/null &
  fluidsynth -i -a pulseaudio -m alsa_seq ~/midi/SONY_SPC700_SNES.sf2 &>/dev/null &
  pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 &>/dev/null &
else
  pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 &>/dev/null &
fi
termux-x11 :0 &
export PIPEWIRE_LATENCY=128/48000
export PULSE_SERVER=127.0.0.1
export GST_PLUGIN_PATH=/data/data/com.termux/files/usr/glibc/lib/gstreamer-1.0
case $getScreenRes in
  txp) get_res Pscreen ;;
  xrandr) get_res Xscreen ;;
  set-txp) set_res "${screenRes}" 
  get_res Pscreen ;;
  *) echo "未定义分辨率类型！"
  exit 1 ;;
esac
eventName+=("分辨率设置为$screenRes")
# temp_alias=$(echo "${CONTAINER_NAME}" | sed 's/ /_/g')
tmux new -d -s _Ctr
case $writeLog in
  true) tmux send -t _Ctr "taskset -c $tasksetUseCore nice -n $niceNum box64 wine explorer /desktop=shell,$screenRes explorer | tee /sdcard/NumBox/log/\"${CONTAINER_NAME}\".log && exit" Enter ;;
  *) tmux send -t _Ctr "taskset -c $tasksetUseCore nice -n $niceNum box64 wine explorer /desktop=shell,$screenRes explorer && exit" Enter ;;
esac
startup_menu () {
startup_select=$(dialog --no-cancel --title "$CONTAINER_NAME 的菜单" --menu "" 0 -1 0 \
  1 "工具箱" \
  2 "关闭容器" \
  3 "重启容器" 2>&1 >/dev/tty)
case $startup_select in
  1) tools_menu () { 
  tools_select=$(dialog --title "$CONTAINER_NAME" --menu "工具箱" 0 -1 0 \
    1 "控制台(Ctrl+b，然后按下D返回)" \
    2 "wine任务管理器" \
    3 "关闭wine任务管理器" \
    4 "cmd命令行" \
    5 "glibc终端" \
    6 "htop任务管理器" 2>&1 >/dev/tty)
  case $tools_select in
    "") startup_menu ;;
    1) tmux attach -t _Ctr
    tools_menu ;;
    2) box64 wine explorer /desktop=shell,$screenRes taskmgr >/dev/null 2>&1 &
    tools_menu ;;
    3) box64 wine cmd /c "taskkill /f /im taskmgr.exe" >/dev/null 2>&1 &
    tools_menu ;;
    4) box64 wine cmd && tools_menu ;;
    5) echo "输入exit退出"
    $PREFIX/glibc/bin/bash && startup_menu ;;
    6) htop && startup_menu ;;
  esac
  }
  tools_menu ;;
  2) parallel ::: "pulseaudio -k" "box64 wineserver -k && echo wineserver已停止 || pkill -f -9 wine" 
  pkill -f com.termux.x11 ; stopserver
  tmux kill-session -t _Ctr ;;
  3) box64 wineserver -k && echo wineserver已停止 || pkill -f -9 wine
  tmux send -t _Ctr "taskset -c $tasksetUseCore nice -n $niceNum box64 wine explorer /desktop=shell,$screenRes explorer" Enter ;;
esac
}
startup_menu