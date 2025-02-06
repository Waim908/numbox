#!/bin/bash
clear
read L W H < ~/NumBox/custom-size
read -n1 -p "输入1返回主菜单，输入其他字符继续" INPUT_NAME
if [[ $INPUT_NAME == 1 ]]; then
  bash ~/Numbox
else
  echo "容器配置目录下的文件夹(/sdcard/NumBox/container)"
  ls -1a /sdcard/NumBox/container
  echo -e "\n"
  echo "如果为空，请创建容器"
  read -p "输入需要设置的容器名：" CONTAINER_NAME
  if [ -z "$CONTAINER_NAME" ]; then
    dialog --title "错误" --msgbox "文件名不能为空！" $L $W 2>&1 >/dev/tty && bash ~/NumBox/Set-container.sh
   else
    if [ -z "$(ls /sdcard/NumBox/container/$CONTAINER_NAME && ls ~/NumBox/container/$CONTAINER_NAME)" ]; then
        dialog --title "错误" --msgbox "$CONTAINER_NAME不存在！重新输入" $L $W && bash ~/NumBox/Set-container.sh
      else
        echo "$CONTAINER_NAME" > $TMPDIR/container_name.txt
        bash ~/NumBox/Set-container2.sh
    fi
    fi      
fi
