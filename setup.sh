#!/bin/bash
cd ~
clear
load () {
# INPUT_CMD () { bash $TMPDIR/cmd;}
frames=('-' '\' '|' '/')
!(INPUT_CMD) & pid=$!
while [ "$pid" ]; do
  printf "\r"
  printf "${frames[$((i%4))]}"
  sleep 0.1
  if ! kill -0 "$pid" 2>/dev/null; then
    pid= 
  fi
  : $((i = (i + 1) % 4))
done
echo -e "\n"
}
file_is_full () {
  aaa=$(file $file_name | grep gzip)
  if [[ -z $aaa ]]; then
    echo "$file_name 下载失败,开始重新下载,如果依旧下载失败,请退出后运行 bash ~/setup.sh"
    if [[ $site == https://github.com ]]; then
      echo "当前使用的下载站为 https://github.com 请确保当前网络环境可以正常链接"
      curl --progress-bar -O https://github.com/Waim908/numbox/releases/download/latest/$file_name
    else
      echo "当前使用的加速站为 $site"
      curl --progress-bar -O $site/https://github.com/Waim908/numbox/releases/download/latest/$file_name
    fi
  fi
}
echo "注意,NumBox无法与mobox共存,这会导致mobox的glibc库被覆盖,如果已经安装mobox请先卸载mobox或者清理termux数据。"
echo "安装Tips:"
echo "1.NumBox为x11合体版设计,请先下载x11合体版termux"
echo "2.给予termux全部权限"
echo "3.电池设置允许termux高耗电"
echo "4.任意方法进入adb shell都可,按照网上的教程解除安卓24线程限制"
read -n1 -p "输入y开始安装，其他任意字符退出" select
if [[ ! $select == y ]]; then
    echo "退出"
fi
clear
termux-wake-lock
echo 软件源阶段
termux-change-repo
yes | apt upgrade
echo 安装x11-repo
yes | pkg install x11-repo
echo 开始安装必要软件包
yes | apt install xkeyboard-config xwayland htop openssl wget imagemagick virglrenderer vulkan-tools mangohud mesa-demos pigz tmux virglrenderer-android vulkan-loader vulkan-loader-generic pulseaudio angle-android file
echo 开始安装x11
cd ~/NumBox/npt_install/ && apt install ./*.deb
echo 开始修复依赖
apt install -f -y
echo 开始测试网络延迟
github=$(ping -c 2 github.com | awk -F'/' 'END {print $5}') ; llkk=$(ping -c 2 gh.llkk.cc | awk -F'/' 'END {print $5}') ; ghp=$(ping -c 2 ghproxy.net | awk -F'/' 'END {print $5}') ; moeyy=$(ping -c 2 github.moeyy.xyz | awk -F'/' 'END {print $5}') &&
# echo "PING测试结果如下:"
# echo "1 github.com ($github ms)"
# echo "2 gh.llkk.cc ($llkk ms)"
# echo "3 ghproxy.net ($ghp ms)"
# echo "4 github.moeyy.xyz ($moeyy ms)"
# echo "无需选择为空或者出错的结果"
# read -p "请选择一个下载源(输入数字)：" SELECT
SELECT=$(dialog --no-cancel --title "选择一个站点" --menu "不要选延迟为空或者错误的选项,允许termux高耗电后可以后台下载" 0 0 0 \
       1 "github.com ($github ms)" \
       2 "gh.llkk.cc ($llkk ms)" \
       3 "ghproxy.net ($ghp ms)" \
       4 "github.moeyy.xyz ($moeyy ms)" 2>&1 >/dev/tty)
case $SELECT in
#    *) echo "无效的选项" && exit 0 ;;
    1) echo "开始下载文件(github.com)"
    site=https://github.com
    curl --progress-bar -O https://github.com/Waim908/numbox/releases/download/latest/termux.tar.xz && echo "(1/4)"
    curl --progress-bar -O https://github.com/Waim908/numbox/releases/download/latest/glibc.tar.xz && echo "(2/4)"
    curl --progress-bar -O https://github.com/Waim908/numbox/releases/download/latest/home.tar.xz && echo "(3/4)"
    curl --progress-bar -O https://github.com/Waim908/numbox/releases/download/latest/sdcard.tar.xz && echo "(4/4)" ;;
    2) echo "开始下载文件(gh.llkk.cc)"
    site=https://gh.llkk.cc
    curl --progress-bar -O https://gh.llkk.cc/https://github.com/Waim908/numbox/releases/download/latest/termux.tar.xz && echo "(1/4)"
    curl --progress-bar -O https://gh.llkk.cc/https://github.com/Waim908/numbox/releases/download/latest/glibc.tar.xz && echo "(2/4)"
    curl --progress-bar -O https://gh.llkk.cc/https://github.com/Waim908/numbox/releases/download/latest/home.tar.xz && echo "(3/4)"
    curl --progress-bar -O https://gh.llkk.cc/https://github.com/Waim908/numbox/releases/download/latest/sdcard.tar.xz && echo "(4/4)" ;;
    3) echo "开始下载文件(ghproxy.net)"
    site=https://ghproxy.net
    curl --progress-bar -O https://ghproxy.net/https://github.com/Waim908/numbox/releases/download/latest/termux.tar.xz && echo "(1/4)"
    curl --progress-bar -O https://ghproxy.net/https://github.com/Waim908/numbox/releases/download/latest/glibc.tar.xz && echo "(2/4)"
    curl --progress-bar -O https://ghproxy.net/https://github.com/Waim908/numbox/releases/download/latest/home.tar.xz && echo "(3/4)"
    curl --progress-bar -O https://ghproxy.net/https://github.com/Waim908/numbox/releases/download/latest/sdcard.tar.xz && echo "(4/4)" ;;
    4) echo "开始下载文件(github.moeyy.xyz)"
    site=https://github.moeyy.xyz
    curl --progress-bar -O https://github.moeyy.xyz/https://github.com/Waim908/numbox/releases/download/latest/termux.tar.xz && echo "(1/4)"
    curl --progress-bar -O https://github.moeyy.xyz/https://github.com/Waim908/numbox/releases/download/latest/glibc.tar.xz && echo "(2/4)"
    curl --progress-bar -O https://github.moeyy.xyz/https://github.com/Waim908/numbox/releases/download/latest/home.tar.xz && echo "(3/4)"
    curl --progress-bar -O https://github.moeyy.xyz/https://github.com/Waim908/numbox/releases/download/latest/sdcard.tar.xz && echo "(4/4)" ;;
esac
echo 开始解压文件
INPUT_CMD () { file_name=termux.tar.xz ; tar xf termux.tar.xz && mv ~/startup-wine.sh ~/.. ;} && echo "(1/4)" && file_is_full &&
INPUT_CMD () { file_name=home.tar.xz ; tar xf home.tar.xz ;} && load && echo "(2/4)" && file_is_full &&
INPUT_CMD () { file_name=sdcard.tar.xz ; tar -xf sdcard.tar.xz -C /sdcard ;} && load && echo "(3/4)" && file_is_full &&
INPUT_CMD () { file_name=glibc.tar.xz ; tar -xf glibc.tar.xz -C $PREFIX ;} && load && echo "(4/4)" && file_is_full &&
echo "开始清理文件"
rm -rf ~/home.tar.xz && rm -rf ~/sdcard.tar.xz && rm -rf ~/glibc.tar.xz && rm -rf termux.tar.xz
mv ~/startup-wine.sh $PREFIX/../
echo "安装完成！"
echo "下次启动可以输入以下命令启动NumBox"
echo NumBox
echo numbox
echo nb
termux-wake-unlock
echo "请重启termux"