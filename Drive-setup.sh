#!/bin/bash
# 此脚本已弃用！！！！
# 此脚本已弃用！！！！
# 此脚本已弃用！！！！
# 原因：wrapper驱动需要在bionic环境才能正常工作
clear
read L W H < ~/NumBox/custom-size
exp_set=$(cat ~/NumBox/drive/vulkan.conf | grep exp_libvulkan= | sed "s/exp_libvulkan=//")
MAIN_MENU=$(dialog --title "Termux图形驱动设置" --menu "选择一个类型" $L $W $H \
    0 "🔙返回" \
    1 "Vulkan类型" \
    2 "GL类型"  \
    3 "实验性libvulkan动态链接库" \
    实验性libvulkan "$exp_set" \
    doc "关于图形驱动" 2>&1 >/dev/tty)
case $MAIN_MENU in
    实验性libvulkan) bash ~/NumBox/Drive-setup.sh ;;
    0) bash ~/NumBox/Numbox ;;    
    1) VK_SET=$(dialog --title "Vulkan" --menu "选择" $L $W $H \
        0 "🔙返回" \
        1 "turnip(骁龙)" \
        2 "wrapper(通用)" \
        3 "termux-turnip(软件源)" \
        4 "termux-turnip-dri3(软件源)" \
        view "查看已经安装的vulkan软件包" \
        view2 "查看当前可安装本地包版本" 2>&1 >/dev/tty)
        case $VK_SET in
            0) bash ~/NumBox/Drive-setup.sh ;;
            1) clear
            echo "正在安装turnip驱动"
            apt autoremove -y mesa-vulkan-icd-freedreno
            apt autoremove -y mesa-vulkan-icd-freedreno-dri3
            apt autoremove -y mesa-vulkan-icd-wrapper
            # cd ~/NumBox/npt_install/drive
            apt install -y --allow-change-held-packages ~/NumBox/npt_install/drive/mesa-vulkan-icd-freedreno_*_aarch64.deb &&
            bash ~/NumBox/Drive-setup.sh ;;
            2) clear
            echo "正在安装wrapper驱动"
            apt autoremove -y mesa-vulkan-icd-freedreno
            apt autoremove -y mesa-vulkan-icd-freedreno-dri3
            # cd ~/NumBox/npt_install/drive
            apt install -y ~/NumBox/npt_install/drive/mesa-vulkan-icd-wrapper_*_aarch64.deb
            bash ~/NumBox/Drive-setup.sh ;;
            3) clear
            echo "正在安装termux-turnip驱动"
            apt autoremove -y mesa-vulkan-icd-freedreno
            apt autoremove -y mesa-vulkan-icd-freedreno-dri3
            apt autoremove -y mesa-vulkan-icd-wrapper
            apt update && yes | apt install mesa-vulkan-icd-freedreno-dri3
            bash ~/NumBox/Drive-setup.sh ;;
            4) clear
            echo "正在安装termux-turnip-dri3驱动"
            apt autoremove -y mesa-vulkan-icd-freedreno
            apt autoremove -y mesa-vulkan-icd-freedreno-dri3
            apt autoremove -y mesa-vulkan-icd-wrapper
            apt update && yes | apt install mesa-vulkan-icd-freedreno-dri3
            bash ~/NumBox/Drive-setup.sh ;;
            view) clear
            dpkg -l | grep "vulkan"
            read -s -n1 -p "输入任意字符返回" && bash ~/NumBox/Drive-setup.sh ;;
            view2) clear
            ls ~/NumBox/npt_install/drive
            read -s -n1 -p "输入任意字符返回" && bash ~/NumBox/Drive-setup.sh ;;
        esac ;;
    2) dialog --title "GL" --msgbox "目前支持VirGL渲染" $L $W && bash ~/NumBox/Drive-setup.sh ;;
    3) exp_setmenu=$(dialog --title "实验性libvulkan" --menu "选择" $L $W $H \
        0 "🔙返回" \
        1 "开启" \
        2 "关闭" 2>&1 >/dev/tty)
        case $exp_setmenu in
            0) bash ~/NumBox/Drive-setup.sh ;;
            1) sed -i "s/exp_libvulkan=.*$/exp_libvulkan=true/g" ~/NumBox/drive/vulkan.conf
            bash ~/NumBox/Drive-setup.sh ;;
            2) sed -i "s/exp_libvulkan=.*$/exp_libvulkan=false/g" ~/NumBox/drive/vulkan.conf
            bash ~/NumBox/Drive-setup.sh ;;
        esac ;;
    doc) clear
    cat ~/NumBox/doc/about_drive.txt
    read -s -n1 -p "输入任意字符返回" && bash ~/NumBox/Drive-setup.sh ;;
esac