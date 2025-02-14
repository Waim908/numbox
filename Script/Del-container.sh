#!/bin/bash
clear
mkdir /sdcard/NumBox/container/ 2>/dev/null
mkdir ~/NumBox/container/ 2>/dev/null
read L W H < ~/NumBox/custom-size
read -n1 -p "输入1返回主菜单，输入其他字符回车继续：" INPUT_ONE
if [[ $INPUT_ONE == 1 ]]; then
  bash ~/NumBox/Numbox 
else
  echo 配置文件路径
  ls -1a /sdcard/NumBox/container
  echo 容器路径（无视.和..目录）
  ls -1a ~/NumBox/container
  read -p "输入需要删除的容器名（输入*号删除全部容器）： " CONTAINER_NAME
  if [[ -z $CONTAINER_NAME ]]; then
    dialog --title "错误" --msgbox "名称不能为空！" $L $W 2>&1 >/dev/tty && bash ~/NumBox/Del-container.sh
   else
    # check_container=$(ls /sdcard/NumBox/container/$CONTAINER_NAME)
    # check_container_2=$(ls ~/NumBox/container/$CONTAINER_NAME)
    # if [[ -z $check_container || -z check_container_2 ]]; then
    #     dialog --title "错误" --msgbox "$CONTAINER_NAME不存在！重新输入" $L $W && bash ~/NumBox/Del-container.sh
    #   else
        dialog --title "Σ(っ °Д °;)っ" --beep-after --yes-label  "删除" --yesno "真的要删除$CONTAINER_NAME？" $H $W 2>&1 >/dev/tty
         if [ $? -eq 0 ]; then
          clear 
          echo "rm -rf /sdcard/NumBox/container/$CONTAINER_NAME && rm -rf ~/NumBox/container/$CONTAINER_NAME" > $TMPDIR/cmd && bash ~/NumBox/Load && echo 删除完成 && sleep 1 
           bash ~/NumBox/Del-container.sh          
          else
            bash ~/NumBox/Del-container.sh 
          fi
    #  fi 
    fi 
fi