glibc_run () {
  # 我知道有grun这个东西好吧，但是对于某些没有安装这个包的情况还是得整个简单的运行命令
  unset LD_PRELOAD
  local PATH="/data/data/com.termux/files/usr/glibc/bin:$PATH"
  $PREFIX/glibc/bin/bash -c "$1"
}