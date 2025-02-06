#!/bin/bash
read L W H < ~/NumBox/custom-size
CONTAINER_NAME=$(cat $TMPDIR/container_name.txt)
reg_wallpaper () {
  source ~/NumBox/boot.conf
  box64 wine reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d C:\wallpaper.bmp /f
  bash ~/NumBox/Container-setting.sh
}
reg_background () {
  source ~/NumBox/boot.conf
  box64 wine reg delete "HKEY_CURRENT_USER\Control Panel\Desktop" /v Wallpaper /f
  box64 wine reg add "HKEY_CURRENT_USER\Control Panel\Colors" /v Background /t REG_SZ /d "$RGB" /f
  bash ~/NumBox/Container-setting.sh
}
reg_theme () {
  cp ~/NumBox/reg/theme.bat ~/NumBox
  sed -i "s%file_name=.*%file_name=$reg_file%g" ~/NumBox/theme.bat
  source ~/NumBox/boot.conf
  box64 wine cmd /c ~/NumBox/theme.bat
  bash ~/NumBox/Container-setting.sh
}
exec_winecfg () {
#  res=$(cat /sdcard/NumBox/container/$CONTAINER_NAME/screen_res)
#  pkill -f com.termux.x11
  stopserver
  termux-x11 :0 &
  source ~/NumBox/boot.conf
#  am start -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1 &
  box64 wine winecfg
  bash ~/NumBox/Container-setting.sh
}
SET_CONTAINER=$(dialog --no-shadow --backtitle "$CONTAINER_NAME" --title "容器设置" --menu "选择一个设置" $L $W $H \
    1 "注册表功能" \
    2 "变量功能" \
    3 "处理器核心绑定" \
    4 "设置显示分辨率" \
    5 "设置字体显示DPI" \
    6 "设置容器桌面壁纸" \
    7 "SmartBox64功能(实验性)" \
    back "🔙返回" 2>&1 >/dev/tty)
    case $SET_CONTAINER in
      back) bash ~/NumBox/Set-container2.sh ;;
      1) bash ~/NumBox/Reg-config.sh ;;
      2) bash ~/NumBox/Env-config.sh ;;
      3) bash ~/NumBox/Cpu-setcore.sh ;;
      4) bash ~/NumBox/Res-set.sh ;;
      5) DPI_SET=$(dialog --title "字体DPI设置" --inputbox "数字越大字体越大越清晰,不推荐过大或者过小" $L $W $H 2>&1 >/dev/tty)
      source ~/NumBox/boot.conf
      echo "box64 wine reg.exe add "HKEY_CURRENT_USER\Control Panel\Desktop" /v LogPixels /t REG_DWORD /d $DPI_SET /f" > $TMPDIR/cmd && bash ~/NumBox/Load && echo "DPI值为$DPI_SET" && sleep 1 && bash ~/NumBox/Container-setting.sh ;;
      6) WALLPAPER_SET=$(dialog --title "自定义容器壁纸" --menu "选择一个选项" $L $W $H \
        0 "🔙返回" \
        1 "输入自定义壁纸文件名(设定壁纸将会导致渲染错误!!!)" \
        2 "使用纯色壁纸" \
        3 "还原NumBox官方壁纸(设定壁纸将会导致渲染错误!!!)" \
        doc "查看帮助" 2>&1 >/dev/tty)
      case $WALLPAPER_SET in
        doc) clear
        cat ~/NumBox/doc/wallpaper.txt
        read -s -n1 -p "输入任意字符返回设置" && bash ~/NumBox/Container-setting.sh ;;
        0) bash ~/NumBox/Container-setting.sh ;;
        3) cp ~/NumBox/wallpaper/* /sdcard/NumBox/wallpaper/ ;;
        1) read res_value < /sdcard/NumBox/container/$CONTAINER_NAME/screen_res
        echo "位于内部存储/NumBox/wallpaper文件夹内的文件有："
        ls /sdcard/NumBox/wallpaper
        echo "复制一个文件名，然后输入任意字符继续"
        read -s -n1 
        INPUT_NAME=$(dialog --title "输入文件名.格式" --inputbox "/sdcard/NumBox/wallpaper" $L $W $H 2>&1 >/dev/tty)
        if [ ! -f "/sdcard/NumBox/wallpaper/$INPUT_NAME" ]; then
          dialog --msgbox "$INPUT_NAME文件不存在！" $L $W $H 2>&1 >/dev/tty
          else
            read -n 2 header < "/sdcard/NumBox/wallpaper/$INPUT_NAME"
            if [[ "$header" == "BM" ]]; then
              magick /sdcard/NumBox/wallpaper/$INPUT_NAME -resize $res_value! ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/wallpaper.bmp
              reg_wallpaper
            else
              magick /sdcard/NumBox/wallpaper/$INPUT_NAME -resize $res_value! ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/wallpaper.bmp
              reg_wallpaper
            fi
          fi ;;
        2) COLOR_SET=$(dialog --title "背景色设置" --menu "选择一个预设或自定义" $L $W $H \
          back "🔙返回" \
          custom "自定义RGB色值" \
          W "纯白" \
          B "纯黑" \
          1 "绿51,204,102" \
          2 "黄255,255,102" \
          3 "青102,255,255" \
          4 "蓝102,179,255" \
          5 "红214,71,0" \
          6 "紫102,51,153" \
          7 "橙255,133,10" \
          8 "粉255,153,204" \
          9 "灰61,61,61" 2>&1 >/dev/tty)
        case $COLOR_SET in
          back) bash ~/NumBox/Container-setting.sh ;;
          custom) RED=$(dialog --title "输入红色色值" --inputbox "必须为数字" $L $W $H 2>&1 >/dev/tty)
          GREEN=$(dialog --title "输入绿色色值" --inputbox "必须为数字" $L $W $H 2>&1 >/dev/tty)
          BLUE=$(dialog --title "输入蓝色色值" --inputbox "必须为数字" $L $W $H 2>&1 >/dev/tty)
          RGB="$RED $GREEN $BLUE" 
          dialog --title "RGB" --msgbox "色值设定为$RGB" $L $W 2>&1 >/dev/tty
          reg_background ;;
          W) RGB="255 255 255"
          reg_wallpaper ;;
          B) RGB="0 0 0"
          reg_wallpaper ;;
          1) RGB="51 204 102"
          reg_wallpaper ;;
          2) RGB="255 255 102"
          reg_wallpaper ;;
          3) RGB="102 255 255"
          reg_wallpaper ;;
          4) RGB="102 179 255"
          reg_wallpaper ;;
          5) RGB="214 71 0"
          reg_wallpaper ;;
          6) RGB="102 51 153"
          reg_wallpaper ;;
          7) RGB="255 133 10"
          reg_wallpaper ;;
          8) RGB="255 153 204"
          reg_wallpaper ;;
          9) RGB="61 61 61"
          reg_wallpaper ;;
        esac ;;
    esac ;;
  7) if [ -f "/sdcard/NumBox/container/$CONTAINER_NAME/SmartBox64_VK.conf" ]; then
    CONF_STATU=yes
  else
    CONF_STATU=no
  fi
  if [ -f "~/box64.box64rc" ]; then
    RC_STATU=yes
  else
    RC_STATU=no
  fi
  if [ -f "/sdcard/NumBox/container/$CONTAINER_NAME/enable_dxvk.conf" ]; then
    DXVK_STATU=yes
  else
    DXVK_STATU=no
  fi
  SB64_SET=$(dialog --title "SmartBox64功能" --menu "来自SmartBox64的部分设置" $L $W $H \
    back "🔙返回" \
    doc "查看帮助" \
    1 "启用vulkan部分相关变量" \
    状态 "$CONF_STATU" \
    2 "禁用vulkan部分相关变量" \
    3 "启用box64rc" \
    状态 "$RC_STATU" \
    4 "禁用box64rc" \
    5 "启用dxvk.conf" \
    状态 "$DXVK_STATU" \
    6 "禁用dxvk.conf" 2>&1 >/dev/tty)
  case $SB64_SET in
    doc) clear
    cat ~/NumBox/doc/about_smartbox64.txt
    read -s -n1 -p "输入任意字符继续" && bash ~/NumBox/Container-setting.sh ;;
    back) ~/NumBox/Container-setting.sh ;;
    1) cp ~/NumBox/conf/SmartBox64_VK.conf /sdcard/NumBox/container/$CONTAINER_NAME/
    bash ~/NumBox/Container-setting.sh ;;
    2) rm -rf /sdcard/NumBox/container/$CONTAINER_NAME/SmartBox64_VK.conf
    bash ~/NumBox/Container-setting.sh ;;
    3) cp /sdcard/NumBox/box64.box64rc ~/.box64rc
    bash ~/NumBox/Container-setting.sh ;;
    4) rm -rf ~/.box64rc
    bash ~/NumBox/Container-setting.sh ;;
    5) cp ~/NumBox/conf/enable_dxvk.conf /sdcard/NumBox/container/$CONTAINER_NAME/
    bash ~/NumBox/Container-setting.sh ;;
    6) rm -rf /sdcard/NumBox/container/$CONTAINER_NAME/enable_dxvk.conf
    bash ~/NumBox/Container-setting.sh ;;
    esac ;;
esac