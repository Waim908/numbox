#!/bin/bash
. ~/NumBox/utils/dialog.conf
. ~/NumBox/utils/var_edit.sh
if [[ ! -v CONTAINER_NAME ]]; then
  if [[ ! -z $1 ]]; then
    export CONTAINER_NAME=$1
    if [[ ! -d ~/NumBox/data/container/${CONTAINER_NAME} ]]; then
      echo -e "容器 \e[33m ${CONTAINER_NAME} \e[0m 不存在"
      exit 1
    else
      . ~/NumBox/utils/path.conf
    fi
  else
    exit_exec () { . ~/NumBox/Numbox;}
    . ~/NumBox/utils/file_list.sh
    file_list "$HOME/NumBox/data/container/" "选择一个容器"
    if [[ -z $BACK_NAME ]]; then
      . ~/NumBox/Numbox
    else
      export CONTAINER_NAME=${BACK_NAME}
      . ~/NumBox/utils/path.conf
    fi
  fi
fi
select=$(dialog ${dialog_arg[@]} --title "变量设置" --backtitle "容器：${BACK_NAME}" --menu "\Z3对于变量的解释不一定100%准确，仅供参考\Zn" $box_sz \
  1 "设置容器变量" \
  2 "设置Box64变量" \
  3 "重置为默认容器变量" 2>&1 >/dev/tty)
if [[ -z $select ]]; then
  . ~/NumBox/Numbox
fi
case $select in
  1) exit_exec () { . ~/NumBox/Var-setting.sh;}
  go_back () { set_ctr_var;}
  set_ctr_var () {
    var_file=$ctr_conf_path/default.conf
    CUSTOM_VAR_EDIT_OPTIONS=("E" "\Z2使用文本编辑器软件打开\Zn" "A" "\Z2添加一个自定义变量\Zn")
    var_list $var_file "${BACK_NAME}" "$HOME/NumBox/data/container/${BACK_NAME}/config/default.conf" "部分变量在更新的驱动可能已经失效或者发生改变，不保证一定有效"
    if [[ $BACK_VAR_NUM == E ]]; then
      . ~/NumBox/utils/empty.sh sd
      cp $var_file $sd_temp/default.conf
      termux-open --content-type text $sd_temp/default.conf
      dialog ${dialog_arg[@]} --title "是否保存？" --yesno "$sd_temp/default.conf" $box_sz2
      if [[ ! $? == 1 ]]; then
        cp $sd_temp/default.conf $var_file
      fi
      set_ctr_var
    elif [[ $BACK_VAR_NUM == A ]]; then
      customForm=$(dialog ${dialog_arg[@]} --title "自定义变量" --form "输入变量值" $box_sz \
        "变量名" 1 1 "" 1 10 1000 0 \
        "变量值" 2 1 "" 2 10 1000 0 2>&1 >/dev/tty)
      array_var=($customForm)
      newVarName=${array_var[0]}
      newVarValue=${array_var[1]}
      if [[ -z $customForm ]]; then
        set_ctr_var
      else
        echo "${newVarName}=${newVarValue}" >> $var_file
        set_ctr_var
      fi
    else
      case $BACK_VAR in
        LC_ALL=*) aboutVar="修改区域语言编码格式，注意可能不是对所有游戏有效，你可能还需要设置时区"
        genrate () {
          cp ~/NumBox/default/glibc/locale-gen $glibc_prefix/etc/
          unset LD_PRELOAD
          $PREFIX/glibc/bin/locale-gen
        }
        SINGLE_SELECT=(
        "简体中文" "zh_CN.UTF-8"
        "繁体中文" "zh_TW.UTF-8"
        "日语" "ja_JP.UTF-8"
        "英文" "en_US.UTF-8"
        "自定义" "语言_区域.编码"
        )
        sed_var_preset_single
        case $single_select in
          简体中文) sed_var "LC_ALL" "zh_CN.UTF-8" ;;
          繁体中文) sed_var "LC_ALL" "zh_TW.UTF-8" ;;
          日语) sed_var "LC_ALL" "ja_JP.UTF-8" ;;
          英文) sed_var "LC_ALL" "en_US.UTF-8" ;;
          自定义) lcall=$(dialog ${dialog_arg[@]} --title "自定义语言编码(LC_ALL)" --inputbox "格式：语言_区域.编码" $box_sz 2>&1 >/dev/tty)
            if [[ -z $lcall ]]; then
              set_ctr_var
            else
              edit_var sed "LC_ALL" "${lcall}" $var_file
              set_ctr_var
            fi ;;
        esac ;;
        ZINK_DESCRIPTOR=*) aboutVar="ZINK描述符"
        SINGLE_SELECT=(
          "auto" "自动检测"
          "lazy" "尝试通过机会性地绑定描述符来使用最少量的CPU"
          "db" "如果可能,请使用EXT_descriptor_buffer"
        )
        sed_var_preset_single
        case $single_select in
          auto) sed_var "ZINK_DESCRIPTOR" "auto" ;;
          lazy) sed_var "ZINK_DESCRIPTOR" "lazy" ;;
          db) sed_var "ZINK_DESCRIPTOR" "db" ;;
        esac ;;
        TZ=*) aboutVar="设置时区"
        SINGLE_SELECT=(
          "Asia/Shanghai" "中国上海"
          "Asia/Tokyo" "日本东京"
          "America/Los_Angeles" "美国洛杉矶"
          "Europe/London" "英国伦敦"
          "custom" "自定义时区"
        )
        sed_var_preset_single
        case $single_select in
          Asia/Shanghai) sed_var "TZ" "Asia/Shanghai" ;;
          Asia/Tokyo) sed_var "TZ" "Asia/Tokyo" ;;
          America/Los_Angeles) sed_var "TZ" "America/Los_Angeles" ;;
          Europe/London) sed_var "TZ" "Europe/London" ;;
          custom) tzset=$(dialog ${dialog_arg[@]} --title "自定义时区" --inputbox "" $box_sz 2>&1 >/dev/tty)
          if [[ -z $tzset ]]; then
            set_ctr_var
          elif [[ ! -d /data/data/com.termux/files/usr/glibc/share/zoneinfo/ ]]; then
            dialog ${dialog_arg[@]} --title "\Z1错误\Zn" --msgbox "当前glibc目录没有内置tzdata，修改时区无效" $box_sz2
            set_ctr_var
          elif [[ ! -d /data/data/com.termux/files/usr/glibc/share/zoneinfo/${tzset} ]]; then
            dialog ${dialog_arg[@]} --title "\Z1错误\Zn" --msgbox "\Z2${tzset}\Zn 似乎不是一个有效的时区值" $box_sz2
            set_ctr_var
          else
            sed_var "TZ" "${tzset}"
          fi
        esac ;;
        ZINK_DEBUG=*) aboutVar="ZINK调试"
        ALL_SELECT=(
        "nir|将所有着色器的NIR形式打印到stderr"
        "spirv|将所有已编译着色器的二进制SPIR-V格式写入当前目录中的文件中，并将带有文件名的消息打印到stderr"
        "tgsi|将TGSI着色器的TGSI形式打印到stderr"
        "validation|Dump_Validation_layer输出"
        "sync|在每次绘制和调度之前发出完全同步屏障"
        "compact|最多使用4个描述符集"
        "noreorder|不重新排序或优化GL命令流"
        "gpl|强制对所有着色器使用Graphics_Pipeline_Library"
        "rp|启用渲染过程优化（用于平铺GPU）"
        "norp|禁用渲染过程优化（用于平铺GPU）"
        "map|打印有关映射的VRAM的信息"
        "flushsync|强制同步刷新/呈现"
        "noshobj|禁用EXT_shader_object"
        "optimal_keys|调试/使用optimal_keys"
        "noopt|禁用异步优化管道编译"
        "nobgc|禁用所有异步管道编译"
        "mem|启用内存分配调试"
        "quiet|禁止显示可能无害的警告"
        )
        sed_var_preset_multiple ;;
        ZINK_CONTEXT_MODE=*) aboutVar="通常设置为base"
        SINGLE_SELECT=(base base auto auto)
        sed_var_preset_single
        case $single_select in
          base) sed_var ZINK_CONTEXT_MODE base ;;
          auto) sed_var ZINK_CONTEXT_MODE auto ;;
        esac ;;
        ZINK_CONTEXT_THREADED=*) aboutVar="可能解决游戏卡死问题"
        SINGLE_SELECT=(true 启用 false 禁用)
        sed_var_preset_single
        case $single_select in
          true) sed_var ZINK_CONTEXT_THREADED true ;;
          false) sed_var ZINK_CONTEXT_THREADED false ;;
        esac ;;
        MESA_SHADER_CACHE_DISABLE=*) aboutVar="禁用着色器缓存"
        SINGLE_SELECT=(true 启用 false 禁用)
        sed_var_preset_single
        case $single_select in
          true) sed_var ZINK_CONTEXT_THREADED true ;;
          false) sed_var ZINK_CONTEXT_THREADED false ;;
        esac ;;
        MESA_SHADER_CACHE_MAX_SIZE=*) aboutVar="着色器缓存最大大小，单位必须为K,M,G"
        SINGLE_SELECT=(256M 小 512M 中 1G 最大上限)
        sed_var_preset_single
        case $single_select in
          256M) sed_var MESA_SHADER_CACHE_MAX_SIZE 256M ;;
          512M) sed_var MESA_SHADER_CACHE_MAX_SIZE 512M ;;
          1G) sed_var MESA_SHADER_CACHE_MAX_SIZE 1G ;;
        esac ;;
        MESA_VK_WSI_DEBUG=*) aboutVar="垂直同步(Vulkan)"
        SINGLE_SELECT=(注释 "既默认sws" sw "启用（通常）" sws "可能导致渲染错误（默认）")
        sed_var_preset_single
        case $single_select in
          注释) edit_var ann MESA_VK_WSI_DEBUG $var_file && go_back ;;
          sw) sed_var MESA_VK_WSI_DEBUG sw ;;
          sws) sed_var MESA_VK_WSI_DEBUG sws ;;
        esac ;;
        MESA_VK_WSI_PRESENT_MODE=*) aboutVar="overrides the WSI present mode clients specify in VkSwapchainCreateInfoKHR::presentMode. Values can be fifo, relaxed, mailbox or immediate."
        SINGLE_SELECT=(fifo fifo relaxed relaxed mailbox "mailbox（预设）" immediate immediate)
        sed_var_preset_single
        case $single_select in
          fifo
        *) sed_var_dialog ;;
      esac
    fi
  }
  set_ctr_var
  ;;
esac