#!/bin/bash
utilsDoNotReimport=1
. ~/NumBox/utils/utils.sh
import dialog.sh
import github_api.sh
import file_list.sh
import numbox.cfg
import gh_site.cfg
Dmenu_select=(1 "Github文件下载加速" 2 "管理/导入本地插件" 3 "插件商店" 4 "检查更新")
Dmenu "插件" "加速站点: "
case $DMENU in
  "") go_to ;;
  1) Dmenu_select=(
    "Github" "https://github.com"
    ""   
  )