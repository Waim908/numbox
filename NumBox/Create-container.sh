#!/bin/bash
. ~/NumBox/utils/dialog.conf
. ~/NumBox/utils/load.sh
count=$(ls ~/NumBox/container | wc -l)
ctr_name="新建容器$(($count+1))"
create_ctr () {
  . ~/NumBox/utils/boot.sh
  # task 添加日志功能
  load "box64 wineboot 2>&1 >/dev/null" "构建容器..."
  echo 安装主题
  un_txz ~/NumBox/data/theme/themes.tar.xz $
}
select_winever() {
  export CONTAINER_NAME=${input}
  . ~/NumBox/utils/path.conf
  mkdir $ctr_path/disk wine
  . ~/NumBox/data/config/numbox.cfg
  export tar_arg=(--strip-components=1)
  . ~/NumBox/utils/unpack.sh
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
  case $select in
    1) echo "开始解压文件..."
    un_txz "~/NumBox/data/wine/wine-9.1-wow64-esync.tar.xz" "$ctr_path/disk"
    ;;
    2) echo "开始解压文件..."
    un_txz "~/NumBox/data/wine/wine-9.1-staging-wow64.tar.xz" "$ctr_path/disk"
    ;;
    3) file_list "/sdcard/NumBox/winepack" "内部存储/NumBox/winepack"
    un_txz $BACK_NAME "$ctr_path/disk"
}
input=$(dialog ${dialog_arg[@]} --title "输入新建容器名(不能包含空格)" --inputbox "点击取消可返回" $box_sz2 "$ctr_name" 2>&1 >/dev/tty)
if [[ -z $input ]]; then
  exec ~/NumBox/Numbox
else
  . ~/NumBox/utils/illegal_str.sh "${input}"
  if [[ ! $str_is == good ]]; then
    dialog ${dialog_arg[@]} --title "错误" --msgbox "非法的字符串 ${input}" $box_sz2
    bash ~/NumBox/Create-container.sh
  elif [[ -d "~/NumBox/container/$input" ]]; then
    dialog ${dialog_arg[@]} --title "错误" --msgbox "文件夹/容器 ${input} 已经存在" $box_sz2
    bash ~/NumBox/Create-container.sh
  else
    create_dir=$(mdkir ~/NumBox/container/${input} 2>&1 >/dev/null)
    if [[ ! -z $create_dir ]]; then
      dialog ${dialog_arg[@]} --title "创建${input}失败" --msgbox "原因：$create_dir"
    else
      create_ctr
    fi
  fi
fi