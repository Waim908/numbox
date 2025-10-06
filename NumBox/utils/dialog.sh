# 生效方式 ${dialog_arg[@]}
#export DIALOGRC=$HOME/NumBox/.dialogrc
dialog_arg=(--colors --erase-on-exit --no-kill --cancel-label "取消" --exit-label "退出" --no-label "否" --yes-label "是" --ok-label "确定")
box_sz="0 -1 0"
box_sz2="-1 -1"
Dmsgbox () {
    dialog ${dialog_arg[@]} --title "$1" --msgbox "$2" $box_sz2 2>&1 >/dev/tty
}
Dmenu () {
    export DMENU=$(dialog ${dialog_arg[@]} --title "$1" --menu "$2" $box_sz ${Dmenu_select[@]} 2>&1 >/dev/tty)
    if [[ ${#DMENU} -gt 30 ]]; then
      dialog --title "字符串过长，不影响使用仅提示" --msgbox "$DMENU" $box_sz2
    fi
}
Dyesno () {
    dialog ${dialog_arg[@]} --title "$1" --yesno "$2" $box_sz2 2>&1 >/dev/tty
}
Dinputbox () {
    export DINPUTBOX=$(dialog ${dialog_arg[@]} --title "$1" --inputbox "$2" $box_sz2 "$3" 2>&1 >/dev/tty)
}
utilsVar+=(DMENU Dmenu_select DINPUT)
# \Z0 黑色

# \Z1 红色

# \Z2 绿色

# \Z3 黄色

# \Z4 蓝色

# \Z5 洋红色

# \Z6 青色

# \Z7 白色

# \Zb 加粗

# \Zn 恢复正常