#!/bin/bash
. ~/NumBox/utils/dialog.conf
. ~/NumBox/utils/load.sh
rmdir ~/NumBox/data/container/*/
count=$(ls ~/NumBox/data/container | wc -l)
ctr_name="新建容器$(($count+1))"
create_ctr () {
  . ~/NumBox/utils/boot.conf
  . ~/NumBox/data/config/create.cfg
  unset DISPLAY
  unset tar_arg
  # task 添加日志功能
  load "box64 wineboot -u >/dev/null 2>&1" "构建容器..."
  echo 安装PREFIX目录
  un_tzst ~/NumBox/data/prefix/disk.tar.zst $ctr_path
  echo 安装主题
  load "box64 wine regedit /C \"C:\windows\resources\themes\apply_human_graphite_theme.reg\" >/dev/null 2>&1"
  mono_ver=$(cat ~/NumBox/data/resources/mono/version)
  gecko_ver=$(cat ~/NumBox/data/resources/gecko/version)
  echo "安装mono(.NET框架) 版本: $mono_ver"
  load "box64 wine msiexec /i \"Z:\home\NumBox\data\resources\mono\x86\wine-mono-${mono_ver}-x86.msi\" >/dev/null 2>&1" "mono x32"
  echo "安装gecko(html框架) 版本：$gecko_ver"
  load "box64 wine msiexec /i \"Z:\home\NumBox\data\resources\gecko\x86\wine-gecko-${gecko_ver}-x86.msi\" >/dev/null 2>&1" "gecko x32"
  load "box64 wine msiecec /i \"Z:\home\NumBox\data\resources\gecko\x64\wine-gecko-${gecko_ver}-x86_64.msi\" >/dev/null 2>&1" "gecko x64"
  echo "执行完成"
}
select_winever() {
  export CONTAINER_NAME=${input}
  . ~/NumBox/utils/path.conf
  mkdir $ctr_path/disk 
  mkdir $ctr_path/wine
  . ~/NumBox/data/config/numbox.cfg
  . ~/NumBox/utils/package.sh
  exit_exec () {
    dialog ${dialog_arg[@]} --msgbox "选择取消" $box_sz2 && exec ~/NumBox/Numbox
  }
  export -f exit_exec
  . ~/NumBox/utils/file_list.sh
  select=$(dialog ${dialog_arg[@]} --title "选择一个wine版本" --menu "" $box_sz \
    1 "(Glibc)wine-9.1-wow64-esync.tar.xz" \
    2 "(Glibc)wine-9.1-staging-wow64.tar.xz" \
    3 "从内部存储/NumBox/winepack导入" 2>&1 >/dev/tty)
  if [[ -z $select ]]; then
    dialog ${dialog_arg[@]} --msgbox "选择取消" $box_sz2 && exec ~/NumBox/Numbox
  fi
  export tar_arg=(--strip-components=1)
  case $select in
    1) echo "开始解压文件..."
    un_txz ~/NumBox/data/wine/wine-9.1-wow64-esync.tar.xz "$ctr_path/wine"
    ;;
    2) echo "开始解压文件..." 
    un_txz ~/NumBox/data/wine/wine-9.1-staging-wow64.tar.xz "$ctr_path/wine"
    ;;
    3) file_list "/sdcard/NumBox/winepack" "内部存储/NumBox/winepack"
    un_txz $BACK_NAME "$ctr_path/wine"
    ;;
  esac
}
input=$(dialog ${dialog_arg[@]} --title "输入新建容器名(不能包含空格)" --inputbox "点击取消可返回" $box_sz2 "$ctr_name" 2>&1 >/dev/tty)
if [[ -z $input ]]; then
  exec ~/NumBox/Numbox
else
  . ~/NumBox/utils/illegal_str.sh "${input}"
  if [[ ! $str_is == good ]]; then
    dialog ${dialog_arg[@]} --title "错误" --msgbox "非法的字符串 ${input}" $box_sz2
    bash ~/NumBox/Create-container.sh
  elif [[ -d "~/NumBox/data/container/$input" ]]; then
    dialog ${dialog_arg[@]} --title "错误" --msgbox "文件夹/容器 ${input} 已经存在" $box_sz2
    bash ~/NumBox/Create-container.sh
  else
    create_dir=$(mkdir ~/NumBox/data/container/${input} 2>&1 >/dev/null)
    if [[ ! -z $create_dir ]]; then
      dialog ${dialog_arg[@]} --title "创建${input}失败" --msgbox "原因：$create_dir" $box_sz2
    else
      select_winever
      create_ctr
    fi
  fi
fi