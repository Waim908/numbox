#!/bin/bash
. ~/NumBox/utils/dialog.conf
if [[ ! -v CONTAINER_NAME ]]; then
  if [[ ! -z $1 ]]; then
    export CONTAINER_NAME=$1
    if [[ ! -d ~/NumBox/data/container/${CONTAINER_NAME} ]]; then
      echo -e "容器 \e[33m ${CONTAINER_NAME} \e[0m 不存在"
      exit 1
    fi
  else
    exit_exec () { . ~/NumBox/Numbox;}
    . ~/NumBox/utils/file_list.sh
    file_list "$HOME/NumBox/data/container/" "选择一个容器"
    if [[ -z $BACK_NAME ]]; then
      . ~/NumBox/Numbox
    else
      export CONTAINER_NAME=${BACK_NAME}
    fi
  fi
fi
parallel "pkill -f com.termux.x11" "pulseaudio -k" "termux-x11:0"

. ~/NumBox/data/contaienr/${CONTAINER_NAME}/config/default.conf
. ~/NumBox/data/contaienr/${CONTAINER_NAME}/config/box64.conf
