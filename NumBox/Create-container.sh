#!/bin/bash
. ~/NumBox/utils/dialog.conf
. ~/NumBox/utils/load.sh
. ~/NumBox/data/config/numbox.cfg
. ~/NumBox/utils/empty.sh sd
. ~/NumBox/utils/reg_edit.sh
. ~/NumBox/utils/file_list.sh
. ~/NumBox/utils/openx11.sh
stopx11
# renice -n ${USER_NICE} -p $$
# rmdir ~/NumBox/data/container/*/
rm -rf ~/NumBox/data/container/_Temp
count=$(ls ~/NumBox/data/container | wc -l)
ctr_name="新建容器$(($count+1))"
if [[ -z $1 ]]; then
   input=$(dialog ${dialog_arg[@]} --title "输入新建容器名(不能包含\Z1空格\Zn，可能出错)" --inputbox "点击取消可返回" $box_sz2 "$ctr_name" 2>&1 >/dev/tty)
else
   input=$1
fi
export WINEESYNC=0
if [[ -z $input ]]; then
  exec ~/NumBox/Numbox
else
  . ~/NumBox/utils/illegal_str.sh "${input}"
  if [[ ! $str_is == good ]]; then
    dialog ${dialog_arg[@]} --title "\Z1错误\Zn" --msgbox "非法的字符串 ${input}" $box_sz2
    . ~/NumBox/Create-container.sh
  fi
  if [[ -d "$HOME/NumBox/data/container/$input" ]]; then
    dialog ${dialog_arg[@]} --title "\Z1错误\Zn" --msgbox "文件夹/容器 ${input} 已经存在" $box_sz2
    . ~/NumBox/Create-container.sh
  else
    if [[ $input == _Temp ]]; then
          dialog ${dialog_arg[@]} --title "\Z1错误\Zn" --msgbox "字符串不能为“_Temp”" $box_sz2
          . ~/NumBox/Create-container.sh
    fi
    create_dir=$(mkdir ~/NumBox/data/container/_Temp 2>&1 >/dev/null)
    if [[ ! -z $create_dir ]]; then
      dialog ${dialog_arg[@]} --title "\Z1创建\Zn${input}\Z1失败\Zn" --msgbox "原因：$create_dir" $box_sz2
    else
      # Former select_winever function content
      export CONTAINER_NAME="_Temp"
      . ~/NumBox/utils/path.conf
      parallel ::: "mkdir $ctr_path/disk" "mkdir $ctr_path/wine" "mkdir $ctr_path/config" "mkdir $ctr_path/temp"
      parallel ::: "cp ~/NumBox/default/box64rc/box64rc.box64rc $ctr_conf_path/" "cp ~/NumBox/default/ctr/* $ctr_conf_path/" "cp ~/NumBox/default/box64/兼容 $ctr_conf_path/box64.conf"
      . ~/NumBox/utils/package.sh
      tar_arg=("--strip-components=1")
      exit_exec () {
        dialog ${dialog_arg[@]} --msgbox "选择取消" $box_sz2
        . ~/NumBox/Numbox
      }
      export -f exit_exec
      if [[ $(ls ~/NumBox/resources/wine/ | wc -l ) -lt 5 ]]; then
        select_bottom=1
      else
        unset select_bottom
      fi
      CUSTOM_FILE_LIST_OPTIONS=("E" "\Z2从/sdcard/NumBox/winepack/导入?\Zn")
      file_list "$HOME/NumBox/data/resources/wine" "内置wine" "选择一个wine版本" "${input}"
      if [[ -z $BACK_NAME ]]; then
        dialog ${dialog_arg[@]} --msgbox "选择取消" $box_sz2 && . ~/NumBox/Numbox
      elif [[ $BACK_NUM == E ]]; then
        CUSTOM_FILE_LIST_OPTIONS=("B" "\Z2从\Z3内置\Z2导入?\Zn")
        file_list "/sdcard/NumBox/winepack" "内部存储/NumBox/winepack" "选择一个wine版本" "${input}"
        if [[ -z $BACK_NAME ]]; then
          dialog ${dialog_arg[@]} --msgbox "选择取消" $box_sz2 && . ~/NumBox/Numbox
        elif [[ -f /sdcard/NumBox/winepack/"${BACK_NAME}" ]]; then
          if ! un_txz /sdcard/NumBox/winepack/"${BACK_NAME}" "$ctr_path/wine"; then
              echo 文件解压失败 && exit 1
          fi
        else
          echo 错误 && exit 1
        fi
      elif [[ -f ~/NumBox/data/resources/wine/${BACK_NAME} ]]; then
        echo 开始解压文件
        if ! un_txz ~/NumBox/data/resources/wine/${BACK_NAME} "$ctr_path/wine"; then
            echo 文件解压失败 && exit 1
        fi
      else
        echo 错误 && exit 1
      fi

      #创建容器
      export USER="steamuser"
      . ~/NumBox/utils/boot.conf
      unset DISPLAY
      unset tar_arg
      export load_strict=1
      if ! load "box64 wineboot -u >$TMPDIR/build_wineboot.log 2>&1" "构建容器..."; then
        cat $TMPDIR/build_wineboot.log
        echo 致命错误,容器构建失败
        echo "错误容器已保存在~/NumBox/data/conatiner/_Temp"
        echo "如果需要调试请执行 \$ bash ~/NumBox/No-gui.sh _Temp"
        echo 下次创建容器将自动删除
        exit 1
      fi
      echo 安装PREFIX目录
      if ! un_txz ~/NumBox/data/prefix/disk.tar.xz $ctr_path; then
        echo 错误，文件解压失败
      fi
      if ! load "box64 wine regedit /C \"C:\windows\resources\themes\reg\apply_human_graphite_theme.reg\" >$TMPDIR/build_wineboot_theme.log 2>&1"  "安装主题"; then
        cat $TMPDIR/build_wineboot_theme.log
        echo 错误，主题安装失败
      fi
      mono_ver=$(cat ~/NumBox/data/resources/mono/version)
      gecko_ver=$(cat ~/NumBox/data/resources/gecko/version)
      echo "安装mono(.NET框架) 版本: $mono_ver"
      if ! load "box64 wine msiexec /qn /i \"Z:\home\NumBox\data\resources\mono\x32\wine-mono-${mono_ver}-x86.msi\" >$TMPDIR/build_wineboot_mono32.log 2>/dev/null" "mono x32"; then
        cat $TMPDIR/build_wineboot_mono32.log
        echo 错误，32位mono安装失败
      fi
      echo "安装gecko(html框架) 版本：$gecko_ver"
      if ! load "box64 wine msiexec /qn /i \"Z:\home\NumBox\data\resources\gecko\x32\wine-gecko-${gecko_ver}-x86.msi\" >$TMPDIR/build_wineboot_gecko32.log 2>/dev/null" "gecko x32"; then
        cat $TMPDIR/build_wineboot_gecko32.log
        echo 错误，32位gecko安装失败
      fi
      if ! load "box64 wine msiexec /qn /i \"Z:\home\NumBox\data\resources\gecko\x64\wine-gecko-${gecko_ver}-x86_64.msi\" >$TMPDIR/build_wineboot_gecko64.log 2>/dev/null" "gecko x64"; then
        cat $TMPDIR/build_wineboot_gecko64.log
        echo 错误，64位gecko安装失败
      fi
      echo 开始写入注册表
      if ! set_reg_key "$ctr_path/disk/user.reg" "Control Panel\\Desktop" "dword:00000078"; then
        echo "错误，DPI 120写入失败"
      fi
      if ! set_reg_key "$ctr_path/disk/user.reg" "Control Panel\\Desktop\\Colors" "background" "\"61 61 61\""; then
        echo "错误，桌面背景颜色写入失败"
      fi
      if ! set_reg_key "$ctr_path/disk/system.reg" "System\\ControlSet001\\Control\\Session Manager\\Environment" "PATH" "str(2):\"%SystemRoot%\system32;%SystemRoot%;%SystemRoot%\system32\wbem;%SystemRoot%\system32\WindowsPowershell\v1.0;Z:\opt\bin\7z\""; then
        echo "错误，7z命令写入失败"
      fi
      if ! load "box64 wine regedit /C \"Z:\home\NumBox\opt\reg\wfm.reg\" >/dev/null 2>&1" "wfm.reg"; then
        echo "wfm.reg写入失败"
      fi
      if ! load "box64 wine regedit /C \"Z:\home\NumBox\opt\reg\fonts.reg\" >/dev/null 2>&1" "fonts.reg"; then
        echo "fonts.reg写入失败"
      fi
      if ! load "box64 wine regedit /C \"Z:\home\NumBox\opt\reg\dll.reg\" >/dev/null 2>&1" "dll.reg"; then
        echo "dll.reg写入失败，原装dll文件将无法调用请手动定义"
      fi
      mv ~/NumBox/data/container/_Temp ~/NumBox/data/container/${input}
      rm -rf $TMPDIR/build_wineboot*.log
      echo "容器\"${input}\"构建完成"
    fi
  fi
fi