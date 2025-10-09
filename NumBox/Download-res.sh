main() {
  . ~/NumBox/utils/utils.sh
  . ~/NumBox/data/config/numbox.cfg
  import echo.sh
  import dialog.sh
  import package.sh
  import github_api.sh
  import file_list.sh
  import free_list.sh
  import last_jump.sh
  import downloader.sh
  otherFileListOptions=(wined3d 关于wined3d)
  file_list ~/NumBox/res_config "选择资源下载文件"
  if [[ -z $returnFileListNum ]]; then
    last_jump
  elif [[ $returnFileListNum == wined3d ]]; then
    Dmsgbox "为什么没有wined3d的下载配置文件？"
  else
    json_file_name="$returnFileListName"
    src_url="$(jq .githubRepo "$HOME/NumBox/res_config/$returnFileListName" | sed -E 's/"|"$//g')"
    file_type="$(jq .fileType "$HOME/NumBox/res_config/$returnFileListName" | sed -E 's/"|"$//g')"
    #    download_type="$(jq .downloadType "$HOME/NumBox/res_config/$returnFileListName" | sed -E 's/"|"$//g')"
    if [[ -z $file_type ]] && [[ $download_type == release ]]; then
      file_name="$(jq .fileName "$HOME/NumBox/res_config/$returnFileListName" | sed -E 's/"|"$//g')"
    fi
    file_path="$(jq .filePath "$HOME/NumBox/res_config/$returnFileListName" | sed -E 's/"|"$//g')"
    info "仓库：$src_url"
    info "文件类型：$file_type"
    #    info "下载类型：$download_type"
    info "指定的文件名：$file_name"
    info "下载到：$file_path"
    echo -e "\n\n"
    repo_info=($(echo "$src_url" | sed -n 's|.*github\.com/\([^/]*\)/\([^/#?]*\).*|\1 \2|p'))
    info "获取Tag"
    ghUser="${repo_info[0]}"
    ghRepo="${repo_info[1]}"
    freeListArry=($(gh_get all-tag))
    free_list "$json_file_name" "选择一个版本"
    case $returnFreeListNum in
    "") main ;;
    *)
      info "获取$returnFreeListName的下载链接"
      ori_url_arry=($(gh_get tag-res-dl ${returnFreeListName//\"/} | grep "$file_name" | grep "$file_type"))
      if [[ ! -z $ori_url_arry ]]; then
        if [[ ${#ori_url_arry[@]} -gt 1 ]]; then
          dl_url="$(get_gh_download_url $ori_url_arry_1)"
          if ! download "$dl_url" "$file_path"; then
            warn "下载$dl_url => $file_path 失败！"
            return 1
          else
            Dmsgbox "下载完成" "$dl_url => $file_path"
            main
          fi
        else
          freeListArry=("${ori_url_arry[@]}")
          free_list "选择一个资源安装" "会自动转换为加速站下载（如果已经设置）"
          case $returnFileListNum in
          "") main ;;
          *)
            dl_url=$(get_gh_download_url ${ori_url_arry//\"/})
            clean_dl_temp
            if ! download "$dl_url" "$file_path"; then
              warn "下载$dl_url => $file_path 失败！"
              return 1
            else
              Dmsgbox "下载完成" "$dl_url => $file_path"
              main
            fi
            ;;
          esac
        fi
      else
        warn "没有获取到任何releases下载链接"
        return 1
      fi
      ;;
    esac
  fi
}
main
