#!/bin/bash
read L W H < ~/NumBox/custom-size
now_site=$(cat ~/NumBox/github-site)
now_ver=$(cat ~/NumBox/.version)
sed_site () {
    if [[ $now_site == github.com ]]; then
        dl_url=$URL
    else
        dl_url=https://$now_site/$URL
    fi
}
goback () {
    bash ~/NumBox/Download-resource.sh
}
if [[ ! -f $PATH/wget ]]; then
    echo "检测到 wget 未安装,开始安装..."
    yes | pkg i wget
fi
MAIN_MENU=$(dialog --backtitle "存储路径 /sdcard/NumBox/resource" --title "在线下载资源" --menu "获取资源与NumBox更新" $L $W $H \
    back "🔙返回" \
    site "切换下载站" \
    当前下载站 "$now_site" \
    0 "获取最新版本号信息" \
    1 "下载最新turnip驱动 ( $turnip_ver )" \
    2 "下载最新dxvk ( $dxvk_ver )" \
    3 "下载最新cnc-ddraw ( $cncddraw_ver )" \
    4 "下载最新vkd3d ( $vkd3d_ver )" \
    5 "手动下载dxvk-gplasync(gitlab)" \
    6 "更新NumBox ( 当前$now_ver 最新$new_ver ) " 2>&1 >/dev/tty)
case $MAIN_MENU in
    back) bash ~/NumBox/Numbox ;;
    site) site_menu () {
    now_site=$(cat ~/NumBox/github-site)
    SITE_SELECT=$(dialog --title "设置下载站" --menu "选择或者自定义一个下载站" $L $W $H \
        back "🔙返回" \
        ping "站点延迟测试" \
        当前选择 "$now_site ($8 ms)" \
        1 "github.com ($t1 ms)" \
        2 "gh.llkk.cc ($t2 ms)" \
        3 "ghproxy.cn ($t3 ms)" \
        4 "ghproxy.net($t4 ms)" \
        5 "gitproxy.click ($t5 ms)" \
        6 "github.tbedu.top ($t6 ms)" \
        7 "github.moeyy.xyz ($t7 ms)" \
        custom "自定义下载站" 2>&1 >/dev/tty)
    case $SITE_SELECT in
        back) bash ~/NumBox/Download-resource.sh ;;
        ping) clear
        echo "正在测试,请稍后..."
        t1=$(ping -c 2 github.com | awk -F'/' 'END {print $5}') ; t2=$(ping -c 2 gh.llkk.cc | awk -F'/' 'END {print $5}') ; t3=$(ping -c 2 ghproxy.cn | awk -F'/' 'END {print $5}') ; t4=$(ping -c 2 ghproxy.net | awk -F'/' 'END {print $5}') ; t5=$(ping -c 2 gitproxy.click | awk -F'/' 'END {print $5}') ; t6=$(ping -c 2 github.tbedu.top | awk -F'/' 'END {print $5}') ; t7=$(ping -c 2 github.moeyy.xyz | awk -F'/' 'END {print $5}') ; t8=$(ping -c 2 $now_site | awk -F'/' 'END {print $5}') &&
        site_menu ;;
        当前选择) site_menu ;;
        1) echo "github.com" > ~/NumBox/github-site
        site_menu ;;
        2) echo "gh.llkk.cc" > ~/NumBox/github-site
        site_menu ;;
        3) echo "ghproxy.cn" > ~/NumBox/github-site
        site_menu ;;
        4) echo "ghproxy.net" > ~/NumBox/github-site
        site_menu ;;
        5) echo "gitproxy.click" > ~/NumBox/github-site
        site_menu ;;
        6) echo "github.tbedu.top" > ~/NumBox/github-site
        site_menu ;;
        7) echo "github.moeyy.xyz" > ~/NumBox/github-site
        site_menu ;;
        custom) INPUT_SITE=$(dialog --title "自定义加速站链接" --inputbox "格式示例(无需https://):githubaaa.com" $L $W $H 2>&1 >/dev/tty)
        echo "$INPUT_SITE" > ~/NumBox/github-site 
        goback ;;
    esac 
    }
    site_menu ;;
    当前下载站) goback ;;
    # curl https://api.github.com/repos/doitsujin/dxvk/releases/latest | grep "tag_name" | sed 's/.*"tag_name": "\(.*\)",/\1/'
    0) clear
    export turnip_ver=$(curl https://api.github.com/repos/K11MCH1/WinlatorTurnipDrivers/releases/latest | grep "tag_name" | sed 's/.*"tag_name": "\(.*\)",/\1/') ; export dxvk_ver=$(curl https://api.github.com/repos/doitsujin/dxvk/releases/latest | grep "tag_name" | sed 's/.*"tag_name": "\(.*\)",/\1/') ; export cncddraw_ver=$(curl https://api.github.com/repos/FunkyFr3sh/cnc-ddraw/releases/latest | grep "tag_name" | sed 's/.*"tag_name": "\(.*\)",/\1/') ; export vkd3d_ver=$(curl https://api.github.com/repos/HansKristian-Work/vkd3d-proton/releases/latest | grep "tag_name" | sed 's/.*"tag_name": "\(.*\)",/\1/') ; export dxvk_ver=$(curl https://api.github.com/repos/doitsujin/dxvk/releases/latest | grep "tag_name" | sed 's/.*"tag_name": "\(.*\)",/\1/') ; export cncddraw_ver=$(curl https://api.github.com/repos/FunkyFr3sh/cnc-ddraw/releases/latest | grep "tag_name" | sed 's/.*"tag_name": "\(.*\)",/\1/') ; export new_ver=$(curl https://api.github.com/repos/Waim908/NumBox/releases/latest | grep "tag_name" | sed 's/.*"tag_name": "\(.*\)",/\1/') &&
    goback ;;
    1) clear
    URL=$(curl https://api.github.com/repos/K11MCH1/WinlatorTurnipDrivers/releases/latest | grep "browser_download_url" | sed 's/.*"browser_download_url": "\(.*\)".*/\1/' | grep wcp)
    sed_site
    wget -P /sdcard/NumBox/resource/turnip $dl_url
    goback ;;
    2) clear
    URL=$(curl https://api.github.com/repos/doitsujin/dxvk/releases/latest | grep "browser_download_url" | sed 's/.*"browser_download_url": "\(.*\)".*/\1/' | head -n 1)
    sed_site
    cd /sdcard/NumBox/resource/dxvk
    wget -P /sdcard/NumBox/resource/dxvk $dl_url
    goback ;;
    3) clear
    URL=$(curl https://api.github.com/repos/FunkyFr3sh/cnc-ddraw/releases/latest | grep "browser_download_url" | sed 's/.*"browser_download_url": "\(.*\)".*/\1/' | grep cnc-ddraw.zip)
    sed_site
    wget -P /sdcard/NumBox/resource/cnc-ddraw $dl_url
    goback ;;
    4) clear
    URL=$(curl https://api.github.com/repos/HansKristian-Work/vkd3d-proton/releases/latest | grep "browser_download_url" | sed 's/.*"browser_download_url": "\(.*\)".*/\1/')
    sed_site
    wget -P /sdcard/NumBox/resource/vkd3d $dl_url
    goback ;;
    5) clear
    echo "关于gitlab这个确实没办法"
    echo "手动下载自己想要的版本后(.tar.gz格式的文件),把文件放到/sdcard/NumBox/resource/dxvk-gplasync"
    read -s -n1 -p "输入任意字符返回" && goback ;;
    6) clear
    YES_NO=$(dialog --title "是否更新？" --menu "等待作者更新" $L $W $H \
    back "🔙还是算了吧" \
    update "更新NumBox" 2>&1 >/dev/tty)
    case $YES_NO in
        back) bash ~/NumBox/Download-resource.sh ;;
        update) clear
        URL=$(curl https://api.github.com/repos/Waim908/NumBox/releases/latest | grep "browser_download_url" | sed 's/.*"browser_download_url": "\(.*\)".*/\1/' | grep update.sh)
        sed_site
        wget -P ~ $dl_url && bash ~/update.sh ;;
    esac ;;
esac
