stopx11 () {
    if [[ -f "/data/data/com.termux/usr/bin/stopserver" ]]; then
        . /data/data/com.termux/usr/bin/stopserver
    else
        pkill -f com.termux.x11
    fi
}
startx11 () {
    if [[ $AM_JUMP == 1 ]]; then
        if [[ -f "/data/data/com.termux/usr/bin/stopserver" ]]; then
            echo 当前为termux合体版，不再跳转到x11客户端
            termux-x11 :$@ &
        else
            termux-x11 :$@ &
            if ! am start --user 0 -n com.termux.x11/.MainActivity; then
                echo 无法跳转到termux-x11客户端Activity，是否安装termux-x11客户端？或者手动打开客户端
            fi
        fi
    else
        termux-x11 :$@ &
    fi
}
get_res () {
    case $1 in
        Xscreen) if ! xrandr | grep -oP 'current \K\d+ x \d+' | tr -d ' '; then 
            echo -e "不支持xrandr命令，请通过 \e[32mpkg i xorg-xrandr\e[37m 命令安装"
            return 1
        fi ;;
        Xfps) if ! xrandr | grep -oP '\d+\.\d+\*'; then
            echo -e "不支持xrandr命令，请通过 \e[32mpkg i xorg-xrandr\e[37m 命令安装"
            return 1
        fi ;;
        Pscreen) if ! termux-x11-preference list > $TMPDIR/termux-x11-preference-info; then
                echo -e "无法获取，可能是termux-x11客户端APP未在前台或后台运行，亦或者此版本不支持 \e[32mtermux-x11-preference\e[37m 命令"
                return 1
            fi
            if [[ -f $TMPDIR/termux-x11-preference-info ]]; then
                export displayResType=$(grep "displayResolutionMode" $TMPDIR/termux-x11-preference-info | cut -d'=' -f2 | tr -d '"')
                case $displayResType in
                    exact) export screenRes=$(grep "displayResolutionCustom" $TMPDIR/termux-x11-preference-info | cut -d'=' -f2 | tr -d '"') ;;
                    custom) export screenRes=$(grep "displayResolutionCustom" $TMPDIR/termux-x11-preference-info | cut -d'=' -f2 | tr -d '"') ;;
                    native) if ! screenRes=$(xrandr | grep -oP 'current \K\d+ x \d+' | tr -d ' '); then 
                        echo -e "不支持xrandr命令，无法获取分辨率，请通过 \e[32mpkg i xorg-xrandr\e[37m 命令安装"
                        return 1
                    fi ;;
                esac
            else
                echo -e "无法找到文件 \e[33m$TMPDIR/termux-x11-preference-info\e[37m"
                return 1
            fi ;;
    esac
}