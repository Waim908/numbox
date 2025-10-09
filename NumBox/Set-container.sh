#!/bin/bash
main () {
utilsDoNotReimport=1
. ~/NumBox/utils/utils.sh
import dialog.sh
import var_edit.sh
import file_list.sh
import select_ctr.sh

unset_utils_var
if ! select_ctr ; then

. ~/NumBox/utils/path.sh
# regeistry
# setname::value
Dmenu_select=(
  1 "容器名称:\Z3$CONTAINER_NAME\Zn"
  2 "环境与box64变量"
  3 "分辨率设置"
  4 "挂载盘设置"
)
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

Dmenu "\Z3${CONTAINER_NAME}\Zn 的设置" ""
case $DMENU in
  "") . ~/NumBox/Numbox ;;
  1) input=$(dialog ${dialog_arg[@]} --title "容器名称" --inputbox "输入新的容器名称" $box_sz2 2>&1 >/dev/tty)
    if [[ -z $input ]]; then
      . ~/NumBox/Set-container.sh "${CONTAINER_NAME}"
    else
      . ~/NumBox/utils/illegal_str.sh "${input}"
      if [[ ! $str_is == good ]]; then
        # dialog ${dialog_arg[@]} --title "\Z1错误\Zn" --msgbox "非法的字符串 ${input}" $box_sz2
        Dmsgbox "\Z1错误\Zn" "非法的字符串 ${input}"
        . ~/NumBox/Set-container.sh "${CONTAINER_NAME}"
      elif [[ -d ~/NumBox/data/container/${input} ]]; then
        # dialog ${dialog_arg[@]} --title "\Z1错误\Zn" --msgbox "容器 ${input} 已经存在" $box_sz2
        Dmsgbox "\Z1错误\Zn" "容器 ${input} 已经存在"
        . ~/NumBox/Set-container.sh "${CONTAINER_NAME}"
      else
        mv ~/NumBox/data/container/${CONTAINER_NAME} ~/NumBox/data/container/${input}
        echo "${input}" > ~/NumBox/default_ctr
        # dialog ${dialog_arg[@]} --title "成功" --msgbox "容器名称已更改为 ${input}" $box_sz2
        Dmsgbox "成功" "容器名称已更改为 ${input}"
        export CONTAINER_NAME=${input}
        . ~/NumBox/Set-container.sh
      fi
    fi ;;
  2) . ~/NumBox/Var-setting.sh "${CONTAINER_NAME}" && . ~/NumBox/Set-container.sh ;;
  3) set_screenres_menu () {
  . $ctr_conf_path/ctr.conf
    if [[ -z $screenRes ]]; then
      screenRes_is="客户端自动获取"
    else
      screenRes_is="${screenRes}"
    fi
  Dmenu_select=(
    1 "通过termux-x11-preference获取分辨率数据(txp)\Z2推荐,termux-x11设置一下就行了\Zn"
    2 "通过xrandr获取分辨率数据(xrandr)"
    3 "自定义分辨率(set-txp)(强制修改客户端为\Z2custom\Zn，分辨率获取失败使用此值)"
  )
  Dmenu "分辨率设置" "类型：\Z3${getScreenRes}\Zn 自定义分辨率：\Z3${screenRes_is}\Zn"
  case $DMENU in
      "") . ~/NumBox/Set-container.sh "${CONTAINER_NAME}" ;;
      1) sed -i "s%getScreenRes=.*%getScreenRes=\"txp\"%g" $ctr_conf_path/ctr.conf
      sed -i "s%screenRes=.*%screenRes=%g" $ctr_conf_path/ctr.conf
      set_screenres_menu ;;
      2) sed -i "s%getScreenRes=.*%getScreenRes=\"xrandr\"%g" $ctr_conf_path/ctr.conf
      sed -i "s%screenRes=.*%screenRes=%g" $ctr_conf_path/ctr.conf
      set_screenres_menu ;;
      3) Dmenu_select=(C "\Z2自定义\Zn" 640x480 640x480@4:3 800x600 800x600@4:3 854x480 854x480@16:9 960x544 960x544@16:9 1024x768 1024x768@4:3 1280x720 1280x720@16:9 1280x800 1280x800@16:10 1280x1024 1280x1024@5:4 1366x768 1366x768@16:9 1440x900 1440x900@16:10 1600x900 1600x900@16:9 1920x1080 1920x1080@16:9 640x1080 640x1080@9:18 800x1600 800x1600@9:18 1024x2080 1024x2080@9:18 1280x2560 1280x2560@9:18 2560x1440 2560x1440@2K 4096x2160 4096x2160@4K)
      Dmenu "分辨率选择" ""
      if [[ -z $DMENU ]]; then
        set_screenres_menu
      elif [[ $DMENU == C ]]; then
        form_res=$(dialog ${dialog_arg[@]} --title "自定义屏幕分辨率" --form "之前的设置：${screenRes}" $box_sz \
          "宽" 1 1 "" 1 10 1000 0 \
          "高" 2 1 "" 2 10 1000 0 2>&1 >/dev/tty)
        if [[ -z $form_res ]]; then
          set_screenres_menu
        else
          width=${form_res[0]}
          height=${form_res[1]}
          if [[ $width =~ ^[1-9][0-9]*$ ]] && [[ $height =~ ^[1-9][0-9]*$ ]]; then
#            sed_var getScreenRes set-txp
            sed -i "s%getScreenRes=.*%getScreenRes=\"set-txp\"%g" $ctr_conf_path/ctr.conf
            sed -i "s%screenRes=.*%screenRes=\"${width}x${height}\"%g" $ctr_conf_path/ctr.conf
            set_screenres_menu
          else
            Dmsgbox "\Z1错误\Zn" "请输入正确的分辨率格式（不能为0），如：1920x1080"
            set_screenres_menu
          fi
        fi
      else
        sed -i "s%getScreenRes=.*%getScreenRes=\"set-txp\"%g" $ctr_conf_path/ctr.conf
#        sed_var screenRes $single_select
        sed -i "s%screenRes=.*%screenRes=\"${DMENU}\"%g" $ctr_conf_path/ctr.conf
        set_screenres_menu
      fi ;;
  esac
  }
  set_screenres_menu ;;
  4) mount_disk_menu () {
#    CUSTOM_FILE_LIST_OPTIONS=(V 查看挂载盘路径对应关系 A 添加挂载盘)
  Dmenu_select=("A" "\Z2添加或修改挂载盘\Zn" "$(ls --ignore="c:" --ignore="h:" -lA $HOME/NumBox/data/container/"${CONTAINER_NAME}"/disk/dosdevices/ | awk '{print $9,$11}')")
  Dmenu "挂载盘设置" "\Z3若进入容器后无法在对应盘符找到你的文件（路径有文件但是为空），请尝试修改路径\Zn"
    # file_list "$HOME/NumBox/data/container/$CONTAINER_NAME/disk/dosdevices/" "挂载盘设置"
  case $DMENU in
    "") . ~/NumBox/Set-container.sh "${CONTAINER_NAME}" ;;
    A) Dmenu_select=(d: d: c: c: e: e: f: f: g: g: i: i: j: j: k: k: l: l: m: m: n: n: o: o: p: p: q: q: r: r: s: s: t: t: u: u: v: v: w: w: x: x: y: y:)
    Dmenu "选择一个盘符"
    case $DMENU in
      "") mount_disk_menu ;;
      *) sdcard=($(cat /proc/mounts | grep -E '/storage/' | grep -v 'emulated' |  awk '{print $2}' | xargs -n1 | awk '{print "外部存储"NR, $0}'| grep -E '/storage/' | grep -v 'emulated' |  awk '{print $2}' | xargs -n1 | awk '{print $0, "外部存储"NR}'))
      disk_tag="$DMENU"
      Dmenu_select=("/storage/emulated/0" "内部存储" ${sdcard[@]} "custom" "手动输入路径")
      Dmenu
      case $DMENU in
        "") mount_disk_menu ;;
        custom) custom_mount_path=$(dialog ${dialog_arg[@]} --inputbox "手动输入自定义路径" $box_sz2 2>&1 >/dev/tty)
        if [[ ! -d "$custom_mount_path" ]]; then
          Dmsgbox "\Z1错误\Zn" "\'$custom_mount_path\' 无法找到"
        else
          if ! ln -sf "$custom_mount_path" $HOME/NumBox/data/container/"$CONTAINER_NAME"/disk/dosdevices/"$disk_tag"; then
            Dmsgbox "\Z1错误\Zn" "路径挂载失败，可能是权限不足，或者文件夹已被删除，或者不存在由于安卓权限限制，可能需要尽量选择子目录而非存储的根目录"
            rm -rf $HOME/NumBox/data/container/"$CONTAINER_NAME"/disk/dosdevices/"$disk_tag"
          fi
          mount_disk_menu
        fi ;;
        *) CUSTOM_FILE_LIST_OPTIONS=("T" "\Z2直接使用这个路径\Zn")
        file_list "$DMENU"
        if [[ -z $returnFileListName ]]; then
          mount_disk_menu
        elif [[ $BACK_NUM == T ]]; then
            if ! ln -sf "${DMENU}/" $HOME/NumBox/data/container/"$CONTAINER_NAME"/disk/dosdevices/"$disk_tag"; then
              Dmsgbox "\Z1错误\Zn" "路径挂载失败，可能是权限不足，或者文件夹已被删除，或者不存在由于安卓权限限制，可能需要尽量选择子目录而非存储的根目录"
              rm -rf $HOME/NumBox/data/container/"$CONTAINER_NAME"/disk/dosdevices/"$disk_tag"
            fi
          mount_disk_menu
        else
          if ! ln -sf "${DMENU}/${returnFileListName}" $HOME/NumBox/data/container/"$CONTAINER_NAME"/disk/dosdevices/"$disk_tag"; then
            Dmsgbox "\Z1错误\Zn" "路径挂载失败，可能是权限不足，或者文件夹已被删除，或者不存在由于安卓权限限制，可能需要尽量选择子目录而非存储的根目录"
            rm -rf $HOME/NumBox/data/container/"$CONTAINER_NAME"/disk/dosdevices/"$disk_tag"
          fi
          mount_disk_menu
        fi ;;
      esac ;;
      z:) Dmenu_select=(1 "独立的Z盘" 2 "撤销独立Z盘")
      Dmenu "关于Z盘" "独立的Z盘包含开始菜单软件占用更多空间,防止病毒感染其他文件\n \Z1并且你无法在wine虚拟桌面访问\Z2$PREFIX\Z1路径，驱动替换bat脚本失效\Zn"
      case $DMENU in
        "") mount_disk_menu ;;
        1) Dyesno "是否创建独立Z盘？" "这需要一些时间"
        if [[ $? == 0 ]]; then
          mkdir $ctr_disk/drive_z
          . ~/NumBox/utils/load.sh
          if ! load "cp -r ~/NumBox/opt $ctr_disk/drive_z/" "正在复制文件"; then
            echo 文件复制失败
            exit 1
          fi
          cd $ctr_disk/dosdevices
          ln -sf ../drive_z z:
          sleep 2 && mount_disk_menu
        else
          mount_disk_menu
        fi ;;
      esac ;;
    esac ;;
  *:) Dyesno "是否删除此挂载盘？" "$DMENU=>$(readlink ~/NumBox/data/container/"${CONTAINER_NAME}"/disk/dosdevices/$DMENU)"
  if [[ $? == 0 ]]; then
    rm -rf ~/NumBox/data/container/"${CONTAINER_NAME}"/disk/dosdevices/$DMENU && mount_disk_menu
  else
    mount_disk_menu
  fi ;;
  esac
  }
  mount_disk_menu ;;
  5) gpu_driver_menu () {
  . $ctr_conf_path/ctr.cfg
  gpuName=$(grep "driverName=" $ctr_conf_path/driver.conf | sed "s%driverName=%%")
  Dmenu_select=(E "mesa3d拓展变量" 1 "Turnip(Adreno)" 2 "Panfrost(Mali)" 3 "LLVMPIPE(CPU)" 4 "VirGL/Virtio(venus)" 5 "Glibc自动选择")
  Dmenu "GPU驱动设置" "当前：$(grep "ctr_conf_path")"
  case $DMENU in
    "") ~/NumBox/Set-container.sh "${CONTAINER_NAME}" ;;
    E) Dyesno "是否启用mesa驱动拓展变量？" "这么做可以提供一部分程序兼容性，也有可能导致未知问题"
    if
    ;;
    1) cp ~/NumBox/default/gpu/turnip_zink.conf $ctr_conf_path/ && gpu_driver_menu ;;
    2) cp ~/NumBox/default/gpu/panforst.conf $ctr_conf_path/driver.conf && gpu_driver_menu ;;
    3) cp ~/NumBox/default/gpu/llvmpipe.conf $ctr_conf_path/driver.conf && gpu_driver_menu ;;
    4) cp ~/NumBox/default/gpu/llvmpipe.conf $ctr_conf_path/driver.conf && gpu_driver_menu ;;
    5) echo "" > $ctr_conf_path/driver.conf ;;
  esac
  }
  gpu_driver_menu ;;

esac
}


