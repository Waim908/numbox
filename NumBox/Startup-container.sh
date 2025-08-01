#!/bin/bash
. ~/NumBox/utils/dialog.conf
if [[ ! -v CONTAINER_NAME ]]; then
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
      export CONTAINER_NAME=${BACK_NAME}
    fi
  fi
fi
parallel ::: "pkill -f com.termux.x11" "pulseaudio -k" "termux-x11 :0 &" "ln -sf /data/data/com.termux/files/home/NumBox/opt /data/data/com.termux/files/opt"
# "echo \"$runCmdPre\" > $HOME/NumBox/data/container/"${CONTAINER_NAME}"/disk/drive_c/.numbox_startfile"
. ~/NumBox/data/container/"${CONTAINER_NAME}"/config/box64.conf
. ~/NumBox/data/container/"${CONTAINER_NAME}"/config/default.conf
. ~/NumBox/data/container/"${CONTAINER_NAME}"/config/ctr.conf
. ~/NumBox/utils/boot.conf
if [[ $WINEESYNC == 1 ]]; then
  export WINEESYNC_TERMUX=1
else
  unset $WINEESYNC_TERMUX
fi
. ~/NumBox/utils/openx11.sh
startx11 0
if [[ $getScreenRes == auto ]]; then
  get_res Pscreen
fi
temp_alias=$(echo "${CONTAINER_NAME}" | sed 's/ /_/g')
tmux new -d -s Ctr-$temp_alias
tmux send -t Ctr-$temp_alias "taskset -c $tasksetUseCore nice -n $niceNum box64 wine explorer /desktop=shell,$screenRes explorer" Enter
startup_menu () {
startup_select=$(dialog --title "$CONTAINER_NAME" --menu "菜单" 0 -1 0 \
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
    1) tmux attach -t Ctr-$temp_alias
    tools_menu ;;
    2) box64 wine explorer /desktop=shell,$screenRes taskmgr >/dev/null 2>&1 &
    tools_menu ;;
    3) box64 wine cmd /c "taskkill /f /im taskmgr.exe" >/dev/null 2>&1 &
    tools_menu ;;
    4) box64 wine cmd && tools_menu ;;
    5) echo "输入exit退出"
    . $PREFIX/glibc/bash && startup_menu ;;
    6) htop && startup_menu ;;
  esac
  }
  tools_menu ;;
  2) parallel ::: "pulseaudio -k" "box64 wineserver -k && echo wineserver已停止 || pkill -f -9 wine && echo wine强制停止" "pkill -f com.termux.x11 ; stopserver" ;;
  3) box64 wineserver -k && echo wineserver已停止 || pkill -f -9 wine && echo wine强制停止
  tmux send -t Ctr-$temp_alias "taskset -c $tasksetUseCore nice -n $niceNum box64 wine explorer /desktop=shell,$screenRes startup" Enter ;;
esac
}
startup_menu