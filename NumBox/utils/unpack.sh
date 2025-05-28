un_txz () {
    pv $1 | tar -I "xz -T${USE_THREAD}" -xf - -C $2 ${tar_arg[@]}
}
un_tzst () {
    pv $1 | tar -I "zstd -T${USE_THREAD}" -xf - -C $2
}

get_tar_type=$(files $1)
