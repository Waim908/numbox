# 声明路径>$1 ; 指定说明 标题$2 副标题$3 背景标题$4 ; 排序类型 $list_type
#. ~/NumBox/utils/dialog.conf
file_list() {
  if [[ ! -d $1 ]]; then
    dialog "${dialog_arg[@]}" --title "错误：路径无效" --msgbox "$1" $box_sz2
    exit_exec
    return
  fi
  if [[ -z $list_type ]]; then
    list_type=A
  fi
  if [[ -z $list_cmd ]]; then
    list_cmd="ls -$list_type $1"
  fi
  local MENU_OPTIONS=()
  
  # 1. 添加自定义选项（保留原始序号）
  if [[ ${#CUSTOM_FILE_LIST_OPTIONS[@]} -gt 0 ]]; then
    MENU_OPTIONS+=("${CUSTOM_FILE_LIST_OPTIONS[@]}")
  fi

  # 2. 添加文件列表（从1开始编号）
  FILE_COUNT=1
  while IFS= read -r file; do
    filename=$(basename "$file")
    MENU_OPTIONS+=("$FILE_COUNT" "$filename")  # 文件用数字编号
    ((FILE_COUNT++))
  done < <(eval "$list_cmd" 2>/dev/null)

  if [[ ${#MENU_OPTIONS[@]} -eq 0 ]]; then
    dialog "${dialog_arg[@]}" --title "错误：空目录" --msgbox "$1" $box_sz2
    exit_exec
    return
  fi

  # 3. 显示菜单并处理选择
  local selection=$(dialog "${dialog_arg[@]}" --title "$2" --backtitle "$4" \
             --menu "$3" $box_sz "${MENU_OPTIONS[@]}" 2>&1 >/dev/tty)

  if [[ -n $selection ]]; then
    # 查找选择的项目名称
    for ((i=1; i<${#MENU_OPTIONS[@]}; i+=2)); do
      if [[ "${MENU_OPTIONS[$i-1]}" == "$selection" ]]; then
        export BACK_NUM=$selection
        export BACK_NAME="${MENU_OPTIONS[$i]}"
        break
      fi
    done
  else
    exit_exec
  fi
}