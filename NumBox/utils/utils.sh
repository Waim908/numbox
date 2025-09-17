import () {
  if [[ -z $utilsPath ]]; then
    export utilsPath="$HOME/NumBox/utils"
  fi
  if [[ $utilsDoNotReimport == 1 ]]; then
    echo "不重复调用utils已启用"
    if [[ -v ${utilsScriptPath} ]]; then
      export utilsScriptPath=()
    fi
    # 变量值不要有空格
    if [[ ${utilsScriptPath[@]} =~ "${utils_path}/${1}" ]]; then
      echo "\"${utilsPath}/${1}\"已经调用过了"
    else
      if ! . "${utilsPath}/${1}"; then
        echo "\"${utils_path}/${1}\"调用失败"
        return 1
      else
        utilsScriptPath+=("${utils_path}/${1}")
      fi
    fi
  else
    if ! . "${utilsPath}/${1}"; then
      echo "\"${utilsPath}/${1}\"调用失败"
      return 1
    fi
  fi
}

unset_utils_var () {
  # 类型可以是env var 或者函数
  for var in "${utilsVar[@]}"
  do
    unset $var
  done
}