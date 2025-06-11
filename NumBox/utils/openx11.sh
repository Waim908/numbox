stopx11 () {
    if [[ -f "/data/data/com.termux/usr/bin/stopserver" ]]; then
        /data/data/com.termux/usr/bin/stopserver
    else
        pkill -f com.termux.x11
    fi
}
startx11 () {
    if [[ $AM_JUMP == 1 ]]; then
        if [[ -f "/data/data/com.termux/usr/bin/stopserver" ]]; then
            echo 当前为termux合体版，不再跳转到x11客户端
            termux-x11 :$1
        else
            termux-x11 :$1
            am start --user 0 -n com.termux.x11/.MainActivity
        fi
    else
        termux-x11 :$1 &
    fi
}