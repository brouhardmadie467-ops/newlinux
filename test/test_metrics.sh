#!/bin/bash
set -e

BASE_URL="http://localhost:3001/api/system/metrics"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_PATH="$SCRIPT_DIR/../server.js"    # 脚本在 test/ 内，server.js 在上级目录
ALERT_LOG="/tmp/server-monitor-alert.log"

cleanup() {
    echo ""
    echo "=== 清理测试环境 ==="
    if [ -n "$SERVER_PID" ] && kill -0 $SERVER_PID 2>/dev/null; then
        kill $SERVER_PID && echo "已停止服务进程 PID=$SERVER_PID"
    fi
    # 清空告警日志（可选）
    > "$ALERT_LOG" 2>/dev/null
}
trap cleanup EXIT

echo "========================================"
echo "  功能测试：server-monitor"
echo "========================================"

# 1. 启动服务
echo ""
echo "=== 1. 启动服务 ==="
node "$SERVER_PATH" &
SERVER_PID=$!
sleep 2

# 检查进程是否存在
if ! kill -0 $SERVER_PID 2>/dev/null; then
    echo "错误：服务启动失败"
    exit 1
fi
echo "服务已启动，PID = $SERVER_PID"

# 2. 基础指标获取
echo ""
echo "=== 2. 获取基础指标 ==="
RESPONSE=$(curl -s "$BASE_URL")
echo "$RESPONSE" | jq .
echo "CPU 使用率: $(echo "$RESPONSE" | jq '.cpu') %"
echo "内存使用率: $(echo "$RESPONSE" | jq '.memory') %"
echo "磁盘使用率: $(echo "$RESPONSE" | jq '.disk') %"
echo "系统负载: $(echo "$RESPONSE" | jq '.load')"

# 3. 模拟高 CPU 负载（使用 stress）
echo ""
echo "=== 3. 模拟高 CPU 负载（30秒） ==="
if command -v stress &> /dev/null; then
    stress --cpu 2 --timeout 30 &
    STRESS_PID=$!
    echo "stress 已启动，PID=$STRESS_PID，持续30秒..."
else
    echo "stress 未安装，请先运行 sudo apt install stress"
    exit 1
fi

# 等待一段时间让负载上升
sleep 8
echo "负载模拟中，当前指标："
curl -s "$BASE_URL" | jq .

# 检查告警日志是否产生（CPU 高负载应触发告警）
echo ""
echo "=== 4. 检查告警日志 ==="
if [ -f "$ALERT_LOG" ]; then
    LOG_CONTENT=$(cat "$ALERT_LOG")
    if [ -n "$LOG_CONTENT" ]; then
        echo "告警日志内容："
        cat "$ALERT_LOG"
        echo "告警记录数：$(wc -l < "$ALERT_LOG")"
    else
        echo "告警日志为空（可能未触发告警，CPU 负载是否超过 90%？）"
    fi
else
    echo "告警日志文件未生成"
fi

# 等待 stress 结束
wait $STRESS_PID 2>/dev/null

# 5. 测试完成后再次获取指标（负载应下降）
echo ""
echo "=== 5. 负载结束后指标 ==="
sleep 2
curl -s "$BASE_URL" | jq .

# 6. 测试磁盘告警模拟（用 dd 临时创建大文件）
echo ""
echo "=== 6. 模拟磁盘占用（可选，谨慎使用） ==="
echo "本测试将创建一个 200MB 临时文件以增加磁盘使用率..."
# 仅在磁盘使用率较低时模拟
CURRENT_DISK=$(curl -s "$BASE_URL" | jq '.disk')
if [ "$CURRENT_DISK" -lt 80 ]; then
    dd if=/dev/zero of=/tmp/bigfile bs=1M count=200 2>/dev/null
    sleep 2
    echo "创建后磁盘使用率："
    curl -s "$BASE_URL" | jq '.disk'
    rm -f /tmp/bigfile
    echo "临时文件已删除"
else
    echo "当前磁盘使用率已较高（$CURRENT_DISK%），跳过模拟"
fi

echo ""
echo "========================================"
echo "  测试完成"
echo "========================================"
