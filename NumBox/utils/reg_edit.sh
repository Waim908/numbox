#!/bin/bash

# 设置注册表键值
# 参数:
#   $1 - 注册表文件路径
#   $2 - 注册表路径 (如: "Control Panel\\Desktop")
#   $3 - 键名
#   $4 - 键值 (如果要删除键，设为空字符串)
set_reg_key() {
    rm -rf $TMPDIR/wine-reg-edit-*
    local file="$1"
    local section="$2"
    local key="$3"
    local value="$4"

    # 创建带有时间戳的临时文件
    local temp_file
    temp_file=$(mktemp "$TMPDIR/wine-reg-edit-XXXXXX")
    trap 'rm -f "$temp_file"' EXIT
    
    local in_section=0
    local key_found=0
    local current_section=""
    local section_started=0
    local last_was_key=0
    local pending_empty=0
    local section_exists=0
    
    # 检查文件是否存在，不存在则创建
    if [[ ! -f "$file" ]]; then
        touch "$file"
    fi
    
    # 先检查目标节是否存在
    while IFS= read -r line; do
        if [[ "$line" =~ ^\[(.*)\][[:space:]]*[0-9a-fA-F]*$ ]]; then
            current_section="${BASH_REMATCH[1]//\\\\/\\}"
            if [[ "$current_section" == "$section" ]]; then
                section_exists=1
                break
            fi
        fi
    done < "$file"
    
    # 重置变量准备处理文件
    in_section=0
    current_section=""
    
    while IFS= read -r line; do
        # 检测节头（支持带时间戳的格式）
        if [[ "$line" =~ ^\[(.*)\][[:space:]]*[0-9a-fA-F]*$ ]]; then
            # 处理转义：将双反斜杠恢复为单反斜杠
            current_section="${BASH_REMATCH[1]//\\\\/\\}"
            
            # 如果在目标节中且需要新增键值
            if [[ $in_section -eq 1 && $key_found -eq 0 && -n "$value" ]]; then
                # 如果上一行是键值行，直接添加新键值
                if [[ $last_was_key -eq 1 ]]; then
                    echo "\"$key\"=$value" >> "$temp_file"
                # 如果上一行是空行，先添加键值再保留空行
                else
                    echo "\"$key\"=$value" >> "$temp_file"
                    echo "" >> "$temp_file"
                fi
                key_found=1
            fi
            
            # 重置节状态
            in_section=0
            last_was_key=0
            section_started=0
            
            # 检查是否是我们要删除的节
            if [[ "$current_section" == "$section" && -z "$key" && -z "$value" ]]; then
                # 跳过这个节（删除它）
                in_section=1  # 标记为在节中，但跳过所有内容
                continue
            fi
            
            # 写入当前节头
            echo "$line" >> "$temp_file"
            
            # 检查是否进入目标节
            if [[ "$current_section" == "$section" ]]; then
                in_section=1
                key_found=0
                section_started=1
            else
                # 保留节间空行状态
                pending_empty=1
            fi
            continue
        fi

        # 处理节间空行
        if [[ $pending_empty -eq 1 && -z "$line" ]]; then
            echo "" >> "$temp_file"
            pending_empty=0
            continue
        fi
        pending_empty=0
        
        # 在目标节中处理键值
        if [[ $in_section -eq 1 ]]; then
            # 如果是删除整个节，跳过所有内容
            if [[ -z "$key" && -z "$value" ]]; then
                continue
            fi
            
            # 匹配键值行
            if [[ "$line" =~ ^\"([^\"]+)\"[[:space:]]*=[[:space:]]*(.*)$ ]]; then
                local reg_key="${BASH_REMATCH[1]}"
                last_was_key=1
                
                if [[ "$reg_key" == "$key" ]]; then
                    key_found=1
                    
                    # 处理删除操作
                    if [[ -z "$value" ]]; then
                        # 如果删除后是节中唯一键值，保留空节
                        if [[ $section_started -eq 1 ]]; then
                            section_started=0
                        fi
                        continue
                    fi
                    
                    # 处理修改操作
                    if [[ "$line" =~ ^\"([^\"]+)\"=\"(.*)\"$ ]]; then
                        # 字符串类型
                        echo "\"$key\"=\"${value//\"/\\\"}\"" >> "$temp_file"
                    elif [[ "$line" =~ ^\"([^\"]+)\"=([a-z]+:.*)$ ]]; then
                        # 特殊类型（dword:/hex:等）
                        echo "\"$key\"=$value" >> "$temp_file"
                    else
                        # 普通数值类型
                        echo "\"$key\"=$value" >> "$temp_file"
                    fi
                    continue
                fi
            fi
            
            # 处理空行（节内部）
            if [[ -z "$line" ]]; then
                # 如果是节开始的第一个空行，保留它
                if [[ $section_started -eq 1 ]]; then
                    section_started=0
                    echo "" >> "$temp_file"
                fi
                last_was_key=0
                continue
            fi
            
            # 非键值行内容（理论上不应该存在）
            echo "$line" >> "$temp_file"
            last_was_key=0
            section_started=0
        else
            # 非目标节内容直接写入
            echo "$line" >> "$temp_file"
            last_was_key=0
        fi
        
    done < "$file"
    
    # 处理在文件末尾的新增键值
    if [[ $in_section -eq 1 && $key_found -eq 0 && -n "$value" ]]; then
        # 如果上一行是键值行，直接添加
        if [[ $last_was_key -eq 1 ]]; then
            echo "\"$key\"=$value" >> "$temp_file"
        # 如果上一行是空行，先添加键值再保留空行
        else
            echo "\"$key\"=$value" >> "$temp_file"
            echo "" >> "$temp_file"
        fi
    fi
    
    # 如果节不存在且需要添加键值，则在文件末尾添加新节和键值
    if [[ $section_exists -eq 0 && -n "$value" ]]; then
        # 确保文件末尾有空行
        if [[ -s "$temp_file" ]]; then
            local last_char=$(tail -c 1 "$temp_file")
            if [[ "$last_char" != "" ]]; then
                echo "" >> "$temp_file"
            fi
        fi
        # 添加新节和键值
        echo "[$section]" >> "$temp_file"
        echo "\"$key\"=$value" >> "$temp_file"
    fi

    # 替换原文件（保留权限）
    cat "$temp_file" > "$file"
}

# 删除注册表节
# 参数:
#   $1 - 注册表文件路径
#   $2 - 要删除的注册表路径 (如: "Control Panel\\Desktop")
delete_reg_section() {
    local file="$1"
    local section="$2"
    
    # 调用set_reg_key函数，key和value都为空表示删除整个节
    set_reg_key "$file" "$section" "" ""
}

# 搜索注册表键值
# 参数:
#   $1 - 注册表文件路径
#   $2 - 要搜索的注册表路径 (如: "Control Panel\\Desktop"，为空则搜索全部)
#   $3 - 搜索关键词 (支持正则表达式)
#   $4 - 搜索类型 ("key", "value" 或 "all")
search_reg_key() {
    local file="$1"
    local search_path="$2"
    local search_term="$3"
    local search_type="$4"
    
    if [[ ! -f "$file" ]]; then
        echo "Error: Registry file '$file' not found."
        return 1
    fi
    
    if [[ -z "$search_term" ]]; then
        echo "Error: Search term cannot be empty."
        return 1
    fi
    
    local current_section=""
    local found_count=0
    local in_target_section=0
    
    while IFS= read -r line; do
        # 检测节头
        if [[ "$line" =~ ^\[(.*)\][[:space:]]*[0-9a-fA-F]*$ ]]; then
            current_section="${BASH_REMATCH[1]//\\\\/\\}"
            
            # 检查是否进入目标路径
            if [[ -n "$search_path" ]]; then
                if [[ "$current_section" == "$search_path" ]]; then
                    in_target_section=1
                else
                    in_target_section=0
                fi
            else
                in_target_section=1  # 如果没有指定路径，则搜索所有节
            fi
            continue
        fi
        
        # 跳过非目标节的内容
        if [[ $in_target_section -eq 0 ]]; then
            continue
        fi
        
        # 跳过空行和注释
        if [[ -z "$line" || "$line" =~ ^\; ]]; then
            continue
        fi
        
        # 匹配键值行
        if [[ "$line" =~ ^\"([^\"]+)\"[[:space:]]*=[[:space:]]*(.*)$ ]]; then
            local reg_key="${BASH_REMATCH[1]}"
            local reg_value="${BASH_REMATCH[2]}"
            
            # 根据搜索类型进行匹配
            local match=0
            case "$search_type" in
                "key")
                    [[ "$reg_key" =~ $search_term ]] && match=1
                    ;;
                "value")
                    [[ "$reg_value" =~ $search_term ]] && match=1
                    ;;
                "all")
                    [[ "$reg_key" =~ $search_term || "$reg_value" =~ $search_term ]] && match=1
                    ;;
                *)
                    echo "Error: Invalid search type. Use 'key', 'value' or 'all'."
                    return 1
                    ;;
            esac
            
            if [[ $match -eq 1 ]]; then
                ((found_count++))
                echo "[$current_section]"
                echo "$line"
                echo ""
            fi
        fi
    done < "$file"
    
    if [[ $found_count -eq 0 ]]; then
        if [[ -n "$search_path" ]]; then
            echo "No matches found for '$search_term' in [$search_path]"
        else
            echo "No matches found for '$search_term' in $file"
        fi
    else
        echo "Found $found_count matches"
    fi
}

# 示例用法：
# 注意转译
# 修改键值（自动识别类型）
# set_reg_key "user.reg" "Control Panel\\Desktop" "LogPixels" "dword:00000078"
#
# 新增键值到现有节
# set_reg_key "user.reg" "Existing\\Section" "NewKey" "\"value\""
#
# 删除键值
# set_reg_key "user.reg" "Control Panel\\Desktop" "Wallpaper" ""
#
# 删除整个节
# delete_reg_section "user.reg" "Unwanted\\Section"
#
# 添加新节和键值
# set_reg_key "user.reg" "New\\Section" "NewKey" "\"new value\""
#
# 搜索特定路径下的键
# search_reg_key "user.reg" "Control Panel\\Desktop" "LogPixels" "key"
#
# 搜索特定路径下的值
# search_reg_key "user.reg" "Software\\Wine\\Fonts" "00000078" "value"
#
# 搜索整个注册表中的所有匹配项
# search_reg_key "user.reg" "" "Wallpaper" "all"