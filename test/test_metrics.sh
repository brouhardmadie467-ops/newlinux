#!/bin/bash
BASE_URL="http://localhost:3001/api/system"

echo "====== 测试 1: 获取实时指标 ======"
curl -s "$BASE_URL/metrics" | jq .
echo ""

echo "====== 测试 2: 查询历史数据 ======"
curl -s "$BASE_URL/metrics/history?hours=1" | jq .
echo ""

echo "====== 测试 3: 模拟高 CPU 告警 ======"
which stress > /dev/null
if [ $? -eq 0 ]; then
    stress --cpu 2 --timeout 5 &
    sleep 2
    curl -s "$BASE_URL/metrics" | jq '.cpu'
    wait
else
    echo "stress 工具未安装，跳过"
fi