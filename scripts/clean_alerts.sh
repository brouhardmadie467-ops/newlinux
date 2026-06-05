#!/bin/bash
# 轮转告警日志：备份 -> 清空 -> 删除7天前的备份
LOG_DIR="/tmp"
ALERT_FILE="server-monitor-alert.log"
ARCHIVE_DIR="/tmp/alert_archives"
RETENTION_DAYS=7

mkdir -p "$ARCHIVE_DIR"

if [ ! -f "$LOG_DIR/$ALERT_FILE" ]; then
    echo "没有告警日志，无需轮转"
    exit 0
fi

# 备份并清空
cp "$LOG_DIR/$ALERT_FILE" "$ARCHIVE_DIR/alert_$(date +%Y%m%d_%H%M%S).log"
> "$LOG_DIR/$ALERT_FILE"

# 清理过期备份
find "$ARCHIVE_DIR" -type f -name "alert_*.log" -mtime +$RETENTION_DAYS -exec rm -f {} \;
echo "日志轮转完成"
