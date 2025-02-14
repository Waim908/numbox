#!/bin/bash
read L W H < ~/NumBox/custom-size
CONTAINER_NAME=$(cat $TMPDIR/container_name.txt)
DISK_SET=$(dialog --title "挂载盘设置" --inputbox "输入挂载盘路径，输入1退出" $L $W $H 2>&1 >/dev/tty)
  if [ "$DISK_SET" == "1" ]; then
    bash ~/NumBox/Set-container2.sh
  else
    cd ~/NumBox/container/$CONTAINER_NAME/disk/dosdevices
    aaaa=$(ls $DISK_SET)
    if [ ! -z "$aaaa" ]; then
      clear
      echo "已知挂载盘信息"
      ls -l ~/NumBox/container/$CONTAINER_NAME/disk/dosdevices
      read -s -n1 -p "输入任意字符继续"
      DISK_PATH=$(dialog --title "盘符设置" --menu "选择一个盘符" $L $W $H \
        0 "🔙返回" \
        1 "D(默认Download)" \
        2 "E" \
        3 "F" \
        4 "G" \
        5 "I" 2>&1 >/dev/tty)
      case $DISK_PATH in
        0) bash ~/NumBox/Set-container2.sh ;;
        1) rm -rf ~/NumBox/container/$CONTAINER_NAME/disk/dosdevices/d:
        ln -s $DISK_SET d:
        bash ~/NumBox/Set-container2.sh ;;
        2) ln -s $DISK_SET e:
        bash ~/NumBox/Set-container2.sh ;;
        3) ln -s $DISK_SET f:
        bash ~/NumBox/Set-container2.sh ;;
        4) ln -s $DISK_SET g:
        bash ~/NumBox/Set-container2.sh ;;
        5) ln -s $DISK_SET i:
        bash ~/NumBox/Set-container2.sh ;;
      esac
    else
      dialog --title "Σ(っ °Д °;)っ" --msgbox "路径无效！重新设置" $L $W 2>&1 >/dev/tty && bash ~/NumBox/Disk-linkset.sh
    fi
  fi