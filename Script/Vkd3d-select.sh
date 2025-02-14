#!/bin/bash
read L W H < ~/NumBox/custom-size
cd ~
mkdir -p $TMPDIR/temp_xf
CONTAINER_NAME=$(cat $TMPDIR/container_name.txt)
X86_64_UNPACKAGE () {
clear
UNPACKAGE_CMD
dialog --title "( ˘▽˘)っ♨" --msgbox "安装完成" $L $W 2>&1 >/dev/tty && bash ~/NumBox/Set-container2.sh
}
UNPACKAGE_CMD () {
    tar xf ~/NumBox/resource/vkd3d/$VERSION.tar.zst -C $TMPDIR/temp_xf && cd $TMPDIR/*/ && cp x86/*.dll ~/NumBox/container/$CONTAINER_NAME/disk/drive/drive_c/windows/syswow64 && cp x64/* ~/NumBox/$CONTAINER_NAME/drive_c/windows/system32
    echo "64:$VERSION" > /sdcard/NumBox/container/$CONTAINER_NAME/D3D64_VERSION
    echo "32:$VERSION" > /sdcard/NumBox/container/$CONTAINER_NAME/D3D32_VERSION
    rm -rf $TMPDIR/temp_xf/*
  }
VKD3D=$(dialog --backtitle "$CONTAINER_NAME" --title "选择一个vkd3d版本" --menu "仅支持DX12，高版本wine已集成vkd3d" $L $W $H \
  0 "🔙返回" \
  import "导入/sdcard/NumBox/resource/vkd3d" \
  lastest "vkd3d2.14.1" \
  1 "vkd3d2.14" \
  2 "vkd3d2.13" 2>&1 >/dev/tty)
case $VKD3D in
  0) bash ~/NumBox/Container-setting.sh ;;
  import) clear
  ls -1a /sdcaed/NumBox/resource/vkd3d
  read -p "复制一个文件名,然后粘贴到此处,为空则返回: " FILE_NAME
  if [[ -z $FILE_NAME ]]; then
    bash ~/NumBox/Cnc-select.sh
  else
    if [[ -f /sdcaed/NumBox/resource/vkd3d/$FILE_NAME ]]; then
        tar xf ~/NumBox/resource/vkd3d/$FILE_NAME -C $TMPDIR/temp_xf && cd $TMPDIR/*/ && cp x86/*.dll ~/NumBox/container/$CONTAINER_NAME/disk/drive/drive_c/windows/syswow64 && cp x64/* ~/NumBox/$CONTAINER_NAME/drive_c/windows/system32
        echo "64:$FILE_NAME" > /sdcard/NumBox/container/$CONTAINER_NAME/D3D64_VERSION
        echo "32:$FILE_NAME" > /sdcard/NumBox/container/$CONTAINER_NAME/D3D32_VERSION
        rm -rf $TMPDIR/temp_xf/*
    else
      dialog --title "w(ﾟДﾟ)w" --msgbox "/sdcaed/NumBox/resource/vkd3d/$FILE_NAME文件不存在！" $L $W && bash ~/NumBox/Cnc-select.sh
    fi
  fi ;;
  lastest) VERSION=vkd3d-proton-2.14.1
  UNPACKAGE_CMD 
  X86_64_UNPACKAGE ;;
  1) VERSION=vkd3d-proton-2.14
  UNPACKAGE_CMD
  X86_64_UNPACKAGE ;;
  2) VERSION=vkd3d-proton-2.13
  UNPACKAGE_CMD
  X86_64_UNPACKAGE ;;
esac