# need import dialog.sh
# 提供一个自由的列表导入到dialog menu列出数据

# 自动排序
# freeListArry=()
sort_arry () {
  for ((i=0; i<${#freeListArry[@]}; i++)); do
    local a_freeListArry+=( $((i+1)) "${freeListArry[$i]}")
  done
  echo ${a_freeListArry[@]}
}

free_list () {
  local get_list=($(sort_arry))
  if [[ -z $get_list ]]; then
    Dmsgbox "\Z1错误\Zn" "没有可显示的选项，未定义变量或变量为空=> \Z3\$freeListArry\Z3"
    return 1
  fi
  if [[ ! -z $otherFreeListOptions ]]; then
    local get_list+=($otherFreeListOptions[@])
  fi
  local free_list_menu=$(dialog ${dialog_arg[@]} --title "$1" --backtitle "$3" --menu "$2" $box_sz "${get_list[@]}" 2>&1 >/dev/tty)
  export returnFreeListName="${get_list[$free_list_menu+($free_list_menu-1)]}"
  export returnFreeListNum="$free_list_menu"
}
utilsVar+=(returnFreeListName returnFreeListNum)