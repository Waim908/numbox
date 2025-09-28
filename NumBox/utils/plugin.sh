# 默认调用utils.sh
. ~/NumBox/utils/utils.sh
# Need import echo.sh
get_plugin_path () {
  pluginName="$1"
  if [[ -z $pluginName ]]; then
    warn "未设置插件名参数"
    return 1
  fi
  if [[ -z $pluginPath ]]; then
    export pluginPath="~/NumBox/data/plugins/${pluginName}"
  fi
}
utilsVar+=(pluginPath)