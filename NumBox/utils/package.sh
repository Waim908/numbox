if [[ -v USE_THREAD ]]; then
    if [[ -z $1 ]]; then
        USE_THREAD=$1
    else
        USE_THREAD=$(nproc)
    fi
fi
#-T${USE_THREAD}
un_package () {
    local path_to_str=$1
    pv ${path_to_str} | tar -I '$3' ${tar_arg[@]} -xf - -C $2 
}

un_txz () {
    local path_to_str=$1
    pv ${path_to_str} | tar -I 'xz' ${tar_arg[@]} -xf - -C $2 
}

un_tzst () {
    local path_to_str=$1
    pv ${path_to_str} | tar  -I 'zstd' ${tar_arg[@]} -xf - -C $2
}

un_gz () {
    local path_to_str=$1
    pv ${path_to_str} | unpigz -p ${USE_THREAD} | tar ${tar_arg[@]} -xf - -C $2
}

un_tar () {
    local path_to_str=$1
    pv ${path_to_str} | tar ${tar_arg[@]} -xf - -C $2
}

7zx () {
    7z -t${USE_THREAD} x $1 -o$2
}