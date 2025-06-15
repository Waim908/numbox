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
sed_var_dialog () {
  if [[ "$BACK_VAR" =~ ^[[:alnum:]_]+=.*$ ]]; then
    varName="${BACK_VAR%%=*}"
    varValue="${BACK_VAR#*=}"
    form_var=$(dialog ${dialog_arg[@]} --backtitle "变量名开头添加#号可保留变量且不生效" --title "编辑" --extra-button --extra-label "删除变量" --form "" $box_sz \
      "变量名" 1 1 "$varName" 1 10 1000 0 \
      "变量值" 2 1 "$varValue" 2 10 1000 0 2>&1 >/dev/tty)
    temp_status=$?
    if [[ -z $form_var ]]; then
      go_back
    elif [[ $temp_status == 3 ]]; then
      dialog --erase-on-exit --no-kill --title "是否删除此变量？"  --yes-label "取消" --no-label "确定" --yesno "$BACK_VAR" $box_sz2
      yesno=$?
      case $yesno in
        0) go_back ;;
        1) edit_var del "$varName" $var_file && sed_var_dialog ;;
      esac
    elif [[ ! -z $BACK_VAR ]]; then
      array_var=($form_var)
      newVarName=${array_var[0]}
      newVarValue=${array_var[1]}
      edit_var sed2 "$varName" "$newVarName" "$newVarValue" $var_file
      go_back
    else
      dialog ${dialog_arg[@]} --title "\Z1未知错误\Zn" --msgbox "\$BACK_NAME=${BACK_NAME}"
    fi
  else
    form_var=$(dialog ${dialog_arg[@]} --title "编辑" --form "不是有效的变量值" $box_sz \
      "字符串" 1 1 "$BACK_VAR" 1 10 1000 0 2>&1 >/dev/tty)
    if [[ -z $form_var ]]; then
      go_back
    else
      sed -i "s%${BACK_VAR}%${form_var}%g" $var_file
      go_back
    fi
  fi
}
sed_var_preset_single () {
  varName="${BACK_VAR%%=*}"
  varValue="${BACK_VAR#*=}"
  single_select=$(dialog ${dialog_arg[@]} --extra-button --extra-label "删除变量" --backtitle "变量名开头添加#号可保留变量且不生效" --title "$varName" --menu "关于预设变量:\n$aboutVar" $box_sz \
    ${SINGLE_SELECT[@]} 2>&1 >/dev/tty)
  single_status=$?
}
sed_var_preset_multiple () {
  echo
}
select=$(dialog ${dialog_arg[@]} --title "变量设置" --backtitle "容器：${BACK_NAME}" --menu "" $box_sz \
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
    var_list $var_file "${BACK_NAME}" "$HOME/NumBox/data/container/${BACK_NAME}/config/default.conf"
    if [[ $BACK_VAR_NUM == E ]]; then
      . ~/NumBox/utils/empty.sh sd
      cp $var_file $sd_temp/default.conf
      termux-open --content-type text $sd_temp/default.conf
      dialog ${dialog_arg[@]} --title "是否保存？" --yesno "$sd_temp/default.conf" $box_sz2
      if [[ ! $? == 1 ]]; then
        cp $sd_temp/default.conf $var_file
      fi
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
        LC_ALL=*) aboutVar="修改区域语音编码格式，注意可能不是对所有游戏有效，你可能还需要设置时区"
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
        if [[ -z $single_select ]]; then
          set_ctr_var
        elif [[ $single_select = 3 ]]; then
          edit_var del "LC_ALL" $var_file
        else
          case $single_select in
            简体中文) edit_var sed "LC_ALL" "zh_CN.UTF-8" $var_file ;;
            繁体中文) edit_var sed "LC_ALL" "zh_TW.UTF-8" $var_file ;;
            日语) edit_var sed "LC_ALL" "ja_JP.UTF-8" $var_file ;;
            英文) edit_var sed "LC_ALL" "en_US.UTF-8" $var_file ;;
            自定义) lcall=$(dialog ${dialog_arg[@]} --title "自定义语言编码(LC_ALL)" --inputbox "格式：语言_区域.编码" $box_sz1 2>&1 >/dev/tty)
              if [[ -z $lcall ]]; then
                set_ctr_var
              else
                edit_var sed "LC_ALL" "${lcall}" $var_file
                set_ctr_var
              fi ;;
          esac
        fi
        ;;
        ZINK_DESCRIPTOR=*) aboutVar="ZINK描述符切换"
        SINGLE_SELECT=(
          "auto" "自动检测"
          ""
        ) 
        ;;
        *) sed_var_dialog ;;
      esac
    fi
  }
  set_ctr_var
  ;;
esac