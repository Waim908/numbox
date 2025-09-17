#!/bin/bash
. ~/NumBox/utils/dialog.sh
export loadStrict=1
. ~/NumBox/utils/load.sh
. ~/NumBox/utils/file_list.sh
if [[ -z $(ls -A ~/NumBox/data/container/) ]]; then
    CUSTOM_FILE_LIST_OPTIONS=("C" "\Z2创建容器?\Zn" "E" "\Z1当前没有可删除的容器\Zn")
else
    CUSTOM_FILE_LIST_OPTIONS=("I" "\Z2查看详情?\Zn" "A" "\Z2删除所有容器？\Zn")
fi
file_list "$HOME/NumBox/data/container/" "\Z1删除容器\Zn" "选择一个需要删除的容器" "$HOME/NumBox/data/container/"
if [[ -z $BACK_NAME ]] || [[ $BACK_NUM == E ]]; then
    . ~/NumBox/Numbox
elif [[ $BACK_NUM == I ]]; then
    ls -lht ~/NumBox/data/container/
    echo "大小："
    du -sh ~/NumBox/data/container/*/
    echo "总占用："
    du -sh ~/NumBox/data/container/
    read -s -n1 -p "输入任意字符返回" && . ~/NumBox/Del-container.sh
elif [[ $BACK_NUM == A ]]; then
    dialog --colors --erase-on-exit --no-kill --title "\Z1删除所有容器？\Zn"  --yes-label "否" --no-label "删除" --yesno "$(ls ~/NumBox/data/container/)" $box_sz2
    if [[ $? == 1 ]]; then
        dialog --colors --erase-on-exit --no-kill --title "\Z1最后一次确认，是否删除所有容器？\Zn"  --yes-label "否" --no-label "删除" --yesno "$(ls ~/NumBox/data/container/)" $box_sz2
        if [[ $? == 1 ]]; then
            if ! load "rm -rf ~/NumBox/data/container/${BACK_NAME}" "正在删除容器"; then
                echo 部分或所有容器删除失败
                return 1
            fi
        else
            . ~/NumBox/Del-container.sh
        fi
    else
        . ~/NumBox/Del-container.sh
    fi
elif [[ $BACK_NUM == C ]]; then
    . ~/NumBox/Create-container.sh
elif [[ -d ~/NumBox/data/container/${BACK_NAME} ]]; then
    dialog --colors --erase-on-exit --no-kill --title "是否删除容器？" --yes-label "否" --no-label "删除" --yesno "容器名：\Z3$BACK_NAME\Zn 大小/路径：$(du -sh ~/NumBox/data/container/${BACK_NAME})" $box_sz2
    if [[ $? == 1 ]]; then 
        if ! load "rm -rf ~/NumBox/data/container/${BACK_NAME}" "正在删除容器"; then
            echo 容器删除失败
            return 1
        fi
    else
        . ~/NumBox/Del-container.sh
    fi
else
    echo 错误
fi