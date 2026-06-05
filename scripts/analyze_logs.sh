#!/bin/bash
# 用法: ./scripts/analyze_logs.sh
# 输出: JSON 字符串

AUTH_LOG="/var/log/auth.log"
SYSLOG="/var/log/syslog"

# ---------- SSH 暴力破解检测 ----------
SSH_FAILURES="[]"
if [ -f "$AUTH_LOG" ]; then
    SSH_FAILURES=$(grep "Failed password" "$AUTH_LOG" 2>/dev/null | \
        awk '{print $11}' | sort | uniq -c | sort -nr | head -5 | \
        awk '{printf "{\"ip\":\"%s\", \"attempts\":%s},", $2, $1}')
    SSH_FAILURES="[${SSH_FAILURES%,}]"
fi

# ---------- OOM 事件检测 ----------
OOM_COUNT=0
if [ -f "$SYSLOG" ]; then
    OOM_COUNT=$(grep -ic "out of memory" "$SYSLOG" 2>/dev/null || echo 0)
fi

# ---------- 输出 JSON ----------
cat <<EOF
{
  "ssh_failures": $SSH_FAILURES,
  "oom_events": $OOM_COUNT,
  "analysis_time": "$(date -Iseconds)"
}
EOF