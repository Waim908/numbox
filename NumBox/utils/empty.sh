create_dir () {
  case $1 in
  sd)
    sdcard_dir=(  
        "/sdcard/NumBox"
        "/sdcard/NumBox/temp"
        "/sdcard/NumBox/ctr_package"
        "/sdcard/NumBox/plugins"
        "/sdcard/NumBox/logs"
        "/sdcard/NumBox/patch"
        "/sdcard/NumBox/resources"
        "/sdcard/NumBox/resources/dxvk"
        "/sdcard/NumBox/resources/cncddraw"
        "/sdcard/NumBox/resources/wined3d"
        "/sdcard/NumBox/resources/vkd3d"
        "/sdcard/NumBox/resources/mono"
        "/sdcard/NumBox/resources/gecko"
        "/sdcard/NumBox/resources/wine"
        "/sdcard/NumBox/resources/drivers"
    )  
    printf "%s\0" "${sdcard_dir[@]}" | parallel -0 mkdir -p ;;
  data)
    data_dir=(
        "$HOME/NumBox/data/container"
        "$HOME/NumBox/data/config"
        "$HOME/NumBox/data/patch"
        "$HOME/NumBox/data/reg"
    )
    printf "%s\0" "${data_dir[@]}" | parallel -0 mkdir -p ;;
  esac
}
copy_config () {
  if [[ ! -v checkFile ]]; then
    echo "数组变量(需要查找的文件)未定义: \$checkFile"
    return 1
  elif [[ ! -v configFile ]]; then
    echo "数组变量(需要复制的文件)未定义: \$configFile"
    return 1
  elif [[ ${#checkFile[@]} -ne ${#configFile[@]} ]]; then
    echo "错误：checkFile 和 configFile 数组长度不一致"
    return 1
  else
    for file_num in "${!checkFile[@]}"
    do
      if [[ -f "${checkFile[$file_num]}" ]]; then
          echo "配置文件找到=> \"${checkFile[$file_num]}\""
      else
          echo "复制文件: \"${configFile[file_num]}\" => \"${checkFile[file_num]}\""
          if ! cp -r -p "${configFile[file_num]}" "${checkFile[file_num]}"; then
            echo "错误，文件复制失败"
            return 1
          fi
      fi
    done
  fi
}
create_dir2 () {
  if [[ ! -v checkDir ]]; then
    echo "数组变量(需要检查是否创建的文件夹)未定义: \$checkDir"
  else
    for mkdir_arg in "${checkDir[@]}"
    do
      if [[ -d "${mkdir_arg}" ]]; then
        echo "找到文件夹=> \"${mkdir_arg}\""
      else
        echo "新建文件夹=> \"$mkdir_arg\""
        if ! mkdir -p "$mkdir_arg";then
          echo "错误，文件夹创建失败"
          return 1
        fi
      fi
    done
  fi
}