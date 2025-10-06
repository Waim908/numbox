#!/bin/bash
# 源码tar包目录: /sdcard/NumBox/resources/box64/src/
mkdir -p /sdcard/NumBox/resources/box64/src/
mkdir -p /sdcard/NumBox/resources/box64/src_output/
rm -rf $TMPDIR/box64_src_output
mkdir $TMPDIR/box64_src_output
if [[ ! -f $PREFIX/glibc/bin/cmake ]]; then
  warn "当前glibc环境没有安装cmake命令！"
  return 1
elif [[ ! -f $PREFIX/glibc/bin/make ]]; then
  warn "当前glibc环境没有安装make命令！"
  return 1
elif [[ ! -f $PREFIX/glibc/bin/python3 ]]; then
  warn "当前glibc环境没有安装python3！"
  return 1
elif ! command -v git; then
  warn "没有安装git！执行以下命令安装"
  info "pkg i git"
  return 1
fi
main () {
utilsDoNotReimport=1
. ~/NumBox/utils/utils.sh
import dialog.sh
import github_api.sh
import echo.sh
import load.sh
import last_jump.sh
import file_list.sh
import free_list.sh
import downloader.sh
import package.sh
import glibc_run.sh
unset_utils_var
loadStrict=1
curlDisplayBar=1
build_box64_menu () {
  build_cmake () {
    Dmenu_select=(1 无编译优化-默认 2 当前指令集架构O3优化 3 arm64v8-a通用指令集优化)
    Dmenu "选择一种编译优化方式"
    case $DMENU in
      "") main ;;
      1) echo "无优化-除非你先前配置过额外的参数" ;;
      2) export CFLAGS="-O3 -marh=armv8-a -mutune=generic -flto=auto"
      export CXXFLAGS="-O3 -marh=armv8-a -mutune=generic -flto=auto"
      export LDFLAGS="-O3 -flto=auto" ;;
      3) export CFLAGS="-O3 -marh=native -flto=auto"
      export CXXFLAGS="-O3 -marh=native -flto=auto"
      export LDFLAGS="-O3 -flto=auto" ;;
    esac
    mkdir build
    cd build
    info "当前构建参数为：-DCMAKE_INSTALL_PREFIX=$PREFIX/glibc -DCMAKE_BUILD_TYPE=RelWithDebInfo -DARM_DYNAREC=on -DARM64=ON ${cmake_arg[@]}"
    info "开始构建，请保持termux在前台运行以防止后台核心锁定问题"
    if ! glibc_run "cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX/glibc -DCMAKE_BUILD_TYPE=RelWithDebInfo -DARM_DYNAREC=on -DARM64=ON ${cmake_arg[@]}"; then
      warn "构建失败"
      return 1
    fi
    info "开始编译"
    if ! glibc_run "make -j$(nproc)"; then
      warn "编译失败！"
      return 1
    else
      unset CFLAGS
      unset CXXFLAGS
      unset LDFLAGS
    fi
    if [[ ! $dont_install == yes ]]; then
      info "开始安装"
      if ! rm -rf /data/data/com.termux/files/usr/glibc/lib/box64-x86_64-linux-gnu/ && glibc_run "make install"; then
        warn "安装失败"
        return 1
      else
        info "命令运行测试"
        if ! glibc_run "box64 --version"; then
          warn "box64 --version 命令运行失败"
        fi
      fi
    else
      info "不再安装"
    fi
    info "获取box64版本号"
    local version_name=$(glibc_run "./box64 --version" | awk '{print $3}')
    if [[ -z $version_name ]]; then
      error "版本号获取失败"
    else
      info "版本：$build_version"
    fi
    unset dont_install
    cd ../..
    info "开始打包源码，请保持termux在前台运行以防止后台核心锁定问题"
    if ! load "tar -I \"xz -T$(nproc)\" -cf /sdcard/NumBox/resources/box64/src_output/box64-"$version_name"-$(date '+%Y%m%d-%H%M%S').tar.xz */" "打包中"; then
      warn "打包失败"
      return 1
    else
      info "打包完成"
      info "/sdcard/NumBox/resources/box64/src_output/box64-"$version_name"-$(date '+%Y%m%d-%H%M%S').tar.xz"
    fi
    cd #防止工作目录错误
    rm -rf $TMPDIR/box64_src_output
  }
  cd $TMPDIR/box64_src_output/*/
  info "修补文件路径"
  sed -i 's/\/usr/\/data\/data\/com.termux\/files\/usr\/glibc/g' CMakeLists.txt
  sed -i 's/\/etc/\/data\/data\/com.termux\/files\/usr\/glibc\/etc/g' CMakeLists.txt
  build_box64_sub_menu () {
    Dmenu_select=(c "取消-源码保存" d "我不需要安装只构建：$dont_install" 1 "预设-通用arm64" 2 "预设-骁龙8g2" 3 "预设-骁龙888" 4 "预设-骁龙865" 5 "预设-骁龙845" 6 "自定义")
    Dmenu  "CMake构建配置" "基础参数-DCMAKE_BUILD_TYPE=RelWithDebInfo -DARM_DYNAREC=on -DARM64=on -DBAD_SIGNAL=on"
    case $DMENU in
      c) main ;;
      d) Dyesno "不需要安装吗？" "构建完成后你可以后续选择安装对应源码包构建的版本"
      if [[ $? == 0 ]]; then
        export dont_install="yes"
      fi
      build_box64_sub_menu ;;
      1) local cmake_arg+=(-DBAD_SIGNAL=on)
      build_cmake ;;
      2) local cmake_arg+=(-DBAD_SIGNAL=on -DSD8G2=on)
      build_cmake ;;
      3) local cmake_arg+=(-DBAD_SIGNAL=on -DSD888=on)
      build_cmake ;;
      4) local cmake_arg+=(-DBAD_SIGNAL=on -DSD865=on)
      build_cmake ;;
      5) local cmake_arg+=(-DBAD_SIGNAL=on -DSD845=on)
      build_cmake ;;
      6) local cmake_arg_arry=(-DBAD_SIGNAL=on -DNOLOADADDR=on -DSD8G2=on -DSD888=on -DSD865=on -DSD845=on)
      local cmake_arg_checklist=($(dialog ${dialog_arg[@]} --title "自定义CMake参数" --checklist "强制参数:-DARM_DYNAREC=on -DARM64=on\n选择完成后你可以加入额外的自定义构建参数比如O3优化，不过可能会破坏兼容性" $box_sz \
        1 "BAD_SIGNAL" on \
        2 "NOLOADADDR(老版本可能需要?)" off \
        3 "SD8G2" off \
        4 "SD888" off \
        5 "SD865" off \
        6 "SD845" off 2>&1 >/dev/tty))
      case $cmake_arg_checklist in
        "") main ;;
        *) for i in ${cmake_arg_checklist[@]}; do
          local add_cmake_arg+=($cmake_arg_arry[$i])
        done
        dialog_arg+=(--no-cancel) Dinputbox "自定义CMake参数" "当前: ${add_cmake_arg[@]}\n输入no取消构建\n格式:-DXXX=on/off"
        if [[ $DINPUTBOX == no ]]; then
          main
        else
          cmake_arg+=(${add_cmake_arg[@]} $DINPUTBOX)
          build_cmake
        fi ;;
      esac ;;
    esac
  }
  build_box64_sub_menu
}

if [[ -z $ghSpeed ]] || [[ $ghSpeed == github.com ]]; then
  dl_url="https://github.com"
else
  dl_url="https://${ghSpeed}/https://github.com"
fi
. ~/NumBox/data/config/numbox.cfg
ghRepo=box64
ghUser=ptitSeb
Dmenu_select=(1 从本地源码构建 2 从本地源码安装 3 构建稳定版-偶数-全部 4 构建开发版-奇数-最新)
Dmenu "Box64版本构建与安装(glibc)" "不会获取到历史奇数版本开发版"
case $DMENU in
  "") last_jump ;;
  1) file_list "/sdcard/NumBox/resources/box64/src/" "从本地源码构建(.tar.gz/.zip包)" "/sdcard/NumBox/resources/box64/src/"
  case $returnFileListNum in
    "") main ;;
    *) if [[ $returnFileName == *.tar.gz ]]; then
          if ! load "un_tgz /sdcard/NumBox/resources/box64/src/\"$returnFileName\" $TMPDIR/box64_src_output" "解压文件"; then
            warn "文件解压失败"
          else
            build_box64_menu
          fi
    elif [[ $returnFileName == *.zip ]]; then
          if ! load "un_tgz /sdcard/NumBox/resources/box64/src/\"$returnFileName\" $TMPDIR/box64_src_output" "解压文件"; then
            warn "文件解压失败"
          else
            build_box64_menu
          fi
    else
      warn "不支持的文件格式/sdcard/NumBox/resources/box64/src/$returnFileName"
      return 1
    fi ;;
  esac ;;
  2) file_list "/sdcard/NumBox/resources/box64/src_output/" "从本地源码安装(.tar.xz包)" "/sdcard/NumBox/resources/box64/src_output/"
  case $returnFileListNum in
    "") main ;;
    *) if ! load "un_txz /sdcard/NumBox/resources/box64/src_output/\"$returnFileName\" $TMPDIR/box64_src_output"; then
      warn "文件解压失败"
    else
      cd $TMPDIR/box64_src_output/*/
      if ! cd build; then
        warn "无法找到构建目录=>build"
        return 1
      else
        info "开始安装"
        if ! rm -rf /data/data/com.termux/files/usr/glibc/lib/box64-x86_64-linux-gnu/ && glibc_run "make install"; then
          warn "安装失败"
          return 1
        else
          info "命令运行测试"
          if ! glibc_run "box64 --version"; then
            warn "box64 --version 命令运行失败"
          fi
        fi
      fi
    fi ;;
  esac ;;
  3) info "获取数据"
  local get_box64_tag=($(gh_get all-tag))
  if [[ -z $get_box64_tag ]]; then
    Dmsgbox "\Z1错误\Zn" "数据获取失败，请检查网络？"
    main
  else
    freeListArry=(${get_box64_tag[@]})
    free_list "稳定发行版（偶数版）"
    case $returnFreeListNum in
      "") mian ;;
      *) box64_src_tag=${returnFreeListName//\"} # <== 返回值里面有双引号
      local src_url_a="$(gh_get tag-res-src $box64_src_tag)"
      local src_url=${src_url_a//\"}
      info "获取到URL $src_url"
      info "开始下载"
      if [[ -z $ghSpeed ]] || [[ $ghSpeed == github.com ]]; then
        info "没有设置github加速站"
      else
        info "加速站设置为$ghSpeed"
        src_url="https://$ghSpped/$src_url"
      fi
      clean_dl_temp
      if ! download "$src_url" "/sdcard/NumBox/resources/box64/src/box64-${box64_src_tag}.tar.gz"; then
        clean_dl_temp
        warn "下载失败"
        return 1
      else
        if ! un_tgz /sdcard/NumBox/resources/box64/src/box64-${box64_src_tag}.tar.gz $TMPDIR/box64_src_output; then
          warn "文件解压失败"
          return 1
        else
          unset cmake_arg
          #  version_name="$box64_src_tag"
          build_box64_menu
        fi
      fi
    esac
  fi ;;
  4) src_url="https://github.com/ptitSeb/box64/archive/refs/heads/main.zip"
  if [[ -z $ghSpeed ]] || [[ $ghSpeed == github.com ]]; then
    info "没有设置github加速站"
  else
    info "加速站设置为$ghSpeed"
    src_url="https://$ghSpped/$src_url"
  fi
  info "开始下载文件"
  clean_dl_temp
  main_zip="$(date '+%Y%m%d-%H%M%S')_mian.zip"
  if ! download "$src_url" /sdcard/NumBox/resources/box64/src/$main_zip; then
    clean_dl_temp
    warn "下载失败"
    return 1
  else
    if ! 7zx /sdcard/NumBox/resources/box64/src/$main_zip $TMPDIR/box64_src_output; then
      warn "文件解压失败"
      return 1
    else
      cd $TMPDIR/box64_src_outpu/box64-main
      unset cmake_arg
      # version_name="dev-main"
      build_box64_menu
    fi
  fi ;;
esac
}
main