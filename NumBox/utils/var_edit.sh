# 声明路径>$1 ; 指定说明 标题$2 副标题$3 背景标题$4
. ~/NumBox/utils/dialog.conf
# need 'var_file'
edit_var () {
  if [[ $1 == sed ]]; then
  # varName,varValue
    sed -i "s%^${2}=.*%${2}=\"${3}\"%g" $4
  elif [[ $1 == sed2 ]]; then
    sed -i "s%^${2}=.*%${3}=\"${4}\"%g" $5  
  # annotation
  elif [[ $1 == ann ]]; then
    sed -i "s%^${2}=.*%#${2}=.*%g" $3
  # un annotation
  elif [[ $1 == unAnn ]]; then
    sed -i "s%^#${2}=.*%${2}=.*%g" $3
  elif [[ $1 == del ]]; then
    sed -i "/^${2}[=]/d" $3
  else
    echo 未声明'$1'
  fi
}
# need go_back () {}
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
      dialog --erase-on-exit --no-kill --title "是否删除此变量？" --yes-label "取消" --no-label "确定" --yesno "$BACK_VAR" $box_sz2
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
sed_var () {
  edit_var  sed ${1} ${2} $var_file
  go_back
}
sed_var_preset_single () {
  varName="${BACK_VAR%%=*}"
  varValue="${BACK_VAR#*=}"
  single_select=$(dialog ${dialog_arg[@]} --extra-button --extra-label "删除变量" --backtitle "变量名开头添加#号可保留变量且不生效" --title "$varName" --menu "关于预设变量：\n \Z3$aboutVar\Zn" $box_sz \
    ${SINGLE_SELECT[@]} 2>&1 >/dev/tty)
  single_status=$?
  if [[ -z $single_select ]]; then
    go_back
  elif [[ $single_status == 3 ]]; then
    dialog  --erase-on-exit --no-kill --title "是否删除\Z2${varName}=${varValue}\Zn" --yes-label "取消" --no-label "确定" --yesno "$aboutVar" $box_sz
    if [[ $? == 1 ]]; then
      edit_var del "${varName}" $var_file
    fi
  fi 
}
sed_var_preset_multiple () {
  varName="${BACK_VAR%%=*}"
  varValue="${BACK_VAR#*=}"
  # need $ALL_SELECT
  MULTIPLE_SELECT=()
  for item in ${ALL_SELECT[@]}; do
    if [[ ",$varValue," =~ ",$item," ]]; then
      multiple_select_is=on
    else
      multiple_select_is=off
    fi
    MULTIPLE_SELECT+=("$item" "选项$item" "$multiple_select_is")
  done
  multiple_select_dialog=$(dialog ${dialog_arg[@]} --extra-button --extra-label "删除变量" --backtitle "变量名开头添加#号可保留变量且不生效" --title "$varName" --checklist "空格键或者鼠标点击或者触摸屏幕进行选择" $box_sz \
     ${MULTIPLE_SELECT[@]} 2>&1 >/dev/tty)
  multiple_status=$?
  if [[ -z $multiple_status ]]; then
    go_back
  elif [[ $multiple_status == 3 ]]; then
    dialog  --erase-on-exit --no-kill --title "是否删除\Z2${varName}=${varValue}\Zn" --yes-label "取消" --no-label "确定" --yesno "$aboutVar" $box_sz
    if [[ $? == 1 ]]; then
      edit_var del "${varName}" $var_file
    fi
  else
    multiple_select=$(echo "${multiple_select_dialog}" | sed 's/"//g; s/ /,/g')
    echo $multiple_select
  fi     
}
var_list () {
if [[ ! -f $1 ]]; then
  dialog ${dialog_arg[@]} --title "文件不存在" --msgbox "$1" $box_sz2 && exit_exec
elif [[ ! -s $1 ]]; then
  dialog ${dialog_arg[@]} --title "文件内容为空" --msgbox "$1" $box_sz2 && exit_exec
else
  FILE_COUNT=1
  MENU_OPTIONS=()
  # MENU_OPTIONS+=("0" "Back (返回)")
  while IFS= read -r line; do
      if [[ -z "$line" ]]; then
          continue
      fi
      MENU_OPTIONS+=("$FILE_COUNT" "$line")
      ((FILE_COUNT++))
  done < "$1"
  # if [ ${#MENU_OPTIONS[@]} -eq 0 ]; then
  #     lsterr=2
  # fi
  FINAL_OPTIONS=("${CUSTOM_VAR_EDIT_OPTIONS[@]}" "${MENU_OPTIONS[@]}")
  selection=$(dialog ${dialog_arg[@]} --title "$2" --backtitle "$4" --menu "$3" $box_sz \
        "${FINAL_OPTIONS[@]}" 2>&1 >/dev/tty)
  if [[ ! -z $selection ]]; then
    let index=($selection-1)*2+1
    export BACK_VAR=${MENU_OPTIONS[$index]}
    export BACK_VAR_NUM=$selection
  else
    exit_exec
  fi
fi
}