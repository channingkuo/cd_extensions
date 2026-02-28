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

  if [ -f ".node-version" ]; then
      echo ""
      echo -e "${green}Switched to Node.js: $(cat .node-version)${nc}"
  else
      echo ""
      echo -e "${red}.node-version not found, fnm will not auto-switch Node.js${nc}"
  fi

  # 打印前端项目的关键信息
  if [ -f "package.json" ]; then
      echo ""
      echo -e "${red}package.json${nc}"
      echo -e "${green}name: $(jq -r '.name // empty' package.json 2>/dev/null)${nc}"
      echo -e "${green}version: $(jq -r '.version // empty' package.json 2>/dev/null)${nc}"
      echo -e "${green}webVersion: $(jq -r '.webVersion // empty' package.json 2>/dev/null)${nc}"
      echo -e "${green}description: $(jq -r '.description // empty' package.json 2>/dev/null)${nc}"
      local scripts=$(jq -r '.scripts // {} | to_entries[] | "  \(.key): \(.value)"' package.json 2>/dev/null)
      if [ -n "$scripts" ]; then
          echo ""
          echo -e "${red}scripts${nc}"
          echo -e "${green}${scripts}${nc}"
      fi
  fi

  if [ -d ".git" ]; then
      echo ""
      echo -e "${red}git status${nc}"
      git status
  fi
}
