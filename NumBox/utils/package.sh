. ~/NumBox/data/config/numbox.cfg

un_txz () {
    path_to_str=$1
    pv ${path_to_str} | tar ${tar_arg[@]} -I "xz -T${USE_THREAD} -d" -xf - -C $2 
    # ${tar_arg[@]}
}

un_tzst () {
    path_to_str=$1
    pv ${path_to_str} | tar ${tar_arg[@]} -I "zstd -T${USE_THREAD}" -xf - -C $2
}

un_gz () {
    path_to_str=$1
    pv ${path_to_str} | tar ${tar_arg[@]} -I "pigz -p ${USE_THREAD}" -zxf - -C $2
}

un_tar () {
    path_to_str=$1
    pv ${path_to_str} | tar ${tar_arg[@]} -xf - -C $2
}

7zx () {
    7z -t${USE_THREAD} x $1 -o$2
}