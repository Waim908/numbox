#!/bin/bash
. ~/NumBox/utils/dialog.conf
if [[ ! -z $1 ]]; then
    export CONTAINER_NAME=$1
    if [[ -d ~/NumBox/data/container/${CONTAINER_NAME} ]]; then
        export CONTAINER_NAME
    else
        echo -e "\e[31m容器 \e[33m${CONTAINER_NAME}\e[33m 不存在\e[37m"
    fi
else
    exit_exec () {
        . ~/NumBox/Numbox
    }
    export -f exit_exec
    . ~/NumBox/utils/file_list.sh
    file_list ~/NumBox/data/container/ "选择一个容器打开"
    if [[ -z $BACK_NAME ]]; then
        . ~/NumBox/Numbox
    elif [[ -d ~/NumBox/data/container/${BACK_NAME} ]]; then
        export CONTAINER_NAME=${BACK_NAME}
        echo 1
    else
        echo -e "\e[31m容器 \e[33m${BACK_NAME}\e[33m 不存在\e[37m"
    fi
fi
. ~/NumBox/utils/openx11.sh
. ~/NumBox/utils/load.sh
. ~/NumBox/utils/dialog.conf
. ~/NumBox/data/container/${CONTAINER_NAME}/config/default.conf
. ~/NumBox/utils/boot.conf
pulseaudio -k
stopx11
startx11 0
box64 wine explorer /desktop=shell,1280x720 >/dev/null 2>&1 &
