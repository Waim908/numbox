#!/bin/bash
read L W H < ~/NumBox/custom-size
CONTAINER_NAME=$(cat $TMPDIR/container_name.txt)
DRIVE=$(cat /sdcard/NumBox/container/$CONTAINER_NAME/drive)
DRIVE_SELECT=$(dialog --no-shadow --backtitle "$CONTAINER_NAME" --title "图形驱动菜单" --menu "Adreno选择骁龙，其他可选virgl，mali可选panfrost或者virgl" $L $W $H \
  0 "🔙返回" \
  当前驱动 "$DRIVE" \
  1 "Turnip" \
  2 "VirGL" \
  PS "详细设置请前往主菜单" 2>&1 >/dev/tty)
case $DRIVE_SELECT in
  当前驱动) bash ~/NumBox/Drive_select.sh ;;
  1) echo "Turnip" > /sdcard/NumBox/container/$CONTAINER_NAME/drive && bash ~/NumBox/Drive-select.sh ;;
  2) echo "VirGL" > /sdcard/NumBox/container/$CONTAINER_NAME/drive && bash ~/NumBox/Drive-select.sh ;;
  0) bash ~/NumBox/Container-setting.sh ;;
  PS) bash ~/NumBox/Numbox ;;
esac