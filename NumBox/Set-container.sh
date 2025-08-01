#!/bin/bash
. ~/NumBox/utils/dialog.conf
. ~/NumBox/utils/var_edit.sh
unset var_file
if [[ ! -v CONTAINER_NAME ]]; then
  if [[ ! -z $1 ]]; then
    export CONTAINER_NAME=$1
    if [[ ! -d ~/NumBox/data/container/${CONTAINER_NAME} ]]; then
      echo -e "容器 \e[33m ${CONTAINER_NAME} \e[0m 不存在"
      exit 1
    fi
  else
    exit_exec () { . ~/NumBox/Numbox;}
    . ~/NumBox/utils/file_list.sh
    file_list "$HOME/NumBox/data/container/" "选择一个容器"
    if [[ -z $BACK_NAME ]]; then
      . ~/NumBox/Numbox
    else
      export CONTAINER_NAME=${BACK_NAME}
    fi
  fi
fi
. ~/NumBox/utils/path.conf
# regeistry
# setname::value
set_container=$(Dmenu "$CONTAINER_NAME" "容器设置" \
  1 "容器名称:$CONTAINER_NAME" \
  2 "环境与box64变量" \
  3 "分辨率设置" \
  4 "挂载盘设置" 2>&1 >/dev/tty)
# "驱动设置"
# "Drectx图形环境"
#  "游戏控制器API" \
#  "生成游戏快捷方式启动脚本" \
#  "windows版本伪装" \
# "box64版本"
# "内建与原装"
# "导出容器"
# "删除容器"
# "空间占用"
case $set_container in
  1) input=$(dialog ${dialog_arg[@]} --title "容器名称" --inputbox "输入新的容器名称" $box_sz2 2>&1 >/dev/tty)
    if [[ -z $input ]]; then
      exit_exec
    else
      . ~/NumBox/utils/illegal_str.sh "${input}"
      if [[ ! $str_is == good ]]; then
        # dialog ${dialog_arg[@]} --title "\Z1错误\Zn" --msgbox "非法的字符串 ${input}" $box_sz2
        Dmsgbox "\Z1错误\Zn" "非法的字符串 ${input}"
        . ~/NumBox/Set-container.sh
      elif [[ -d ~/NumBox/data/container/${input} ]]; then
        # dialog ${dialog_arg[@]} --title "\Z1错误\Zn" --msgbox "容器 ${input} 已经存在" $box_sz2
        Dmsgbox "\Z1错误\Zn" "容器 ${input} 已经存在"
        . ~/NumBox/Set-container.sh
      else
        mv ~/NumBox/data/container/${CONTAINER_NAME} ~/NumBox/data/container/${input}
        echo "${input}" > ~/NumBox/default_ctr
        # dialog ${dialog_arg[@]} --title "成功" --msgbox "容器名称已更改为 ${input}" $box_sz2
        Dmsgbox "成功" "容器名称已更改为 ${input}"
        export CONTAINER_NAME=${input}
        . ~/NumBox/Set-container.sh
      fi
    fi ;;
  2) . ~/NumBox/Var-setting.sh ;;
  3) set_screenres_menu () {
  var_file="$ctr_conf_path/ctr.conf"
  go_back () { set_screenres_menu;} 
  . $ctr_conf_path/ctr.conf
  if [[ -z $screenRes ]]; then
    screenRes_is="客户端自动获取"
  fi
  set_screenres=$(Demnu "分辨率设置" "类型：\Z3${getScreenRes}\Zn 自定义分辨率：\Z3${screenRes_is}\Zn" \
    1 "通过termux-x11-perference获取分辨率数据(txp)\Z2推荐,termux-x11设置一下就行了\Zn" \
    2 "通过xrandr获取分辨率数据(xrandr)" \
    3 "自定义分辨率(set-txp)(强制修改客户端为\Z2exact\Zn)" 2>&1 >/dev/tty)
  case $set_screenres in
      "") . ~/NumBox/Set-container.sh ;;
      1) sed -i "s%getScreenRes=.*%getScreenRes=\"txp\"%g" $ctr_conf_path/ctr.conf
      sed -i "s%screenRes=.*%screenRes=%g" $ctr_conf_path/ctr.conf
      set_screenres_menu ;;
      2) sed -i "s%getScreenRes=.*%getScreenRes=\"xrandr\"%g" $ctr_conf_path/ctr.conf
      sed -i "s%screenRes=.*%screenRes=%g" $ctr_conf_path/ctr.conf
      set_screenres_menu ;;
      3) SINGLE_SELECT=(C 自定义 640x480 640x480@4:3 800x600 800x600@4:3 854x480 854x480@16:9 960x544 960x544@16:9 1024x768 1024x768@4:3 1280x720 1280x720@16:9 1280x800 1280x800@16:10 1280x1024 1280x1024@5:4 1366x768 1366x768@16:9 1440x900 1440x900@16:10 1600x900 1600x900@16:9 1920x1080 1920x1080@16:9 640x1080 640x1080@9:18 800x1600 800x1600@9:18 1024x2080 1024x2080@9:18 1280x2560 1280x2560@9:18 2560x1440 2560x1440@2K 4096x2160 4096x2160@4K)
      sed_var_preset_single
      if [[ $single_select == C]]; then
        form_res=$(dialog ${dialog_arg[@]} --title "自定义屏幕分辨率" --form "之前的设置：${screenRes}" $box_sz \
          "宽" 1 1 "$varName" 1 10 1000 0 \
          "高" 2 1 "$varValue" 2 10 1000 0 2>&1 >/dev/tty)
        if [[ -z $form_res ]]; then
          go_back
        else
          width=${form_res[0]}
          height=${form_res[1]}
          if [[ $width =~ ^[1-9][0-9]*$ ]] && [[ $height =~ ^[1-9][0-9]*$ ]]; then
            sed_var getScreenRes set-txp
            sed -i "s%screenRes=.*%screenRes=\"${width}x${height}\"%g" $ctr_conf_path/ctr.conf
            go_back
          else
            Dmsgbox "\Z1错误\Zn" "请输入正确的分辨率格式（不能为0），如：1920x1080"
            go_back
          fi
        fi
      else
        sed_var getScreenRes set-txp
        sed_var screenRes $single_select
      fi ;;
    esac
  }
  set_screenres_menu ;;
  4) mount_disk_menu () {
    exit_exec () { mount_disk_menu;}
    CUSTOM_FILE_LIST_OPTIONS=(V 查看挂载盘路径对应关系 A 添加挂载盘)
    file_list $ctr_disk
    if [[ $BACK_NUM == V ]]; then
      Dmsgbox "路径对应关系" "$(ls -lA ${ctr_disk} | awk '{print $9,$10,$11}')" &&  mount_disk_menu
    elif [[ $BACK_NAME == c: ]] && [[ $BACK_NAME == z: ]]; then
      Dmsgbox "\Z1Sorry\Zn" "\Z1请勿修改 C盘 与 Z盘 挂载\Zn" && mount_disk_menu
    fi
  }
  mount_disk_menu ;;
esac