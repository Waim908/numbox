# 声明路径>$1 ; 指定说明 标题$2 副标题$3 背景标题$4
#. ~/NumBox/utils/dialog.sh
# need 'var_file' and functions 'go_back' and 'Dmsgbox'
edit_var () {
  if [[ $1 == sed ]]; then
  # varName,varValue
    sed -i "s%^export ${2}=.*%export ${2}=\"${3}\"%g" $4
  elif [[ $1 == sed2 ]]; then
    sed -i "s%^export ${2}=.*%export ${3}=\"${4}\"%g" $5
  # annotation
  elif [[ $1 == ann ]]; then
    sed -i "s%^export ${2}=%#export ${2}=%g" $3
  # un annotation
  elif [[ $1 == unAnn ]]; then
    sed -i "s%^#export ${2}=%export ${2}=%g" $3
  elif [[ $1 == del ]]; then
    sed -i "/^export ${2}[=]/d" $3
  elif [[ $1 == del2 ]]; then
    sed -i "/^export ${2}/d" $3
  else
    echo 未声明'$1'
  fi
}
search_var () {
  case $1 in
    var) echo -e "搜索到可用变量的变量值\n"
    echo ${3} | grep --color ${2}
    read -s -n1 -p "输入任意字符返回" && go_back ;;
    file) echo -e "搜索到可用变量的变量值\n"
    grep --color ${3} ${2}
    read -s -n1 -p "输入任意字符返回" && go_back ;;
  esac
}
del_var_dialog () {
  dialog ${dialog_arg[@]} --title "是否删除?" --yes-label "确定" --no-label "取消" --yesno "\Z1${1}\Zn" $box_sz2
  if [[ $? == 0 ]]; then
    if [[ $back_var_is_str == 1 ]]; then
      edit_var del2 "${1}" "$var_file" && go_back
    else
      edit_var del "${1}" "$var_file" && go_back
    fi
  else
    go_back
  fi
}
# need go_back () {}
sed_var_dialog () {
  if [[ "$BACK_VAR" =~ ^export[[:space:]][[:alnum:]_]+=.*$ ]]; then
    varName="${BACK_VAR#export }"
    varName="${varName%%=*}"
    varValue=$(awk -F'=' '{print $2}' <<< "$BACK_VAR" | sed 's/^"\|"$//g')
    form_var=$(dialog ${dialog_arg[@]} --extra-button --extra-label "删除此行" --backtitle "变量名开头添加#号可保留变量且不生效（如果没有默认内置变量值）" --title "编辑" --extra-button --extra-label "删除变量" --form "" $box_sz \
      "变量名" 1 1 "$varName" 1 10 1000 0 \
      "变量值" 2 1 "$varValue" 2 10 1000 0 2>&1 >/dev/tty)
    temp_status=$?
    if [[ -z $form_var ]]; then
      go_back
    elif [[ $temp_status == 3 ]]; then
      del_var_dialog "$varName"
    elif [[ ! -z $BACK_VAR ]]; then
      array_var=($form_var)
      newVarName=${array_var[0]}
      newVarValue=${array_var[1]}
      edit_var sed2 "$varName" "$newVarName" "$newVarValue" $var_file
      go_back
    else
      dialog ${dialog_arg[@]} --title "\Z1未知错误\Zn" --msgbox "\$returnFileName=${returnFileName}"
    fi
  else
    form_var=$(dialog ${dialog_arg[@]} --title "编辑" --extra-button --extra-label "删除此行" --form "不是有效的变量值，如果是请删除#号" $box_sz \
      "字符串" 1 1 "$BACK_VAR" 1 10 1000 0 2>&1 >/dev/tty)
    form_status=$?
    if [[ -z $form_var ]]; then
      go_back
    elif [[ $form_status == 3 ]]; then
      back_var_is_str=1
      del_var_dialog "$BACK_VAR"
    else
      sed -i "s%${BACK_VAR}%${form_var}%g" $var_file
      go_back
    fi
  fi
}
sed_var () {
  edit_var sed ${1} ${2} $var_file
  go_back
}
sed_var_preset_single () {
  varName="${BACK_VAR#export }"
  varName="${varName%%=*}"
  varValue=$(awk -F'=' '{print $2}' <<< "$BACK_VAR" | sed 's/^"\|"$//g')
  single_select=$(dialog ${dialog_arg[@]} --extra-button --extra-label "删除变量" --backtitle "变量名开头添加#号可保留变量且不生效" --title "$varName=$varValue" --menu "关于预设变量：\n \Z3$aboutVar\Zn" $box_sz \
    ${SINGLE_SELECT[@]} 2>&1 >/dev/tty)
  single_status=$?
  if [[ -z $single_select ]]; then
    go_back
  elif [[ $single_status == 3 ]]; then
    del_var_dialog "$varName"
  fi
}
sed_var_preset_multiple () {
  varName="${BACK_VAR#export }"
  varName="${varName%%=*}"
  varValue=$(awk -F'=' '{print $2}' <<< "$BACK_VAR" | sed 's/^"\|"$//g')
  # need $ALL_SELECT
  if [[ $2 == nodesc ]]; then
    MULTIPLE_SELECT=()
    for item in ${ALL_SELECT[@]}; do
      if [[ ",$varValue," =~ ",$item," ]]; then
        multiple_select_is=on
      else
        multiple_select_is=off
      fi
      MULTIPLE_SELECT+=("$item" "选项$item" "$multiple_select_is")
    done
    multiple_select_dialog=$(dialog ${dialog_arg[@]} --extra-button --extra-label "删除变量" --backtitle "变量名开头添加#号可保留变量且不生效" --title "$varName=$vaValue" --checklist "空格键或者鼠标点击或者触摸屏幕进行选择\n关于预设变量：\n \Z3$aboutVar\Zn" $box_sz \
      ${MULTIPLE_SELECT[@]} 2>&1 >/dev/tty)
    multiple_status=$?
    if [[ -z $multiple_select_dialog ]]; then
      go_back
    elif [[ $multiple_status == 3 ]]; then
      del_var_dialog "$varName"
    else
      multiple_select=$(echo "${multiple_select_dialog}" | sed 's/"//g; s/ /,/g')
      sed_var "${varName}" "${multiple_select}"
    fi
  else
    # ALL_SELECT=("变量|描述" ...)
    # 注意不能有空格
    varName="${BACK_VAR#export }"
    varName="${varName%%=*}"
    varValue=$(awk -F'=' '{print $2}' <<< "$BACK_VAR" | sed 's/^"\|"$//g')
    MULTIPLE_SELECT=()
    for item_desc in "${ALL_SELECT[@]}"; do
        item=${item_desc%%|*}
        desc=${item_desc#*|}
        if [[ ",$varValue," =~ ",$item," ]]; then
            multiple_select_is=on
        else
            multiple_select_is=off
        fi
        MULTIPLE_SELECT+=("$item" "$desc" "$multiple_select_is")
    done
    multiple_select_dialog=$(dialog ${dialog_arg[@]} --extra-button --extra-label "删除变量" --backtitle "变量名开头添加#号可保留变量且不生效（如果没有默认内置变量值）" --title "$varName=$varValue" --checklist "空格键或者鼠标点击或者触摸屏幕进行选择\n关于预设变量：\n \Z3$aboutVar\Zn" $box_sz \
      ${MULTIPLE_SELECT[@]} 2>&1 >/dev/tty)
    multiple_status=$?
    if [[ -z $multiple_select_dialog ]]; then
      go_back
    elif [[ $multiple_status == 3 ]]; then
      del_var_dialog "$varName"
    else
      multiple_select=$(echo "${multiple_select_dialog}" | sed 's/"//g; s/ /,/g')
      sed_var "${varName}" "${multiple_select}"
    fi
  fi
}
get_var () {
    varName="${BACK_VAR#export }"
    varName="${varName%%=*}"
    varValue=$(awk -F'=' '{print $2}' <<< "$BACK_VAR" | sed 's/^"\|"$//g')
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
  while IFS= read -r line || [[ -n "$line" ]]; do
      if [[ -z "$line" ]]; then
          continue
      fi
      local MENU_OPTIONS+=("$FILE_COUNT" "$line")
      ((FILE_COUNT++))
  done < "$1"
  # if [ ${#MENU_OPTIONS[@]} -eq 0 ]; then
  #     lsterr=2
  # fi
  local FINAL_OPTIONS=("${CUSTOM_VAR_EDIT_OPTIONS[@]}" "${MENU_OPTIONS[@]}")
  selection=$(dialog ${dialog_arg[@]} --title "$2" --backtitle "$4" --menu "$3" $box_sz \
        "${FINAL_OPTIONS[@]}" 2>&1 >/dev/tty)
  if [[ ! -z $selection ]]; then
    let index=($selection-1)*2+1
    export BACK_VAR=${MENU_OPTIONS[$index]}
    export BACK_VAR_NUM=$selection
  else
    echo "在 $1 目录下没有发现任何文件，且未定义拓展选项"
    return 1
  fi
fi
}