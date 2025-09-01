unset LD_PRELOAD
# export PATH=/data/data/com.termux/files/usr/glibc/bin:$PATH
# export PATH=$(echo $PATH | tr ':' '\n' | sort -u | tr '\n' ':')
# export LD_LIBRARY_PATH=$PREFIX/glibc/lib:$PREFIX/lib
if [[ -v CONTAINER_NAME ]]; then
    export WINEPREFIX="/data/data/com.termux/files/home/NumBox/data/container/${CONTAINER_NAME}/disk"
    export BOX64_LD_LIBRARY_PATH="$HOME/NumBox/data/container/${CONTAINER_NAME}/wine/lib/wine/x86_64-unix:$PREFIX/glibc/lib/box64-x86_64-linux-gnu"
    export MESA_SHADER_CACHE_DIR="/data/data/com.termux/files/home/NumBox/data/container/${CONTAINER_NAME}/temp/mesa"
    export PATH="/data/data/com.termux/files/usr/glibc/bin:$HOME/NumBox/data/container/${CONTAINER_NAME}/wine/bin:$PATH"
else
    export PATH="/data/data/com.termux/files/usr/glibc/bin:$PATH"
fi
export PATH=$(echo "$PATH" | tr ':' '\n' | awk '!x[$0]++' | paste -sd ':')
export DISPLAY=:0
export FONTCONFIG_PATH=/data/data/com.termux/files/usr/glibc/etc/fonts
export USE_HEAP=1
export LIBGL_DRIVERS_PATH=/data/data/com.termux/files/usr/glibc/lib/dri
# cachedir
export XDG_RUNTIME_DIR="${TMPDIR}"
export MESA_NO_ERROR=1