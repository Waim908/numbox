#!/bin/bash
read L W H < ~/NumBox/custom-size
mkdir -p $TMPDIR/temp_xf
CONTAINER_NAME=$(cat $TMPDIR/container_name.txt)
X86_64_UNPACKAGE_1 () {
clear
tar xf ~/NumBox/resource/dxvk/dxvk/$VERSION.tar.gz -C $TMPDIR/temp_xf/ && cd $TMPDIR/temp_xf/*/ && cp x32/*.dll ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/windows/syswow64 && cp x64/*.dll ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/windows/system32
cd ~
echo "64:$VERSION" > /sdcard/NumBox/container/$CONTAINER_NAME/D3D64_VERSION
echo "32:$VERSION" > /sdcard/NumBox/container/$CONTAINER_NAME/D3D32_VERSION
rm -rf $TMPDIR/temp_xf/*
dialog --title "( ˘▽˘)っ♨" --msgbox "安装完成" $L $W 2>&1 >/dev/tty && bash ~/NumBox/Set-container2.sh
}
X86_64_UNPACKAGE_2 () {
clear
tar xf ~/NumBox/resource/dxvk/gplasync/$VERSION.tar.gz -C $TMPDIR/temp_xf/ && cd $TMPDIR/temp_xf/*/ && cp x32/*.dll ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/windows/syswow64 && cp x64/*.dll ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/windows/system32
cd ~
echo "64:$VERSION" > /sdcard/NumBox/container/$CONTAINER_NAME/D3D64_VERSION
echo "32:$VERSION" > /sdcard/NumBox/container/$CONTAINER_NAME/D3D32_VERSION
rm -rf $TMPDIR/temp_xf/*
dialog --title "( ˘▽˘)っ♨" --msgbox "安装完成" $L $W 2>&1 >/dev/tty && bash ~/NumBox/Set-container2.sh
bash ~/NumBox/Set-container.sh
}
X86_64_UNPACKAGE_3 () {
clear
tar xf ~/NumBox/resource/dxvk/async/$VERSION.tar.gz -C $TMPDIR/temp_xf/ && cd $TMPDIR/temp_xf/*/ && cp x32/*.dll ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/windows/syswow64 && cp x64/*.dll ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/windows/system32
cd ~
echo "64:$VERSION" > /sdcard/NumBox/container/$CONTAINER_NAME/D3D64_VERSION
echo "32:$VERSION" > /sdcard/NumBox/container/$CONTAINER_NAME/D3D32_VERSION
rm -rf $TMPDIR/temp_xf/*
dialog --title "( ˘▽˘)っ♨" --msgbox "安装完成" $L $W 2>&1 >/dev/tty && bash ~/NumBox/Set-container2.sh
bash ~/NumBox/Set-container.sh
}
X86_64_UNPACKAGE_DXVK () {
clear
tar xf $dxvk_path/$FILE_NAME -C $TMPDIR/temp_xf/ && cd $TMPDIR/temp_xf/*/ && cp x32/*.dll ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/windows/syswow64 && cp x64/*.dll ~/NumBox/container/$CONTAINER_NAME/disk/drive_c/windows/system32
cd ~
echo "64:$FILE_NAME" > /sdcard/NumBox/container/$CONTAINER_NAME/D3D64_VERSION
echo "32:$FILE_NAME" > /sdcard/NumBox/container/$CONTAINER_NAME/D3D32_VERSION
rm -rf $TMPDIR/temp_xf/*
dialog --title "( ˘▽˘)っ♨" --msgbox "安装完成" $L $W 2>&1 >/dev/tty && bash ~/NumBox/Set-container2.sh
bash ~/NumBox/Set-container.sh
}
DXVK=$(dialog --backtitle "$CONTAINER_NAME" --title "选择一个dxvk版本" --menu "支持DX8~11" $L $W 8 \
  0 "🔙返回" \
  import "导入/sdcard/NumBox/resource/" \
  latest "2.5.3" \
  latest-g "gplasync2.5.3-1" \
  1 "2.5.2" \
  2 "gplasync2.5.2-1" \
  3 "2.5.1" \
  4 "gplasync2.5.1-1" \
  5 "2.4.1" \
  6 "gplasync2.4.1-1" \
  7 "2.3.1" \
  8 "2.2" \
  9 "2.1" \
  10 "2.0" \
  11 "2.0" \
  12 "1.10.3" \
  13 "async1.10.3" \
  14 "1.9.4" \
  15 "1.7.3" \
  16 "0.72" 2>&1 >/dev/tty)
case $DXVK in
  0) bash ~/NumBox/Container-setting.sh ;;
  import) clear
  IMPORT_MENU=$(dialog --title "选择一个要导入的类型" --menu "" $L $W $H \
  dxvk "/sdcard/NumBox/resource/dxvk" \
  dxvk-gplasync "/sdcard/NumBox/resource/dxvk-gplasync" 2>&1 >/dev/tty)
  case $IMPORT_MENU in
    dxvk) dxvk_path=/sdcard/NumBox/resource/dxvk ;;
    dxvk-gplasync) dxvk_path=/sdcard/NumBox/resource/dxvk-gplasync ;;
  esac
  ls -1a $dxvk_path
  read -p "复制一个文件名,然后粘贴到此处,为空则返回: " FILE_NAME
  if [[ -z $FILE_NAME ]]; then
    bash ~/NumBox/Dxvk-select.sh
  else
    if [[ -f $dxvk_path/$FILE_NAME ]]; then
      X86_64_UNPACKAGE_DXVK
    else
      dialog --title "w(ﾟДﾟ)w" --msgbox "$dxvk_path/$FILE_NAME文件不存在！" $L $W && bash ~/NumBox/Dxvk-select.sh
    fi
  fi ;;
  latest) VERSION=dxvk-2.5.3
  X86_64_UNPACKAGE_1 ;;
  latest-g) VERSION=dxvk-gplasync-v2.5.3-1
  X86_64_UNPACKAGE_2 ;;
  1) VERSION=dxvk-2.5.2
  X86_64_UNPACKAGE_1 ;;
  2) VERSION=dxvk-gplasync-v2.5.2-1
  X86_64_UNPACKAGE_2 ;;
  3) VERSION=dxvk-2.5.1
  X86_64_UNPACKAGE_1 ;;
  4) VERSION=dxvk-gplasync-v2.4.1-1
  X86_64_UNPACKAGE_2 ;;
  5) VERSION=dxvk-2.4.1
  X86_64_UNPACKAGE_1 ;;
  6) VERSION=dxvk-gplasync-v2.5-1
  X86_64_UNPACKAGE_2 ;;
  7) VERSION=dxvk-2.3.1
  X86_64_UNPACKAGE_1 ;;
  8) VERSION=dxvk-2.2
  X86_64_UNPACKAGE_1 ;;
  9) VERSION=dxvk-2.1
  X86_64_UNPACKAGE_1 ;;
  10) VERSION=dxvk-2.0
  X86_64_UNPACKAGE_1 ;;
  11) VERSION=dxvk-async-2.0
  X86_64_UNPACKAGE_3 ;;
  12) VERSION=dxvk-1.10.3
  X86_64_UNPACKAGE_1 ;;
  13) VERSION=dxvk-async-1.10.3
  X86_64_UNPACKAGE_3 ;;
  14) VERSION=dxvk-1.9.4
  X86_64_UNPACKAGE_1 ;;
  15) VERSION=dxvk-1.7.3
  X86_64_UNPACKAGE_1 ;;
  16) VERSION=dxvk-0.72
  X86_64_UNPACKAGE_1 ;;
esac