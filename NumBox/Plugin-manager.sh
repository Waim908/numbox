#!/bin/bash
utilsDoNotReimport=1
. ~/NumBox/utils/utils.sh
import dialog.sh
import github_api.sh
import file_list.sh
import last_jump.sh
import plugin.sh
unset_utils_var
Dmenu_select=(1 "Github下载设置" 2 "管理/导入插件" 3 "插件商店" 4 "检查插件更新")
Dmenu "插件" "加速站点: "
case $DMENU in
  "") last_jump ;;
  1) lastJump=1
  . ~/NumBox/Set-github.com ;;
  2) plugin_menu () {
  otherOptions=(I "导入插件" A "按照名称排序(默认)" T "按照时间排序" S "按照体积排序")
  file_list "~/NumBox/plugins/" "管理插件"
  case $returnFileName in
    I) ;;
    A) lsArg=1A
    plugin_menu ;;
    T) lsArg=1tA
    plugin_menu ;;
    S) lsArg=1SA
    plugin_menu ;;
    *) pluginName="$returnFileName"

    Dmenu_select=(1 "插件菜单" 2 "更新插件" 3 "重装插件" 4 "卸载插件")
    Dmenu "$pluginName"
    case $DMENU in
      1) get_plugin_path && . "${pluginPath}"/main.sh ;;
      2)
    esac
    ;;
  }
  plugin_menu ;;
  3) ;;
esac