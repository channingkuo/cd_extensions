#!/bin/zsh

# Ensure compinit is loaded and initialized
autoload -Uz compinit && compinit

# Remove comment to remove 'ck' alias if it exists to avoid conflict with the function definition
# unalias ck 2>/dev/null

red='\033[1;31m'
green='\033[32m'
nc='\033[0m'

ck() {
  local original_pwd=$PWD
  local original_path=$PATH
  local CONFIG_FILE="kuo.env"
  local map_info="/Users/kuo/Documents/ChanningKuo/Shell/kuo/cd_extensions/.ck-config.json"

  folder_target="$1"
  target="$2"
  target_path="~/"

  # 读取配置文件的keys
  local -a keys
  if [[ -f "$map_info" && -r "$map_info" ]]; then
      keys=("${(f)$(jq -r '.[].key' "$map_info" 2>/dev/null)}")
      if [[ ${#keys} -eq 0 ]]; then
          keys=(ats ysw)
      fi
  else
      keys=(ats ysw)
  fi

  if [[ -n "$1" && ${#keys} -gt 0 ]]; then
      target_path=$(jq -r --arg key "$1" '.[] | select(.key == $key) | .path' "$map_info" 2>/dev/null)
      [[ "$target_path" == "null" || -z "$target_path" ]] && target_path="$1"
  fi

  if [ "$2" != "" ]; then
      target_path=$target_path$target
  fi

  cd $target_path
  echo -e "${red}pwd:$target_path${nc}"

  export PATH=$original_path

  if [ -f "$CONFIG_FILE" ]; then
    echo ""
    echo -e "${red}Project environments${nc}"
    while IFS= read -r line; do
        echo -e "${green}${line}${nc}"
    done < "$CONFIG_FILE"

    CONDA_ENV=$(grep "Conda Env:" "$CONFIG_FILE" | awk -F ': ' '{print $2}')
    if [ -n "$CONDA_ENV" ]; then
        echo ""
        echo -e "${red}Switching Conda Env: $CONDA_ENV${nc}"
        conda activate "$CONDA_ENV"
    fi
    # 提取Java环境参数
    JAVA_ENV=$(grep "Java:" "$CONFIG_FILE" | awk -F ': ' '{print $2}')
    if [ -n "$JAVA_ENV" ]; then
        echo ""
        echo -e "${red}Switching Conda Env: emacs${nc}"
        conda activate emacs
        echo -e "${red}Switching to Java: $JAVA_ENV${nc}"
        case "$JAVA_ENV" in
            8)
                # jdk8
                export JAVA_HOME=$(/usr/libexec/java_home -v1.8)
                echo -e "${green}Done${nc}"
                ;;
            11)
                # jdk11
                export JAVA_HOME=$(/usr/libexec/java_home -v11)
                echo -e "${green}Done${nc}"
                ;;
            17)
                # jdk17
                export JAVA_HOME=$(/usr/libexec/java_home -v17)
                echo -e "${green}Done${nc}"
                ;;
            *)
                echo -e "${red}Unknown Java version: $JAVA_ENV${nc}"
                ;;
        esac
    fi

    # 检查是否有特殊的逻辑，比如临时添加export
    # 读取并执行export命令
    Export_ENV=$(grep "Export:" "$CONFIG_FILE" | awk -F ': ' '{print $2}')
    if [ -n "$Export_ENV" ]; then
        echo ""
        echo -e "${red}Extra Export${nc}"
        while IFS= read -r line; do
            if [[ "$line" == Export:* ]]; then
                export_command=$(echo "$line" | sed 's/^Export:/export/')
                echo -e "${green}Executing: $export_command${nc}"
                eval "$export_command"
            fi
        done < "$CONFIG_FILE"
    fi
  else
    if [ -f ".git/$CONFIG_FILE" ]; then
        echo ""
        echo -e "${red}Project environments${nc}"
        while IFS= read -r line; do
            echo -e "${green}${line}${nc}"
        done < ".git/$CONFIG_FILE"

        CONDA_ENV=$(grep "Conda Env:" ".git/$CONFIG_FILE" | awk -F ': ' '{print $2}')
        if [ -n "$CONDA_ENV" ]; then
            echo ""
            echo -e "${red}Swicthing Conda Env: $CONDA_ENV${nc}"
            conda activate "$CONDA_ENV"
        fi
        # 提取Java环境参数
        JAVA_ENV=$(grep "Java:" ".git/$CONFIG_FILE" | awk -F ': ' '{print $2}')
        if [ -n "$JAVA_ENV" ]; then
            echo ""
            echo -e "${red}Switching to Java: $JAVA_ENV${nc}"
            case "$JAVA_ENV" in
                8)
                    # jdk8
                    export JAVA_HOME=$(/usr/libexec/java_home -v1.8)
                    echo -e "${green}Done${nc}"
                    ;;
                11)
                    # jdk11
                    export JAVA_HOME=$(/usr/libexec/java_home -v11)
                    echo -e "${green}Done${nc}"
                    ;;
                17)
                    # jdk17
                    export JAVA_HOME=$(/usr/libexec/java_home -v17)
                    echo -e "${green}Done${nc}"
                    ;;
                *)
                    echo -e "${red}Unknown Java version: $JAVA_ENV${nc}"
                    ;;
            esac
        fi

        # 检查是否有特殊的逻辑，比如临时添加export
        # 读取并执行export命令
        Export_ENV=$(grep "Export:" ".git/$CONFIG_FILE" | awk -F ': ' '{print $2}')
        if [ -n "$Export_ENV" ]; then
            echo ""
            echo -e "${red}Extra Export${nc}"
            while IFS= read -r line; do
                if [[ "$line" == Export:* ]]; then
                    export_command=$(echo "$line" | sed 's/^Export:/export/')
                    echo -e "${green}Executing: $export_command${nc}"
                    eval "$export_command"
                fi
            done < ".git/$CONFIG_FILE"
        fi
    fi
  fi

  # 打印前端项目的依赖和脚本
  if [ -f "package.json" ]; then
      echo ""
      echo -e "${red}package.json${nc}"
      while IFS= read -r line; do
          echo -e "${green}${line}${nc}"
      done < "package.json"
  fi

  if [ -d ".git" ]; then
      echo ""
      echo -e "${red}git status${nc}"
      git status
  fi
}
