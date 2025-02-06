#!/bin/bash
clear
read L W H < ~/NumBox/custom-size
export DEFAULT_CONTAINER_NAME=$(cat ~/NumBox/default_startup_container)
if [ -z "$DEFAULT_CONTAINER_NAME" ]; then
    dialog --title "错误" --msgbox "未设置默认启动容器" $L $W 2>&1 >/dev/tty && bash ~/NumBox/Numbox
  else
    clear
    if [[ -d ~/NumBox/container/$DEFAULT_CONTAINER_NAME ]]; then
      export CONTAINER_NAME=$DEFAULT_CONTAINER_NAME
      export screen="$(cat /sdcard/NumBox/container/$CONTAINER_NAME/screen_res)"
      bash ~/NumBox/startup-container.sh
    else
      dialog --title "错误" --msgbox "默认容器 $DEFAULT_CONTAINER_NAME 不存在" $L $W 2>&1 >/dev/tty && bash ~/NumBox/Numbox
    fi
fi