#!/bin/bash
read L W H < ~/NumBox/custom-size
mkdir -p $TMPDIR/temp_xf
CONTAINER_NAME=$(cat $TMPDIR/container_name.txt)
X86_UNPACKAGE () {
clear
UNPACKAGE_CMD
dialog --title "( ˘▽˘)っ♨" --msgbox "安装完成" $L $W 2>&1 >/dev/tty && bash ~/NumBox/Set-container2.sh
}
CNC_DDRAW=$(dialog --backtitle "$CONTAINER_NAME" --title "选择一个cnc-ddraw版本" --menu "仅支持DX9,2D" $L $W $H \
  1 "cnc-ddraw 7.0(仅32位)" \
  2 "cnc-ddraw 7.1(仅32位)" \
  3 "🔙返回" 2>&1 >/dev/tty)
case $CNC_DDRAW in
  1) UNPACKAGE_CMD () {
  unzip ~/NumBox/resource/cncddraw/cnc-ddraw7.0.zip -d $TMPDIR/temp_xf/ && cd $TMPDIR/temp_xf/ && cp *.dll ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/windows/syswow64/ && mkdir -p ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/ProgramData/cnc-ddraw && cp -r Shaders/ ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/ProgramData/cnc-ddraw/ && cp ddraw.ini ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/ProgramData/cnc-ddraw/
    echo "32:cnc-ddraw7.0" > /sdcard/NumBox/container/$CONTAINER_NAME/D3D32_VERSION
    rm -rf $TMPDIR/temp_xf/*
  }
  X86_UNPACKAGE ;;
  2) UNPACKAGE_CMD () {
  unzip ~/NumBox/resource/cncddraw/cnc-ddraw7.1.zip -d $TMPDIR/temp_xf/ && cd $TMPDIR/temp_xf/ && cp *.dll ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/windows/syswow64/ && mkdir -p ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/ProgramData/cnc-ddraw && cp -r Shaders/ ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/ProgramData/cnc-ddraw/ && cp ddraw.ini ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/ProgramData/cnc-ddraw/
    echo "32:cnc-ddraw7.1" > /sdcard/NumBox/container/$CONTAINER_NAME/D3D32_VERSION
    rm -rf $TMPDIR/temp_xf/*
  }
  X86_UNPACKAGE ;;
  3) bash ~/NumBox/Set-container2.sh ;;
esac