#!/bin/bash
. ~/NumBox/utils/dialog.conf
. ~/NumBox/utils/load.sh
. ~/NumBox/data/config/numbox.cfg
clean () {
rm -rf $TMPDIR/tempCtr-*/
if ! box64 wineserver -k; then
  pkill -f wine
fi
stopx11
}
clean
trap clean EXIT
export CONTAINER_NAME=$(basename $(mktemp -d $TMPDIR/tempCtr-XXXXXX))
export ctr_path=$TMPDIR/$CONTAINER_NAME
  parallel ::: "mkdir $ctr_path/disk" "mkdir $ctr_path/wine" "mkdir $ctr_path/config" 
  parallel ::: "cp ~/NumBox/default/ctr/* $ctr_path/config" "cp ~/NumBox/default/box64/* $ctr_path/config"
  . ~/NumBox/utils/package.sh
  tar_arg=("--strip-components=1")
  exit_exec () {
    dialog ${dialog_arg[@]} --msgbox "选择取消" $box_sz2 && . ~/NumBox/Numbox
  }
  export -f exit_exec
  . ~/NumBox/utils/file_list.sh 
  CUSTOM_FILE_LIST_OPTIONS=("E" "\Z2从/sdcard/NumBox/winepack/导入?\Zn") 
  file_list "$HOME/NumBox/data/wine" "内置wine" "选择一个wine版本" "${INPUT}"
  if [[ -z $BACK_NAME ]]; then
    dialog ${dialog_arg[@]} --msgbox "选择取消" $box_sz2 && . ~/NumBox/Numbox
  elif [[ -f ~/NumBox/data/wine/${BACK_NAME} ]]; then
    echo 开始解压文件
    if ! un_txz ~/NumBox/data/wine/${BACK_NAME} "$ctr_path/wine"; then
        echo 文件解压失败 && exit 1
    fi
  elif [[ $BACK_NUM == E ]]; then
    CUSTOM_FILE_LIST_OPTIONS=("B" "\Z2从\Z3内置\Z2导入?\Zn") 
    file_list "/sdcard/NumBox/winepack" "内部存储/NumBox/winepack" "选择一个wine版本" "${input}"
    if [[ -z $BACK_NAME ]]; then
      dialog ${dialog_arg[@]} --msgbox "选择取消" $box_sz2 && . ~/NumBox/Numbox
    elif [[ -f /sdcard/NumBox/winepack/${BACK_NAME} ]]; then
      if ! un_txz /sdcard/NumBox/winepack/${BACK_NAME} "$ctr_path/wine"; then
          echo 文件解压失败 && exit 1
      fi
    elif [[ $BACK_NUM == B ]]; then
      select_winever
    else
      echo 错误 && exit 1
    fi
  else
    echo 错误 && exit 1
  fi
  # . ~/NumBox/utils/boot.conf
unset LD_PRELOAD
# export PATH=/data/data/com.termux/files/usr/glibc/bin:$PATH
# export PATH=$(echo $PATH | tr ':' '\n' | sort -u | tr '\n' ':')
export PATH="$PATH:/data/data/com.termux/files/usr/glibc/bin:$TMPDIR/${CONTAINER_NAME}/wine/bin"
export PATH=$(echo "$PATH" | tr ':' '\n' | awk '!x[$0]++' | paste -sd ':')
export BOX64_LD_LIBRARY_PATH="$TMPDIR/${CONTAINER_NAME}/wine/lib/wine/x86_64-unix:$PREFIX/glibc/lib/box64-x86_64-linux-gnu"
export WINEPREFIX="$TMPDIR/${CONTAINER_NAME}/disk"
export FONTCONFIG_PATH=/data/data/com.termux/files/usr/glibc/etc/fonts
export USE_HEAP=1
export LIBGL_DRIVERS_PATH=/data/data/com.termux/files/usr/glibc/lib/dri
if [[ $WINEESYNC == 1 ]]; then
    export WINEESYNC_TERMUX=1
fi
  unset tar_arg
  unset DISPLAY
  # task 添加日志功能
  export load_strict=1
  if ! load "taskset -c ${USE_CORE} box64 wineboot -u >$TMPDIR/build_wineboot.log 2>&1" "构建容器..."; then
    cat $TMPDIR/build_wineboot.log
    echo 致命错误,容器构建失败
    exit 1
  fi
  echo 安装PREFIX目录
  un_tzst ~/NumBox/data/prefix/disk.tar.zst $ctr_path &&
  if ! load "nice -n ${USE_NICE} taskset -c ${USE_CORE} box64 wine regedit /C \"C:\windows\resources\themes\apply_human_graphite_theme.reg\" >$TMPDIR/build_wineboot_theme.log 2>&1"  "安装主题"; then
    cat $TMPDIR/build_wineboot_theme.log
    echo 错误，主题安装失败
  fi
  mono_ver=$(cat ~/NumBox/data/resources/mono/version)
  gecko_ver=$(cat ~/NumBox/data/resources/gecko/version)
  echo "安装mono(.NET框架) 版本: $mono_ver"
  if ! load "nice -n ${USE_NICE} taskset -c ${USE_CORE} box64 wine msiexec /i \"Z:\home\NumBox\data\resources\mono\x32\wine-mono-${mono_ver}-x86.msi\" >$TMPDIR/build_wineboot_mono32.log 2>&1" "mono x32"; then
    cat $TMPDIR/build_wineboot_mono32.log
    echo 错误，32位mono安装失败
  fi
  echo "安装gecko(html框架) 版本：$gecko_ver"
  if ! load "nice -n ${USE_NICE} taskset -c ${USE_CORE} box64 wine msiexec /i \"Z:\home\NumBox\data\resources\gecko\x32\wine-gecko-${gecko_ver}-x86.msi\" >$TMPDIR/build_wineboot_gecko32.log 2>&1" "gecko x32"; then
    cat $TMPDIR/build_wineboot_gecko32.log
    echo 错误，32位gecko安装失败
  fi
  if ! load "nice -n ${USE_NICE} taskset -c ${USE_CORE} box64 wine msiexec /i \"Z:\home\NumBox\data\resources\gecko\x64\wine-gecko-${gecko_ver}-x86_64.msi\" >$TMPDIR/build_wineboot_gecko64.log 2>&1" "gecko x64"; then
    cat $TMPDIR/build_wineboot_gecko64.log
    echo 错误，64位gecko安装失败
  fi
  echo 开始写入注册表
  # Desktop
  set_reg_key "$ctr_path/disk/user.reg" "Control Panel\\Desktop" "LogPixels" "dword:00000078"
  set_reg_key "$ctr_path/disk/user.reg" "Control Panel\\Desktop" "Background" "\"61 61 61\""
  # wfm.exe
  if ! load "nice -n ${USE_NICE} taskset -c ${USE_CORE} box64 wine regedit /C \"Z:\home\NumBox\opt\reg\wfm.reg\" >/dev/null 2>&1" "wfm.reg"; then
    echo "wfm.reg写入失败"
  fi
  if ! load "nice -n ${USE_NICE} taskset -c ${USE_CORE} box64 wine regedit /C \"Z:\home\NumBox\opt\reg\fonts.reg\" >/dev/null 2>&1" "fonts.reg"; then
    echo "fonts.reg写入失败"
  fi
  if ! load "nice -n ${USE_NICE} taskset -c ${USE_CORE} box64 wine regedit /C \"Z:\home\NumBox\opt\reg\dll.reg\" >/dev/null 2>&1" "dll.reg"; then
    echo "dll.reg写入失败，原装dll文件将无法调用请手动定义"
  fi
parallel ::: "rm -rf $TMPDIR/build_wineboot_*.log" "rm -rf $ctr_path/disk/dosdevices/h:"
parallel ::: "ln -sf $TMPDIR/ $ctr_path/disk/dosdevices/z:" "ln -sf $TMPDIR"
. ~/NumBox/utils/openx11.sh
stopx11
startx11 0
export DISPLAY=0
get_res Pscreen
box64 wine explorer /desktop=shell,$screenRes