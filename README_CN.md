```markdown
<div align="center">

# 🖥️ Server Monitor

[![Node.js Version](https://img.shields.io/badge/node-%3E%3D18.0.0-brightgreen.svg)](https://nodejs.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-linux-blue.svg)](https://www.linux.org/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

**一款轻量级、高性能的 Node.js 服务器监控 API 服务**

实时系统性能指标监控，提供简洁的 RESTful API 接口

🇨🇳 **中文文档（当前）** · 🌐 **[English Documentation](README.md)**

[快速开始](#-快速开始) · [API 文档](#-api-接口) · [服务管理](#️-服务管理) · [问题反馈](https://github.com/superboyyy/server-monitor/issues)

</div>

---

## ✨ 特性

🚀 **实时监控** - 实时监控 CPU、内存、磁盘使用率及系统负载
📊 **RESTful API** - 简洁的 HTTP API 接口，易于集成
🌐 **CORS 支持** - 内置跨域支持，方便前端调用
⚙️ **systemd 集成** - 同时支持系统级和用户级服务安装
🔄 **自动重启** - 服务异常退出时自动重启，保障高可用
📝 **日志记录** - 集成 systemd 日志系统，便于调试
🚨 **告警记录** - 当 CPU 或磁盘使用率超过阈值时自动写入告警日志
🐳 **轻量无依赖** - 极低资源占用，适用于各类环境

## 🚀 快速开始

### 系统要求

- **Node.js** v18.0.0 或更高版本（Express 5 要求）
- **npm** 包管理器
- **Linux** 系统（需支持 systemd）

### 📦 安装方式

#### 方式一：克隆仓库（推荐）

```bash
# 克隆项目
git clone https://github.com/brouhardmadie467-ops/newlinux
cd server-monitor

# 安装依赖（可选，安装脚本会自动执行）
npm install

# 用户级服务安装（推荐，无需 sudo）
./install-service.sh --user
```

> **💡 推荐使用安装脚本**：安装脚本将自动完成：
> - 检查系统依赖
> - 安装 npm 依赖
> - 自动替换服务文件中的用户名和路径
> - 启动并启用服务

#### 方式二：系统级服务安装

```bash
# 系统级服务安装（需要 sudo 权限）
sudo ./install-service.sh
```

#### 方式三：直接运行（开发模式）

```bash
# 安装依赖
npm install

# 启动服务
npm start
# 或
node server.js
```

<div align="center">

### 🎯 一键体验

```bash
curl -s http://localhost:3001/api/system/metrics | jq .
```

</div>

## 📊 API 接口

### 获取系统指标

**端点:** `GET /api/system/metrics`

<table>
<tr>
<th>请求</th>
<th>响应</th>
</tr>
<tr>
<td>

```bash
curl http://localhost:3001/api/system/metrics
```

</td>
<td>

```json
{
  "cpu": 15,
  "memory": 68,
  "disk": 45,
  "load": "0.8",
  "timestamp": "2025-09-10T12:30:42.123Z"
}
```

</td>
</tr>
</table>

### 📋 返回字段说明

| 字段 | 类型 | 说明 | 取值范围 |
|-------|------|-------------|-------|
| `cpu` | `number` | CPU 使用率百分比 | 0-100 |
| `memory` | `number` | 内存使用率百分比 | 0-100 |
| `disk` | `number` | 磁盘使用率百分比 | 0-100 |
| `load` | `string` | 系统 1 分钟平均负载 | ≥ 0.0 |
| `timestamp` | `string` | 数据采集时间戳（ISO 8601 格式） | - |

### 💡 使用示例

<details>
<summary><b>JavaScript / Node.js</b></summary>

```javascript
const response = await fetch('http://localhost:3001/api/system/metrics');
const metrics = await response.json();

console.log(`CPU: ${metrics.cpu}%`);
console.log(`内存: ${metrics.memory}%`);
console.log(`磁盘: ${metrics.disk}%`);
console.log(`负载: ${metrics.load}`);
```

</details>

<details>
<summary><b>Python</b></summary>

```python
import requests

response = requests.get('http://localhost:3001/api/system/metrics')
metrics = response.json()

print(f"CPU: {metrics['cpu']}%")
print(f"内存: {metrics['memory']}%") 
print(f"磁盘: {metrics['disk']}%")
print(f"负载: {metrics['load']}")
```

</details>

<details>
<summary><b>Shell / Bash</b></summary>

```bash
#!/bin/bash
metrics=$(curl -s http://localhost:3001/api/system/metrics)

cpu=$(echo $metrics | jq -r '.cpu')
memory=$(echo $metrics | jq -r '.memory') 
disk=$(echo $metrics | jq -r '.disk')
load=$(echo $metrics | jq -r '.load')

echo "CPU: ${cpu}%"
echo "内存: ${memory}%"
echo "磁盘: ${disk}%"
echo "负载: ${load}"
```

</details>

## ⚙️ 服务管理

### 用户级服务管理

<table>
<tr>
<th>操作</th>
<th>命令</th>
<th>说明</th>
</tr>
<tr>
<td>📊 查看状态</td>
<td><code>systemctl --user status server-monitor</code></td>
<td>查看服务运行状态</td>
</tr>
<tr>
<td>▶️ 启动服务</td>
<td><code>systemctl --user start server-monitor</code></td>
<td>启动监控服务</td>
</tr>
<tr>
<td>⏹️ 停止服务</td>
<td><code>systemctl --user stop server-monitor</code></td>
<td>停止监控服务</td>
</tr>
<tr>
<td>🔄 重启服务</td>
<td><code>systemctl --user restart server-monitor</code></td>
<td>重启监控服务</td>
</tr>
<tr>
<td>📝 查看日志</td>
<td><code>journalctl --user -u server-monitor -f</code></td>
<td>实时查看服务日志</td>
</tr>
<tr>
<td>❌ 禁用自启</td>
<td><code>systemctl --user disable server-monitor</code></td>
<td>禁止开机自启动</td>
</tr>
</table>

### 系统级服务管理

<table>
<tr>
<th>操作</th>
<th>命令</th>
<th>说明</th>
</tr>
<tr>
<td>📊 查看状态</td>
<td><code>sudo systemctl status server-monitor</code></td>
<td>查看服务运行状态</td>
</tr>
<tr>
<td>▶️ 启动服务</td>
<td><code>sudo systemctl start server-monitor</code></td>
<td>启动监控服务</td>
</tr>
<tr>
<td>⏹️ 停止服务</td>
<td><code>sudo systemctl stop server-monitor</code></td>
<td>停止监控服务</td>
</tr>
<tr>
<td>🔄 重启服务</td>
<td><code>sudo systemctl restart server-monitor</code></td>
<td>重启监控服务</td>
</tr>
<tr>
<td>📝 查看日志</td>
<td><code>sudo journalctl -u server-monitor -f</code></td>
<td>实时查看服务日志</td>
</tr>
<tr>
<td>❌ 禁用自启</td>
<td><code>sudo systemctl disable server-monitor</code></td>
<td>禁止开机自启动</td>
</tr>
</table>

## 🛠️ 安装脚本使用指南

### 基本用法

```bash
# 显示帮助信息
./install-service.sh --help

# 安装为用户服务（推荐）
./install-service.sh --user

# 安装为系统服务
./install-service.sh --system

# 检查服务状态
./install-service.sh --status

# 查看服务日志
./install-service.sh --logs

# 卸载服务
./install-service.sh --uninstall
```

### 🔧 脚本特性

| 功能 | 说明 |
|---------|-------------|
| 🔍 **自动依赖检查** | 自动检查 Node.js、npm 及必要文件 |
| 🤖 **智能安装** | 自动创建 package.json 并安装依赖 |
| ⚙️ **自动配置** | 自动替换服务文件中的用户名和路径占位符 |
| 🎯 **双重支持** | 同时支持系统级和用户级服务安装 |
| 📦 **完整管理** | 提供安装、卸载、状态查看、日志查看等功能 |
| ⚠️ **错误处理** | 完善的错误提示和异常处理 |
| 🎨 **彩色输出** | 清晰的信息分类展示 |

> **🚀 一键安装**：安装脚本自动处理所有配置，无需手动修改任何文件！

## 🔧 配置说明

### 环境变量

| 变量 | 默认值 | 说明 |
|----------|---------|-------------|
| `PORT` | `3001` | 服务监听端口 |
| `NODE_ENV` | `production` | 运行环境 |
| `ALERT_LOG` | `/tmp/server-monitor-alert.log`（用户服务）或 `/var/log/server-monitor-alert.log`（系统服务） | 告警日志文件路径 |
| `CPU_THRESHOLD` | `90` | 触发告警的 CPU 使用率百分比阈值 |
| `DISK_THRESHOLD` | `90` | 触发告警的磁盘使用率百分比阈值 |

*CPU 和磁盘阈值可以通过在服务文件或运行时设置这些环境变量来自定义。*

### 服务配置

服务配置文件 `server-monitor.service` 支持自定义：

```ini
[Service]
Type=simple
User=YOUR_USERNAME
WorkingDirectory=/path/to/server_monitor
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=10
Environment=NODE_ENV=production
Environment=PORT=3001
Environment=ALERT_LOG=/var/log/server-monitor-alert.log
Environment=CPU_THRESHOLD=90
Environment=DISK_THRESHOLD=90
```

> **⚠️ 重要提示**：使用前需要替换配置文件中的占位符：
> - 将 `YOUR_USERNAME` 替换为你的实际用户名
> - 将 `/path/to/server_monitor` 替换为实际项目路径
> 
> 或者直接使用安装脚本，它会自动处理这些配置！

### 告警日志轮转

为防止告警日志无限增长，提供了日志轮转脚本：

```bash
# 手动执行
./scripts/clean_alerts.sh

# 或设置每日 cron 定时任务（运行 `crontab -e` 并添加以下行）：
0 2 * * * /path/to/server-monitor/scripts/clean_alerts.sh
```

该操作将备份当前告警日志、清空原文件，并删除超过 7 天的存档。

## 🧪 测试

项目包含自动化测试脚本，用于验证核心功能：

```bash
# 运行测试脚本（需要安装 curl 和 stress）
./test/test_metrics.sh
```

测试内容：
- 启动服务并检查 API 响应
- 模拟高 CPU 负载（使用 `stress` 工具）以验证告警功能
- 检查告警日志中是否生成了对应记录
- 清理临时文件和进程

## 🚨 故障排除

<details>
<summary><b>🔧 端口被占用</b></summary>

```bash
# 查看端口占用情况
sudo netstat -tlnp | grep :3001
# 或使用 ss 命令
sudo ss -tlnp | grep :3001

# 结束占用端口的进程
sudo kill -9 <PID>
```

</details>

<details>
<summary><b>🚨 服务启动失败</b></summary>

```bash
# 查看详细错误日志
journalctl --user -u server-monitor -n 50
# 或查看系统服务日志
sudo journalctl -u server-monitor -n 50

# 检查服务状态
systemctl --user status server-monitor
```

</details>

<details>
<summary><b>📦 依赖安装失败</b></summary>

```bash
# 清理 npm 缓存
npm cache clean --force

# 删除 node_modules 并重新安装
rm -rf node_modules package-lock.json
npm install
```

</details>

<details>
<summary><b>🔐 权限问题</b></summary>

- **用户服务**：确保当前用户具有执行权限
- **系统服务**：确保使用 `sudo` 权限运行安装脚本
- **文件权限**：确保脚本具有可执行权限 `chmod +x install-service.sh`

</details>

### 🔄 重新安装

```bash
# 1. 卸载现有服务
./install-service.sh --uninstall

# 2. 清理依赖（可选）
rm -rf node_modules package-lock.json

# 3. 重新安装
./install-service.sh --user
```

## 📁 项目结构

```
server-monitor/
├── 📄 server.js                 # 主服务文件
├── ⚙️ server-monitor.service    # systemd 服务配置
├── 🚀 install-service.sh        # 一键安装脚本
├── 📦 package.json              # 项目配置文件
├── 🔒 package-lock.json         # 依赖锁定文件
├── 📖 README.md                 # 英文版文档
├── 📖 README_CN.md              # 中文版文档（当前文件）
├── 📄 LICENSE                   # MIT 许可证
├── 🙈 .gitignore                # Git 忽略规则
├── 🧪 test/
│   └── test_metrics.sh          # 自动化测试脚本
└── 🛠️ scripts/
    └── clean_alerts.sh          # 告警日志轮转脚本
```

## 🛠️ 技术栈

| 技术 | 版本 | 用途 |
|------------|---------|---------|
| **Node.js** | ≥18.0.0 | 运行时环境 |
| **Express.js** | ^5.1.0 | Web 框架 |
| **systemd** | - | 服务管理 |
| **Shell 脚本** | - | 自动化安装与测试 |

<div align="center">

---

**🌐 服务访问地址**：http://localhost:3001/api/system/metrics

</div>
```