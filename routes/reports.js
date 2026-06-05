const express = require('express');
const router = express.Router();
const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

// GET /api/reports/latest
router.get('/latest', (req, res) => {
    try {
        // 1. 执行巡检
        const patrolScript = path.join(__dirname, '../scripts/patrol_check.sh');
        execSync(`bash "${patrolScript}"`);

        // 2. 生成报告
        const reportScript = path.join(__dirname, '../scripts/generate_report.sh');
        execSync(`bash "${reportScript}"`);

        // 3. 读取最新报告（假设存放在 logs/reports/ 下）
        const reportsDir = path.join(__dirname, '../logs/reports');
        const files = fs.readdirSync(reportsDir).filter(f => f.startsWith('patrol-report-')).sort().reverse();
        if (files.length === 0) {
            return res.status(404).json({ error: '没有找到巡检报告' });
        }
        const latest = path.join(reportsDir, files[0]);
        const content = fs.readFileSync(latest, 'utf-8');
        res.json({
            report_name: files[0],
            generated_at: new Date().toISOString(),
            content: content
        });
    } catch (err) {
        res.status(500).json({ error: '获取报告失败', details: err.message });
    }
});

module.exports = router;