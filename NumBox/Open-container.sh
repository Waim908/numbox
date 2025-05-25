#!/bin/bash
source ~/NumBox/utils/file_list.sh ~/NumBox/container/ 容器 选择一个容器打开 "~/NumBox/container/"
if [[ $lsterr == 2 ]]; then
  dialog --title "错误" --msgbox "容器不存在！请创建容器" $L $W && bash ~/NumBox/Numbox
elif [[ $lsterr == 1 ]]; then
  bash ~/NumBox/Numbox
else
  export CONTAINER_NAME=$BACK_NAME
  bash ~/NumBox/startup-container.sh
fi