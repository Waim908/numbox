#!/bin/bash
read L W H < ~/NumBox/custom-size
CONTAINER_NAME=$(cat $TMPDIR/container_name.txt)
unset LD_PRELOAD
export PATH=/data/data/com.termux/files/usr/glibc/bin:$PATH
source /sdcard/NumBox/container/$CONTAINER_NAME/default.conf
locale_file=/data/data/com.termux/files/usr/glibc/etc/locale.gen
sed_lang () {
  clear
  echo "安装完成后输入任意字符返回"
  sed -i "s/^#$lang_encoding/$lang_encoding/g" $PREFIX/glibc/etc/locale.gen
  sed -i "s%LC_ALL=.*%LC_ALL=$lang_encoding%g" /sdcard/NumBox/container/$CONTAINER_NAME/default.conf
  locale-gen 
  read -s -n1
  bash ~/NumBox/Env-config.sh
}
auto_sed () {
  clear
  sed -i "s%$env_name=.*%$env_name=\"$env_value\"%g" /sdcard/NumBox/container/$CONTAINER_NAME/default.conf
  bash ~/NumBox/Env-config.sh
}
LANG_1="$LC_ALL"
GL_1="$MESA_GL_VERSION_OVERRIDE"
PULSE_1="$PULSE_LATENCY_MSEC"
WSI_1="$MESA_VK_WSI_DEBUG"
DXVK_1="$DXVK_HUD"
DXVK_FPS_1="$DXVK_FRAME_RATE"
VKD3D_FPS_1="$VKD3D_FRAME_RATE"
VKD3D_LV="$VKD3D_FEATURE_LEVEL"
TZ_1="$TZ"
ENV_SELECT=$(dialog --no-shadow --title "$CONTAINER_NAME 的变量"  --menu "删除此菜单变量可能会导致报错" $L $W $H \
  0 "🔙返回" \
  1 "语言与编码(LC_ALL)" \
  值 "$LANG_1" \
  2 "GL版本号(MESA_GL_VERSION_OVERRIDE)" \
  值 "$GL_1" \
  3 "pulse音频延迟(PULSE_LATENCY_MSEC)" \
  值 "$PULSE_1" \
  4 "垂直同步(MESA_VK_WSI_DEBUG)" \
  值 "$WSI_1" \
  5 "Dxvk显示(DXVK_HUD)" \
  值 "$DXVK_1" \
  6 "Dxvk帧率限制(DXVK_FRAME_RATE)" \
  值 "$DXVK_FPS_1" \
  7 "Vkd3d帧率限制(VKD3D_FRAME_RATE)" \
  值 "$VKD3D_FPS_1" \
  8 "Vkd3d特性等级(VKD3D_FEATURE_LEVEL)" \
  值 "$VKD3D_LV" \
  9 "时区设置(TZ)" \
  值 "$TZ_1" \
  debug "调试变量配置信息" \
  edit "使用外部编辑器编辑变量配置" 2>&1 >/dev/tty)
case $ENV_SELECT in
  0) bash ~/NumBox/Set-container2.sh ;;
  值) bash ~/NumBox/Env-config.sh ;;
  1) LANG_SET=$(dialog --backtitle "选择后自动安装" --title "语言编码" --menu "选择预设或者自定义" $L $W $H \
    0 "🔙返回" \
    1 "中文UTF-8" \
    2 "日语UTF-8" \
    3 "英语UTF-8" \
    4 "自定义" \
    5 "查看编码配置(locale.gen)" \
    6 "还原locale.gen配置文件" 2>&1 >/dev/tty)
    case $LANG_SET in
      0) bash ~/NumBox/Set-container2.sh ;;
      1) lang_encoding="zh_CN.UTF-8"
      sed_lang ;;
      2) lang_encoding="ja_JP.UTF-8"
      sed_lang ;;
      3) lang_encoding="en_US.UTF-8"
      sed_lang ;;
      4) lang_encoding=$(dialog --title "输入一个语言编码，格式语言缩写_国家缩写.编码" --inputbox "请确保你输入的值正确" $L $W $H 2>&1 >/dev/tty)
      if [ ! -n "$lang_encoding" ]; then
        dialog --title "错误Σ(っ °Д °;)っ" --msgbox "不能为空哦！" $L $W
        bash ~/NumBox/Env-config.sh
      else
        sed_cmd
      fi ;;
      5) clear
      cat -n $PREFIX/glibc/etc/locale.gen
      echo "去掉#号就是已安装的编码"
      read -s -n1 -p "输入任意字符返回" && bash ~/NumBox/Env-config.sh ;;
      6) cp ~/NumBox/bak/locale.gen $PREFIX/glibc/etc/ && dialog --title "locale.gen" --msgbox "还原完成并返回" $L $W 2>&1 >/dev/tty && bash ~/NumBox/Env-config.sh ;;
    esac ;;
  2) env_name=MESA_GL_VERSION_OVERRIDE
  GL_VER=$(dialog --title "GL版本" --menu "通过修改GL版本返回值可以提高兼容性，以下为预设" $L $W $H \
    0 "🔙返回" \
    1 "4.6COMPACT(推荐)" \
    2 "3.3" \
    3 "3.1COMPAT" \
    4 "2.1" \
    5 "自定义" \
    doc "查看帮助" 2>&1 >/dev/tty)
    case $GL_VER in
      0) bash ~/NumBox/Env-config.sh ;;
      1) env_value="4.6COMPAT"
      auto_sed ;;
      2) env_value="3.3"
      auto_sed ;;
      3) env_value="3.1COMPAT"
      auto_sed ;;
      4) env_value="2.1"
      auto_sed ;;
      5) env_value=$(dialog --title "自定义GL版本" --inputbox "输入GL的版本号" $L $W $H 2>&1 >/dev/tty)
      if [ ! -n "$env_value" ]; then
        dialog --title "错误Σ(っ °Д °;)っ" --msgbox "不能为空哦！" $L $W
        bash ~/NumBox/Env-config.sh
      else
        auto_sed
      fi ;;
      doc) clear
      cat ~/NumBox/doc/gl_ver.txt
      echo "输入任意字符返回"
      read -s -n1 && bash ~/NumBox/Env-config.sh ;;
     esac ;;
  3) env_name=PULSE_LATENCY_MSEC
  PULSELA=$(dialog --title "pulse audio音频延迟" --menu "适当的值可以解决音频卡顿的问题，过大或者过小可能影响耗电" $L $W $H \
    0 "🔙返回" \
    1 "30" \
    2 "40(推荐)" \
    3 "50" \
    4 "60(推荐)" \
    5 "自定义" 2>&1 >/dev/tty)
    case $PULSELA in
      0) bash ~/NumBox/Env-config.sh ;;
      1) env_value=30
      auto_sed ;;
      2) env_value=40
      auto_sed ;;
      3) env_value=50
      auto_sed ;;
      4) env_value=60
      auto_sed ;;
      5) env_value=$(dialog --title "自定义pulse音频延迟" --inputbox "不推荐直接修改为0" $L $W $H 2>&1 >/dev/tty)
      if [ ! -n "$env_value" ]; then
        dialog --title "错误Σ(っ °Д °;)っ" --msgbox "不能为空哦！" $L $W
        bash ~/NumBox/Env-config.sh
      else
        auto_sed
      fi ;;
    esac ;;
  4) env_name=MESA_VK_WSI_DEBUG
  WSI_D=$(dialog --title "垂直同步" --menu "启用此选项防止画面条纹撕裂，但影响性能" $L $W $L \
    0 "🔙返回" \
    1 "禁用" \
    2 "启用" 2>&1 >/dev/tty)
    case $WSI_D in
      0) bash ~/NumBox/Env-config.sh ;;
      1) env_value="(sw"
      auto_sed ;;
      2) env_value="sw"
      auto_sed ;;
    esac ;;
  5) env_name=DXVK_HUD
  DXVK_H=$(dialog --title "DXVK HUD" --menu "在屏幕上显示一些数据,从下方选择预设或者自定义" $L $W $H \
    0 "🔙返回" \
    1 "不显示" \
    2 "只显示fps" \
    3 "fps与dx版本与版本号" \
    4 "dx版本与版本号与开发信息" \
    5 "fps,gpu使用率,内存占用,帧率表" \
    6 "自定义" \
    doc "关于DXVK_HUD" 2>&1 >/dev/tty)
    case $DXVK_H in
    0) bash ~/NumBox/Env-config.sh ;;
    1) env_value=""
    auto_sed ;;
    2) env_value="fps"
    auto_sed ;;
    3) env_value="fps,api,version"
    auto_sed ;;
    4) env_value="api,version,devinfo"
    auto_sed ;;
    5) env_value="fps,gpuload,memory,frametimes,scale=0.8,opacity=0.8"
    auto_sed ;;
    6) env_value=$(dialog --title "自定义HUD" --inputbox "输入参数,用英文逗号隔开" $L $W $H 2>&1 >/dev/tty)
    auto_sed ;;
    doc) clear
    cat ~/NumBox/doc/dxvk_hub.txt
    echo "输入任意字符返回"
    read -s -n1 && bash ~/NumBox/Env-config.sh ;;
  esac ;;
  6) env_name=DXVK_FRAME_RATE FPS_DXVK_SET=$(dialog --title "dxvk帧率限制" --menu "通过限制此值可以有效减小负载增加稳定性" $L $W $H \
  0 "🔙返回" \
  1 "不限制" \
  2 "15" \
  3 "30" \
  4 "45" \
  5 "60" \
  6 "75" \
  7 "90" \
  8 "120" \
  9 "144" \
  10 "自定义" 2>&1 >/dev/tty)
  case $FPS_DXVK_SET in
    0) bash ~/NumBox/Env-config.sh ;;
    1) env_value=0
    auto_sed ;;
    2) env_value=15
    auto_sed ;;
    3) env_value=30
    auto_sed ;;
    4) env_value=45
    auto_sed ;;
    5) env_value=60
    auto_sed ;;
    6) env_value=75
    auto_sed ;;
    7) env_value=90
    auto_sed ;;
    8) env_value=120
    auto_sed ;;
    9) env_value=144
    auto_sed ;;
    10) env_value=$(dialog --title "自定义帧数限制" --inputbox "输入数字" $L $W $H 2>&1 >/dev/tty)
    auto_sed ;;
  esac ;;
  7) env_name=VKD3D_FRAME_RATE FPS_VKD3D_SET=$(dialog --title "vkd3d帧率限制" --menu "通过限制此值可以有效减小负载增加稳定性" $L $W $H \
  0 "🔙返回" \
  1 "不限制" \
  2 "15" \
  3 "30" \
  4 "45" \
  5 "60" \
  6 "75" \
  7 "90" \
  8 "120" \
  9 "144" \
  10 "自定义" 2>&1 >/dev/tty)
  case $FPS_VKD3D_SET in
    0) bash ~/NumBox/Env-config.sh ;;
    1) env_value=0
    auto_sed ;;
    2) env_value=15
    auto_sed ;;
    3) env_value=30
    auto_sed ;;
    4) env_value=45
    auto_sed ;;
    5) env_value=60
    auto_sed ;;
    6) env_value=75
    auto_sed ;;
    7) env_value=90
    auto_sed ;;
    8) env_value=120
    auto_sed ;;
    9) env_value=144
    auto_sed ;;
    10) env_value=$(dialog --title "自定义帧数限制" --inputbox "输入数字" $L $W $H 2>&1 >/dev/tty)
    auto_sed ;;    
  esac ;;
  8) env_name=VKD3D_FEATURE_LEVEL
  VKD3D_SET=$(dialog --title "自定义VKD3D特性等级" --menu "选择一个预设" $L $W $H \
    0 "🔙返回" \
    1 "12_2" \
    2 "12_1" \
    3 "12_0" \
    4 "11_1" \
    5 "11_0" \
    6 "10_1" \
    7 "10_0" \
    8 "9_3" \
    9 "9_2" \
    10 "9_1" 2>&1 >/dev/tty)
  case $VKD3D_SET in
    0) bash ~/NumBox/Env-config.sh ;;
    1) env_value="12_2"
    auto_sed ;;
    2) env_value="12_1"
    auto_sed ;;
    3) env_value="12_0"
    auto_sed ;;
    4) env_value="11_1"
    auto_sed ;;
    5) env_value="11_0"
    auto_sed ;;
    6) env_value="10_1"
    auto_sed ;;
    7) env_value="10_0"
    auto_sed ;;
    8) env_value="9_3"
    auto_sed ;;
    9) env_value="9_2"
    auto_sed ;;
    10) env_value="9_1"
    auto_sed ;;
  esac ;;
  9) env_name=TZ
  TZ_SET=$(dialog --title "自定义时区设置" --menu "选择一个预设或者自定义" $L $W $H \
    0 "🔙返回" \
    1 "亚洲/上海(中国)" \
    2 "亚洲/东京(日本)" \
    3 "美洲/洛杉矶(美国)" \
    4 "大洋洲/南乔治亚" \
    5 "欧洲/伦敦(英国)" \
    6 "非洲/开罗(埃及)" \
    7 "自定义时区" 2>&1 >/dev/tty)
  case $TZ_SET in
    1) env_value="Asia/Shanghai"
    auto_sed ;;
    2) env_value="Asia/Tokyo"
    auto_sed ;;
    3) env_value="America/Los_Angeles"
    auto_sed ;;
    4) env_value="Atlantic/South_Georgia"
    auto_sed ;;
    5) env_value="Europe/London"
    auto_sed ;;
    6) env_value="Africa/Cairo"
    auto_sed ;;
    7) env_value=$(dialog --title "自定义时区" --inputbox "请输入TZ变量支持的分区格式")
    auto_sed ;;
  esac ;;
  debug)
    clear
    source /sdcard/NumBox/container/$CONTAINER_NAME/default.conf 2> /sdcard/NumBox/log/Env_debug.log
    echo "日志路径/sdcard/NumBox/log/Env_debug.log"
    echo "————————————————"
    cat "/sdcard/NumBox/log/Env_debug.log"
    echo -e "\n"
    echo "————————————————"
    echo "仅供参考，如果为空说明变量无语法错误"
    read -s -n1 -p "输入任意字符返回" && bash ~/NumBox/Env-config.sh ;;
  edit) termux-open --content-type text /sdcard/NumBox/container/$CONTAINER_NAME/default.conf && dialog --msgbox "保存后返回菜单" $L $W && bash ~/NumBox/Env-config.sh ;;
esac