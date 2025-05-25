# 声明路径>$1 ; 指定说明 标题$2 副标题$3 背景标题$4 ; 错误赋值$?=1 排序类型 $list_type
. ~/NumBox/utils/dialog.conf
if [ "$(ls -A $1)" ]; then
if [[ -z $list_type ]]; then
  list_type=A
fi
FILE_COUNT=1
MENU_OPTIONS=()
# MENU_OPTIONS+=("0" "Back (返回)")
while IFS= read -r file; do
    filename=$(basename "$file")
    MENU_OPTIONS+=("$FILE_COUNT" "$filename")
    ((FILE_COUNT++))
done < <(ls -$list_type $1)
if [ ${#MENU_OPTIONS[@]} -eq 0 ]; then
    lsterr=2
fi
selection=$(dialog $arg --title "$2" --backtitle "$4" --menu "$3" $box_sz \
       "${MENU_OPTIONS[@]}" 2>&1 >/dev/tty)
if [[ $? == 0 ]]; then
  let index=($selection-1)*2+1
  export BACK_NAME=${MENU_OPTIONS[$index]}
else
  exit_exec
fi
else
  ls $1 2>/dev/null
  if [[ $? == 0 ]]; then
    dir_is=文件路径下无文件
  else
    dir_is=文件路径不存在
  fi
  dialog ${dialog_arg[@]} --title "$dir_is" --msgbox "$1" $box_sz2
  return 1
fi