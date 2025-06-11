# 声明路径>$1 ; 指定说明 标题$2 副标题$3 背景标题$4
. ~/NumBox/utils/dialog.conf
# need 'var_file'
edit_var () {
  if [[ $1 == sed ]]; then
  # varName,varValue
    sed -i "s%^${2}=.*%${2}=${3}%g" $4
  elif [[ $1 == sed2 ]]; then
    sed -i "s%^${2}=.*%${3}=${4}%g" $5  
  # annotation
  elif [[ $1 == ann ]]; then
    sed -i "s%^${2}=.*%#${2}=.*%g" $3
  # un annotation
  elif [[ $1 == unAnn ]]; then
    sed -i "s%^#${2}=.*%${2}=.*%g" $3
  elif [[ $1 == del ]]; then
    sed -i "%^${2}=.*%d" $3
  else
    echo 未声明'$1'
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
    export BACK_NAME=${MENU_OPTIONS[$index]}
  else
    exit_exec
  fi
fi
}