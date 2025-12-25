while [ -n $1 ]; do
  case $1 in
  --res) local screen_res=$2 ;;
  --no-desktop)
    local exec_arg="$2"
    shift
    ;;
  --no-shelldesktop)
    local exec_arg="explorer /desktop=desktop_one,$screen_res $3"
    shift
    ;;
  --custom-exec-arg)
    local exec_arg="$2"
    shift
    ;;
  --desktop)
    local exec_arg="explorer /desktop=shell,$screen_res $3"
    shift
    ;;
  esac
  shift
done
# numbox_startup.exe 1
exec_box64_wine() {
  if [[ $writeLog == true ]] && [[ $displayLog == true ]]; then
    taskset -c $tasksetUseCore nice -n $niceNum box64 wine $exec_arg | tee /sdcard/NumBox/logs/box64wine_debug.log
  elif [[ $writeLog == true ]] && [[ $displayLog == false ]]; then
    taskset -c $tasksetUseCore nice -n $niceNum box64 wine $exec_arg >/sdcard/NumBox/logs/box64wine_debug.log
  elif [[ $writeLog == false ]] && [[ $displayLog == true ]]; then
    taskset -c $tasksetUseCore nice -n $niceNum box64 wine $exec_arg
  elif [[ $writeLog == false ]] && [[ $displayLog == false ]]; then
    taskset -c $tasksetUseCore nice -n $niceNum box64 wine $exec_arg >/dev/null 2>&1
  else
    taskset -c $tasksetUseCore nice -n $niceNum box64 wine $exec_arg
  fi
}
if ! exec_box64_wine; then
  if ! st dialog --title "\Z1启动失败！\Zn" --msgbox "返回值为=> $?，返回终端以查看详情" 999 999; then
    echo "启动失败"
  fi
fi
