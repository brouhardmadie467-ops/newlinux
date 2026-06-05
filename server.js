const express = require('express');
const fs = require('fs');
const { execSync } = require('child_process');

// 加载路由模块
const metricsRouter = require('./routes/metrics');
const logsRouter = require('./routes/logs');
const reportsRouter = require('./routes/reports');
const opsRouter = require('./routes/ops');

// 初始化数据库（确保表结构存在）
require('./db/database');

const app = express();
const PORT = process.env.PORT || 3001;
const ALERT_LOG = process.env.ALERT_LOG || '/tmp/server-monitor-alert.log';

// 跨域设置
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Content-Type');
    next();
});

app.use(express.json());

// 挂载路由
app.use('/api/system', metricsRouter);
app.use('/api/logs', logsRouter);
app.use('/api/reports', reportsRouter);
app.use('/api/ops', opsRouter);

// 健康检查
app.get('/', (req, res) => {
    res.json({ status: 'ok', service: 'server-monitor', version: '1.0.0' });
});

// 404 处理
app.use((req, res) => {
    res.status(404).json({ error: 'Not found' });
});

// 启动服务
app.listen(PORT, () => {
    console.log(`✅ Server monitor running on http://localhost:${PORT}`);
});

// ========== 定时告警（每 30 秒检查一次，保留原逻辑） ==========
// 注意：此逻辑已同时存在于 routes/metrics.js 的指标采集时即时告警，
// 这里保留作为兜底机制，确保即使无 HTTP 请求也能触发告警。

function getCPUUsage() {
    try {
        const stdout = execSync(
            "top -bn1 | grep '%Cpu(s):' | awk '{print $2 + $4}'"
        ).toString();
        return parseFloat(stdout);
    } catch {
        return -1;
    }
}

function getDiskUsage() {
    try {
        return parseInt(
            execSync("df -h / | awk 'NR==2{print $5}' | sed 's/%//'").toString().trim(), 10
        ) || 0;
    } catch {
        return -1;
    }
}

setInterval(() => {
    const cpu = getCPUUsage();
    const disk = getDiskUsage();
    if (cpu > 90 || disk > 90) {
        const msg = `[${new Date().toISOString()}] ALERT CPU=${cpu}% DISK=${disk}%\n`;
        fs.appendFile(ALERT_LOG, msg, (err) => {
            if (err) console.error('写入告警日志失败', err);
        });
    }
}, 30000);