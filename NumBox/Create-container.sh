#!/bin/bash
. ~/NumBox/utils/dialog.conf
count=$(ls ~/NumBox/container | wc -l)
ctr_name="新建容器$(($count+1))"
create_ctr () {
  . ~/NumBox/utils/boot
  . ~/NumBox/utils/load
  
}
input=$(dialog ${dialog_arg[@]} --title "输入新建容器名" --inputbox "点击取消可返回" $box_sz2 "$ctr_name" 2>&1 >/dev/tty)
if [[ -z $input ]]; then
  bash ~/NumBox/Numbox 
else
  . ~/NumBox/utils/illegal_str.sh "${input}"
  if [[ ! $str_is == good ]]; then
    dialog ${dialog_arg[@]} --title "错误" --msgbox "非法的字符串 ${input}" $box_sz2
    bash ~/NumBox/Create-container.sh
  elif [[ -d "~/NumBox/container/$input" ]]; then
    dialog ${dialog_arg[@]} --title "错误" --msgbox "文件夹/容器 ${input} 已经存在" $box_sz2
    bash ~/NumBox/Create-container.sh 
  else
    create_dir=$(mdkir ~/NumBox/container/${input} 2>&1 >/dev/null)
    if [[ ! -z $create_dir ]]; then
      dialog ${dialog_arg[@]} --title "创建${input}失败" --msgbox "原因：$create_dir"
    else

    fi
  fi
fi