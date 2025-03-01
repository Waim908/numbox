# 声明路径>$1 ; 指定说明>$2 ; 错误赋值$lsterr=1
read L W H < ~/NumBox/custom-size
FILE_COUNT=1
MENU_OPTIONS=()
# MENU_OPTIONS+=("0" "Back (返回)")
while IFS= read -r file; do
    filename=$(basename "$file")
    MENU_OPTIONS+=("$FILE_COUNT" "$filename")
    ((FILE_COUNT++))
done < <(ls -A $1)
if [ ${#MENU_OPTIONS[@]} -eq 0 ]; then
    lsterr=1
fi
selection=$(dialog --cancel-label "返回" --title "$2选择" --menu "请选择一个$2" $L $W $H \
       "${MENU_OPTIONS[@]}" 2>&1 >/dev/tty)
if [ -z "$selection" ]; then
    lsterr=1
fi
let index=($selection-1)*2+1
BACK_NAME=${MENU_OPTIONS[$index]}