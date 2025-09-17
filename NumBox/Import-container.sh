#!/bin/bash
. ~/NumBox/utils/dialog.sh
. ~/NumBox/utils/empty.sh 
create_dir sd
. ~/NumBox/utils/file_list.sh
. ~/NumBox/utils/load.sh
if [[ $(ls /sdcard/NumBox/ctr_package | wc -l ) -lt 5 ]]; then
    selectBottom=1
else
  unset selectBottom
fi
file_list "/sdcard/NumBox/ctr_package/*.ctr" "选择一个要导入的包" "格式为 XXXX.ctr 压缩类型为gzip"
