# 重写几乎所有代码，开始2.0部分编写

# Tasklist

1.实现自定义导入PREFIX前缀包

2.不使用任何第三方桌面环境实现自动读取termux-x11客户端设置的分辨率启动

3.通过markdown实现帮助文档

4.加入更多可选驱动（swrast virtio panfrost）


## 关于

在termux上的glibc环境运行wine，支持容器管理和容器的导入导出

## 安装步骤(至少保留>=10G的存储空间用来存放容器和NumBox)

###### 注意，无法与mobox共存

# termux和x11合体版（因为都在前台跑所以不会锁CPU核心为小核更加流畅）

1. 下载[termux合体版修改](https://github.com/Waim908/termux-app/releases/tag/1.0.5.1) or [termux合体版](https://github.com/jiaxinchen-max/termux-app/releases/tag/1.0.5)
###### 1.1 使用termux合体版前请关闭系统深色模式，要不然字体看不到
###### 1.2 其次合体版安装时，如果你已经安装了termux , termux x11..... 等软件，需要先卸载否则会有包名冲突
###### 1.3 需要给予termux所有权限，电池设置允许termux后台高耗电
###### 1.4 点启动》设置》 在里面打开悬浮窗，通过悬浮窗启动命令行
###### 1.5 任意方法进入adb shell 按照网上的教程解除安卓32线程限制


# 更新日志

## 1.0

支持容器功能，支持容器打包和导入，可更换d3d环境，可选vulkan驱动，
~~支持自定义壁纸自动转换bmp格式~~（此功能会导致渲染错误，目前暂时无法解决），支持注册表功能，创建容器集成了很多软件（如播放器和运行库），支持调试日志功能，加入在线下载资源，可更换下载站适应大陆网络环境

## 2.0

开发中

# 使用的开源项目
[glibc包](https://github.com/mebabo1/menano)

[glibc](https://github.com/termux-pacman/glibc-packages)

[box64](https://github.com/ptitSeb/box64)

[dxvk](https://github.com/doitsujin/dxvk)

[dxvk-async](https://gitlab.com/Ph42oN/dxvk-gplasync)

[dxvk-gplasync](https://gitlab.com/Ph42oN/dxvk-gplasync)

[cnc-ddraw](https://github.com/FunkyFr3sh/cnc-ddraw)

[vkd3d](https://github.com/HansKristian-Work/vkd3d-proton)

[wined3d](https://fdossena.com/?p=wined3d/index.frag)

[mesa3d](https://www.mesa3d.org/)

[wine](https://www.winehq.org)

[wine-termux](https://github.com/Waim908/wine-termux)

[termux](https://github.com/termux/termux-app/)

[termux-x11](https://github.com/termux/termux-x11)

[termux与x11合体版](https://github.com/jiaxinchen-max/termux-app)

[wine主题](https://github.com/listumps/wine_themes)

[turnip驱动](https://github.com/K11MCH1/WinlatorTurnipDrivers)

[参考与部分文件](https://github.com/K11MCH1/WinlatorTurnipDrivers)

