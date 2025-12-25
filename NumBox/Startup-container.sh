#!/bin/bash
utilsDoNotReimport=1
. ~/NumBox/utils/utils.sh
import dialog.sh
import file_list.sh
import select_ctr.sh
import last_jump.sh
import openx11.sh
import startup_wine.sh
import echo.sh
unset_utils_var
main() {
  . ~/NumBox/data/config/debug.cfg
  parallel ::: "tmux kill-session -t _Ctr" "rm -rf $PREFIX/glibc/wine" "rm -rf ~/.config/pulse/* &" "rm -rf $TMPDIR/pulse-* &" "rm -rf $TMPDIR/wine-* &" "pkill -f com.termux.x11 &" "pulseaudio -k &" "ln -sf /data/data/com.termux/files/home/NumBox/opt /data/data/com.termux/files/opt" "tmux source-file ~/NumBox/.tmux.conf"
  # 补丁适配 #1
  ln -sf /data/data/container/"${CONTAINER_NAME}"/wine $PREFIX/glibc/wine
  # "echo \"$runCmdPre\" > $HOME/NumBox/data/container/"${CONTAINER_NAME}"/disk/drive_c/.numbox_startfile"
  export USER="steamuser"
  . ~/NumBox/utils/boot.sh
  . ~/NumBox/data/container/"${CONTAINER_NAME}"/config/box64.conf
  . ~/NumBox/data/container/"${CONTAINER_NAME}"/config/default.conf
  . ~/NumBox/data/container/"${CONTAINER_NAME}"/config/ctr.conf
  if [[ $WINEESYNC == 1 ]]; then
    #补丁适配 #2
    export WINEESYNC_TERMUX=1
  else
    unset $WINEESYNC_TERMUX
  fi
  # 提高，无需root
  if [[ $ulimitEnabled == true ]]; then
    limit_num="$(ulimit -Hn)"
    ulimit -s $limit_num
    ulimit -c unlimited
  fi

  # if [[ $midiSupport == true ]]; then
  #   # 此功能无效，测试用
  #   # need soundfonts *.sf2  file path
  #   pkill -f -9 fluidsynth
  #   # pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 &>/dev/null &
  #   fluidsynth -i -a pulseaudio -m alsa_seq ~/midi/SONY_SPC700_SNES.sf2 &>/dev/null &
  #   pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 &>/dev/null &
  # else
  #   pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 &>/dev/null &
  # fi

  termux-x11 :0 &
  export PIPEWIRE_LATENCY=128/48000
  export PULSE_SERVER=127.0.0.1
  export GST_PLUGIN_PATH=/data/data/com.termux/files/usr/glibc/lib/gstreamer-1.0:/sdcard/NumBox/
  export defaultScreenRes="$screenRes"

  case $getScreenRes in
  txp) get_res Pscreen ;;
  xrandr)
    get_res Xscreen
    ;;
  set-txp)
    set_res "${screenRes}"
    get_res Pscreen
    ;;
  *) export screenRes="$defaultScreenRes" ;;
  esac

  if [[ ! -z "$screenRes" ]]; then
    export screenRes="$defaultScreenRes"
  fi
  # temp_alias=$(echo "${CONTAINER_NAME}" | sed 's/ /_/g')
  tmux new -d -s _Ctr

  startup_menu() {
    startup_select=$(dialog --no-cancel --title "$CONTAINER_NAME 的菜单" --menu "" 0 -1 0 \
      1 "工具箱" \
      2 "关闭容器" \
      3 "重启容器" 2>&1 >/dev/tty)
    case $startup_select in
    1)
      tools_menu() {
        tools_select=$(dialog --title "$CONTAINER_NAME" --menu "工具箱" 0 -1 0 \
          1 "控制台(Ctrl+b，然后按下D返回)" \
          2 "wine任务管理器" \
          3 "关闭wine任务管理器" \
          4 "cmd命令行" \
          5 "glibc终端" \
          6 "htop任务管理器" 2>&1 >/dev/tty)
        case $tools_select in
        "") startup_menu ;;
        1)
          tmux attach -t _Ctr
          tools_menu
          ;;
        2)
          box64 wine explorer /desktop=shell,$screenRes taskmgr >/dev/null 2>&1 &
          tools_menu
          ;;
        3)
          box64 wine cmd /c "taskkill /f /im taskmgr.exe" >/dev/null 2>&1 &
          tools_menu
          ;;
        4) box64 wine cmd && tools_menu ;;
        5)
          clear
          echo "输入exit退出"
          $PREFIX/glibc/bin/bash && startup_menu
          ;;
        6) htop && startup_menu ;;
        esac
      }
      tools_menu
      ;;
    2)
      parallel ::: "pulseaudio -k" "box64 wineserver -k && echo wineserver已停止 || pkill -f -9 wine"
      stopx11
      tmux kill-session -t _Ctr
      ;;
    3)
      box64 wineserver -k && echo wineserver已停止 || pkill -f -9 wine
      exec_box64_wine
      ;;
    esac
  }
  if tmux send -t _Ctr "bash ~/NumBox/startup_wine.sh"
    startup_menu
}
main
