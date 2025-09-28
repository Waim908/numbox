#!/bin/bash
. ~/NumBox/utils/dialog.sh
. ~/NumBox/utils/empty.sh
. ~/NumBox/utils/echo.sh

if ! mkdir -p /sdcard/NumBox; then
  info "内部存储未授权"
  termux-setup-storage
fi

create_dir sd
create_dir data

configFile=(
  "~/NumBox/default/config/numbox.cfg"
  "~/NumBox/default/config/gh_site.cfg"
)

checkFile=(
  "~/NumBox/data/config/numbox.cfg"
  "~/NumBox/data/config/gh_site.cfg"
)

copy_config

nb_ver=$(cat ~/NumBox/.version)

Dmenu_select=(1 "启动默认容器" 2 "启动快捷脚本" 3 "wine容器管理" 4 "NumBox插件" 5 "NumBox设置" 6 "关于NumBox" 7 "插件菜单")
Dmenu "NumBox主菜单" "触屏，键盘，鼠标以进行对话框操作" "${nb_ver}"
case $DMENU in
  1) ;;
  2) ;;
  3) ;;
  4) Dmenu_select=($(ls ~/NumBox/plugins))
