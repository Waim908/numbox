#!/bin/bash
source ~/NumBox/utils/dialog.conf
source ~/NumBox/utils/path.conf
wine_pack=$(dialog ${dialog_arg[@]} --title "选择一个wine包" --menu "" $box_sz \
  1 "(内置)wine-9.1-wow64-esync.tar.xz" \
  2 "(内置)wine-9.1-wow64-esync.tar.xz" \
  3 "(自定义)/sdcard/NumBox/winepack" 2>&1 >/dev/tty)
case $wine_pack in
  1) source ~/NumBox/utils/load "tar xf ~/NumBox/built/wine/wine-9.1-wow64-esync.tar.xz -C $TMPDIR" "开始解压 wine-9.1-wow64-esync.tar.xz" ;;
esac