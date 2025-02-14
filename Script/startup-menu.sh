#!/bin/bash
clear
read L W H < ~/NumBox/custom-size
goback () {
  bash ~/NumBox/startup-menu.sh
}
START_MENU=$(dialog --no-cancel --no-shadow --backtitle "NumBox GPU_drive: $drive_type" --title "$CONTAINER_NAME" --menu "如果卡顿,小窗termux" $L $W $H \
  taskmgr "wine任务管理器" \
  killtaskmgr "杀死wine任务管理器进程" \
  run "运行" \
  1 "查看日志" \
  2 "htop任务管理器" \
  3 "wine命令行" \
  shutdown "结束容器实例" \
  restart "重启容器" \
  shell "termux终端" \
  doc "查看帮助" 2>&1 >/dev/tty)
case $START_MENU in
  taskmgr) clear
  box64 wine explorer /desktop=shell,$screen taskmgr >/dev/null &
  goback ;;
  killtaskmgr) clear
  box64 wine cmd /c "taskkill /f /im taskmgr.exe" >/dev/null &
  goback ;;
  run) RUN_P=$(dialog --title "运行" --inputbox "输入要运行的程序" $L $W $H 2>&1 >/dev/tty)
  box64 wine explorer /desktop=shell,$screen $RUN_P >/dev/null &
  goback ;;
  1) tmux attach -t 0 && goback ;;
  2) htop && goback ;;
  3) clear
  box64 wine cmd && goback ;;
  shutdown) clear
  box64 wineserver -k >/dev/null 2>&1
  pulseaudio -k >/dev/null 2>&1
  pkill -f virgl_test_server_android
  pkill -f virgl_test_server
  stopserver
  tmux kill-session -t 0
  tmux kill-session -t 1
  termux-wake-unlock
  echo "结束" ;;
  restart) clear
  box64 wineserver -k >/dev/null 2>&1
  bash ~/NumBox/startup-container.sh ;;
  shell) tmux new -d -s 1
  tmux attach -t 1 && bash ~/NumBox/startup-menu.sh ;;
  doc) clear
  cat ~/NumBox/doc/startup.txt
  read -s -n1 -p "输入任意字符返回" && goback ;;
esac