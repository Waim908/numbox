#!/bin/bash
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

# 示例用法：
# 修改键值（自动识别类型）
# set_reg_key "user.reg" "Control Panel\\Desktop" "LogPixels" "dword:00000078"
#
# 新增键值到现有节
# set_reg_key "user.reg" "Existing\\Section" "NewKey" "\"value\""
#
# 删除键值
# set_reg_key "user.reg" "Control Panel\\Desktop" "Wallpaper" ""
#
# 添加新节和键值
# set_reg_key "user.reg" "New\\Section" "NewKey" "\"new value\""