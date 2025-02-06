#!/bin/bash
read L W H < ~/NumBox/custom-size
CONTAINER_NAME=$(cat $TMPDIR/container_name.txt)
SET_MAIN_MENU=$(dialog --no-shadow --title "$CONTAINER_NAME" --menu "选择一个选项" $L $W $H \
  back "🔙返回主菜单" \
  0 "容器详情" \
  1 "DrectX图形环境" \
  2 "GPU图形驱动选择" \
  3 "容器设置" \
  4 "将此容器设置为默认启动容器" \
  5 "添加挂载盘" \
  6 "📦️将此容器打包"\
  7 "重命名此容器" \
  8 "选择box64预设"  2>&1 >/dev/tty)
case $SET_MAIN_MENU in
  back) bash ~/NumBox/Numbox ;;
  0) clear
  Winever=$(cat /sdcard/NumBox/container/$CONTAINER_NAME/version 2>/dev/null)
  Gpu=$(cat /sdcard/NumBox/container/$CONTAINER_NAME/device 2>/dev/null)
  D3D32=$(cat /sdcard/NumBox/container/$CONTAINER_NAME/D3D32_VERSION)
  D3D64=$(cat /sdcard/NumBox/container/$CONTAINER_NAME/D3D64_VERSION)
  STORAGE=$(du -sh ~/NumBox/container/$CONTAINER_NAME)
  echo 容器名：$CONTAINER_NAME
  echo 容器占用空间：$STORAGE
  echo 当前wine版本包：$Winever
  echo 当前图形驱动：$Gpu
  echo 当前32位DX图形渲染环境：$D3D32
  echo 当前64位DX图形渲染环境：$D3D64
  read -s -n1 -p "输入任意字符返回" && bash ~/NumBox/Set-container2.sh
  ;;
  1) DRECTX=$(dialog --no-shadow --backtitle "$CONTAINER_NAME" --title "选择一个DrectX图形环境" --menu "选择cnc后或者vkd3d，其余的dx版本由上一次的选择的版本补全" $L $W $H \
  1 "wined3d(32&64,DX1~11)(GL)" \
  2 "cnc-ddraw(仅32,DX9,2D)(GL)" \
  3 "dxvk(32&64,DX8~11)(VK)" \
  4 "vkd3d(32&64,DX12)(VK)" \
  5 "🔙返回菜单" 2>&1 >/dev/tty)
  case $DRECTX in
    1) bash ~/NumBox/Wined3d-select.sh ;;
    2) bash ~/NumBox/Cnc-select.sh ;;
    3) bash ~/NumBox/Dxvk-select.sh ;;
    4) bash ~/NumBox/Vkd3d-select.sh ;;
    5) bash ~/NumBox/Set-container2.sh ;;
  esac ;;
  2) bash ~/NumBox/Drive-select.sh ;;
  3) bash ~/NumBox/Container-setting.sh ;;
  4) DEFAULT_SET=$(dialog --title "默认启动容器设置" --menu "选择一个选项" $L $W $H \
    0 "🔙返回" \
    1 "将此容器设置为默认启动容器" \
    2 "清空默认启动容器设置" 2>&1 >/dev/tty)
  case $DEFAULT_SET in
    0) bash ~/NumBox/Set-container2.sh ;;
    1) echo "$CONTAINER_NAME" > ~/NumBox/default_startup_container && bash ~/NumBox/Set-container2.sh ;;
    2) echo "" >~/NumBox/default_startup_container && bash ~/NumBox/Set-container2.sh ;;
    esac ;;
  5) bash ~/NumBox/Disk-linkset.sh ;;
  6) bash ~/NumBox/Package-container.sh ;;
  7) RENAME=$(dialog --title "重命名 $CONTAINER_NAME 容器" --inputbox "点击cancel取消" $L $W $H 2>&1 >/dev/tty)
  if [[ -z $RENAME ]]; then
    dialog --title "错误" --msgbox "名称为空！" $L $W && bash ~/NumBox/Set-container2.sh
  else
    if [[ -d "~/NumBox/container/$RENAME" ]]; then
      dialog --title "错误" --msgbox "$RENAME 容器已存在,请重新命名!" $L $W && bash ~/NumBox/Set-container2.sh
    else
      mv ~/NumBox/container/$CONTAINER_NAME ~/NumBox/container/$RENAME && mv /sdcard/NumBox/container/$CONTAINER_NAME /sdcard/NumBox/container/$RENAME && echo "$RENAME" > $TMPDIR/container_name.txt && bash ~/NumBox/Set-container2.sh
    fi
  fi ;;
  8) source /sdcard/NumBox/container/$CONTAINER_NAME/box64.conf
  BOX64_SET=$(dialog --title "BOX64预设" --memu "选择一个预设或者编辑预设" $L $W $H \
    值 "$BOX64_CONF_NAME" \
    1 "稳定" \
    2 "兼容" \
    3 "快速" \
    4 "性能" \
    5 "编辑预设" 2>&1 >/dev/tty)
  case $BOX64_SET in
    1) cp ~/NumBox/box64/stable.conf /sdcard/NumBox/container/$CONTAINER_NAME/box64cf.conf
    bash ~/NumBox/Set-container2.sh ;;
    2) cp ~/NumBox/box64/compatible.conf /sdcard/NumBox/container/$CONTAINER_NAME/box64cf.conf
    bash ~/NumBox/Set-container2.sh ;;
    3) cp ~/NumBox/box64/speed.conf /sdcard/NumBox/container/$CONTAINER_NAME/box64cf.conf
    bash ~/NumBox/Set-container2.sh ;;
    4) cp ~/NumBox/box64/performance.conf /sdcard/NumBox/container/$CONTAINER_NAME/box64cf.conf
    bash ~/NumBox/Set-container2.sh ;;
    5) termux-open --content-type /sdcard/NumBox/container/$CONTAINER_NAME/box64cf.conf
    bash ~/NumBox/Set-container2.sh ;;
  esac ;;
esac