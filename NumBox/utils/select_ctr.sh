select_ctr () {
  if [[ ! -z $1 ]]; then
      export CONTAINER_NAME="$1"
      if [[ ! -d ~/NumBox/data/container/"${CONTAINER_NAME}" ]]; then
        echo -e "容器 \e[33m ${CONTAINER_NAME} \e[0m 不存在"
        return 1
      fi
  else
      # need ```import file_list.sh```
      if ! file_list "$HOME/NumBox/data/container/" "选择一个容器"; then
        return 1
      else
        export CONTAINER_NAME="${returnFileListName}"
      fi
  fi
}