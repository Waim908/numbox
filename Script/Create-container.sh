#!/bin/bash
read L W H < ~/NumBox/custom-size
cd /sdcard/NumBox/container/ && rmdir * 2>/dev/null
cd ~/NumBox/container && rmdir * 2>/dev/null
mkdir -p /sdcard/NumBox/container/
mkdir -p ~/NumBox/container/
source /sdcard/NumBox/debug.conf
setup_done () {
  dialog --msgbox "引导完成，可以前往主菜单选择容器打开了(>▽<)" $L $W 2>&1 >/dev/tty && bash ~/NumBox/Numbox
}
LIST_CONTAINER () {
  clear
  echo "已知~/NumBox/container/下的容器目录："
  ls -la ~/NumBox/container
  echo "已知/sdcard/NumBox/container下的容器设置目录："
  ls -la /sdcard/NumBox/container
  echo "Tips）如果你想自己构建或者下载想要的wine版本，可以参考https://github.com/Waim908/wine-termux"
  read -p "⌨️按下任意键返回容器创建" && bash ~/NumBox/Create-container.sh 
}
CUSTOM_STEP_ONE () {
  echo $FILE_NAME >/sdcard/NumBox/container/$CONTAINER_NAME/version
  cp ~/NumBox/default-config/* /sdcard/NumBox/container/$CONTAINER_NAME/
}
CUSTOM_STEP_TWO () {
  echo "tar xf /sdcard/NumBox/winetarxz/$FILE_NAME -C $TMPDIR/winetmp/ && cd $TMPDIR/winetmp/*/ && mv * ~/NumBox/container/$CONTAINER_NAME/wine" > $TMPDIR/cmd && echo 开始解压文件... && bash ~/NumBox/Load
}
FIRST_STEP () {
  clear
  mkdir ~/NumBox/container/$CONTAINER_NAME/disk
  mkdir ~/NumBox/container/$CONTAINER_NAME/wine && mkdir -p $TMPDIR/winetmp/
}
NEXT_STEP () {
#  pkill -f com.termux.x11
  stopserver
  termux-x11 :0 &
  rm -rf  $TMPDIR/winetmp/
  echo "引导阶段,请手动前往termux-x11选择取消或者继续（直接安装可能需要魔法）mono安装,稍后可以选择离线安装"
  echo "box64 wineboot 2>&1 >/dev/null" >$TMPDIR/cmd && bash ~/NumBox/Load && bash ~/NumBox/Load && rm -rf  $TMPDIR/winetmp/
  echo "开始复制文件"
  cp -r ~/NumBox/prefix/disk/ ~/NumBox/container/$CONTAINER_NAME/
  cp ~/NumBox/reg/wfm.reg ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/
  cp ~/NumBox/opt/wine.bat ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/
#  cp ~/NumBox/reg/desktop.reg ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/
  cp /sdcard/NumBox/container/$CONTAINER_NAME/dll.reg ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/
  cp ~/NumBox/wallpaper/wallpaper.bmp ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/
  tar xf ~/NumBox/theme/themes.tar.xz -C ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/windows/resources/
  echo "开始写入注册表"
  box64 wine cmd /c "C:\wine.bat" 2>&1 >/dev/null
  box64 wine reg import "C:\dll.reg" 2>&1 >/dev/null
  box64 wine reg import "C:\windows\resources\themes\reg\apply_human_graphite_theme.reg" 2>&1 >/dev/null
#  cp ~/reg/desktop.reg ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/
#  box64 wine reg import "C:\desktop.reg" 2>&1 >/dev/null
#  box64 wine reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "C:\wallpaper.bmp" /f 2>&1 >/dev/null
  box64 wine reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v LogPixels /t REG_DWORD /d 120 /f 2>&1 >/dev/null
  box64 wine reg add "HKEY_CURRENT_USER\Control Panel\Colors" /v Background /t REG_SZ /d "61,61,61" /f 2>&1 >/dev/null
  box64 wine reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v DoubleClickHeight /t REG_SZ /d 4 /f 2>&1 >/dev/null
  box64 wine reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v DoubleClickWidth /t REG_SZ /d 4 /f 2>&1 >/dev/null
  box64 wine reg import "C:\wfm.reg" 2>&1 >/dev/null
#  box64 wine reg import "C:\desktop.reg" 2>&1 >/dev/null
  echo "开始安装字体"
  tar xf ~/NumBox/opt/fonts.tar.xz -C ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/windows/
  box64 wine reg import "Z:\opt\reg\fonts.reg" 2>&1 >/dev/null
  SELECT_MENU=$(dialog --title "Mono与Gecko离线安装" --menu "是否离线安装mono与gecko？" $L $W $H \
    0 "跳过" \
    1 "安装mono与gecko" \
    2 "仅安装mono" \
    3 "仅安装gecko" 2>&1 >/dev/tty)
  case $SELECT_MENU in
    0) echo "跳过" 
    setup_done ;;
    1) echo "box64 wine msiexec /i \"Z:\opt\install\wine-mono-9.4.0-x86.msi\" 2>&1 >/dev/null && box64 wine msiexec /i \"Z:\opt\install\wine-gecko-2.47.4-x86_64.msi\"" >$TMPDIR/cmd && bash ~/NumBox/Load 
    setup_done ;;
    2) echo "box64 wine msiexec /i \"Z:\opt\install\wine-mono-9.4.0-x86.msi\" 2>&1 >/dev/null" >$TMPDIR/cmd && bash ~/NumBox/Load 
    setup_done ;;
    3) echo "box64 wine msiexec /i \"Z:\opt\install\wine-gecko-2.47.4-x86_64.msi\" 2>&1 >/dev/null" >$TMPDIR/cmd && bash ~/NumBox/Load 
    setup_done ;;
  esac
}
CONTAINER_NAME=$(dialog --backtitle "空容器将自动删除（ ￣ー￣）" --title "在此输入你要创建的容器名" --inputbox "（为空则返回）" $L $W $H  2>&1 >/dev/tty)
if [ -z "$CONTAINER_NAME" ]; then
      bash ~/NumBox/Numbox
    else
      if [ -d "/sdcard/NumBox/container/$CONTAINER_NAME" ]; then
        dialog --title "错误" --msgbox "容器已存在！" $L $W && bash ~/NumBox/Create-container.sh
      else
      if [[ $CONTAINER_NAME == config ]]; then
        dialog --title "错误" --msgbox "容器名不能为config!" $L $W && bash ~/NumBox/Create-container.sh
      fi
      mkdir ~/NumBox/container/$CONTAINER_NAME
      mkdir /sdcard/NumBox/container/$CONTAINER_NAME
      export CONTAINER_NAME
      source ~/NumBox/boot.conf
      WINE_VER=$(dialog --no-shadow --backtitle "$CONTAINER_NAME" --title "选项" --menu "选择一个wine版本，或者输入已存在文件名（内部存储/NumBox/winetarxz）" $L $W $H  \
        0 "🔙返回" \
        1 "🍷10.0-wow64" \
        2 "🍷9.22-wow64" \
        custom "🍷自定义（输入文件名）" \
        view "查看容器列表" \
        doc "关于wine包" 2>&1 >/dev/tty)
      case $WINE_VER in 
         1) FILE_NAME="10.0-wow64.tar.xz"
         FIRST_STEP
         CUSTOM_STEP_ONE
         CUSTOM_STEP_TWO
         NEXT_STEP ;;
         2) FILE_NAME="9.22-wow64.tar.xz"
         FIRST_STEP
         CUSTOM_STEP_ONE
         CUSTOM_STEP_TWO
         NEXT_STEP ;;         
         custom) clear
         echo "目录/sdcard/NumBox/winetarxz"
         ls -1a  /sdcard/NumBox/winetarxz
         echo -e "\n"
         read -p "复制要导入的文件名到此处：" FILE_NAME
        # FILE_NAME=$(dialog --backtitle "将要导入的文件移动到 /sdcard/NumBox/winetarxz" --title "在此处输入文件名，不要为空或者不存在" --inputbox "格式为：xxx.tar.xz" $L $W $H 2>&1 >/dev/tty)
          if [ -z "$FILE_NAME" ]; then
            dialog --title "错误" --msgbox "文件名为空！" $L $W && bash ~/NumBox/Create-container.sh
          else
              if [ ! -f "/sdcard/NumBox/winetarxz/$FILE_NAME" ];then
                dialog --msgbox "$FILE_NAME文件不存在！" $L $W && 2>&1 >/dev/tty && bash ~/NumBox/Create-container.sh
              else
                  FIRST_STEP
                  CUSTOM_STEP_ONE
                  CUSTOM_STEP_TWO
                  NEXT_STEP
              fi
          fi ;;
         view) LIST_CONTAINER ;;
         doc) clear && cat ~/NumBox/doc/winetarxz.txt && read -p "回车返回菜单" && bash ~/NumBox/Numbox ;;
         0) bash ~/NumBox/Numbox ;;
      esac
  fi
fi