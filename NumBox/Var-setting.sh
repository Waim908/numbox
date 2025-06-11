#!/bin/bash
. ~/NumBox/utils/dialog.conf
. ~/NumBox/utils/var_edit.sh
if [[ ! -v CONTAINER_NAME ]]; then
    if [[ ! -z $1 ]]; then
        CONTAINER_NAME=$1
    else
        echo "参数为空"
        exit 1
    fi
fi
. ~/NumBox/utils/path.conf
sed_var_dialog () {
    if [[ "$BACK_NAME" =~ ^[[:alnum:]_]+=.*$ ]]; then
        varName="${BACK_NAME%%=*}"
        varValue="${BACK_NAME#*=}"   
        form_var=$(dialog ${dialog_arg[@]} --backtitle "开头添加#号可保留变量且不生效" --title "编辑" --form "" $box_sz \
            "变量名" 1 1 "$varName" 1 10 1000 0 \
            "变量值" 2 1 "$varValue" 2 10 1000 0 2>&1 >/dev/tty)
        temp_status=$?
        if [[ -z $form_var ]]; then
            go_back
        elif [[ $temp_status == 3 ]]; then
            dialog --erase-on-exit --no-kill --title "是否删除此变量？"  --yes-label "取消" --no-label "确定" --yesno "$BACK_NAME" $box_sz2
            yesno=$?
            case $yesno in
                0) go_back ;;
                1) edit_var del "$BACK_NAME" ;;
            esac
        else
            array_var=($form_var)
            newVarName=${array_var[0]}
            newVarValue=${array_var[1]}
            edit_var sed2 "$varName" "$newVarName" "$newVarValue" $var_file
            go_back
        fi
    else
        form_var=$(dialog ${dialog_arg[@]} --title "编辑" --form "不是有效的变量值" $box_sz \
            "字符串" 1 1 "$BACK_NAME" 1 10 1000 0 2>&1 >/dev/tty)
        if [[ -z $form_var ]]; then
            go_back
        else
            sed -i "s%${BACK_NAME}%${form_var}%g" $var_file
            go_back
        fi
    fi
}
select=$(dialog ${dialog_arg[@]} --title "变量设置" --backtitle "$(cat ~/NumBox/default/ctr/README)" --menu "" $box_sz \
    1 "设置容器变量" \
    2 "设置Box64变量" \
    3 "重置为默认容器变量" 2>&1 >/dev/tty)
if [[ -z $select ]]; then
    . ~/NumBox/Numbox
fi
case $select in
    1) exit_exec () { . ~/NumBox/Var-setting.sh;}
    go_back () { set_ctr_var;}
    set_ctr_var () {
        export var_file=$ctr_conf_path/default.conf
        var_list $var_file
        case $BACK_NAME in
            *) sed_var_dialog "${CONTAINER_NAME}" ;;
        esac
    }
    set_ctr_var
    ;;
esac