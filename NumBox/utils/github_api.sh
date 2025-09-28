# 进入glibc环境`grun --shell`

# 没Key每个小时可以使用60次，有Key 1500/h，其他限制针对LFS (VERSION: 2022)
# 详情见https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api

test_api () {
  if ! ping api.github.com; then
    echo -e "\e[31mERROR:\e[0m 无法链接到github api！请检查网络代理"
    return 1
  fi
}

Gcurl () {
#  local api_url="https://api.github.com/repos/${gh_user}/${gh_repo}"
  if [[ ! -z ${ghToken} ]]; then
    # "TOKEN访问"
    if ! curl --progress-bar --request GET --url "$1" --header "Accept: application/vnd.github+json" --header "Authorization: Bearer $gh_token"; then
      echo -e "\e[31mERROR:\e[0m 访问 \e[36m\"$1\"\e[0m 失败，请检查网址拼写或者网络及代理设置是否正常"
      return 1
    fi
  else
    # "未设置TOKEN"
    if ! curl --progress-bar --request GET --url "$1" --header "Accept: application/vnd.github+json"; then
      echo -e "\e[31mERROR:\e[0m 访问 \e[36m\"$1\"\e[0m 失败，请检查网址拼写或者网络及代理设置是否正常"
      return 1
    fi
  fi
}

check_var () {
  if [[ -z $ghUser ]]; then
    echo -e "\e[31mERROR:\e[0m 未定义或空 \$ghUser 变量，无法定位github用户"
    return 1
  elif [[ -z $ghRepo ]]; then
    echo -e "\e[31mERROR:\e[0m 未定义或空 \$ghRepo 变量，无法定位github仓库名称"
    return 1
  fi
}

# res_get $1<=type $2<=tag_name
# 返回值推荐作为数组存储在变量方便处理
# 返回值带双引号!
# 返回值带双引号!
# 返回值带双引号!
gh_get () {
  if [[ -z $apiUrl ]]; then
    local api_url="https://api.github.com/repos/${ghUser}/${ghRepo}"
  else
    local api_url="$apiUrl"
  fi
  if check_var; then
    case $1 in
      # 相同URL
      all) Gcurl "$api_url" | jq . ;;
      star) Gcurl "$api_url" | jq .stargazers_count ;;
      # tags
      all-tag) Gcurl "$api_url/tags" | jq .[].name ;;
      # 相同URL
      all-res) Gcurl "$api_url/releases" | jq . ;;
      all-res-tag) Gcurl "$api_url/releases" | jq .[].tag_name ;;
      # 相同URL
      latest-res) Gcurl "$api_url/releases/latest" | jq . ;;
      latest-res-tag) Gcurl "$api_url/releases/latest" | jq .tag_name ;;
      latest-res-dl) Gcurl "$api_url/releases/latest" | jq ".assets[] | .browser_download_url" ;;
      latest-res-src) Gcurl "$api_url/releases/latest" | jq .tarball_url ;;
      # 相同URL
      tag-res) Gcurl "$api_url/releases/tags/${2}" | jq . ;;
      tag-res-body) Gcurl "$api_url/releases/tags/${2}" | jq .body ;;
      tag-res-dl) Gcurl "$api_url/releases/tags/${2}" | jq ".assets[] | .browser_download_url" ;;
      tag-res-src) Gcurl "$api_url/releases/tags/${2}" | jq .tarball_url ;;
      latest-res-src) Gcurl "$api_url/releases/tags/${2}" | jq .tarball_url ;;
    esac
  fi
}

gh_json_get () {
  if [[ -f "$2" ]]; then
    case $1 in
      all) jq . $2 ;;
      all-tag) jq .[].name $2 ;;
#      all-res) Gcurl "$api_url/releases" | jq . ;;
      all-res-tag) jq .[].tag_name $2 ;;
#      latest-res) Gcurl "$api_url/releases/latest" | jq . ;;
      latest-res-tag) jq .tag_name $2 ;;
      latest-res-dl) jq ".assets[] | .browser_download_url" $2 ;;
#      tag-res) Gcurl "$api_url/releases/tags/${2}" | jq . ;;
      tag-res-body) jq .body $2 ;;
      tag-res-dl) jq ".assets[] | .browser_download_url" $2 ;;
      star) jq .stargazers_count $2 ;;
      src) jq .tarball_url $2 ;;
    esac
  else
    echo -e "\e[31mERROR:\e[0m 无法找到\e[36m\"$2\"\e[0m"
  fi
}
# 通用，确保数据返回为json 格式
api_get () {
  if [[ -z $customApiURL ]]; then
    echo -e "\e[31mERROR:\e[0m 未定义或空 \$customApiURL 变量，无法访问自定义API URL"
  else
    curl "$customApiURL" | jq "$@"
  fi
}
# 其他既直接对json文件操作的通用方法可以参考jq的命令用法