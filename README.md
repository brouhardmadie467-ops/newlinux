根据项目当前最新结构和改善建议，以下是更新后的 `README.md` 文件内容。与原来相比，更新了项目结构、环境变量说明、Node.js 版本要求、补充了日志轮转和测试脚本信息，并修正了部分细节描述（如 Git 仓库地址、安装说明）。所有原有核心章节（特性、快速开始、API 接口、服务管理、安装脚本使用、故障排除等）均完整保留并优化。

```markdown
<div align="center">

# 🖥️ Server Monitor

[![Node.js Version](https://img.shields.io/badge/node-%3E%3D18.0.0-brightgreen.svg)](https://nodejs.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-linux-blue.svg)](https://www.linux.org/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

**A lightweight, high-performance Node.js server monitoring API service**

Real-time system performance metrics monitoring with clean RESTful API interface

🇺🇸 **English Documentation (Current)** · 📖 **[中文文档](README_CN.md)**

[Quick Start](#-quick-start) · [API Documentation](#-api-interface) · [Service Management](#️-service-management) · [Report Issues](https://github.com/superboyyy/server-monitor/issues)

</div>

---

## ✨ Features

🚀 **Real-time Monitoring** - Monitor CPU, memory, disk usage and system load in real-time
📊 **RESTful API** - Clean HTTP API interface, easy to integrate
🌐 **CORS Support** - Built-in CORS support, frontend friendly
⚙️ **systemd Integration** - Support both system-level and user-level service installation
🔄 **Auto Restart** - Automatic restart on service failure, ensuring high availability
📝 **Logging** - Integrated with systemd logging system for easy debugging
🚨 **Alerting** - Automatic alert logging when CPU or disk usage exceeds defined thresholds
🐳 **Lightweight** - Minimal resource footprint, suitable for all environments

## 🚀 Quick Start

### System Requirements

- **Node.js** v18.0.0 or higher (required by Express 5)
- **npm** package manager
- **Linux** system (with systemd support)

### 📦 Installation Methods

#### Method 1: Clone Repository (Recommended)

```bash
# Clone the project
git clone https://github.com/superboyyy/server-monitor.git
cd server-monitor

# Install dependencies (optional, script will do it)
npm install

# User-level service installation (recommended, no sudo required)
./install-service.sh --user
```

> **💡 Recommended to use installation script**: The installation script will automatically:
> - Check system dependencies
> - Install npm dependencies
> - Auto-configure username and path in service files
> - Enable and start the service

#### Method 2: System-level Service Installation

```bash
# System-level service installation (requires sudo)
sudo ./install-service.sh
```

#### Method 3: Direct Run (Development Mode)

```bash
# Install dependencies
npm install

# Start service
npm start
# or
node server.js
```

<div align="center">

### 🎯 One-Click Experience

```bash
curl -s http://localhost:3001/api/system/metrics | jq .
```

</div>

## 📊 API Interface

### Get System Metrics

**Endpoint:** `GET /api/system/metrics`

<table>
<tr>
<th>Request</th>
<th>Response</th>
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

### 📋 Response Field Descriptions

| Field | Type | Description | Range |
|-------|------|-------------|-------|
| `cpu` | `number` | CPU usage percentage | 0-100 |
| `memory` | `number` | Memory usage percentage | 0-100 |
| `disk` | `number` | Disk usage percentage | 0-100 |
| `load` | `string` | System load average (1 minute) | ≥ 0.0 |
| `timestamp` | `string` | Data collection timestamp (ISO 8601) | - |

### 💡 Usage Examples

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

## ⚙️ Service Management

### User Service Management

<table>
<tr>
<th>Operation</th>
<th>Command</th>
<th>Description</th>
</tr>
<tr>
<td>📊 Check Status</td>
<td><code>systemctl --user status server-monitor</code></td>
<td>View service running status</td>
</tr>
<tr>
<td>▶️ Start Service</td>
<td><code>systemctl --user start server-monitor</code></td>
<td>Start monitoring service</td>
</tr>
<tr>
<td>⏹️ Stop Service</td>
<td><code>systemctl --user stop server-monitor</code></td>
<td>Stop monitoring service</td>
</tr>
<tr>
<td>🔄 Restart Service</td>
<td><code>systemctl --user restart server-monitor</code></td>
<td>Restart monitoring service</td>
</tr>
<tr>
<td>📝 View Logs</td>
<td><code>journalctl --user -u server-monitor -f</code></td>
<td>View service logs in real-time</td>
</tr>
<tr>
<td>❌ Disable Auto-start</td>
<td><code>systemctl --user disable server-monitor</code></td>
<td>Disable auto-start on boot</td>
</tr>
</table>

### System Service Management

<table>
<tr>
<th>Operation</th>
<th>Command</th>
<th>Description</th>
</tr>
<tr>
<td>📊 Check Status</td>
<td><code>sudo systemctl status server-monitor</code></td>
<td>View service running status</td>
</tr>
<tr>
<td>▶️ Start Service</td>
<td><code>sudo systemctl start server-monitor</code></td>
<td>Start monitoring service</td>
</tr>
<tr>
<td>⏹️ Stop Service</td>
<td><code>sudo systemctl stop server-monitor</code></td>
<td>Stop monitoring service</td>
</tr>
<tr>
<td>🔄 Restart Service</td>
<td><code>sudo systemctl restart server-monitor</code></td>
<td>Restart monitoring service</td>
</tr>
<tr>
<td>📝 View Logs</td>
<td><code>sudo journalctl -u server-monitor -f</code></td>
<td>View service logs in real-time</td>
</tr>
<tr>
<td>❌ Disable Auto-start</td>
<td><code>sudo systemctl disable server-monitor</code></td>
<td>Disable auto-start on boot</td>
</tr>
</table>

## 🛠️ Installation Script Usage

### Basic Usage

```bash
# Show help information
./install-service.sh --help

# Install as user service (recommended)
./install-service.sh --user

# Install as system service
./install-service.sh --system

# Check service status
./install-service.sh --status

# View service logs
./install-service.sh --logs

# Uninstall service
./install-service.sh --uninstall
```

### 🔧 Script Features

| Feature | Description |
|---------|-------------|
| 🔍 **Auto Dependency Check** | Automatically check Node.js, npm and required files |
| 🤖 **Smart Installation** | Auto-create package.json and install dependencies |
| ⚙️ **Auto Configuration** | Auto-replace placeholders in service files for username and path |
| 🎯 **Dual Support** | Support both system-level and user-level service installation |
| 📦 **Complete Management** | Provide installation, uninstallation, status viewing, log viewing functions |
| ⚠️ **Error Handling** | Comprehensive error messages and exception handling |
| 🎨 **Colored Output** | Clear information categorization display |

> **🚀 One-Click Installation**: The installation script automatically handles all configurations, no need to manually modify any files!

## 🔧 Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `3001` | Service listening port |
| `NODE_ENV` | `production` | Runtime environment |
| `ALERT_LOG` | `/tmp/server-monitor-alert.log` (user service) or `/var/log/server-monitor-alert.log` (system service) | Path to the alert log file |
| `CPU_THRESHOLD` | `90` | CPU usage percentage that triggers an alert |
| `DISK_THRESHOLD` | `90` | Disk usage percentage that triggers an alert |

*The CPU and disk thresholds can be customized by setting these environment variables in the service file or at runtime.*

### Service Configuration

Service configuration file `server-monitor.service` supports customization:

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

> **⚠️ Important Note**: You need to replace placeholders in the configuration file before use:
> - Replace `YOUR_USERNAME` with your actual username
> - Replace `/path/to/server_monitor` with the actual project path
> 
> Or just use the installation script, it will handle these configurations automatically!

### Alert Log Rotation

To prevent alert logs from growing indefinitely, a log rotation script is provided:

```bash
# Execute manually
./scripts/clean_alerts.sh

# Or set up a daily cron job (run `crontab -e` and add the following line):
0 2 * * * /path/to/server-monitor/scripts/clean_alerts.sh
```

This will back up the current alert log, clear the original, and delete archives older than 7 days.

## 🧪 Testing

The project includes an automated test script that verifies core functionality:

```bash
# Run the test script (requires curl and stress to be installed)
./test/test_metrics.sh
```

The test will:
- Start the service and check the API response
- Simulate high CPU load (using `stress`) to verify alerting
- Check the alert log for generated entries
- Clean up temporary files and processes

## 🚨 Troubleshooting

<details>
<summary><b>🔧 Port Already in Use</b></summary>

```bash
# Check port usage
sudo netstat -tlnp | grep :3001
# or use ss command
sudo ss -tlnp | grep :3001

# Kill the process using the port
sudo kill -9 <PID>
```

</details>

<details>
<summary><b>🚨 Service Start Failed</b></summary>

```bash
# View detailed error logs
journalctl --user -u server-monitor -n 50
# or view system service logs
sudo journalctl -u server-monitor -n 50

# Check service status
systemctl --user status server-monitor
```

</details>

<details>
<summary><b>📦 Dependency Installation Failed</b></summary>

```bash
# Clean npm cache
npm cache clean --force

# Remove node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

</details>

<details>
<summary><b>🔐 Permission Issues</b></summary>

- **User service**: Ensure current user has execution permissions
- **System service**: Ensure running installation script with `sudo` privileges
- **File permissions**: Ensure script has executable permissions `chmod +x install-service.sh`

</details>

### 🔄 Reinstallation

```bash
# 1. Uninstall existing service
./install-service.sh --uninstall

# 2. Clean dependencies (optional)
rm -rf node_modules package-lock.json

# 3. Reinstall
./install-service.sh --user
```

## 📁 Project Structure

```
server-monitor/
├── 📄 server.js                 # Main service file
├── ⚙️ server-monitor.service    # systemd service configuration
├── 🚀 install-service.sh        # Installation script
├── 📦 package.json              # Project configuration
├── 🔒 package-lock.json         # Dependency lock file
├── 📖 README.md                 # English documentation
├── 📖 README_CN.md              # Chinese documentation
├── 📄 LICENSE                   # MIT license
├── 🙈 .gitignore                # Git ignore rules
├── 🧪 test/
│   └── test_metrics.sh          # Automated test script
└── 🛠️ scripts/
    └── clean_alerts.sh          # Alert log rotation script
```

## 🛠️ Tech Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| **Node.js** | ≥18.0.0 | Runtime environment |
| **Express.js** | ^5.1.0 | Web framework |
| **systemd** | - | Service management |
| **Shell Script** | - | Automated installation & testing |

## 🤝 Contributing

We welcome all forms of contributions! Please follow these steps:

1. **Fork** this project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a **Pull Request**

### Development Guidelines

- Follow existing code style
- Add appropriate comments
- Test your changes
- Update relevant documentation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## ⭐ Star History

If this project helps you, please give it a ⭐ Star!

<div align="center">

---

**🌐 Access URL**: http://localhost:3001/api/system/metrics

**📧 Report Issues**: [GitHub Issues](https://github.com/superboyyy/server-monitor/issues)

**🔗 More Projects**: [GitHub Profile](https://github.com/superboyyy)

Made with ❤️ by [Aiden](https://github.com/superboyyy)

</div>
。