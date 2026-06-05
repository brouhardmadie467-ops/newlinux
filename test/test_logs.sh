#!/bin/bash
BASE_URL="http://localhost:3001/api/logs"

echo "====== 测试 4: 日志分析 ======"
curl -s "$BASE_URL/analysis" | jq .
echo ""