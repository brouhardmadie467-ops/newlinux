<div align="center">

# 🖥️ Server Monitor

[![Node.js Version](https://img.shields.io/badge/node-%3E%3D14.0.0-brightgreen.svg)](https://nodejs.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-linux-blue.svg)](https://www.linux.org/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

**一个轻量级、高性能的 Node.js 服务器监控 API 服务**

实时监控系统性能指标，提供简洁的 RESTful API 接口

📖 **[English Documentation](README.md)** · 🇨🇳 **中文文档 (当前)**

[快速开始](#-快速开始) · [API 文档](#-api-接口) · [部署指南](#️-服务管理) · [问题反馈](https://github.com/superboyyy/server-monitor/issues)

</div>

---

## ✨ 功能特性

🚀 **实时监控** - 实时监控 CPU、内存、磁盘使用率和系统负载  
📊 **RESTful API** - 提供简洁的 HTTP API 接口，易于集成  
🌐 **跨域支持** - 内置 CORS 支持，前端友好  
⚙️ **systemd 集成** - 支持系统级和用户级服务安装  
🔄 **自动重启** - 服务异常时自动重启，保证高可用性  
📝 **日志记录** - 集成 systemd 日志系统，便于调试  
🐳 **轻量级** - 极小的资源占用，适合各种环境

## 🚀 快速开始

### 系统要求

- **Node.js** v14.0.0 或更高版本 
- **npm** 包管理器
- **Linux** 系统（支持 systemd）

### 📦 安装方式

#### 方式一：克隆仓库 (推荐)

```bash
# 克隆项目
git clone https://github.com/user/server-monitor.git
cd server-monitor

# 安装依赖
npm install

# 用户级服务安装 (推荐，无需 sudo 权限)
./install-service.sh --user
```

> **💡 推荐使用安装脚本**：安装脚本会自动：
> - 检查系统依赖
> - 安装 npm 依赖
> - 自动配置服务文件中的用户名和路径
> - 启用并启动服务

#### 方式二：系统级服务安装

```bash
# 系统级服务安装 (需要 sudo 权限)
sudo ./install-service.sh
```

#### 方式三：直接运行 (开发模式)

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

### 📋 响应字段说明

| 字段 | 类型 | 描述 | 范围 |
|------|------|------|------|
| `cpu` | `number` | CPU 使用率百分比 | 0-100 |
| `memory` | `number` | 内存使用率百分比 | 0-100 |
| `disk` | `number` | 磁盘使用率百分比 | 0-100 |
| `load` | `string` | 系统平均负载 (1分钟) | ≥ 0.0 |
| `timestamp` | `string` | 数据采集时间戳 (ISO 8601) | - |

### 💡 使用示例

<details>
<summary><b>JavaScript / Node.js</b></summary>

```javascript
const response = await fetch('http://localhost:3001/api/system/metrics');
const metrics = await response.json();

console.log(`CPU: ${metrics.cpu}%`);
console.log(`Memory: ${metrics.memory}%`);
console.log(`Disk: ${metrics.disk}%`);
console.log(`Load: ${metrics.load}`);
```

</details>

<details>
<summary><b>Python</b></summary>

```python
import requests

response = requests.get('http://localhost:3001/api/system/metrics')
metrics = response.json()

print(f"CPU: {metrics['cpu']}%")
print(f"Memory: {metrics['memory']}%") 
print(f"Disk: {metrics['disk']}%")
print(f"Load: {metrics['load']}")
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
echo "Memory: ${memory}%"
echo "Disk: ${disk}%"
echo "Load: ${load}"
```

</details>

## ⚙️ 服务管理

### 用户服务管理

<table>
<tr>
<th>操作</th>
<th>命令</th>
<th>描述</th>
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
<td>禁用开机自启动</td>
</tr>
</table>

### 系统服务管理

<table>
<tr>
<th>操作</th>
<th>命令</th>
<th>描述</th>
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
<td>禁用开机自启动</td>
</tr>
</table>

## 🛠️ 安装脚本使用

### 基本用法

```bash
# 显示帮助信息
./install-service.sh --help

# 安装为用户服务 (推荐)
./install-service.sh --user

# 安装为系统服务
./install-service.sh --system

# 查看服务状态
./install-service.sh --status

# 查看服务日志
./install-service.sh --logs

# 卸载服务
./install-service.sh --uninstall
```

### 🔧 脚本特性

| 特性 | 描述 |
|------|------|
| 🔍 **自动依赖检查** | 自动检查 Node.js、npm 和必要文件 |
| 🤖 **智能安装** | 自动创建 package.json 并安装依赖 |
| ⚙️ **自动配置** | 自动替换服务文件中的用户名和路径占位符 |
| 🎯 **双重支持** | 支持系统级和用户级服务安装 |
| 📦 **完整管理** | 提供安装、卸载、状态查看、日志查看功能 |
| ⚠️ **错误处理** | 完善的错误提示和异常处理 |
| 🎨 **彩色输出** | 清晰的信息分类显示 |

> **🚀 一键安装**：安装脚本会自动处理所有配置，无需手动修改任何文件！

## 🔧 配置

### 环境变量

| 变量 | 默认值 | 描述 |
|------|--------|------|
| `PORT` | `3001` | 服务监听端口 |
| `NODE_ENV` | `production` | 运行环境 |

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
```

> **⚠️ 重要提示**：使用前需要替换配置文件中的占位符：
> - 将 `YOUR_USERNAME` 替换为你的实际用户名
> - 将 `/path/to/server_monitor` 替换为项目的实际路径
> 
> 或者直接使用安装脚本，它会自动处理这些配置！

## 🚨 故障排除

<details>
<summary><b>🔧 端口已被占用</b></summary>

```bash
# 检查端口占用
sudo netstat -tlnp | grep :3001
# 或使用 ss 命令
sudo ss -tlnp | grep :3001

# 终止占用进程
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

# 删除 node_modules 重新安装
rm -rf node_modules package-lock.json
npm install
```

</details>

<details>
<summary><b>🔐 权限问题</b></summary>

- **用户服务**: 确保当前用户有执行权限
- **系统服务**: 确保以 `sudo` 权限运行安装脚本
- **文件权限**: 确保脚本具有可执行权限 `chmod +x install-service.sh`

</details>

### 🔄 重新安装

```bash
# 1. 卸载现有服务
./install-service.sh --uninstall

# 2. 清理依赖 (可选)
rm -rf node_modules package-lock.json

# 3. 重新安装
./install-service.sh --user
```

## 📁 项目结构

```
server-monitor/
├── 📄 server.js                 # 主服务文件
├── ⚙️ server-monitor.service    # systemd 服务配置
├── 🚀 install-service.sh        # 安装脚本
├── 📦 package.json              # 项目配置文件  
├── 🔒 package-lock.json         # 依赖锁定文件
├── 📖 README.md                 # 项目文档
└── 🙈 .gitignore                # Git 忽略文件
```

## 🛠️ 技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| **Node.js** | ≥14.0.0 | 运行时环境 |
| **Express.js** | ^5.1.0 | Web 框架 |
| **systemd** | - | 服务管理 |
| **Shell Script** | - | 自动化安装 |

## 🤝 贡献指南

我们欢迎所有形式的贡献！请遵循以下步骤：

1. **Fork** 本项目
2. 创建你的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交你的改动 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开一个 **Pull Request**

### 开发规范

- 遵循现有的代码风格
- 添加适当的注释
- 测试你的更改
- 更新相关文档

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## ⭐ Star History

如果这个项目对你有帮助，请给个 ⭐ Star 支持一下！

<div align="center">

---

**🌐 访问地址**: http://localhost:3001/api/system/metrics

**📧 问题反馈**: [GitHub Issues](https://github.com/superboyyy/server-monitor/issues)

**🔗 更多项目**: [GitHub Profile](https://github.com/superboyyy)

Made with ❤️ by [Aiden](https://github.com/superboyyy)

</div>