#!/bin/bash
read L W H < ~/NumBox/custom-size
source /sdcard/NumBox/debug.conf
DEBUG_SET=$(dialog --title "调试设置" --menu "选择一个选项" $L $W $H \
    back "🔙返回" \
    日志状态 "$write_logfile" \
    on "记录日志" \
    off "不记录日志" \
    1 "wine调试设置" \
    值 "$WINEDEBUG" \
    2 "box64日志等级" \
    值 "$BOX64_LOG" \
    3 "DXVK日志等级" \
    值 "$DXVK_LOG_LEVEL" \
    edit "编辑配置文件" \
    doc "查看帮助" 2>&1 >/dev/tty)
  case $DEBUG_SET in
    值) bash ~/NumBox/Debug-set.sh ;;
    back) bash ~/NumBox/Numbox ;;
    statu) bash ~/NumBox/Debug-set.sh ;;
    on) sed -i "s%write_logfile=.*%write_logfile=on%g" /sdcard/NumBox/debug.conf && bash ~/NumBox/Debug-set.sh ;;
    off) sed -i "s%write_logfile=.*%write_logfile=off%g" /sdcard/NumBox/debug.conf && bash ~/NumBox/Debug-set.sh ;;
    1) wine_set=$(dialog --title "wine调试设置" --menu "选择一个选项" $L $W $H \
      back "🔙返回" \
      0 "(-all)关闭" \
      1 "(warn,err,fixme)预设1,参考winlator" \
      2 "(warn,err,fixme,loaddll)预设2,显示dll动态链接库调用" 2>&1 >/dev/tty)
    case $wine_set in
        back) bash ~/NumBox/Debug-set.sh ;;
        0) sed -i "s%WINEDEBUG=.*%WINEDEBUG=-all%g" /sdcard/NumBox/debug.conf && bash ~/NumBox/Debug-set.sh ;;
        1) sed -i "s%WINEDEBUG=.*%WINEDEBUG=+warn,+err,+fixme%g" /sdcard/NumBox/debug.conf && bash ~/NumBox/Debug-set.sh ;;
        2) sed -i "s%WINEDEBUG=.*%WINEDEBUG=+warn,+err,+fixme,+loaddll%g" /sdcard/NumBox/debug.conf && bash ~/NumBox/Debug-set.sh ;;
    esac ;;
    2) box64_set=$(dialog --title "box64调试设置" --menu "选择一个选项" $L $W $H \
      back "🔙返回" \
      0 "关闭" \
      1 "信息" \
      2 "详细" \
      3 "全部" 2>&1 >/dev/tty)
    case $box64_set in
      back) bash ~/NumBox/Debug-set.sh ;;
      0) sed -i "s%BOX64_DEBUG=.*%BOX64_DEBUG=0%g" /sdcard/NumBox/debug.conf && bash ~/NumBox/Debug-set.sh ;;
      1) sed -i "s%BOX64_DEBUG=.*%BOX64_DEBUG=1%g" /sdcard/NumBox/debug.conf && bash ~/NumBox/Debug-set.sh ;;
      2) sed -i "s%BOX64_DEBUG=.*%BOX64_DEBUG=2%g" /sdcard/NumBox/debug.conf && bash ~/NumBox/Debug-set.sh ;;
      3) sed -i "s%BOX64_DEBUG=.*%BOX64_DEBUG=3%g" /sdcard/NumBox/debug.conf && bash ~/NumBox/Debug-set.sh ;;
    esac ;;
    3) dxvk_set=$(dialog --title "DXVK日志等级" --menu "选择一个选项" $L $W $H \
      back "🔙返回" \
      0 "none(不显示)" \
      1 "error" \
      2 "warn" \
      3 "info" \
      4 "debug" 2>&1 >/dev/tty)
    case $dxvk_set in
      0) sed -i "s%DXVK_LOG_LEVEL=.*%DXVK_LOG_LEVEL=none%g" /sdcard/NumBox/debug.conf && bash ~/NumBox/Debug-set.sh ;;
      1) sed -i "s%DXVK_LOG_LEVEL=.*%DXVK_LOG_LEVEL=error%g" /sdcard/NumBox/debug.conf && bash ~/NumBox/Debug-set.sh ;;
      2) sed -i "s%DXVK_LOG_LEVEL=.*%DXVK_LOG_LEVEL=warn%g" /sdcard/NumBox/debug.conf && bash ~/NumBox/Debug-set.sh ;;
      3) sed -i "s%DXVK_LOG_LEVEL=.*%DXVK_LOG_LEVEL=info%g" /sdcard/NumBox/debug.conf && bash ~/NumBox/Debug-set.sh ;;
      4) sed -i "s%DXVK_LOG_LEVEL=.*%DXVK_LOG_LEVEL=debug%g" /sdcard/NumBox/debug.conf && bash ~/NumBox/Debug-set.sh ;;
    esac ;;
    edit) clear
    termux-open --content-type text /sdcard/NumBox/debug.conf
    bash ~/NumBox/Debug-set.sh ;;
    edit) nano $TMPDIR/debug_statu && bash ~/NumBox/Numbox ;;
    doc) clear
    cat ~/NumBox/doc/debug.txt
    read -s -n1 -p "输入任意字符返回" && bash ~/NumBox/Debug-set.sh ;;
esac