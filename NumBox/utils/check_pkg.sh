check_pkg () {
  if [[ -v check_pkg_arg ]]; then
    if [[ -z $2 ]]; then
      echo "未定义要查找的包"
      return 1
    else
      check_pkg_arg="$2"
    fi
  fi
  case $1 in
    pkg) for i in "$check_pkg_arg"; 
    do {
      if dpkg-query -L ${i} >/dev/null; then
        echo "找到软件包${i}"
      else
        echo "无法找到软件包${i}"
      fi
    } &
    done
    ;;
    command) for i in "$check_pkg_arg"; 
    do {
      if command -v ${i} >/dev/null; then
        echo "找到命令${i}"
      else
        echo "无法找到命令${i}"
      fi
    } &>/dev/null
    done
    ;;
    *) echo "未定义查找类型，可用 check_pkg pkg 或者 command 参数二 输包名或定义数组变量chech_pkg_arg" && return 1 ;;
  esac
}