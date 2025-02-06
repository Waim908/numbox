#!/bin/bash
clear
read L W H < ~/NumBox/custom-size
echo "在 /sdcard/NumBox/IO_package 路径可导入的nbp包文件名:"
ls /sdcard/NumBox/IO_package | sed 's/\.nbp//'
echo -e "\n"
read -p "输入要导入的nbp包（无需.nbp后缀，直接输入文件名,输入为空则返回主菜单）:" NBP_NAME
if [ -z "$NBP_NAME" ]; then
  bash ~/NumBox/Numbox
else
  if [ -f /sdcard/NumBox/IO_package/$NBP_NAME.nbp ]; then
    clear
    file_type=$(file -b /sdcard/NumBox/IO_package/$NBP_NAME.nbp | grep "gzip")
    # echo $header | grep -a "" >/dev/null
      if [[ ! -z $file_type ]]; then
          if [ -d ~/NumBox/container/$NBP_NAME ]; then
            dialog --title "错误" --msgbox "$NBP_NAME 容器已存在，请重命名或者删除容器" $L $W
            bash ~/NumBox/Numbox
          fi
          clear
          echo "正在多线程解包导入 $NBP_NAME.nbp"
          echo "tar -I pigz -xf /sdcard/NumBox/IO_package/$NBP_NAME.nbp -C ~/NumBox/container" > $TMPDIR/cmd && bash ~/NumBox/Load 
          cp -r ~/NumBox/container/config/$NBP_NAME/ /sdcard/NumBox/container/
          rm -rf ~/NumBox/container/config/
          cd ~/NumBox/container/$NBP_NAME/disk/dosdevices && ln -s /sdcard/ d:
          dialog --title "成功" --msgbox "首次启动完成引导，然后重启容器即可" $L $W
          bash ~/NumBox/Numbox
      else
          dialog --title "错误" --msgbox "$NBP_NAME.nbp 不是有效的包" $L $W && bash ~/NumBox/Import-container.sh
      fi
  else
    dialog --title "错误" --msgbox "文件不存在" $L $W
    bash ~/NumBox/Import-container.sh
  fi
fi
