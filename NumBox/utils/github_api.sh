# 没Key每个小时可以使用60次，有Key 1500/h，其他限制针对LFS (VERSION: 2022)
# 详情见https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api

#示例 curl 
Gcurl () {
  local api_url="https://api.github.com/repos/${gh_user}/${gh_repo}"
  if [[ ! -z ${GH_TOKEN} ]]; then
    curl --request GET --url "" --header "Accept: application/vnd.github+json" --header "Authorization: Bearer $gh_token"
  else
    curl --request GET --url "$1" --header "Accept: application/vnd.github+json"
  fi
}
# res_get $1<=type $2<=tag_name
res_get () {
  local api_url="https://api.github.com/repos/${gh_user}/${gh_repo}"
  # Run 'sed_usre_repo' function or custom key
  case $1 in
    tag)
    Gcurl "$api_url/release/${2}" | grep "tag_name" | sed 's/.*"tag_name": "\(.*\)",/\1/' 
    ;;
    release) 
    Gcurl "$api_url/release/${2}" | grep "browser_download_url" | sed 's/.*"browser_download_url": "\(.*\)".*/\1/'
    ;;
    star)
    Gcurl "$api_url" | grep "stargazers_count"
    ;;
    get-tag)

    esac

}