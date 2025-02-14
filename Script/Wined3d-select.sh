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
WINED3D=$(dialog --backtitle "$CONTAINER_NAME" --title "选择一个wined3d版本" --menu "支持D3D范围1~11" $L $W $H \
    0 "内建D3D" \
    1 "8.15" \
    2 "9.10" \
    3 "9.22" \
    4 "3.21" \
    5 "4.21" \
    6 "🔙返回" 2>&1 >/dev/tty)
case $WINED3D in
      0) clear
      cd ~/NumBox/container/$CONTAINER_NAME/wine/lib/wine/i386-windows/ && cp d3d11.dll dxgi.dll d3d10.dll d3d8.dll wined3d.dll d3d10_1.dll d3d9.dll d3d10core.dll ddraw.dll ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/windows/syswow64/ && cd ~/NumBox/container/$CONTAINER_NAME/wine/lib/wine/x86_64-windows/ && cp d3d11.dll dxgi.dll d3d10.dll d3d8.dll wined3d.dll d3d10_1.dll d3d9.dll d3d10core.dll ddraw.dll ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/windows/system32/
      echo "64:wined3d" > /sdcard/NumBox/container/$CONTAINER_NAME/D3D64_VERSION
      echo "32:wined3d" > /sdcard/NumBox/container/$CONTAINER_NAME/D3D32_VERSION
      X86_64_UNPACKAGE ;;
      1) UNPACKAGE_CMD () {
      tar xf ~/NumBox/resource/wined3d/wined3d8.15.tar.xz -C $TMPDIR/temp_xf/ && cd $TMPDIR/temp_xf/*/ && cp x32/*.dll ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/windows/syswow64 && cp x64/*.dll ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/windows/system32
      echo "64:wined3d8.15" > /sdcard/NumBox/container/$CONTAINER_NAME/D3D64_VERSION
      echo "32:wined3d8.15" > /sdcard/NumBox/container/$CONTAINER_NAME/D3D32_VERSION
      rm -rf $TMPDIR/temp_xf/*
      }
      X86_64_UNPACKAGE ;;
      2) UNPACKAGE_CMD () {
      tar xf ~/NumBox/resource/wined3d/wined3d9.10.tar.xz -C $TMPDIR/temp_xf/ && cd $TMPDIR/temp_xf/*/ && cp x32/*.dll ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/windows/syswow64 && cp x64/*.dll ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/windows/system32
      echo "64:wined3d9.10" > /sdcard/NumBox/container/$CONTAINER_NAME/D3D64_VERSION
      echo "32:wined3d9.10" > /sdcard/NumBox/container/$CONTAINER_NAME/D3D32_VERSION
      rm -rf $TMPDIR/temp_xf/*
      } 
      X86_64_UNPACKAGE ;;
      3) UNPACKAGE_CMD () {
      tar xf ~/NumBox/resource/wined3d/wined3d9.22.tar.xz -C $TMPDIR/temp_xf/ && cd $TMPDIR/temp_xf/*/ && cp x32/*.dll ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/windows/syswow64 && cp x64/*.dll ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/windows/system32
      echo "64:wined3d9.22" > /sdcard/NumBox/container/$CONTAINER_NAME/D3D64_VERSION
      echo "32:wined3d9.22" > /sdcard/NumBox/container/$CONTAINER_NAME/D3D32_VERSION
      rm -rf $TMPDIR/temp_xf/*
      }
      X86_64_UNPACKAGE ;;
      4) UNPACKAGE_CMD () {
      tar xf ~/NumBox/resource/wined3d/wined3d3.21.tar.xz -C $TMPDIR/temp_xf/ && cd $TMPDIR/temp_xf/*/ && cp x32/*.dll ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/windows/syswow64 && cp x64/*.dll ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/windows/system32
      echo "64:wined3d3.21" > /sdcard/NumBox/container/$CONTAINER_NAME/D3D64_VERSION
      echo "32:wined3d3.21" > /sdcard/NumBox/container/$CONTAINER_NAME/D3D32_VERSION
      rm -rf $TMPDIR/temp_xf/*
      }
      X86_64_UNPACKAGE ;;
      5) UNPACKAGE_CMD () {
      tar xf ~/NumBox/resource/wined3d/wined3d4.21.tar.xz -C $TMPDIR/temp_xf/ && cd $TMPDIR/temp_xf/*/ && cp x32/*.dll ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/windows/syswow64 && cp x64/*.dll ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/windows/system32
      echo "64:wined3d4.21" > /sdcard/NumBox/container/$CONTAINER_NAME/D3D64_VERSION
      echo "32:wined3d4.21" > /sdcard/NumBox/container/$CONTAINER_NAME/D3D32_VERSION
      rm -rf $TMPDIR/temp_xf/* 
      }
      X86_64_UNPACKAGE ;;
      6) bash ~/NumBox/Container-setting.sh ;;
esac