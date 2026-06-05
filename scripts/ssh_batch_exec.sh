#!/bin/bash
# 用法: ./scripts/ssh_batch_exec.sh <别名> <命令>
# 别名在 config/hosts.conf 中定义

ALIAS="$1"
COMMAND="$2"
HOSTS_FILE="config/hosts.conf"

if [ -z "$ALIAS" ] || [ -z "$COMMAND" ]; then
    echo '{"error": "Usage: ./ssh_batch_exec.sh <alias> <command>"}'
    exit 1
fi

# 从配置文件中查找别名对应的连接信息
HOST_LINE=$(grep "^$ALIAS " "$HOSTS_FILE" 2>/dev/null)
if [ -z "$HOST_LINE" ]; then
    echo "{\"error\": \"别名 '$ALIAS' 未在 $HOSTS_FILE 中找到\"}"
    exit 1
fi

HOST=$(echo "$HOST_LINE" | awk '{print $2}')

# 执行 SSH 命令
ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$HOST" "$COMMAND" 2>&1