utilsDoNotReimport=1
. ~/NumBox/utils/utils.sh
import dialog.sh
import github_api.sh
import echo.sh
echo $DMENU
unset_utils_var
echo $DMENU
. ~/NumBox/data/config/numbox.cfg
Dmenu_select=(1 "加速站设置" 2 "API联通性测试")
Dmenu "github设置" "1"
case $DMENU in
  1) site_set () {
    . ~/NumBox/data/config/numbox.cfg
    if [[ -z $ghSpeed ]]; then
      ghSpeed_is="自动选择"
    else
      ghSpeed_is="$ghSpeed"
    fi
    Dmenu_select=(T "PING测试" $(cat ~/NumBox/data/config/gh_site.cfg))
    Dmenu "加速站设置" "当前选择 $ghSpeed_is"
    case $DMENU in
      T) cp ~/NumBox/data/config/gh_site.cfg $TMPDIR/gh_ping_test.txt
      if ! parallel -j$(nproc) --progress --arg-file="$HOME/NumBox/data/config/gh_site.cfg" "ping -i 0.1 -c 5 -W 2 {} 2>/dev/null | awk -F'/' '/^rtt/ {print \$5} END {if (NR<5) print \"error\"}' | xargs -I [] echo \"[] {}\"" | while read latency domain; do sed -i "/^$domain\$/s/^/$latency /" $TMPDIR/gh_ping_test.txt; done ;then
        WARN "parallel执行失败！"
      fi
      Dmsgbox "测试完毕" ""
      ;;

    esac
  }
  site_set ;;

