check_downloader () {
  # 直接在numbox.cfg设置
  if [[ -z  $useDownloader ]]; then
    echo curl
  else
    echo "$useDownloader"
  fi
  if ! command -v "$downloader"; then
    echo "无法找到下载器 $downloader，切换为termux预装的curl"
    if ! command -v curl; then
      echo -e "\e[31m\e[1mWARN: \e[31m未安装curl！请通过以下命令安装\e[0m"
      echo -e "\e[36m\e[1mINFO: \e[36mpkg i curl\e[0m"
      return 1
    fi
  fi
}
clean_dl_temp () {
  # 不需要断点续传可以直接删掉所有临时文件，但是考虑到多任务的话不推荐
  rm -rf $TMPDIR/dl_temp.*
}
download () {
  # check_downloader
  if [[ $curlDisplayBar == 1 ]]; then
    local curl_arg+=(--progress-bar)
  fi
  if [[ $downloaderUseAndroidUA == 1 ]]; then
    local curl_arg+=(--user-agent "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36")
    local wget_arg+=(--user-agent="Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36")
    local aria2c_arg+=(-U "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36")
  fi
  # custom arg
  local curl_arg+=(${curlArg[@]})
  local wget_arg+=(${wgetArg[@]})
  local aria2c_arg+=(${aria2cArg[@]})
  local temp_file=$(mktemp -u $TMPDIR/dl_temp.XXXXXX)
  # local rename="$1"
  case $useDownloader in
    curl|*|"") echo -e "Downloader: \e[32mcurl\e[0m"
    echo -e "\033[1;36m$2 => \033[1;33m$1\033[0m"
    if curl ${curl_arg[@]} -L -C - -o $temp_file "$1"; then # <== 必须有-L参数否则无法重定向链接解析不出来
      mv "$temp_file" "$2"
    else
      echo -e "\e[33m\e[1mERROR: (curl) \e[33m $2 => $1 下载失败\e[0m"
      rm -rf $temp_file
      return 1
    fi ;;
    wget) echo -e "Downloader: \e[32mwget\e[0m"
    echo -e "\033[1;36m$2 => \033[1;33m$1\033[0m"
    if wget -O $temp_file -c "$1"; then
      mv "$temp_file" "$2"
    else
      echo -e "\e[33m\e[1mERROR: (wget) \e[33m $2 => $1 下载失败\e[0m"
      rm -rf $temp_file
      return 1
    fi ;;
    aria2c) echo -e "Downloader: \e[32maria2c\e[0m"
    echo -e "\033[1;36m$2 => \033[1;33m$1\033[0m"
    if [[ -z $useThread ]]; then
      local useThread=$(nproc)
    fi
    if aria2c -x $useThread -s $useThread  -c -o $(basename $temp_file) -d $TMPDIR/ "$1"; then
      mv "$temp_file" "$2"
    else
      echo -e "\e[33m\e[1mERROR: (aria2c) \e[33m $2 => $1 下载失败\e[0m"
      rm -rf $temp_file
      return 1
    fi ;;
  esac
}
utilsVar+=(useDownloader curlDisplayBar downloaderUseAndroidUA)