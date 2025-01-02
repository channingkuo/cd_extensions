#!/bin/zsh

cd_hook() {
    # 项目的环境需求列表
    CONFIG_FILE="kuo.env"

    # 检查目标目录是否存在
    if [ ! -d "$1" ]; then
        echo "cd: no such file or directory: $1"
        return 1
    else
        cd "$1"
    fi

    red='\033[1;31m'
    green='\033[32m'
    nc='\033[0m'

    # 检查目标目录下是否存在特定文件
    if [ -f "$CONFIG_FILE" ]; then
        echo ""
        echo -e "${red}Project environments${nc}"
        while IFS= read -r line; do
            echo -e "${green}${line}${nc}"
        done < "$CONFIG_FILE"

        CONDA_ENV=$(grep "Conda Env:" "$CONFIG_FILE" | awk -F ': ' '{print $2}')
        if [ -n "$CONDA_ENV" ]; then
            echo ""
            echo -e "${red}Swicthing Conda Env: $CONDA_ENV${nc}"
            conda activate "$CONDA_ENV"
        fi
        # 提取Java环境参数
        JAVA_ENV=$(grep "Java:" "$CONFIG_FILE" | awk -F ': ' '{print $2}')
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
    fi

    # 打印前端项目的依赖和脚本
    if [ -f "package.json" ]; then
        echo ""
        echo -e "${red}package.json${nc}"
        while IFS= read -r line; do
            echo -e "${green}${line}${nc}"
        done < "package.json"
    fi

    # git status
    if [ -d ".git" ]; then
        echo ""
        echo -e "${red}git status:${nc}"
        git status
    fi
}
cd_hook "$1"
