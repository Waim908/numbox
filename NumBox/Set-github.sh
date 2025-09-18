utilsDoNotReimport=1
. ~/NumBox/utils/utils.sh
import dialog.sh
import github_api.sh
import echo.sh
import last_jump.sh
echo $DMENU
unset_utils_var
echo $DMENU
. ~/NumBox/data/config/numbox.cfg
Dmenu_select=(1 "加速站设置" 2 "API联通性测试")
Dmenu "github设置" "1"
case $DMENU in
  "") last_jump ;;
  1) site_set () {
    . ~/NumBox/data/config/numbox.cfg
    if [[ -z $ghSpeed ]]; then
      ghSpeed_is="自动选择"
    else
      ghSpeed_is="$ghSpeed"
    fi
    Dmenu_select=(T "PING测试" A "添加自定义加速站" auto "自动检测镜像站" $(cat ~/NumBox/data/config/gh_site.cfg))
    Dmenu "加速站设置" "当前选择 $ghSpeed_is"
    case $DMENU in
      "") . ~/NumBox/Set-github.sh ;;
      T) cat ~/NumBox/data/config/gh_site.cfg | sed 's/^[0-9]* "//;s/"$//' > $TMPDIR/gh_ping_test.txt
      if ! parallel -j$(nproc) "ping -c 5 -W 2 {} 2>/dev/null | awk -F'/' '/^rtt/ {print \$5} END {if (NR<5) print \"error\"}' | xargs -I [] echo \"[] {}\"" ::: $(cat $TMPDIR/gh_ping_test.txt) | while read latency domain; do sed -i "/^$domain\$/s/^/$latency /" $TMPDIR/gh_ping_test.txt; done;then
        WARN "parallel执行失败！"
      fi
      Dmsgbox "测试完毕(仅供参考)" "$(cat $TMPDIR/gh_ping_test.txt | sort -n)" ;;
      A) Dinputbox "例子：www.123456.com"
      case $DINPUTBOX in
        "") site_set ;;
        *) line="$($(cat ~/NumBox/data/config/gh_site.cfg | wc -l)+1)"
        echo "$line ${DINPUTBOX}" >> ~/NumBox/data/config/gh_site.cfg
        site_set ;;
      esac ;;
      *) get_site=$(grep -e "^${DMENU} " ~/NumBox/data/config/gh_site.cfg | sed ”s/^${DMENU} //“ | sed 's/"//' | sed 's/"$//')
      

    esac
  }
  site_set ;;
esac