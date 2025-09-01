#!/bin/bash
. ~/NumBox/utils/dialog.conf
. ~/NumBox/utils/empty.sh sd
. ~/NumBox/utils/file_list.sh
. ~/NumBox/utils/load.sh
if [[ $(ls /sdcard/NumBox/ctr_package | wc -l ) -lt 5 ]]; then
    select_bottom=1
else
  unset select_bottom
fi
file_list "/sdcard/NumBox/ctr_package/*.ctr" "选择一个要导入的包" "格式为 XXXX.ctr 压缩类型为gzip"
