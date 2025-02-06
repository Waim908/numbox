#!/bin/bash
clear
read L W H < ~/NumBox/custom-size
VAR_BOOT () {
  export CONTAINER_NAME
  screen="$(cat /sdcard/NumBox/container/$CONTAINER_NAME/screen_res)"
  export screen
#  export Exec="wine explorer /desktop=shell,$screen Wine_Activity.exe wfm.exe"
}
RUN_CMD_1 () {
  VAR_BOOT
  clear
  bash ~/NumBox/startup-container.sh
}
RUN_CMD () {
  if [[ -z $CONTAINER_NAME ]]; then
    dialog --title "错误" --msgbox "未创建容器" $L $W && bash ~/NumBox/Numbox 
  else
    RUN_CMD_1
  fi
}
BACK_CMD () {
  bash ~/NumBox/Open-container.sh
}
DIR_PATH=~/NumBox/container/
directories=$(cd $DIR_PATH && find "." -maxdepth 1 -type d ! -name "." | sort)
dir_count=$(echo "$directories" | wc -l)
echo "路径$DIR_PATH"
echo "请选择一个容器:"
for ((i=1; i<=$dir_count; i++)); do
    entry=$(echo "$directories" | sed -n "${i}p")
    echo "$i: $entry"
done
read -p "输入序号，Ctrl+c退出: " choice
if [[ $choice =~ ^[1-$dir_count]$ ]]; then
    export CONTAINER_NAME="$(echo "$directories" | sed -n "${choice}p" | sed 's/^\.\///')"
    RUN_CMD
else
    echo "无效的序号，请输入1到$dir_count之间的数字。"
    BACK_CMD
fi