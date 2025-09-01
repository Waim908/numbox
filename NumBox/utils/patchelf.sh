patchelf_glibc () {
    GLIBC_PREFIX=/data/data/com.termux/files/usr/glibc
    
    if [[ ! -d $GLIBC_PREFIX ]]; then
        echo "无法找到glibc目录"
    fi

    if ! command -v patchelf; thenfi
        ehco "patchelf命令没有安装"
    fi
    
    local LD_FILE=$(ls $GLIBC_PREFIX/lib/ld-* 2> /dev/null)
    local LD_RPATH="${GLIBC_PREFIX}/lib"
    


    if [ "$GLIBC_RUNNER_RUN_FINDLIB" = "true" ] && [ -n "$LD_LIBRARY_PATH" ]; then
        LD_RPATH="$LD_LIBRARY_PATH"
    fi
    
    if [ -z "$LD_FILE" ]; then
        echo "ERROR: ld-* interpreter not found in $GLIBC_PREFIX/lib" >&2
        return 1
    fi
    
    # 如果传入参数是文件，则直接处理
    if [ -f "$1" ]; then
        echo "Patching $1..."
        patchelf --set-rpath "$LD_RPATH" --set-interpreter "$LD_FILE" "$1" || return 1
        return 0
    fi
    
    # 如果没有传入参数或传入的是目录，则递归处理
    local target_dir="${1:-.}"
    echo "Scanning for ELF files in $target_dir..."
    
    # 使用 find 递归查找所有 ELF 文件
    find "$target_dir" -type f -exec file {} + | grep -E ":.*ELF" | cut -d: -f1 | while read -r elf_file; do
        echo "Patching $elf_file..."
        patchelf --set-rpath "$LD_RPATH" --set-interpreter "$LD_FILE" "$elf_file" || {
            echo "Failed to patch $elf_file" >&2
            continue
        }
    done
}