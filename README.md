# 重写几乎所有代码，开始2.0部分编写

## 关于

在termux上的glibc环境运行wine，支持容器管理和容器的导入导出

## 安装步骤(至少保留>=10G的存储空间用来存放容器和NumBox)

###### 注意，无法与mobox共存

1. 下载[termux合体版](https://github.com/jiaxinchen-max/termux-app/releases/tag/1.0.5)
###### 1.1 使用termux合体版前请关闭系统深色模式，要不然字体看不到
###### 1.2 其次合体版安装时，如果你已经安装了termux , termux x11..... 等软件，需要先卸载否则会有包名冲突
###### 1.3 需要给予termux所有权限，电池设置允许termux后台高耗电
###### 1.4 点启动》设置》 在里面打开悬浮窗，通过悬浮窗启动命令行
###### 1.5 任意方法进入adb shell 按照网上的教程解除安卓24线程限制

2. 执行
```curl -O https://github.com/Waim908/numbox/releases/download/latest/setup.sh && bash ~/setup.sh```

使用任意加速站点解决国内github有时无法访问问题，[参照](https://github.akams.cn/)

```curl -O https://加速站/https://github.com/Waim908/numbox/releases/download/latest/setup.sh && bash ~/setup.sh```

3.重启termux

# 其他

如果设置壁纸导致渲染错误(如画面非驱动原因导致的严重撕裂，比如在桌面左下角菜单选择时画面产生的撕裂)，进入容器后点击左下角起点菜单，选择 0.开头的 运行bat脚本，黑窗口执行完后重启你的容器

1.容器导入后需要重启一次

2.首次创建容器默认是wined3d，你可以在容器设置里换成dxvk

~~3.首次安装是wrapper驱动而不是turnip驱动，如果你想，也可以换成turnip驱动~~ （后面考虑加入wine arm64 bionic环境支持）

3.wrapper无法在glibc环境正常工作，因为依赖项来自安卓bionic(即/system/lib64)，故仅能在termux原装环境正常工作

~~肝不动了，草~~

创建容器的工作目录使用termux-wine这个仓库的包后会有工作目录报错，是因为代码z盘的挂载路径设置为了/data/data/com.termux/files/usr/glibc/而不是$HOME，不过也可以不用管了，因为没有任何影响，就当~~特性~~吧[doge]

# 更新日志

## 1.0

支持容器功能，支持容器打包和导入，可更换d3d环境，可选vulkan驱动，
~~支持自定义壁纸自动转换bmp格式~~（此功能会导致渲染错误，目前暂时无法解决），支持注册表功能，创建容器集成了很多软件（如播放器和运行库），支持调试日志功能，加入在线下载资源，可更换下载站适应大陆网络环境


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
