# 默认调用utils.sh
. ~/NumBox/utils/utils.sh
import echo.sh
pluginName="$1"
if [[ -z $pluginName ]]; then
  warn "未设置插件名参数"
  exit 1
fi
if [[ -z $pluginPath ]]; then
  export pluginPath="~/NumBox/data/plugins/${pluginName}"
fi
