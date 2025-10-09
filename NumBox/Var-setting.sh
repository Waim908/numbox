#!/bin/bash
. ~/NumBox/utils/utils.sh
utilsDoNotReimport=1
import dialog.sh
import file_list.sh
import export_var_edit.sh
import last_jump.sh
import select_ctr.sh
unset_utils_var
if select_ctr; then
select=$(dialog ${dialog_arg[@]} --title "变量设置" --backtitle "容器：${returnFileListName}" --menu "\Z3对于变量的解释不一定100%准确，仅供参考\Zn" $box_sz \
  1 "设置容器变量" \
  2 "设置Box64变量" 2>&1 >/dev/tty)
case $select in
  "") last_jump ;;
  # 通用环境变量，总是最后一个应用完成变量覆盖
  1) go_back () { set_ctr_var;}
  set_ctr_var () {
    var_file=$ctr_conf_path/default.conf
    CUSTOM_VAR_EDIT_OPTIONS=("E" "\Z2使用文本编辑器软件打开\Zn" "A" "\Z2添加一个自定义变量\Zn" "D" "\Z2还原默认变量配置\Zn")
    var_list $var_file "${returnFileListName}" "$HOME/NumBox/data/container/${returnFileListName}/config/default.conf" "部分变量在更新的版本可能已经失效或者发生改变，不保证一定有效"
    if [[ $BACK_VAR_NUM == E ]]; then
      . ~/NumBox/utils/empty.sh sd
      cp $var_file $sd_temp/default.conf
      termux-open --content-type text $sd_temp/default.conf
      dialog ${dialog_arg[@]} --title "是否保存？" --yesno "$sd_temp/default.conf" $box_sz2
      if [[ ! $? == 1 ]]; then
        cp $sd_temp/default.conf $var_file
      fi
      set_ctr_var
    elif [[ $BACK_VAR_NUM == A ]]; then
      customForm=$(dialog ${dialog_arg[@]} --title "自定义变量" --form "输入变量值" $box_sz \
        "变量名" 1 1 "" 1 10 1000 0 \
        "变量值" 2 1 "" 2 10 1000 0 2>&1 >/dev/tty)
      array_var=($customForm)
      newVarName=${array_var[0]}
      newVarValue=${array_var[1]}
      if [[ -z $customForm ]]; then
        set_ctr_var
      else
        sed -i "\$aexport ${newVarName}=\"${newVarValue}\"" $var_file
        set_ctr_var
      fi
    elif [[ $BACK_VAR_NUM == D ]]; then
      dialog ${dialog_arg[@]} --title "提示" --yesno "是否还原默认变量配置？" $box_sz2
      if [[ $? == 0 ]]; then
        cp ~/NumBox/default/ctr/default.conf $ctr_conf_path/default.conf && go_back
      else
        go_back
      fi
    elif [[ -z $BACK_VAR ]]; then
      . ~/NumBox/Var-setting.sh
    else
      case $(echo "$BACK_VAR" | sed 's/^export //') in
        LC_ALL=*) aboutVar="修改区域语言编码格式，注意可能不是对所有游戏有效，你可能还需要设置时区"
        genrate () {
          cp ~/NumBox/default/glibc/locale-gen $glibc_prefix/etc/
          unset LD_PRELOAD
          $PREFIX/glibc/bin/locale-gen
        }
        SINGLE_SELECT=(
        "简体中文" "zh_CN.UTF-8"
        "繁体中文" "zh_TW.UTF-8"
        "日语" "ja_JP.UTF-8"
        "英文" "en_US.UTF-8"
        "自定义" "语言_区域.编码"
        )
        sed_var_preset_single
        if [[ $single_select == 自定义 ]]; then
            lcall=$(dialog ${dialog_arg[@]} --title "自定义语言编码(LC_ALL)" --inputbox "格式：语言_区域.编码" $box_sz 2>&1 >/dev/tty)
            if [[ -z $lcall ]]; then
              set_ctr_var

            else
              edit_var sed "LC_ALL" "${lcall}" $var_file
              set_ctr_var
            fi
        else
          sed_var LC_ALL $single_select
        fi ;;
        ZINK_DESCRIPTOR=*) aboutVar="ZINK描述符"
        SINGLE_SELECT=(
          "auto" "自动检测"
          "lazy" "尝试通过机会性地绑定描述符来使用最少量的CPU"
          "db" "如果可能,请使用EXT_descriptor_buffer"
        )
        sed_var_preset_single
        sed_var ZINK_DESCRIPTOR $single_select ;;
        TZ=*) aboutVar="设置时区"
        SINGLE_SELECT=(
          "Asia/Shanghai" "中国上海"
          "Asia/Tokyo" "日本东京"
          "America/Los_Angeles" "美国洛杉矶"
          "Europe/London" "英国伦敦"
          "custom" "自定义时区"
        )
        sed_var_preset_single
        if [[ $single_select == custom ]]; then
          tzset=$(dialog ${dialog_arg[@]} --title "自定义时区" --inputbox "" $box_sz 2>&1 >/dev/tty)
          if [[ -z $tzset ]]; then
            set_ctr_var
          elif [[ ! -d /data/data/com.termux/files/usr/glibc/share/zoneinfo/ ]]; then
            dialog ${dialog_arg[@]} --title "\Z1错误\Zn" --msgbox "当前glibc目录没有内置tzdata，修改时区无效" $box_sz2
            set_ctr_var
          elif [[ ! -d /data/data/com.termux/files/usr/glibc/share/zoneinfo/${tzset} ]]; then
            dialog ${dialog_arg[@]} --title "\Z1错误\Zn" --msgbox "\Z2${tzset}\Zn 似乎不是一个有效的时区值" $box_sz2
            set_ctr_var
          else
            sed_var TZ "${tzset}"
          fi
        else
          sed_var TZ $single_select
        fi ;;
        ZINK_DEBUG=*) aboutVar="ZINK调试"
        ALL_SELECT=(
        "nir|将所有着色器的NIR形式打印到stderr"
        "spirv|将所有已编译着色器的二进制SPIR-V格式写入当前目录中的文件中，并将带有文件名的消息打印到stderr"
        "tgsi|将TGSI着色器的TGSI形式打印到stderr"
        "validation|Dump_Validation_layer输出"
        "sync|在每次绘制和调度之前发出完全同步屏障"
        "compact|最多使用4个描述符集"
        "noreorder|不重新排序或优化GL命令流"
        "gpl|强制对所有着色器使用Graphics_Pipeline_Library"
        "rp|启用渲染过程优化（用于平铺GPU）"
        "norp|禁用渲染过程优化（用于平铺GPU）"
        "map|打印有关映射的VRAM的信息"
        "flushsync|强制同步刷新/呈现"
        "noshobj|禁用EXT_shader_object"
        "optimal_keys|调试/使用optimal_keys"
        "noopt|禁用异步优化管道编译"
        "nobgc|禁用所有异步管道编译"
        "mem|启用内存分配调试"
        "quiet|禁止显示可能无害的警告"
        )
        sed_var_preset_multiple ;;
        ZINK_CONTEXT_MODE=*) aboutVar="通常设置为base"
        SINGLE_SELECT=(base base auto auto threaded threaded)
        sed_var_preset_single
        sed_var ZINK_CONTEXT_MODE $single_select ;;
        ZINK_CONTEXT_THREADED=*) aboutVar="可能解决游戏卡死问题"
        SINGLE_SELECT=(true 启用 false 禁用)
        sed_var_preset_single
        sed_var ZINK_CONTEXT_THREADED $single_select ;;
        MESA_SHADER_CACHE_DISABLE=*) aboutVar="禁用着色器缓存"
        SINGLE_SELECT=(true 启用 false 禁用)
        sed_var_preset_single
        sed_var MESA_SHADER_CACHE_DISABLE $single_select ;;
        MESA_SHADER_CACHE_MAX_SIZE=*) aboutVar="着色器缓存最大大小，单位必须为K,M,G"
        SINGLE_SELECT=(256M 小 512M 中 1G 最大上限)
        sed_var_preset_single
        sed_var MESA_SHADER_CACHE_MAX_SIZE $single_select ;;
        MESA_VK_WSI_DEBUG=*) aboutVar="垂直同步(Vulkan)"
        SINGLE_SELECT=(sw "启用（通常）" sws "性能最好，可能导致渲染错误，例如条纹画面撕裂（默认）")
        sed_var_preset_single
        sed_var MESA_VK_WSI_DEBUG $single_select ;;
        MESA_VK_WSI_PRESENT_MODE=*) aboutVar="overrides the WSI present mode clients specify in VkSwapchainCreateInfoKHR::presentMode. Values can be fifo, relaxed, mailbox or immediate."
        SINGLE_SELECT=(fifo fifo relaxed relaxed mailbox "mailbox（预设）" immediate immediate)
        sed_var_preset_single
        sed_var MESA_VK_WSI_PRESENT_MODE $single_select ;;
        mesa_glthread=*)
        SINGLE_SELECT=(true 启用 false 禁用)
        sed_var_preset_single
        sed_var mesa_glthread $single_select ;;
        WINE_DO_NOT_CREATE_DXGI_DEVICE_MANAGER=*) aboutVar="此变量只存在于补丁构建或者proton版本中，启用可以修复unityH264视频解码问题，但是关闭此变量可能导致某些游戏运行出现问题"
        SINGLE_SELECT=(注释 不启用 1 启用)
        sed_var_preset_single
        case $single_select in
          注释) edit_var ann WINE_DO_NOT_CREATE_DXGI_DEVICE_MANAGER $var_file && go_back ;;
          1) sed_var WINE_DO_NOT_CREATE_DXGI_DEVICE_MANAGER 1  ;;
        esac ;;
        PULSE_LATENCY_MSEC=*) aboutVar="音频延迟，可以解决声音延迟问题，当然如果游戏声音出现问题可能需要winecfg配置使用pulseaudio而不是alsa"
        SINGLE_SELECT=(30 30 45 45 60 60 100 100 custom 自定义)
        sed_var_preset_single
        if [[ $single_select == custom ]]; then
          input_pulse_latency=$(dialog ${dialog_arg[@]} --title "自定义PULSE音频延迟" --inputbox "${varVaule}" $box_sz)
          if [[ -z $input_pulse_latency ]]; then
            go_back
          else
            sed_var PULSE_LATENCY_MSEC $input_pulse_latency
          fi
        else
          sed_var PULSE_LATENCY_MSEC $single_select
        fi ;;
        WINEESYNC=*) aboutVar="自动应用变量WINEESYNC_TERMUX，启用补丁构建或者proton版本才能WINEE使用\n文件描述符限制大于1048576,执行ulimit -Hn[或-Sn] 数字[如果无就是直接查看限制],非root设备(root可以修改，通过权限命令临时修改上限)也能使用esync，但是无法设置超过安卓文件描述符上限 \n 当前设备硬件限制$(ulimit -Hn) \n 软件限制$(ulimit -Sn)"
        SINGLE_SELECT=(0 禁用 1 启用)
        sed_var_preset_single
        sed_var WINEESYNC $single_select ;;
        WINEFSYNC=*) aboutVar="启用补丁构建或者proton版本（源码fsync也要修改以适配安卓），且wine使用的c标准库支持futex并且能正确调用到系统内核futex否则真不推荐启用这个，不推荐与WINEESYNC一起启用"
        SINGLE_SELECT=(0 禁用 1 "启用(不推荐)")
        sed_var_preset_single
        sed_var WINEFSYNC $single_select ;;
        TU_DEBUG=*) aboutVar="如果你的turnip驱动无法正常工作可能需要修改此值"
        ALL_SELECT=(
        "3d_load|3d_load"
        "bos|bos"
        "dynamic|dynamic"
        "fdm|fdm"
        "flushall|flushall"
        "forcebin|forcebin"
        "gmem|gmem"
        "layout|layout"
        "log_skip_gmem_ops|log_skip_gmem_ops"
        "nolrz|nolrz"
        "nolrzfc|nolrzfc"
        "nobin|nobin"
        "nobinmerging|nobinmerging"
        "noconcurrentresolves|noconcurrentresolves"
        "noconcurrentunresolves|noconcurrentunresolves"
        "noconform|noconform"
        "nir|nir"
        "nomultipos|nomultipos"
        "noubwc|noubwc"
        "perf|perf"
        "perfc|perfc"
        "push_consts_per_stage|push_consts_per_stage"
        "rast_order|rast_order"
        "rd|rd"
        "startup|startup"
        "syncdraw|syncdraw"
        "sysmem|sysmem"
        "unaligned_store|unaligned_store"
        )
        sed_var_preset_multiple ;;
        GALLIUM_HUD=*) aboutVar="使用OpenGL渲染时显示帧率和折线图\n 只显示fps:simple,fps \n显示fps和折线图:fps"
        ALL_SELECT=(
        "simple|简单显示"
        "stdout|将计数器数值输出到标准输出stdout"
        "csv|将计数器数值以CSV格式输出至stdout，名称间用+号分隔"
        "fps|fps"
        "frametime|frametime"
        "cpu|cpu"
        "samples-passed|samples-passed"
        "primitives-generated|primitives-generated"
        "ia-vertices|ia-vertices"
        "ia-primitives|ia-primitives"
        "vs-invocations|vs-invocations"
        "gs-invocations|gs-invocations"
        "gs-primitives|gs-primitives"
        "clipper-invocations|clipper-invocations"
        "clipper-primitives-generated|clipper-primitives-generated"
        "ps-invocations|ps-invocations"
        "hs-invocations|hs-invocations"
        "ds-invocations|ds-invocations"
        "cs-invocations|cs-invocations"
        )
        sed_var_preset_multiple ;;
        ZINK_USE_LAVAPIPE=*) aboutVar="ZINK使用lavapipe"
        SINGLE_SELECT=(false 禁用 true 启用)
        sed_var_preset_single
        sed_var ZINK_USE_LAVAPIPE $single_select ;;
        MESA_EXTENSION_MAX_YEAR=*) aboutVar="修复老OpenGL游戏崩溃问题，设置为游戏发行时的年份"
        SINGLE_SELECT=(2001 年 自定义 游戏发行年份)
        sed_var_preset_single
        case $single_select in
          2001) sed_var MESA_EXTENSION_MAX_YEAR 2001 ;;
          自定义) input_mesa_year=$(dialog ${dialog_arg[@]} --title "输入游戏发行年份" --inputbox "" $box_sz2)
          if [[ -z $input_mesa_year ]]; then
            go_back
          else
            sed_var MESA_EXTENSION_MAX_YEAR $input_mesa_year
          fi
        esac ;;
        LIBGL_ALWAYS_SOFTWARE=*) aboutVar="始终使用软件渲染"
        SINGLE_SELECT=(true 启用 false 禁用 注释 禁用)
        if [[ $single_select == 注释 ]]; then
          edit_var ann LIBGL_ALWAYS_SOFTWARE $var_file && go_back
        else
          sed_var LIBGL_ALWAYS_SOFTWARE $single_select
        fi ;;
        MESA_GL_VERSION_OVERRIDE=*) aboutVar="指定OpenGL的版本，提高此值解决游戏OpenGL版本识别问题或者和wined3d相关"
        SINGLE_SELECT=(4.6COMPAT "兼容性" 3.3COMPAT 3.3兼容 4.6 4.6 3.3 3.3 3.1 3.1 2.1 2.1 custom 自定义)
        sed_var_preset_single
        if [[ $single_select == custom ]]; then
          input_mesa_gl_version=$(dialog --title "自定义GL版本(MESA_GL_VERSION_OVERRIDE)" --inputbox "数字.数字|FC|COMPAT" $box_sz2)
          if [[ -z $input_mesa_gl_version ]]; then
            go_back
          else
            sed_var MESA_GL_VERSION_OVERRIDE $input_mesa_gl_version
          fi
        else
          sed_var MESA_GL_VERSION_OVERRIDE $single_select
        fi ;;
        DXVK_HUD=*) aboutVar="调用dxvk时显信息"
        ALL_SELECT=(
        "devinfo|显示GPU名称和驱动程序版本"
        "fps|显示当前帧率"
        "frametimes|显示帧时间图表"
        "submissions|显示每帧提交的命令缓冲区数量"
        "drawcalls|显示每帧的绘制调用和渲染通道数量"
        "pipelines|显示图形和计算管道的总数"
        "descriptors|显示描述符池和描述符集的数量"
        "memory|显示已分配和使用的设备内存量"
        "allocations|显示详细的内存块子分配信息"
        "gpuload|显示估计的GPU负载(可能不准确)"
        "version|显示DXVK版本"
        "api|显示应用程序使用的D3D功能级别"
        "cs|显示工作线程统计信息"
        "compiler|显示着色器编译器活动"
        "samplers|显示当前使用的采样器对数量[D3D9专用]"
        "ffshaders|显示从固定功能状态生成的着色器数量[D3D9专用]"
        "swvp|显示设备是否在软件顶点处理模式下运行[D3D9专用]"
        )
        sed_var_preset_multiple ;;
        DXVK_FRAME_RATE=*) aboutVar="限制Dxvk的帧率"
        SINGLE_SELECT=(0 无限制 15 15 30 30 45 45 60 60 90 90 120 120 144 144 custom 无限制)
        sed_var_preset_single
        if [[ $single_select == custom ]]; then
          input_dxvk_max_fps=$(dialog ${dialog_arg} --title "限制dxvk帧率(DXVK_FRAME_RATE)" --inputbox "输入允许dxvk的最大fps值" $box_sz2)
          if [[ -z $input_dxvk_max_fps ]]; then
            go_back
          else
            sed_var DXVK_FRAME_RATE $input_dxvk_max_fps
          fi
        else
          sed_var DXVK_FRAME_RATE $single_select
        fi ;;
        VKD3D_FRAME_RATE=*) aboutVar="限制vkd3d的帧率，如此变量被注释或不存在则使用DXVK_FRAME_RATE"
        SINGLE_SELECT=(0 无限制 15 15 30 30 45 45 60 60 90 90 120 120 144 144 custom 无限制)
        sed_var_preset_single
        if [[ $single_select == custom ]]; then
          input_dxvk_max_fps=$(dialog ${dialog_arg} --title "限制dxvk帧率(DXVK_FRAME_RATE)" --inputbox "输入允许dxvk的最大fps值" $box_sz2)
          if [[ -z $input_dxvk_max_fps ]]; then
            go_back
          else
            sed_var DXVK_FRAME_RATE $input_dxvk_max_fps
          fi
        else
          sed_var DXVK_FRAME_RATE $single_select
        fi ;;
        DXVK_CONFIG_FILE=*) aboutVar="dxvk配置文件路径，优先级可能和dxvk相关变量产生影响，对应路径必须存放文件哦"
        SINGLE_SELECT=(
          "注释" "不使用配置文件"
          "C盘，每个容器独立" "$PREFIX/NumBox/data/container/${CONTAINER_NAME}/disk/dosdevices/c:/dxvk.conf"
          "D盘，挂载路径" "$PREFIX/NumBox/data/container/${CONTAINER_NAME}/disk/dosdevices/d:/dxvk.conf"
          "自定义" "自定义文件路径，\Z7注意必须为Linux文件路径\Zn"
        )
        sed_var_preset_single
        case $single_select in
          注释) edit_var ann DXVK_CONFIG_FILE $var_file ;;
          C盘，每个容器独立) sed_var DXVK_CONFIG_FILE "$PREFIX/NumBox/data/container/${CONTAINER_NAME}/disk/dosdevices/c:/dxvk.conf" ;;
          D盘，挂载路径) sed_var DXVK_CONFIG_FILE "$PREFIX/NumBox/data/container/${CONTAINER_NAME}/disk/dosdevices/d:/dxvk.conf" ;;
          自定义) input_dxvk_config_file=$(dialog --title "自定义Dxvk配置文件(DXVK_CONFIG_FILE)" --inputbox "请输入一个有效的Linux文件路径，例如/sdcard/Download/dxvk.conf")
          if [[ -z $input_dxvk_config_file ]]; then
            go_back
          else
            sed_var DXVK_CONFIG_FILE "${input_dxvk_config_file}"
          fi
        esac ;;
        vblank_mode=*) aboutVar="OpenGL VSync垂直同步，防止画面撕裂"
        SINGLE_SELECT=(0 关闭，性能最好 1 由应用程序自定义，间隔1 2 由应用程序自定义，间隔2 3 强制垂直同步)
        sed_var_preset_single
        sed_var vblank_mode $single_select ;;
        VKD3D_FEATURE_LEVEL=*) aboutVar="Dx12特性等级"
        SINGLE_SELECT=(9_1 9_1 9_3 9_3 10_0 10_0 10_1 10_1 11_0 11_0 11_1 11_1 12_0 12_0 12_1 12_1 12_2 12_2)
        sed_var_preset_single
        sed_var VKD3D_FEATURE_LEVEL $single_select ;;
        DXVK_ASYNC=*) aboutVar="dxvk的async或者gplasync版本必须启用此选项"
        SINGLE_SELECT=(1 启用 0 禁用)
        sed_var_preset_single
        sed_var DXVK_ASYNC $single_select ;;
        DXVK_GPLASYNCCACHE=*) aboutVar="dxvk的gplasync版本需要启用此选项"
        SINGLE_SELECT=(1 启用 0 禁用)
        sed_var_preset_single
        sed_var DXVK_GPLASYNCCACHE $single_select ;;
        DRAW_USE_LLVM=*) aboutVar="如果设置为零，绘制模块将不会使用 LLVM 执行着色器、顶点提取等"
        SINGLE_SELECT=(1 启用 0 禁用)
        sed_var_preset_single
        sed_var DXVK_GPLASYNCCACHE $single_select ;;
        LIBGL_SHOW_FPS=*) aboutVar="显示OpenGL渲染的fps到stdout标准输出(无图形HUD)，不过还是推荐用GALLIUM_HUD变量"
        SINGLE_SELECT=(1 启用 0 禁用)
        sed_var_preset_single
        sed_var DXVK_GPLASYNCCACHE $single_select ;;
        WINE_FULLSCREEN_INTEGER_SCALING=*) aboutVar="解决游戏分辨率缩放问题，只有proton版本或者应用补丁构建的wine才能使用"
        SINGLE_SELECT=(1 启用 0 禁用)
        sed_var_preset_single
        sed_var WINE_FULLSCREEN_INTEGER_SCALING $single_select ;;
        STAGING_SHARED_MEMORY=*) aboutVar="仅限应用了staging补丁的wine，使用共享内存来优化wineserver调用，性能提升可能不明显，\n对于使用特定API的应用可以启用"
        SINGLE_SELECT=(1 启用 0 禁用)
        sed_var_preset_single
        sed_var STAGING_SHARED_MEMORY $single_select ;;
        STAGING_RT_PRIORITY_SERVER=*) aboutVar="仅限应用了staging补丁的wine，设置实时进程优先级，不推荐设置为99\n 此设置你可以按数字键快速索引到想要的数"
        SINGLE_SELECT=(0 0 1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 10 10 11 11 12 12 13 13 14 14 15 15 16 16 17 17 18 18 19 19 20 20 21 21 22 22 23 23 24 24 25 25 26 26 27 27 28 28 29 29 30 30 31 31 32 32 33 33 34 34 35 35 36 36 37 37 38 38 39 39 40 40 41 41 42 42 43 43 44 44 45 45 46 46 47 47 48 48 49 49 50 50 51 51 52 52 53 53 54 54 55 55 56 56 57 57 58 58 59 59 60 60 61 61 62 62 63 63 64 64 65 65 66 66 67 67 68 68 69 69 70 70 71 71 72 72 73 73 74 74 75 75 76 76 77 77 78 78 79 79 80 80 81 81 82 82 83 83 84 84 85 85 86 86 87 87 88 88 89 89 90 90 91 91 92 92 93 93 94 94 95 95 96 96 97 97 98 98 99 99)
        sed_var_preset_single
        sed_var STAGING_RT_PRIORITY_SERVER $single_select ;;
        STAGING_WRITECOPY=*) aboutVar="仅限应用了staging补丁的wine，此变量可能导致大量错误发生，不推荐启用\n 模拟Windows的内存管理系统"
        SINGLE_SELECT=(1 启用 0 禁用)
        sed_var_preset_single
        sed_var STAGING_SHARED_MEMORY $single_select ;;
        LARGE_ADDRESS_AWARE=*) aboutVar="仅限应用了LAA补丁的wine，此变量可以使32位应用程序可以使用2G以上的内存(大概到4G?)"
        SINGLE_SELECT=(1 启用 0禁用)
        sed_var_preset_single
        sed_var LARGE_ADDRESS_AWARE $single_select ;;
        LIBGL_DRI3_DISABLE=*) aboutVar="禁用dri3渲染（可能降低性能）"
        SINGLE_SELECT=(true 启用 false 禁用)
        sed_var_preset_single
        sed_var LIBGL_DRI3_DISABLE $single_select ;;
        *) sed_var_dialog ;;
      esac
    fi
  }
  set_ctr_var ;;

  # BOX64

  2) go_back () { set_ctr_box64_var;}
  set_ctr_box64_var () {
    var_file="$ctr_conf_path/box64.conf"
    CUSTOM_VAR_EDIT_OPTIONS=("E" "\Z2使用文本编辑器软件打开\Zn" "A" "\Z2添加一个自定义变量\Zn" "S" "\Z3选择预设\Zn" "R" "\Z2使用文本编辑器软件打开RCFILE\Zn" P "\Z3选择RCFILE预设\Zn")
    var_list $var_file "${returnFileListName}" "$HOME/NumBox/data/container/${returnFileListName}/config/box64.conf" "部分变量在更新的版本可能已经失效或者发生改变，不保证一定有效"
    if [[ $BACK_VAR_NUM == E ]]; then
      . ~/NumBox/utils/empty.sh
      create_dir sd
      cp $var_file $sd_temp/box64.conf
      termux-open --content-type text $sd_temp/box64.conf
      dialog ${dialog_arg[@]} --title "是否保存？" --yesno "$sd_temp/box64.conf" $box_sz2
      if [[ ! $? == 1 ]]; then
        cp $sd_temp/box64.conf $var_file
      fi
      set_ctr_box64_var
    elif [[ $BACK_VAR_NUM == P ]]; then
      CUSTOM_FILE_LIST_OPTIONS=("U" "我定义的预设文件")
      file_list "$HOME/NumBox/default/box64rc/" "选择一个RCFILE预设"
      if [[ $BACK_NUM == U ]]; then
        unset CUSTOM_FILE_LIST_OPTIONS
        file_list "$HOME/NumBox/data/box64rc/" "选择一个你定义的预设文件"
        if [[ -f $HOME/NumBox/data/box64rc/${returnFileListName} ]]; then
          cp $HOME/NumBox/data/box64rc/${returnFileListName} $ctr_conf_path/box64.conf
        else
          dialog ${dialog_arg[@]} --title "\Z1错误\Zn" --msgbox "未能找到文件\Z2$HOME/NumBox/data/box64rc/${returnFileListName}\Zn!" $box_sz2
          go_back
        fi
      elif [[ -z $returnFileListName ]]; then
        set_ctr_box64_var
      else
        cp $HOME/NumBox/default/box64rc/${returnFileListName} $ctr_conf_path/box64.box64rc
        go_back
      fi
    elif [[ $BACK_VAR_NUM == R ]]; then
      . ~/NumBox/utils/empty.sh
      create_dir sd
      cp ~/NumBox/default/box64/box64.box64rc $sd_temp/box64.box64rc
      termux-open --content-type text $sd_temp/box64.box64rc
      dialog ${dialog_arg[@]} --title "是否保存？" --yesno "$sd_temp/box64.box64rc" $box_sz2
      if [[ ! $? == 1 ]]; then
        cp $sd_temp/box64.box64rc $var_file
      elif [[ -z $returnFileListName ]]; then
        set_ctr_box64_var
      else
        cp $HOME/NumBox/default/box64/${returnFileListName} $ctr_conf_path/box64.conf && go_back
      fi
    elif [[ $BACK_VAR_NUM == S ]]; then
      CUSTOM_FILE_LIST_OPTIONS=("U" "我定义的预设文件")
      file_list "$HOME/NumBox/default/box64/" "选择一个预设"
      if [[ $BACK_NUM == U ]]; then
        unset CUSTOM_FILE_LIST_OPTIONS
        file_list "$HOME/NumBox/data/box64/" "选择一个你定义的预设文件"
        if [[ -f $HOME/NumBox/data/box64/${returnFileListName} ]]; then
          cp $HOME/NumBox/data/box64/${returnFileListName} $ctr_conf_path/box64.conf
        else
          dialog ${dialog_arg[@]} --title "\Z1错误\Zn" --msgbox "未能找到文件\Z2$HOME/NumBox/data/box64/${returnFileListName}\Zn!" $box_sz2
          go_back
        fi
      elif [[ -z $returnFileListName ]]; then
        set_ctr_box64_var
      else
        cp $HOME/NumBox/default/box64/${returnFileListName} $ctr_conf_path/box64.conf && go_back
      fi
    elif [[ $BACK_VAR_NUM == A ]]; then
      customForm=$(dialog ${dialog_arg[@]} --title "自定义变量" --form "输入变量值" $box_sz \
        "变量名" 1 1 "" 1 10 1000 0 \
        "变量值" 2 1 "" 2 10 1000 0 2>&1 >/dev/tty)
      array_var=($customForm)
      newVarName=${array_var[0]}
      newVarValue=${array_var[1]}
      if [[ -z $customForm ]]; then
        set_ctr_box64_var
      else
        sed -i "\$a${newVarName}=\"${newVarValue}\"" $var_file
        set_ctr_box64_var
      fi
    elif [[ -z $BACK_VAR ]]; then
      . ~/NumBox/Var-setting.sh
    else
      case $(echo "$BACK_VAR" | sed 's/^export //') in
        BOX64_DYNAREC_SAFEFLAGS=*) aboutVar="控制CALL/RET指令的标志位处理方式\n\n0: 完全忽略标志位（可能更快但兼容性差）\n1: RET需要标志位，CALL不需要（平衡速度与兼容性，默认）\n2: 所有CALL/RET都需要标志位（最精确但性能最低）"
        SINGLE_SELECT=(0 0 1 1 2 2)
        sed_var_preset_single
        sed_var BOX64_DYNAREC_SAFEFLAGS $single_select ;;
        BOX64_DYNAREC_FASTROUND=*) aboutVar="浮点数舍入模式优化\n\n0: 精确模拟x86舍入模式（完全兼容但慢）\n1: 快速舍入（牺牲精度换速度，默认）\n2: 混合模式（精确舍入+快速转换，折中方案）"
        SINGLE_SELECT=(0 0 1 1 2 2)
        sed_var_preset_single
        sed_var BOX64_DYNAREC_FASTROUND $single_select ;;
        BOX64_DYNAREC_X87DOUBLE=*) aboutVar="x87浮点单元仿真模式\n\n0: 尽量使用float优化（最快，默认）\n1: 强制使用double精度（更精确但慢）\n2: 检查精度控制模式（动态调整精度）"
        SINGLE_SELECT=(0 0 1 1 2 2)
        sed_var_preset_single
        sed_var BOX64_DYNAREC_X87DOUBLE $single_select ;;
        BOX64_DYNAREC_BIGBLOCK=*) aboutVar="DynaRec代码块生成策略\n\n0: 小代码块（适合多线程/JIT程序如Unity）\n1: 最大代码块（可能引发线程问题）\n2: 较大代码块（仅ELF内存区，默认）\n3: 超大代码块（Wine程序专用，风险最高）"
        SINGLE_SELECT=(0 0 1 1 2 2 3 3)
        sed_var_preset_single
        sed_var BOX64_DYNAREC_BIGBLOCK $single_select ;;
        BOX64_DYNAREC_STRONGMEM=*) aboutVar="x86强内存模型仿真\n\n0: 不模拟（最快但可能数据错误）\n1: 基础内存屏障（基本兼容）\n2: 包含SIMD内存屏障（推荐用于现代CPU，默认）\n3: 全面内存屏障（最严格但性能差）"
        SINGLE_SELECT=(0 0 1 1 2 2 3 3)
        sed_var_preset_single
        sed_var BOX64_DYNAREC_STRONGMEM $single_select ;;
        BOX64_DYNAREC_FORWARD=*) aboutVar="允许的代码块向前跳转距离\n\n0: 禁止向前跳转（最保守）\n128: 默认值（平衡块大小与稳定性）\n自定义: 手动输入字节数（值越大块越大风险越高）"
        SINGLE_SELECT=(0 0 128 128 custom 自定义)
        sed_var_preset_single
        if [[ $single_select == custom ]]; then
          input_box64_dynarec_forward=$(dialog ${dialog_arg[@]} --title "BOX64_DYNAREC_FORWARD" --inputbox "输入数字（推荐128-1024）" $box_sz2)
          if [[ -z $input_box64_dynarec_forward ]]; then
            set_ctr_box64_var
          else
            sed_var BOX64_DYNAREC_FORWARD $input_box86_dynarec_forward
          fi
        else
          sed_var BOX64_DYNAREC_FORWARD $single_select
        fi ;;
        BOX64_DYNAREC_CALLRET=*) aboutVar="CALL/RET指令优化\n\n0: 使用跳转表（最稳定，默认）\n1: 直接优化（更快但可能崩溃）\n2: 增强优化（含脏块处理，仅Linux版可用）"
        SINGLE_SELECT=(0 0 1 1 2 2)
        sed_var_preset_single
        sed_var BOX64_DYNAREC_CALLRET $single_select ;;
        BOX64_DYNAREC_WAIT=*) aboutVar="DynaRec块生成等待\n\n0: 不等待（使用解释器，适合多线程程序）\n1: 等待块生成完成（更稳定，默认）"
        SINGLE_SELECT=(0 0 1 1)
        sed_var_preset_single
        sed_var BOX64_DYNAREC_WAIT $single_select ;;
        BOX64_AVX=*) aboutVar="AVX指令集模拟\n\n0: 禁用（兼容旧CPU）\n1: 基础AVX/BMI1/F16C\n2: 完整AVX2/BMI2/FMA（ARM64默认）"
        SINGLE_SELECT=(0 0 1 1 2 2)
        sed_var_preset_single
        sed_var BOX64_AVX $single_select ;;
        BOX64_MMAP32=*) aboutVar="32位内存映射\n\n0: 禁用（标准64位模式）\n1: 启用（Wine WOW64兼容模式，默认）"
        SINGLE_SELECT=(0 0 1 1)
        sed_var_preset_single
        sed_var BOX64_MMAP32 $single_select ;;
        BOX64_UNITYPLAYER=*) aboutVar="Unity游戏优化\n\n0: 禁用（标准模式）\n1: 自动应用保守设置（DYNAREC_BIGBLOCK=0+STRONGMEM=1，默认）"
        SINGLE_SELECT=(0 0 1 1)
        sed_var_preset_single
        sed_var BOX64_UNITYPLAYER $single_select ;;
        box64presetName=*)
        input_box64presetName=$(dialog --title "自定义预设名称" --inputbox "$(awk -F'=' '{print $2}' <<< "$BACK_VAR" | sed 's/^"\|"$//g')" $box_sz2 "" 2>&1 >/dev/tty)
        if [[ -z $input_box64presetName ]] || [[ $input_box64presetName == $varVaule ]]; then
          set_ctr_box64_var
        else
          sed_var box64presetName $input_box64presetName
        fi ;;
        BOX64_NORCFILES=*) aboutVar="禁用所有配置文件\n\n0: 正常加载配置文件（默认）\n1: 禁用所有rc文件"
        SINGLE_SELECT=(0 0 1 1)
        sed_var_preset_single
        sed_var BOX64_NORCFILES $single_select ;;
        BOX64_MAXCPU=*) aboutVar="box64使用的CPU核心数量"
        SINGLE_SELECT=(auto nproc自动识别 custom 自定义 "max" "使用$(nproc)个核心")
        sed_var_preset_single
        case $single_select in
          auto) sed_var BOX64_MAXCPU "\"\$(nproc)\"" ;;
          custom) custom_box64_max_cpu=$(dialog ${dialog_arg[@]} --title "自定义box64使用的CPU核心数量" --inputbox "最大可用：$(nproc)" $box_sz2 2>&1 >/dev/tty)
          if [[ $custom_box64_max_cpu =~ ^[1-9][0-9]*$ ]]; then
            sed_var BOX64_MAXCPU $custom_box64_max_cpu
          else
            Dmsgbox "错误" "\Z1错误的格式\n"
            set_ctr_box64_var
          fi ;;
          max) sed_var $(nproc) ;;
        esac ;;
        *) sed_var_dialog ;;
      esac
    fi
  }
  set_ctr_box64_var ;;
esac
else
  last_jump
fi