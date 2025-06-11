. ~/NumBox/data/config/numbox.cfg
if [[ -v USE_THREAD ]]; then
    USE_THREAD=$(nproc)
fi
un_txz () {
    path_to_str=$1
    pv ${path_to_str} | xz -T${USE_THREAD} -d | tar ${tar_arg[@]} -xf - -C $2 
}

un_tzst () {
    path_to_str=$1
    pv ${path_to_str} | zstd -T${USE_THREAD} -d | tar ${tar_arg[@]} -xf - -C $2
}

un_gz () {
    path_to_str=$1
    pv ${path_to_str} | unpigz -p ${USE_THREAD} | tar ${tar_arg[@]} -xf - -C $2
}

un_tar () {
    path_to_str=$1
    pv ${path_to_str} | tar ${tar_arg[@]} -xf - -C $2
}

7zx () {
    7z -t${USE_THREAD} x $1 -o$2
}