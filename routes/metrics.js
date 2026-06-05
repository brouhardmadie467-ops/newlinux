const express = require('express');
const router = express.Router();
const { execSync } = require('child_process');
const fs = require('fs');
const db = require('../db/database');

const ALERT_LOG = process.env.ALERT_LOG || '/tmp/server-monitor-alert.log';

// ---------- 指标采集函数 ----------
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

function getMemoryUsage() {
    try {
        const memLine = execSync(
            "free -m | grep Mem | awk '{print $2,$3}'"
        ).toString().trim();
        const [total, used] = memLine.split(/\s+/).map(Number);
        return total ? +((used / total) * 100).toFixed(1) : 0;
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

function getSystemLoad() {
    try {
        return execSync("cat /proc/loadavg | awk '{print $1}'").toString().trim();
    } catch {
        return 'N/A';
    }
}

function collectMetrics() {
    return {
        cpu: getCPUUsage(),
        memory: getMemoryUsage(),
        disk: getDiskUsage(),
        load: getSystemLoad(),
        timestamp: new Date().toISOString()
    };
}

// ---------- 写入告警日志 ----------
function checkAlert(metrics) {
    if (metrics.cpu > 90 || metrics.disk > 90) {
        const msg = `[${metrics.timestamp}] ALERT CPU=${metrics.cpu}% DISK=${metrics.disk}%\n`;
        fs.appendFile(ALERT_LOG, msg, (err) => {
            if (err) console.error('写入告警日志失败', err);
        });
    }
}

// ---------- API 路由 ----------

// GET 实时指标
router.get('/metrics', (req, res) => {
    try {
        const metrics = collectMetrics();

        // 写入 SQLite 历史记录
        try {
            db.prepare(
                'INSERT INTO metrics (cpu, memory, disk, load, timestamp) VALUES (?, ?, ?, ?, ?)'
            ).run(metrics.cpu, metrics.memory, metrics.disk, metrics.load, metrics.timestamp);
        } catch (dbErr) {
            console.error('数据库写入失败:', dbErr.message);
        }

        // 即时告警
        checkAlert(metrics);

        res.json(metrics);
    } catch (error) {
        console.error('获取系统指标失败:', error);
        res.status(500).json({ error: '获取系统指标失败' });
    }
});

// GET 历史数据（最近 N 小时）
router.get('/metrics/history', (req, res) => {
    try {
        const hours = parseInt(req.query.hours) || 24;
        const rows = db.prepare(
            `SELECT * FROM metrics WHERE timestamp >= datetime('now', '-' || ? || ' hours') ORDER BY timestamp DESC`
        ).all(hours);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: '查询历史数据失败', details: err.message });
    }
});

module.exports = router;