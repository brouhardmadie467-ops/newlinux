/**
 * server.js - 服务器监控仪表盘后端（修复路由兼容性）
 */

const http = require('http');
const express = require('express');
const WebSocket = require('ws');
const path = require('path');
const fs = require('fs');
const { execSync } = require('child_process');

// ==================== 配置 ====================
const PORT = 3001;
const PUSH_INTERVAL_MS = 1000;
const LOGS_CACHE_MS = 30000;

// ==================== Express & WebSocket ====================
const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

// ==================== 静态文件 ====================
const publicDir = path.join(__dirname, 'public');
if (!fs.existsSync(publicDir)) {
    fs.mkdirSync(publicDir);
}
app.use(express.static(publicDir));

// ==================== CPU 使用率（差值法） ====================
let cpuPrevIdle = 0;
let cpuPrevTotal = 0;

function initCPU() {
    try {
        const stat = fs.readFileSync('/proc/stat', 'utf8');
        const cpuLine = stat.split('\n')[0].split(/\s+/).filter(Boolean);
        cpuPrevIdle = parseInt(cpuLine[4], 10) + parseInt(cpuLine[5], 10);
        cpuPrevTotal = cpuLine.slice(1).reduce((acc, val) => acc + parseInt(val, 10), 0);
    } catch {
        cpuPrevIdle = 0;
        cpuPrevTotal = 0;
    }
}
initCPU();

function getCPUUsage() {
    try {
        const stat = fs.readFileSync('/proc/stat', 'utf8');
        const cpuLine = stat.split('\n')[0].split(/\s+/).filter(Boolean);
        const idle = parseInt(cpuLine[4], 10) + parseInt(cpuLine[5], 10);
        const total = cpuLine.slice(1).reduce((acc, val) => acc + parseInt(val, 10), 0);

        const diffIdle = idle - cpuPrevIdle;
        const diffTotal = total - cpuPrevTotal;

        cpuPrevIdle = idle;
        cpuPrevTotal = total;

        if (diffTotal <= 0) return 0;
        const usage = (1 - diffIdle / diffTotal) * 100;
        return Math.min(100, Math.max(0, parseFloat(usage.toFixed(1))));
    } catch {
        return 0;
    }
}

// ==================== 内存 / 磁盘 / 负载 ====================
function getMemoryUsage() {
    try {
        const stdout = execSync("free | awk '/Mem:/{printf \"%.1f\", $3/$2*100}'", { encoding: 'utf8' });
        return parseFloat(stdout) || 0;
    } catch {
        return 0;
    }
}

function getDiskUsage() {
    try {
        const stdout = execSync("df -h / | awk 'NR==2{print $5}' | sed 's/%//'", { encoding: 'utf8' }).trim();
        return parseInt(stdout, 10) || 0;
    } catch {
        return 0;
    }
}

function getLoadAverage() {
    try {
        const raw = fs.readFileSync('/proc/loadavg', 'utf8');
        return raw.split(' ')[0];
    } catch {
        try {
            const stdout = execSync("uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//'", { encoding: 'utf8' }).trim();
            return stdout || '0.00';
        } catch {
            return '0.00';
        }
    }
}

// ==================== 日志分析 ====================
let cachedLogResult = null;
let lastLogFetch = 0;

function collectLogAnalysis() {
    const result = { ssh_failures: [], oom_events: 0 };

    try {
        const sshRaw = execSync(
            'grep "Failed password" /var/log/auth.log 2>/dev/null | tail -n 1000',
            { encoding: 'utf8', maxBuffer: 5 * 1024 * 1024 }
        );
        const lines = sshRaw.trim().split('\n').filter(Boolean);
        const ipCounts = {};
        lines.forEach(line => {
            const match = line.match(/from (\d+\.\d+\.\d+\.\d+)/);
            if (match) {
                const ip = match[1];
                ipCounts[ip] = (ipCounts[ip] || 0) + 1;
            }
        });
        result.ssh_failures = Object.entries(ipCounts)
            .map(([ip, attempts]) => ({ ip, attempts }))
            .sort((a, b) => b.attempts - a.attempts)
            .slice(0, 5);
    } catch { /* 无日志文件 */ }

    try {
        const oomRaw = execSync(
            'grep -ci "out of memory" /var/log/syslog 2>/dev/null || echo 0',
            { encoding: 'utf8' }
        ).trim();
        result.oom_events = parseInt(oomRaw, 10) || 0;
    } catch {
        try {
            const oomRaw = execSync(
                'grep -ci "out of memory" /var/log/kern.log 2>/dev/null || echo 0',
                { encoding: 'utf8' }
            ).trim();
            result.oom_events = parseInt(oomRaw, 10) || 0;
        } catch {
            result.oom_events = 0;
        }
    }

    return result;
}

// ==================== WebSocket 连接 ====================
wss.on('connection', (ws) => {
    console.log(`[WS] 客户端已连接 (在线: ${wss.clients.size})`);

    const currentMetrics = {
        cpu: getCPUUsage(),
        memory: getMemoryUsage(),
        disk: getDiskUsage(),
        load: getLoadAverage(),
        timestamp: new Date().toISOString()
    };
    ws.send(JSON.stringify({ type: 'metrics', data: currentMetrics }));

    ws.on('close', () => {
        console.log(`[WS] 客户端断开 (在线: ${wss.clients.size})`);
    });

    ws.on('error', (err) => {
        console.error('[WS] 错误:', err.message);
    });
});

// ==================== 定时推送 ====================
setInterval(() => {
    if (wss.clients.size === 0) return;

    const metrics = {
        cpu: getCPUUsage(),
        memory: getMemoryUsage(),
        disk: getDiskUsage(),
        load: getLoadAverage(),
        timestamp: new Date().toISOString()
    };

    const message = JSON.stringify({ type: 'metrics', data: metrics });

    wss.clients.forEach((client) => {
        if (client.readyState === WebSocket.OPEN) {
            client.send(message);
        }
    });
}, PUSH_INTERVAL_MS);

// ==================== HTTP API 路由 ====================
app.get('/api/logs/analysis', (req, res) => {
    const now = Date.now();
    if (cachedLogResult && (now - lastLogFetch < LOGS_CACHE_MS)) {
        return res.json(cachedLogResult);
    }

    try {
        const result = collectLogAnalysis();
        cachedLogResult = result;
        lastLogFetch = now;
        res.json(result);
    } catch (e) {
        res.status(500).json({ error: '日志分析失败', message: e.message });
    }
});

app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', uptime: process.uptime() });
});

// ==================== 🔧 兜底中间件（修复 '*': 兼容 path-to-regexp v8） ====================
// 不使用 app.get('*')，改用中间件实现 SPA 回退
app.use((req, res, next) => {
    // 只对 GET 请求且非 API/WebSocket 路径返回 index.html
    if (req.method === 'GET' && !req.path.startsWith('/api/') && !req.path.startsWith('/ws')) {
        res.sendFile(path.join(publicDir, 'index.html'));
    } else {
        next();
    }
});

// ==================== 启动 ====================
server.listen(PORT, () => {
    console.log('========================================');
    console.log(`🚀 服务器监控仪表盘已启动`);
    console.log(`   网页: http://localhost:${PORT}/index.html`);
    console.log(`   WebSocket: ws://localhost:${PORT}/ws`);
    console.log(`   日志 API: http://localhost:${PORT}/api/logs/analysis`);
    console.log('========================================');
});