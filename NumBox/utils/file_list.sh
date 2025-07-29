# 声明路径>$1 ; 指定说明 标题$2 副标题$3 背景标题$4 ; 排序类型 $list_type
#. ~/NumBox/utils/dialog.conf
file_list() {
    if [[ -d $1 ]]; then
        if [[ -z $2 ]]; then
            list_type=A  # 默认按字母排序
        else
            list_type=$2
        fi
    fi
    

        MENU_OPTIONS=()
        
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
        done < <(ls -$list_type "$1")

        # 3. 显示菜单并处理选择
        selection=$(dialog "${dialog_arg[@]}" --title "$2" --backtitle "$4" \
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
    elif [[ -z $selection ]]; then
        exit_exec
    else
        # 错误处理（目录不存在或为空）
        ls "$1" 2>/dev/null
        if [[ $? == 0 ]]; then
            dialog "${dialog_arg[@]}" --title "错误：空目录" --msgbox "$1" $box_sz2
        else
            dialog "${dialog_arg[@]}" --title "错误：路径无效" --msgbox "$1" $box_sz2
        fi
        exit_exec
    fi
}