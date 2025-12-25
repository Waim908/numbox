#!/bin/bash
utilsDoNotReimport=1
. ~/NumBox/utils/utils.sh
import echo.sh
import dialog.sh
import package.sh
import github_api.sh
import file_list.sh
import free_list.sh
import last_jump.sh
import downloader.sh
unset_utils_var
main() {
  . ~/NumBox/data/config/numbox.cfg
  # useDownloader=curl
  downloaderMkdir=1
  otherFileListOptions=(wined3d官网源)
  file_list "$HOME/NumBox/res_config/" "选择资源下载文件"
  if [[ -z $returnFileListName ]]; then
    last_jump
  elif [[ $returnFileListName == wined3d官网源 ]]; then
    info "获取重定向链接"
    dl_url_1="$(curl -s -I -L -w "%{url_effective}" --user-agent "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36" "https://downloads.fdossena.com/geth.php?r=wined3d-all" | tail -n 1)"
    if [[ -z $dl_url_1 ]]; then
      warn "获取重定向链接失败"
      return 1
    else
      info "获取下载列表"
      freeListArry=($(curl -L --user-agent "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36" "$dl_url_1" | grep -o 'href="[^"]*"' | sed 's/href="//;s/"//'))
      free_list "wined3d官网源" "选择一个版本下载"
      case $returnFreeListNum in
      "") main ;;
      *)
        file_path="/sdcard/NumBox/resources/wined3d"
        dl_url="$dl_url_1${returnFreeListName}"
        if ! download "$dl_url" "$file_path/$returnFreeListName/"; then
          warn "下载$dl_url => $file_path/$returnFreeListName/ 失败！"
          return 1
        else
          Dmsgbox "下载完成" "$dl_url => $file_path/$returnFreeListName/"
          main
        fi
        ;;
      esac
    fi
  else
    json_file_name="$returnFileListName"
    src_url="$(jq .githubRepo "$HOME/NumBox/res_config/$returnFileListName" | sed -E 's/"|"$//g')"
    file_type="$(jq .fileType "$HOME/NumBox/res_config/$returnFileListName" | sed -E 's/"|"$//g')"
    #    download_type="$(jq .downloadType "$HOME/NumBox/res_config/$returnFileListName" | sed -E 's/"|"$//g')"
    # if [[ -z $file_type ]] && [[ $download_type == release ]]; then
    file_name="$(jq .fileName "$HOME/NumBox/res_config/$returnFileListName" | sed -E 's/"|"$//g')"
    # fi
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
      info "获取$returnFreeListName 的下载链接"
      tag_name=${returnFreeListName//\"/}
      ori_url_arry=($(gh_get tag-res-dl $tag_name | grep "$file_name" | grep "$file_type"))
      if [[ ! -z $ori_url_arry ]]; then
        if [[ ${#ori_url_arry[@]} -eq 1 ]]; then
          dl_url=$(get_gh_download_url ${ori_url_arry//\"/})
          if ! download "$dl_url" "$file_path/$tag_name"; then
            warn "下载$dl_url => $file_path/$tag_name 失败！"
            return 1
          else
            Dmsgbox "下载完成" "$dl_url => $file_path/$tag_name"
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
            if ! download "$dl_url" "$file_path/$tag_name"; then
              warn "下载$dl_url => $file_path/$tag_name 失败！"
              return 1
            else
              Dmsgbox "下载完成" "$dl_url => $file_path/$tag_name"
              main
            fi
            ;;
          esac
        fi
      else
        echo "${ori_url_arry[@]}"
        warn "没有获取到任何releases下载链接"
        return 1
      fi
      ;;
    esac
  fi
}
main
