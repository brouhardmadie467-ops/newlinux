#!/bin/bash
# 用法: ./scripts/generate_report.sh
# 将巡检结果整合为 Markdown 报告，保存到 logs/reports/

REPORT_DIR="logs/reports"
mkdir -p "$REPORT_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="$REPORT_DIR/patrol-report-$TIMESTAMP.md"

cat > "$REPORT_FILE" <<EOF
# 服务器巡检报告

**生成时间**: $(date '+%Y-%m-%d %H:%M:%S')

## 磁盘使用情况
\`\`\`
$(df -h)
\`\`\`

## 内存使用情况
\`\`\`
$(free -h)
\`\`\`

## 系统负载
$(uptime)

## 最近登录
\`\`\`
$(last -5 2>/dev/null || echo "无登录记录")
\`\`\`
EOF

echo "报告已生成: $REPORT_FILE"