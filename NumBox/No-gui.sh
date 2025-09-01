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
    CUSTOM_FILE_LIST_OPTIONS=(J "跳过容器选择，glibc Only")
    file_list "$HOME/NumBox/data/container/" "无图形界面启动(Debug Wrapper)" "glibc + wine"
    if [[ -z $BACK_NAME ]]; then
      . ~/NumBox/Numbox
    elif [[ $BACK_NUM == J ]]; then
      unset CONTAINER_NAME
    else
      export CONTAINER_NAME=${BACK_NAME}
    fi
  fi
fi
echo "使用exit命令退出环境"
. ~/NumBox/utils/boot.conf
if [[ ! -z $CONTAINER_NAME ]]; then
    . ~/NumBox/utils/path.conf
    . ~/NumBox/data/container/"${CONTAINER_NAME}"/config/box64.conf
    . ~/NumBox/data/container/"${CONTAINER_NAME}"/config/default.conf
    echo 当前WINE环境所有可执行命令如下：
    ls ~/NumBox/data/container/"${CONTAINER_NAME}"/wine/bin/
    echo "强行结束wine: \$ pkill -f -9 wine"
    echo "或者停止wineserver: \$ box64 wineserver -k"
    echo "执行方法：\$ box64 [可执行命令]"
else
  unset WINEPREFIX
fi
#export PS1="(glibc)\u@\h \w $ "
$PREFIX/glibc/bin/bash