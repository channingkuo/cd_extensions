#!/bin/zsh

compdef _ck_completion ck

_ck_completion() {
    local config_file="/Users/kuo/Documents/ChanningKuo/Shell/kuo/cd_extensions/.ck-config.json"
    local jq_bin="/usr/bin/jq"
    local ls_bin="/bin/ls"
    local sed_bin="/usr/bin/sed"

    # 读取配置文件的keys
    local -a keys
    if [[ -f "$config_file" && -r "$config_file" ]]; then
        keys=("${(f)$($jq_bin -r '.[].key' "$config_file" 2>/dev/null)}")
        if [[ ${#keys} -eq 0 ]]; then
            keys=(ats ysw)
        fi
    else
        keys=(ats ysw)
    fi

    # 获取第一个参数
    local context="${words[2]%/}"

    # 获取路径
    local path=""
    if [[ -n "$context" && ${#keys} -gt 0 ]]; then
        path=$($jq_bin -r --arg key "$context" '.[] | select(.key == $key) | .path' "$config_file" 2>/dev/null)
        [[ "$path" == "null" || -z "$path" ]] && path=""
    fi

    local -a target_directions
    local dir=""
    if [[ -z "$context" ]]; then
        target_directions=("${keys[@]}")
        _describe 'command' target_directions
    elif [[ -n "$path" && -d "$path" ]]; then
        target_directions=("${(@f)$($ls_bin "$path" 2>/dev/null)}")
        _describe 'command' target_directions
    elif [[ -d "$PWD/$context" ]]; then
        target_directions=("${(@f)$($ls_bin -d "$context"/*/ 2>/dev/null | $sed_bin 's|/$||;s|.*/||')}")
        _describe 'command' target_directions -S '/' -p "$context/"
    else
        # print -l "\nDebug target_directions:" "$context"
        target_directions=("${keys[@]}" "${(@f)$($ls_bin -d $PWD/*/ 2>/dev/null | $sed_bin 's|/$||;s|.*/||')}")

        existed_key=false
        prefix=""
        # 如果$context 已经包含了/
        if [[ "$context" == *"/"* ]]; then
            prefix="${context%/*}/"
            target_directions=("${(@f)$($ls_bin -d "$prefix"/*/ 2>/dev/null | $sed_bin 's|/$||;s|.*/||')}")
            # print -l "\nDebug target_directions:" "$prefix"
        else
            for key in "${keys[@]}"; do
                if [[ "$key" == "$context"* ]]; then
                    existed_key=true
                    break
                fi
            done
        fi

        if [[ "$existed_key" == true ]]; then
            _describe 'command' target_directions
        else
            _describe 'command' target_directions -S '/' -p "$prefix"
        fi
    fi

}
