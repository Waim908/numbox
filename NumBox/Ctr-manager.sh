#!/bin/bash
. ~/NumBox/utils/dialog.conf
CUSTOM_FILE_LIST_OPTIONS=("C" "\Z2创建容器\Zn" "I" "\Z2导入容器\Zn" "T" "\Z3启动一个临时的沙盒容器\Zn")
exit_exec () { . ~/NumBox/Numbox;}
. ~/NumBox/utils/file_list.sh
file_list "$HOME/NumBox/data/container" "容器管理器"
case $BACK_NUM 
C) . ~/NumBox/Create-container.sh ;;
I) . ~/NumBox/Import-container.sh ;;
T) . ~/NumBox/Sandbox-container,sh ;;
  export CONTAINER_NAME=${BACK_NUM}
  ctr_select=$(dialog ${dialog_arg[@]} --title "$CONTAINER_NAME" --menu "管理当前容器" $box_sz \
    1 "打开容器" \
    2 "设置默认启动容器" \
    3 "生成游戏启动脚本" \
    4 "设置分辨率" \ 
    5 "游戏控制器API" \ 
    6 "变量设置" \
    7 "box64设置" 2>&1 >/dev/tty)
  case $ctr_select in
    1) . ~/NumBox/Startup-container.sh ;;
    2) echo "$CONTAINER_NAME" > ~/NumBox/default_ctr
    Dmsgbox "$CONTAINER_NAME" "现在是默认启动容器"
    

esac