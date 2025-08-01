sed_user_repo () {
    # $1 = "XXXX/https://github.com/user/repo"
    local gh_arry=($(echo "$1" | awk -F'/' '{print $(NF-1), $NF}'))
    export gh_user="${gh_arry[0]}"
    export gh_repo="${gh_arry[1]}"
}
# res_get $1 $2<=URL
res_get () {
    case $1 in
        latest) sed_user_repo $2
            parallel curl https://api.github.com/repos/$gh_user/$gh_repo/latest | grep "tag_name" | sed 's/.*"tag_name": "\(.*\)",/\1/'

}