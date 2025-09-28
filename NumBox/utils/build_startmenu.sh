build_startmenu () {
  local container=$1
  if [[ -d ~/NumBox/data/container/$container ]]; then
    echo "无法找到容器"
  else
    ln -sf $2 "/data/data/com.termux/files/home/NumBox/data/$container/container/新建容器1/disk/drive_c/ProgramData/Microsoft/Windows/Start Menu/$3"
  fi
}
