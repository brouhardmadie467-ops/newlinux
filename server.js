const express = require('express');
const { execSync } = require('child_process');  // 执行 Linux 命令
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 3001;
const ALERT_LOG = process.env.ALERT_LOG || '/tmp/server-monitor-alert.log';

// 跨域设置（保留原样）
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Content-Type');
    next();
});

// ========== 指标采集（全部改为调用 Linux 原生命令） ==========
function getCPUUsage() {
    try {
        // top -bn1 批量输出，grep 定位 '%Cpu(s):' 行，awk 将用户态 + 系统态百分比相加
        const stdout = execSync("top -bn1 | grep '%Cpu(s):' | awk '{print $2 + $4}'").toString();
        return parseFloat(stdout);
    } catch {
        return -1;
    }
}

function getMemoryUsage() {
    try {
        // free -m 输出内存，grep Mem 提取 total 和 used 列
        const memLine = execSync("free -m | grep Mem | awk '{print $2,$3}'").toString().trim();
        const [total, used] = memLine.split(/\s+/).map(Number);
        return total ? +((used / total) * 100).toFixed(1) : 0;
    } catch {
        return -1;
    }
}

function getDiskUsage() {
    // 原实现已经是命令，保持不变
    try {
        return parseInt(execSync("df -h / | awk 'NR==2{print $5}' | sed 's/%//'").toString().trim(), 10) || 0;
    } catch {
        return -1;
    }
}

function getSystemLoad() {
    try {
        // 直接读 /proc/loadavg，取第一列（1分钟负载）
        return execSync("cat /proc/loadavg | awk '{print $1}'").toString().trim();
    } catch {
        return 'N/A';
    }
}

// 汇总指标
function collectMetrics() {
    return {
        cpu: getCPUUsage(),
        memory: getMemoryUsage(),
        disk: getDiskUsage(),
        load: getSystemLoad(),
        timestamp: new Date().toISOString()
    };
}

// ========== API 端点 ==========
app.get('/api/system/metrics', (req, res) => {
    try {
        res.json(collectMetrics());
    } catch (error) {
        console.error('获取系统指标失败:', error);
        res.status(500).json({ error: '获取系统指标失败' });
    }
});

// 启动服务器
app.listen(PORT, () => {
    console.log(`系统监控API服务器运行在端口 ${PORT}`);
});

// ========== 阈值告警（每30秒检查一次） ==========
setInterval(() => {
    const m = collectMetrics();
    if (m.cpu > 90 || m.disk > 90) {
        const msg = `[${m.timestamp}] ALERT CPU=${m.cpu}% DISK=${m.disk}%\n`;
        fs.appendFile(ALERT_LOG, msg, (err) => {
            if (err) console.error('写入告警日志失败', err);
        });
    }
}, 30000);