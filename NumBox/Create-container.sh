#!/bin/bash
utilsDoNotReimport=1
. ~/NumBox/utils/utils.sh
import dialog.sh
import load.sh
import numbox.cfg
import empty.sh
import reg_edit.sh
import file_list.sh
import openx11.sh
import echo.sh
unset_utils_var
create_dir sd
stopx11
# renice -n ${USER_NICE} -p $$
# rmdir ~/NumBox/data/container/*/
rm -rf ~/NumBox/data/container/_Temp
count=$(ls ~/NumBox/data/container | wc -l)
ctr_name="新建容器$(($count+1))-$RANDOM"
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
          dialog ${dialog_arg[@]} --title "\Z1错误\Zn" --msgbox "字符串不能为_Temp" $box_sz2
          . ~/NumBox/Create-container.sh
    fi
    temp_dir=$(mkdir ~/NumBox/data/container/_Temp 2>&1 >/dev/null)
    if [[ ! -z $temp_dir ]]; then
      dialog ${dialog_arg[@]} --title "\Z1创建\Zn${input}\Z1失败\Zn" --msgbox "原因：$temp_dir" $box_sz2
    else
      # Former select_winever function content
      export CONTAINER_NAME="_Temp"
      . ~/NumBox/utils/path.sh
      parallel ::: "mkdir $ctr_path/disk" "mkdir $ctr_path/wine" "mkdir $ctr_path/config" "mkdir $ctr_path/temp"
      parallel ::: "mkdir $ctr_disk_c/windows/system32" "mkdir $ctr_disk_c/windows/syswow64" "mkdir $ctr_path/temp/mesa" "mkdir $ctr_path/temp/windows" "cp ~/NumBox/default/box64rc/box64rc.box64rc $ctr_conf_path/" "cp ~/NumBox/default/ctr/* $ctr_conf_path/" "cp ~/NumBox/default/box64/兼容 $ctr_conf_path/box64.conf"
      . ~/NumBox/utils/package.sh
      tar_arg=("--strip-components=1")
      if [[ $(ls ~/NumBox/resources/wine/ | wc -l ) -lt 5 ]]; then
        selectBottom=1
      else
        unset selectBottom
      fi
      if ! file_list "/sdcard/NumBox/resources/wine" "/sdcard/NumBox/resources/wine" "选择一个wine版本" "${input}"; then
        warn "/sdcard/NumBox/resources/wine 目录下没有找到 wine包，请导入"

      fi
      if [[ -z $returnFileListName ]]; then
        dialog ${dialog_arg[@]} --msgbox "选择取消" $box_sz2 && . ~/NumBox/Numbox
      elif [[ -f ~/NumBox/data/resources/wine/${returnFileListName} ]]; then
        echo 开始解压文件
        if ! un_txz "$HOME/NumBox/data/resources/wine/${returnFileListName}" "$ctr_path/wine"; then
            echo 文件解压失败 && exit 1
        fi
      else
        warn 错误
        exit 1
      fi

      #创建容器
      # Proton 用户名适配
      export USER="steamuser"
      . ~/NumBox/utils/boot.sh
      unset DISPLAY
      unset tar_arg
      export loadStrict=1
      if ! load "box64 wineboot -u >$TMPDIR/build_wineboot.log 2>&1" "构建容器..."; then
        cat $TMPDIR/build_wineboot.log
        warn 致命错误,容器构建失败
        info "错误容器已保存在~/NumBox/data/conatiner/_Temp"
        info "如果需要调试请执行 \$ bash ~/NumBox/No-gui.sh _Temp"
        info 下次创建容器将自动删除
        exit 1
      fi
      # C:\Users\Administrator\AppData\Local\Temp
      ln -sf $ctr_disk_c/users/steamuser/AppData/Local/Temp/ $ctr_path/temp/windows
      echo 安装PREFIX目录
      if ! un_txz ~/NumBox/data/prefix/disk.tar.xz $ctr_path; then
        error 错误，文件解压失败
      fi
      if ! load "box64 wine regedit /C \"C:\windows\resources\themes\reg\apply_human_graphite_theme.reg\" >$TMPDIR/build_wineboot_theme.log 2>&1"  "安装主题"; then
        cat $TMPDIR/build_wineboot_theme.log
        error 错误，主题安装失败
      fi
      mono_ver=$(cat ~/NumBox/data/resources/mono/version)
      gecko_ver=$(cat ~/NumBox/data/resources/gecko/version)
      echo "安装mono(.NET框架) 版本: $mono_ver"
      if ! load "box64 wine msiexec /qn /i \"Z:\home\NumBox\data\resources\mono\x32\wine-mono-${mono_ver}-x86.msi\" >$TMPDIR/build_wineboot_mono32.log 2>/dev/null" "mono x32"; then
        cat $TMPDIR/build_wineboot_mono32.log
        error 错误，32位mono安装失败
      fi
      echo "安装gecko(html框架) 版本：$gecko_ver"
      if ! load "box64 wine msiexec /qn /i \"Z:\home\NumBox\data\resources\gecko\x32\wine-gecko-${gecko_ver}-x86.msi\" >$TMPDIR/build_wineboot_gecko32.log 2>/dev/null" "gecko x32"; then
        cat $TMPDIR/build_wineboot_gecko32.log
        error 错误，32位gecko安装失败
      fi
      if ! load "box64 wine msiexec /qn /i \"Z:\home\NumBox\data\resources\gecko\x64\wine-gecko-${gecko_ver}-x86_64.msi\" >$TMPDIR/build_wineboot_gecko64.log 2>/dev/null" "gecko x64"; then
        cat $TMPDIR/build_wineboot_gecko64.log
        error 错误，64位gecko安装失败
      fi
      echo 开始写入注册表
      set_reg_key "$ctr_path/disk/user.reg" "Control Panel\\Desktop" "LogPixels" "dword:00000078"
      set_reg_key "$ctr_path/disk/user.reg" "Control Panel\\Desktop\\Colors" "background" "\"61 61 61\""
      # set_reg_key "$ctr_path/disk/system.reg" "System\\ControlSet001\\Control\\Session Manager\\Environment" "PATH" "str(2):\"%SystemRoot%\system32;%SystemRoot%;%SystemRoot%\system32\wbem;%SystemRoot%\system32\WindowsPowershell\v1.0;Z:\opt\bin\7z\""
      if ! load "box64 wine regedit /C \"Z:\home\NumBox\opt\reg\wfm.reg\" >/dev/null 2>&1" "wfm.reg"; then
        error "wfm.reg写入失败"
      fi
      if ! load "box64 wine regedit /C \"Z:\home\NumBox\opt\reg\fonts.reg\" >/dev/null 2>&1" "fonts.reg"; then
        error "fonts.reg写入失败"
      fi
      if ! load "box64 wine regedit /C \"Z:\home\NumBox\opt\reg\dll.reg\" >/dev/null 2>&1" "dll.reg"; then
        error "dll.reg写入失败，原装dll文件将无法调用请手动定义"
      fi
      mv ~/NumBox/data/container/_Temp ~/NumBox/data/container/${input}
      rm -rf $TMPDIR/build_wineboot*.log
      info "容器\"${input}\"构建完成"
    fi
  fi
fi