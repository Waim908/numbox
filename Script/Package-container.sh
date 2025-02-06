#!/bin/bash
read L W H < ~/NumBox/custom-size
CONTAINER_NAME=$(cat $TMPDIR/container_name.txt)
rm -rf /sdcard/NumBox/IO_package/package.nbp
PACK_MENU=$(dialog --title "$CONTAINER_NAME" --menu "是否将当前容器打包？" $L $W $H \
  0 "🔙还是算了" \
  1 "没错" \
  doc "关于容器打包" 2>&1 >/dev/tty)
case $PACK_MENU in
  doc) clear
  cat ~/NumBox/doc/package.txt
  read -s -n1 -p "输入任意字符返回" && bash ~/NumBox/Set-container2.sh ;;
  0) bash ~/NumBox/Set-container2.sh ;;
  1) clear
#  rm -rf $TMPDIR/*.nbp
  mkdir -p $TMPDIR/NumBoxPackage/
  rm -rf $TMPDIR/NumBoxPackage/*
#  mkdir $TMPDIR/NumBoxPackage/wpf
  mkdir $TMPDIR/NumBoxPackage/config
  echo "cp -r ~/NumBox/container/$CONTAINER_NAME/ $TMPDIR/NumBoxPackage/" > $TMPDIR/cmd && echo "正在复制容器" && bash ~/NumBox/Load
    echo "注意：除c,h盘，其他挂载盘将删除或重置(不会删除对应路径的文件)"
    rm -rf $TMPDIR/NumBoxPackage/$CONTAINER_NAME/disk/d:
    rm -rf $TMPDIR/NumBoxPackage/$CONTAINER_NAME/disk/e:
    rm -rf $TMPDIR/NumBoxPackage/$CONTAINER_NAME/disk/f:
    rm -rf $TMPDIR/NumBoxPackage/$CONTAINER_NAME/disk/g:
    rm -rf $TMPDIR/NumBoxPackage/$CONTAINER_NAME/disk/i:
    echo "正在复制配置文件"
    cp -r /sdcard/NumBox/container/$CONTAINER_NAME/ $TMPDIR/NumBoxPackage/config/
    cd $TMPDIR/NumBoxPackage
    echo "tar -P -I pigz -cf /sdcard/NumBox/IO_package/package.nbp ." > $TMPDIR/cmd && echo "开始多线程打包" && bash ~/NumBox/Load && cd /sdcard/NumBox/IO_package && mv package.nbp $CONTAINER_NAME.nbp && echo "打包完成！路径在/sdcard/NumBox/IO_package/$CONTAINER_NAME.nbp"
    read -s -n1 -p "输入任意字符返回" && bash ~/NumBox/Set-container2.sh ;;
esac