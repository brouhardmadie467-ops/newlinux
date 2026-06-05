#!/bin/bash
# 用法: ./scripts/patrol_check.sh
# 检查磁盘使用率、内存、关键服务状态

echo "=== 巡检开始: $(date) ==="

# 1. 磁盘使用率 > 80% 的分区
echo "--- 磁盘检查 ---"
df -h | awk 'NR>1 && $5+0 > 80 {print "警告: 分区 "$6" 使用率 "$5}'

# 2. 内存使用率 > 90%
echo "--- 内存检查 ---"
free -m | awk '/Mem:/ {if ($3/$2 * 100 > 90) print "警告: 内存使用率 " $3/$2*100 "%"}'

# 3. 关键服务检查（sshd, cron, node）
echo "--- 服务检查 ---"
for svc in sshd cron node; do
    if pgrep -x "$svc" > /dev/null 2>&1; then
        echo "服务 $svc: 运行中"
    else
        echo "服务 $svc: 未运行"
    fi
done

echo "=== 巡检结束: $(date) ==="