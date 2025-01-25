#!/bin/bash
clear
load () {
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
cp /sdcrad/setup.sh ~
echo "注意,NumBox无法与mobox共存,这会导致mobox的glibc库被覆盖,如果已经安装mobox请先卸载mobox或者清理termux数据。"
echo "安装Tips:"
echo "1.NumBox为x11合体版设计,请先下载x11合体版termux"
echo "2.给予termux全部权限"
echo "3.电池设置允许termux高耗电"
echo "4.任意方法进入adb shell都可,按照网上的教程解除安卓24线程限制"
echo "5.确保NumBox数据包在/sdcard/NumBox数据包.tar.xz (或者/storage/emulated/0/NumBox数据包.tar.xz)如果此包不存在将跳转到123网盘下载链接"
read -n1 -p "输入y开始安装，其他任意字符退出" select
if [[ ! $select == y ]]; then
    echo "退出"
fi
clear
termux-wake-lock
if [[ -f /sdcard/NumBox数据包.tar.xz ]]; then
    echo "已经存在数据包"
else
    clear
    echo "https://space.bilibili.com/483380143"
    echo "前往作者b站获取数据包下载,如果已下载数据包,请把NumBox数据包.tar.xz放在/sdcard 目录下(或者叫 /storage/emulated/0 目录下)"
    exit 0
fi
echo 开始解压文件
INPUT_CMD () { tar -xf /sdcard/NumBox数据包.tar.xz -C ~ ;} && load && echo "(1/4)"
INPUT_CMD () { tar -xf ~/home.tar.xz -C ~ ;} && load && echo "(2/4)"
INPUT_CMD () { tar -xf ~/sdcard.tar.xz -C /sdcard ;} && load && echo "(3/4)"
INPUT_CMD () { tar -xf ~/glibc.tar.xz -C $PREFIX ;} && load && echo "(4/4)"
echo "开始清理文件"
rm -rf ~/home.tar.xz && rm -rf ~/sdcard.tar.xz && rm -rf ~/glibc.tar.xz
mv ~/startup-wine.sh $PREFIX/../
echo 软件源阶段
termux-change-repo
yes | apt upgrade
echo 安装x11-repo
yes | pkg install x11-repo
echo 开始安装必要软件包
yes | apt install xkeyboard-config xwayland htop openssl wget imagemagick virglrenderer vulkan-tools mangohud mesa-demos pigz tmux virglrenderer-android vulkan-loader vulkan-loader-generic mangohud pulseaudio angle-android
echo 开始安装本地deb包
cd ~/NumBox/npt_install/ && apt install ./*.deb
echo 开始安装通用vulkan驱动
cd ~/NumBox/npt_install/drive && apt insatll ./mesa-vulkan-icd-wrapper_*.deb
echo "开始禁用turnip(非dri3)驱动更新,因为更新会导致termux软件源里的旧驱动取代新驱动"
apt-mark  hold mesa-vulkan-icd-freedreno
echo 开始修复依赖
yes | apt install -f
echo 开始删除不必要的软件包
yes | apt autoremove
echo "安装完成！"
echo "下次启动可以输入以下命令启动NumBox"
echo NumBox
echo numbox
echo nb
termux-wake-unlock
echo "安装完成,请重启termux!"