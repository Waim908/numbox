#!/bin/bash
. ~/NumBox/utils/dialog.conf
create_ctrname () {
count=$(ls ~/NumBox/container | wc -l)
ctr_name="新建容器$(($count+1))"
input=$(dialog ${dialog_arg[@]} --title "输入新建容器名" --inputbox "点击取消可返回" $box_sz2 "$ctr_name" 2>&1 >/dev/tty)
a=$?
  if [[ $a == 1 ]]; then
    bash ~/NumBox/Numbox
  else
  if [[ $str_is == good ]]; then
    if [[ -d "$input" ]]; then
      dialog ${dialog_arg[@]} --title "容器 $input已存在" --msgbox "请重新创建容器" $box_sz2
      . ~/NumBox/utils/illegal_str.sh "$input"
      create_ctrname
    else
      echo "$input" > $TMPDIR/ctr_name
    fi
  elif [[ $str_is == bad ]]; then
    dialog ${dialog_arg[@]} --title "非法的字符串 $input" --msgbox "重新命名" $box_sz2
    . ~/NumBox/utils/illegal_str.sh "$input"
    create_ctrname
  fi
  fi
}
create_ctrname
mkdir ~/NumBox/container/$(cat $TMPDIR/ctr_name)
if [[ ! $? == 0 ]]; then
  dialog ${dialog_arg[@]} --title "文件夹创建失败" --msgbox "重新取一个名称吧" $box_sz2
  create_ctrname
else
. ~/NumBox/utils/dialog.conf
. ~/NumBox/utils/path.conf
. ~/NumBox/utils/load
build_prefix () {
  mv $ctr_path/*/ $ctr_path/wine
  mkdir $ctr_path/disk
  . ~/NumBox/utils/boot
  . ~/NumBox/config/numbox.cfg
  . ~/NumBox/config/create.cfg
  load "taskset -c $USE_CORE nice -n $USE_NICE box64 wineboot 2>&1 >/dev/null" "开始构建wine前缀目录"
  load "taskset -c $USE_CORE nice -n $USE_NICE cp -r ~/NumBox/prefix/disk $ctr_path" "解压前缀目录"
#  load "taskset -c $USE_CORE nice -n $USE_NICE "
    echo DEMO
}
wine_pack=$(dialog ${dialog_arg[@]} --title "选择一个wine包" --menu "" $box_sz \
  1 "(内置)wine-9.1-wow64-esync.tar.xz" \
  2 "(内置)wine-9.1-staging-wow64.tar.xz" \
  3 "(自定义)/sdcard/NumBox/winepack" 2>&1 >/dev/tty)
case $wine_pack in
  0) . ~/NumBox/Numbox ;;
  255) . ~/NumBox/Numbox ;;
  1) load "tar xf ~/NumBox/built/wine/wine-9.1-wow64-esync.tar.xz -C ${ctr_path}" "开始解压 wine-9.1-wow64-esync.tar.xz"
  build_prefix ;;
  2) load "tar xf ~/NumBox/built/wine/wine-9.1-staging-wow64.tar.xz -C ${ctr_path}"
  build_prefix ;;
  3) . ~/NumBox/utils/file_list "/sdcard/NumBox/winepack" "选择一个wine包" "/sdcard/NumBox/winepack" ;;
esac
fi