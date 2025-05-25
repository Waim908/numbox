stopserver () {
    if [[ -f "/data/data/com.termux/usr/bin/stopserver" ]]; then
        /data/data/com.termux/usr/bin/stopserver
    else
        pkill -f com.termux.x11
    fi
}