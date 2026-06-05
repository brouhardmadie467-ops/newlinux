const express = require('express');
const router = express.Router();
const { execSync } = require('child_process');
const path = require('path');

// GET /api/logs/analysis?type=ssh|oom|all
router.get('/analysis', (req, res) => {
    try {
        const scriptPath = path.join(__dirname, '../scripts/analyze_logs.sh');
        const raw = execSync(`bash "${scriptPath}"`).toString().trim();

        // Shell 脚本输出的是 JSON 字符串
        const result = JSON.parse(raw);
        res.json(result);
    } catch (err) {
        res.status(500).json({
            error: '日志分析失败',
            details: err.message,
            hint: '可能需要 root 权限读取 /var/log/auth.log'
        });
    }
});

module.exports = router;