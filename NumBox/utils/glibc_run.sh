glibc_run () {
  unset LD_PRELOAD
  local PATH="/data/data/com.termux/files/usr/glibc/bin:$PATH"
  $PREFIX/glibc/bin/bash -c "$1"
}