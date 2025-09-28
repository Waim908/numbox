main () {
utilsDoNotReimport=1
. ~/NumBox/utils/utils.sh
import dialog.sh
import github_api.sh
import echo.sh
import last_jump.sh
import load.sh
import free_list.sh
unset_utils_var
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
    otherFreeListOptions=(T "PING测试" A "添加自定义加速站" auto "自动检测镜像站" $(cat ~/NumBox/data/config/gh_site.cfg))
    freeListArry=(cat ~/NumBox/data/config/gh_site.cfg)
    free_list "加速站设置" "当前选择 $ghSpeed_is"
    case $returnFreeListNum in
      "") . ~/NumBox/Set-github.sh ;;
      T) cat ~/NumBox/data/config/gh_site.cfg | sed 's/^[0-9]* "//;s/"$//' > $TMPDIR/gh_ping_test.txt
      info "请稍后，如果长时间无响应请Ctrl+C 退出"
      if ! parallel -j$(nproc) "ping -c 5 -W 2 {} 2>/dev/null | awk -F'/' '/^rtt/ {print \$5} END {if (NR<5) print \"error\"}' | xargs -I [] echo \"[] {}\"" ::: $(cat $TMPDIR/gh_ping_test.txt) | while read latency domain; do sed -i "/^$domain\$/s/^/$latency /" $TMPDIR/gh_ping_test.txt; done;then
        warn "parallel执行失败！"
      fi
      Dmsgbox "测试完毕(仅供参考)" "$(cat $TMPDIR/gh_ping_test.txt | sort -n)" ;;
      A) Dinputbox "输入加速站" "例子：www.123456.com"
      case $DINPUTBOX in
        "") site_set ;;
        *) line="$($(cat ~/NumBox/data/config/gh_site.cfg | wc -l)+1)"
        echo "$line ${DINPUTBOX}" >> ~/NumBox/data/config/gh_site.cfg
        site_set ;;
      esac ;;
      *) sed -i "s/^ghSpeed=.*/ghSpeed=\"${returnFreeListName}\"\g" ~/NumBox/data/config/numbox.cfg
      Dmsgbox "镜像站已设置为" "\Z3$returnFreeListName\Zn"
      site_set ;;
    esac
  }
  site_set ;;
  2) clear
  info  "间隔0.2s 10发包"
  if ! ping -c 10 -i 0.2 api.github.com; then
    warn "PING测试失败"
  fi
  info "测试结束"
  read -s -n1 -p "输入任意字符返回" && . ~/NumBox/Set-github.com ;;
esac
}