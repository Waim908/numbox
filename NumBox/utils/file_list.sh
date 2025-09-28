# 直接重写，之前deepseek写的居然要循环
file_list () {
  # Need import dialog
  if [[ -z $1 ]]; then
    local list_path="$(pwd)"
  else
    local list_path=${1}
  fi
  if [[ -z $lsArg ]]; then
    local arg=(-1A)
  else
    local arg=${lsArg[@]}
  fi
  local get_file_list=($(ls ${arg[@]} $list_path | nl))
  if [[ ! -z ${otherOptions} ]]; then
    if [[ -z $listBottom ]]; then
      local get_file_list=("${otherOptions[@]}" "${get_file_list[@]}")
    else
      local get_file_list+=("${otherOptions[@]}")
    fi
  fi
  if [[ -z $get_file_list ]];  then
    if [[ -d "$list_path" ]]; then
      local dir_is_true="\Z2yes\Zn"
    else
      local dir_is_true="\Z1no\Zn"
    fi
    if [[ -z $(ls -1 $list_path) ]]; then
      local dir_is_empty="\Z1yes\Zn"
    else
      local dir_is_empty="\Z2no\Zn"
    fi
    if local test=$(ls -1 $list_path);  then
      local ls_error="\Z2no\Zn"
    else
      local ls_error="\Z1${test}\Zn"
    fi
    Dmsgbox "\Z1错误\Zn" "可以显示的内容为空:\n=> \"\Z4$list_path\Zn\"\n1.该目录是否存在？=>$dir_is_true\n2.该目录是否为空？=>$dir_is_empty\n3.其他错误？=>$ls_error"
    return 1
  fi
  local file_list_menu=$(dialog ${dialog_arg[@]} --no-shadow --backtitle "$4" --title "$2" --menu "$3" $box_sz ${get_file_list[@]} 2>&1 >/dev/tty)
  case $file_list_menu in
    "") return 0 ;;
    *) export returnFileListNum="${file_list_menu}"
    export returnFileName="${get_file_list[$(($file_list_menu+($file_list_menu-1)))]}" ;;
  esac
}
utilsVar+=(returnFileListNum returnFileName)