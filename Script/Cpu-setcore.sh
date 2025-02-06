#!/bin/bash
clear
read L W H < ~/NumBox/custom-size
CONTAINER_NAME=$(cat $TMPDIR/container_name.txt)
goback () {
  bash ~/NumBox/Cpu-setcore.sh
}
source /sdcard/NumBox/container/$CONTAINER_NAME/cpu_core.conf
CORE_MENU=$(dialog --no-shadow --title "$CONTAINER_NAME 的处理器核心设置" --menu "使应用程序使用不同的处理器核心" $L $W $H \
  0 "🔙返回" \
  1 "🍷Wine核心绑定" \
  2 "启用taskset核心绑定" \
  3 "禁用taskset核心绑定" \
  状态 "$USE_CPU_CORE_CONF" 2>&1 >/dev/tty)
case $CORE_MENU in
  状态) bash ~/NumBox/Cpu-setcore.sh ;;
  0) bash ~/NumBox/Set-container2.sh ;;
  1) sed -i "s%USE_CPU_CORE_CONF=.*%USE_CPU_CORE_CONF=false%g" cpu_core.conf
  CORE_SET=$(dialog --no-shadow --title "核心设置" --menu "cpu核心序号从0开始,故最后一个等于总数减一" $L $W $H \
    back "🔙返回" \
    1 "处理器核心总数" \
    值 "$CPU_CORE" \
    2 "需要使用的处理器核心序号" \
    值 "$USE_CORE" \
    doc "查看帮助" 2>&1 >/dev/tty)
  case $CORE_SET in
    back) goback ;;
    值) bash ~/NumBox/Cpu-setcore.sh ;;
    doc) clear
    cat ~/NumBox/doc/cpu_core.txt 
    read -n1 -s -p "输入任意字符返回" && bash ~/NumBox/Cpu-setcore.sh ;;
    1) INPUT_BOX=$(dialog --title "cpu核心总数" --inputbox "输入数字" $L $W $H 2>&1 >/dev/tty)
    sed -i "s%CPU_CORE=.*%CPU_CORE=\"$INPUT_BOX\"%g" /sdcard/NumBox/container/$CONTAINER_NAME/cpu_core.conf
    bash ~/NumBox/Cpu-setcore.sh ;;
    2) INPUT_BOX=$(dialog --title "设置需要使用的cpu核心" --inputbox "示例:0,1,3,4,7" $L $W $H 2>&1 >/dev/tty)
    sed -i "s%USE_CORE=.*%USE_CORE=\"$INPUT_BOX\"%g" /sdcard/NumBox/container/$CONTAINER_NAME/cpu_core.conf
    bash ~/NumBox/Cpu-setcore.sh ;;
  esac ;;
  2) sed -i "s%USE_CPU_CORE_CONF=.*%USE_CPU_CORE_CONF=true%g" /sdcard/NumBox/container/$CONTAINER_NAME/cpu_core.conf && bash ~/NumBox/Cpu-setcore.sh ;;
  3) sed -i "s%USE_CPU_CORE_CONF=.*%USE_CPU_CORE_CONF=false%g" /sdcard/NumBox/container/$CONTAINER_NAME/cpu_core.conf && bash ~/NumBox/Cpu-setcore.sh ;;
esac