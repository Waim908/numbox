if [[ -v USE_THREAD ]]; then
    if [[ ! -z $1 ]]; then
        USE_THREAD=$1
    else
        USE_THREAD=$(nproc)
    fi
fi

un_package () {
    echo -e "\033[1;36m\"$1\"\033[0m => \033[1;33m\"$2\"\033[0m"
    local path_to_str="$1"
    pv ${path_to_str} | tar -I '$3' ${tar_arg[@]} -xf - -C $2
}

un_txz () {
    echo -e "\033[1;36m\"$1\"\033[0m => \033[1;33m\"$2\"\033[0m"
    local path_to_str="$1"
    pv ${path_to_str} | tar -I 'xz' ${tar_arg[@]} -xf - -C $2
}

un_tzst () {
    echo -e "\033[1;36m\"$1\"\033[0m => \033[1;33m\"$2\"\033[0m"
    local path_to_str="$1"
    pv ${path_to_str} | tar  -I 'zstd' ${tar_arg[@]} -xf - -C $2
}

un_tgz () {
    echo -e "\033[1;36m\"$1\"\033[0m => \033[1;33m\"$2\"\033[0m"
    local path_to_str="$1"
    pv ${path_to_str} | tar -I 'unpigz' ${tar_arg[@]} -xf - -C $2
}

un_tar () {
    echo -e "\033[1;36m\"$1\"\033[0m => \033[1;33m\"$2\"\033[0m"
    local path_to_str="$1"
    pv ${path_to_str} | tar ${tar_arg[@]} -xf - -C $2
}

7zx () {
    echo -e "\033[1;36m\"$1\"\033[0m => \033[1;33m\"$2\"\033[0m"
    7z -mmt${USE_THREAD} x "$1" -o"$2"
}

7z2 () {
  7z -mmt${USE_THREAD}
}