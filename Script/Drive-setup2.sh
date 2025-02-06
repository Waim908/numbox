#!/bin/bash
clear
read L W H < ~/NumBox/custom-size
rm -rf $TMPDIR/temp_xf
SO_NAME=$(cat ~/NumBox/vk_name)
sed_json () {
    sed -i "s%/data/data/com.winlator/files/imagefs/usr/lib/libvulkan_freedreno.so%/data/data/com.termux/files/usr/glibc/lib/libvulkan_freedreno.so%g" $TMPDIR/temp_xf/turnip/freedreno_icd.aarch64.json
}
MAIN_MENU=$(dialog --title "驱动安装" --no-shadow --backtitle "NumBox版本更新后请重新选择" --menu "选择一个驱动类型" $L $W $H \
    0 "🔙返回" \
    1 "Glibc-Turnip(默认)" \
    2 "Winlator-Glibc-Turnip(v25 r8)" \
    3 "自定义WCP文件" \
    上次替换 "$SO_NAME" \
    PS "WCP文件是winlator glibc的同款文件" 2>&1 >/dev/tty)
case $MAIN_MENU in
    PS) bash ~/NumBox/Drive-setup2.sh ;;
    0) bash ~/NumBox/Numbox ;;
    1) clear
    cp ~/NumBox/resource/drive/default/* $PREFIX/glibc/lib
    cp ~/NumBox/resource/drive/json/* $PREFIX/glibc/share/vulkan/icd.d/
    echo "Glibc-Turnip" > ~/NumBox/vk_name
    dialog --msgbox "已替换为Glibc-Turnip" $L $W && bash ~/NumBox/Drive-setup2.sh ;;
    2) clear
    mkdir -p $TMPDIR/temp_xf
    tar xvf ~/NumBox/resource/drive/turnip-v25.0.0-R8.wcp -C $TMPDIR/temp_xf
    cd $TMPDIR/temp_xf/turnip
    cp *.so $PREFIX/glibc/lib && sed_json && cp *.json $PREFIX/glibc/share/vulkan/icd.d
    cd $TMPDIR/temp_xf/zink && cp * $PREFIX/glibc/lib
    echo "Winlator-Glibc-Turnip(v25 r8)" > ~/NumBox/vk_name
    dialog --msgbox "已替换为Winlator-Glibc-Turnip(v25 r8)" $L $W && bash ~/NumBox/Drive-setup2.sh ;;
    3) clear
    INPUT_WCP=$(dialog --title "输入WCP文件名" --inputbox "存放在/sdcard/NumBox/wcp下的文件,格式: xxx.wcp" $L $W $H 2>&1 >/dev/tty)
    if [[ -z $INPUT_WCP ]]; then
        dialog --title "错误" --msgbox "文件名为空！" $L $W && bash ~/NumBox/Drive-setup2.sh
    else
        if [[ ! -f /sdcard/NumBox/wcp/$INPUT_WCP ]]; then
            dialog --title "错误" --msgbox "文件不存在！" $L $W && bash ~/NumBox/Drive-setup2.sh
        else
            clear
            mkdir -p $TMPDIR/temp_xf
            tar xvf /sdcard/NumBox/wcp/$INPUT_WCP -C $TMPDIR/temp_xf
            cd $TMPDIR/temp_xf/turnip
            cp *.so $PREFIX/glibc/lib && sed_json && cp *.json $PREFIX/glibc/share/vulkan/icd.d
            cd $TMPDIR/temp_xf/zink && cp * $PREFIX/glibc/lib
            echo "$INPUT_WCP" > ~/NumBox/vk_name
            dialog --msgbox "$INPUT_WCP 安装完成！" $L $W && bash ~/NumBox/Drive-setup2.sh
        fi
    fi ;;
esac