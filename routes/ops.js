const express = require('express');
const router = express.Router();
const { execSync } = require('child_process');
const path = require('path');

// POST /api/ops/execute
// 请求体示例: { "command": "uptime", "hosts": ["web1", "web2"] }
// hosts 对应 config/hosts.conf 中的别名
router.post('/execute', (req, res) => {
    try {
        const { command, hosts } = req.body;
        if (!command || !hosts || !Array.isArray(hosts)) {
            return res.status(400).json({ error: '缺少 command 或 hosts 参数' });
        }

        const scriptPath = path.join(__dirname, '../scripts/ssh_batch_exec.sh');
        const results = [];

        for (const host of hosts) {
            try {
                const stdout = execSync(`bash "${scriptPath}" "${host}" "${command}"`, {
                    timeout: 10000
                }).toString();
                results.push({ host, success: true, output: stdout.trim() });
            } catch (err) {
                results.push({ host, success: false, error: err.message });
            }
        }

        res.json({ command, results });
    } catch (err) {
        res.status(500).json({ error: '批量执行失败', details: err.message });
    }
});

module.exports = router;