#!/bin/bash
clear
read L W H < ~/NumBox/custom-size
rm -rf $TMPDIR/temp_xf
SO_NAME=$(cat ~/NumBox/vk_name)
sed_json () {
    sed -i "s%/data/data/com.winlator/files/imagefs/usr/lib/libvulkan_freedreno.so%/data/data/com.termux/files/usr/glibc/lib/libvulkan_freedreno.so%g" $TMPDIR/temp_xf/turnip/freedreno_icd.aarch64.json
}
source ~/NumBox/drive/virgl.conf
IS_VIRGL=$(cat ~/NumBox/virgl_so)
MAIN_MENU=$(dialog --title "驱动安装" --no-shadow --backtitle "NumBox版本更新后请重新选择" --menu "选择一个驱动类型" $L $W $H \
    0 "🔙返回" \
    import "从/sdcard/NumBox/resource/turnip导入wcp" \
    1 "Glibc-Turnip(默认)" \
    2 "Winlator-Glibc-Turnip(v25.0.0 r8)" \
    3 "设置为virgl服务器" \
    4 "设置为virgl-android服务器" \
    virgl服务器类型 "$virgl_server_type" \
    5 "使用来自glibc的virgl-zink动态链接库" \
    6 "使用来自winlator的virgl动态链接库" \
    virgl动态链接库类型 "$IS_VIRGL" \
    PS "WCP文件是winlator glibc的同款文件" 2>&1 >/dev/tty)
case $MAIN_MENU in
    PS) bash ~/NumBox/Drive-setup2.sh ;;
    virgl服务器类型) bash ~/NumBox/Drive-setup2.sh ;;
    0) bash ~/NumBox/Numbox ;;
    import) clear
    ls -1a /sdcard/NumBox/resource/turnip
    read -p "复制一个文件名,然后粘贴到此处,为空则返回: " FILE_NAME
    if [[ -z $FILE_NAME ]]; then
        bash ~/NumBox/Drive-setup2.sh
    else
        if [[ -f /sdcard/NumBox/resource/turnip/$FILE_NAME ]]; then
            mkdir -p $TMPDIR/temp_xf
            tar xvf /sdcard/NumBox/turnip/$FILE_NAME -C $TMPDIR/temp_xf
            cd $TMPDIR/temp_xf/turnip
#            cp *.so $PREFIX/glibc/lib && sed_json && cp *.json $PREFIX/glibc/share/vulkan/icd.d
#            cd $TMPDIR/temp_xf/zink && cp * $PREFIX/glibc/lib
            cp $TMPDIR/temp_xf/turnip/libvulkan_freedreno.so ~/NumBox/resource/drive/replace/lib/
            cp $TMPDIR/temp_xf/zink/* ~/NumBox/resource/drive/replace/lib/
            sed_json && $TMPDIR/temp_xf/turnip/freedreno_icd.aarch64.json ~/NumBox/resource/drive/replace/share/vulkan/icd.d/
            echo "$FILE_NAME" > ~/NumBox/vk_name
            dialog --msgbox "$FILE_NAME 安装完成！" $L $W && bash ~/NumBox/Drive-setup2.sh
        else
            dialog --title "w(ﾟДﾟ)w" --msgbox "/sdcard/NumBox/resource/turnip/$FILE_NAME文件不存在！" $L $W && bash ~/NumBox/Drive-setup2.sh
        fi
    fi ;;
    1) clear
    cp ~/NumBox/resource/drive/default/* ~/NumBox/resource/drive/replace/lib/
    cp ~/NumBox/resource/drive/json/* ~/NumBox/resource/drive/replace/share/vulkan/icd.d/
    echo "Glibc-Turnip" > ~/NumBox/vk_name
    dialog --msgbox "已替换为Glibc-Turnip" $L $W && bash ~/NumBox/Drive-setup2.sh ;;
    2) clear
    mkdir -p $TMPDIR/temp_xf
    tar xvf ~/NumBox/resource/drive/turnip-v25.0.0-R8.wcp -C $TMPDIR/temp_xf
#    cd $TMPDIR/temp_xf/turnip
    cp $TMPDIR/temp_xf/turnip/libvulkan_freedreno.so ~/NumBox/resource/drive/replace/lib/
    cp $TMPDIR/temp_xf/zink/* ~/NumBox/resource/drive/replace/lib/
    sed_json && $TMPDIR/temp_xf/turnip/freedreno_icd.aarch64.json ~/NumBox/resource/drive/replace/share/vulkan/icd.d/
    echo "Winlator-Glibc-Turnip(v25 r8)" > ~/NumBox/vk_name
    dialog --msgbox "已替换为Winlator-Glibc-Turnip(v25 r8)" $L $W && bash ~/NumBox/Drive-setup2.sh ;;
    3) sed -i "s%virgl_server_type=.*%virgl_server_type=virgl%g" ~/NumBox/drive/virgl.conf && bash ~/NumBox/Drive-setup2.sh ;;
    4) sed -i "s%virgl_server_type=.*%virgl_server_type=android%g" ~/NumBox/drive/virgl.conf && bash ~/NumBox/Drive-setup2.sh ;;
    5) echo "glibc-zink" > ~/NumBox/virgl_so
    bash ~/NumBox/Drive-setup2.sh ;;
    6) echo "winlator-virgl" > ~/NumBox/virgl_so
    bash ~/NumBox/Drive-setup2.sh ;;
esac