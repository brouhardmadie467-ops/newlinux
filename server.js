// server.js
const express = require('express');
const os = require('os');
const { exec } = require('child_process');
const fs = require('fs');
const app = express();

// 允许跨域
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Content-Type');
    next();
});

// 获取CPU使用率
function getCPUUsage() {
    return new Promise((resolve) => {
        // 读取/proc/stat获取系统CPU使用率
        fs.readFile('/proc/stat', 'utf8', (err, data) => {
            if (err) {
                resolve(0);
                return;
            }
            
            const lines = data.split('\n');
            const cpuLine = lines[0]; // 第一行是总CPU统计
            const cpuTimes = cpuLine.split(/\s+/).slice(1).map(Number);
            
            // CPU时间：user, nice, system, idle, iowait, irq, softirq, steal
            const [user, nice, system, idle, iowait, irq, softirq, steal] = cpuTimes;
            
            // 计算总时间和空闲时间
            const totalTime = user + nice + system + idle + iowait + irq + softirq + steal;
            const idleTime = idle + iowait;
            
            // 等待一段时间后再次读取
            setTimeout(() => {
                fs.readFile('/proc/stat', 'utf8', (err2, data2) => {
                    if (err2) {
                        resolve(0);
                        return;
                    }
                    
                    const lines2 = data2.split('\n');
                    const cpuLine2 = lines2[0];
                    const cpuTimes2 = cpuLine2.split(/\s+/).slice(1).map(Number);
                    
                    const [user2, nice2, system2, idle2, iowait2, irq2, softirq2, steal2] = cpuTimes2;
                    const totalTime2 = user2 + nice2 + system2 + idle2 + iowait2 + irq2 + softirq2 + steal2;
                    const idleTime2 = idle2 + iowait2;
                    
                    // 计算时间差
                    const totalDiff = totalTime2 - totalTime;
                    const idleDiff = idleTime2 - idleTime;
                    
                    // 计算CPU使用率
                    const cpuPercent = totalDiff > 0 ? Math.round((1 - idleDiff / totalDiff) * 100) : 0;
                    resolve(Math.max(0, Math.min(cpuPercent, 100)));
                });
            }, 100);
        });
    });
}

// 获取内存使用率
function getMemoryUsage() {
    const totalMem = os.totalmem();
    const freeMem = os.freemem();
    const usedMem = totalMem - freeMem;
    return Math.round((usedMem / totalMem) * 100);
}

// 获取磁盘使用率
function getDiskUsage() {
    return new Promise((resolve) => {
        exec("df -h / | awk 'NR==2{print $5}' | sed 's/%//'", (error, stdout) => {
            if (error) {
                resolve(0);
            } else {
                resolve(parseInt(stdout.trim()) || 0);
            }
        });
    });
}

// 获取系统负载
function getSystemLoad() {
    const loads = os.loadavg();
    return loads[0].toFixed(1); // 1分钟平均负载
}

// API端点
app.get('/api/system/metrics', async (req, res) => {
    try {
        const [cpu, disk] = await Promise.all([
            getCPUUsage(),
            getDiskUsage()
        ]);
        
        const metrics = {
            cpu: cpu,
            memory: getMemoryUsage(),
            disk: disk,
            load: getSystemLoad(),
            timestamp: new Date().toISOString()
        };
        
        res.json(metrics);
    } catch (error) {
        console.error('获取系统指标失败:', error);
        res.status(500).json({ error: '获取系统指标失败' });
    }
});

// 启动服务器
const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
    console.log(`系统监控API服务器运行在端口 ${PORT}`);
});