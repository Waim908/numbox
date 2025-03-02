# 声明路径>$1 ; 指定说明 标题$2 副标题$3 背景标题$4 ; 错误赋值$lsterr=1 取消选择 2 路径下无文件 ; 排序类型 $list_type
read L W H < ~/NumBox/custom-size
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
selection=$(dialog --cancel-label "返回" --title "$2" --backtitle "$4" --menu "$3" $L $W $H \
       "${MENU_OPTIONS[@]}" 2>&1 >/dev/tty)
if [ -z "$selection" ]; then
    lsterr=1
fi
let index=($selection-1)*2+1
BACK_NAME=${MENU_OPTIONS[$index]}