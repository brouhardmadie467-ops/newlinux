🤖 Assistant
以下是为您的项目量身定制的《中文版 README》，专为 Linux 新手设计，包含完整的目录说明、每个文件的作用、详细的安装与使用步骤，以及常见问题解答。
──────────────────────────────────────────────────
🖥️ 服务器监控小助手（server-monitor）
一个轻量级的 Linux 服务器监控工具，使用 Node.js + Shell 脚本实现。它可以实时查看 CPU、内存、磁盘、系统负载，自动分析日志中的攻击行为，生成巡检报告，还能批量管理多台远程服务器。
本工具适合 **Linux 初学者** 学习实践，也适合个人开发者或运维人员快速部署。
──────────────────────────────────────────────────
🎯 主要功能
•	✅ 实时系统指标：CPU、内存、磁盘、负载，全部通过 Linux 原生命令获取
•	✅ 指标历史记录：自动存入 SQLite 数据库，可查询最近数小时的数据
•	✅ 智能告警：当 CPU > 90% 或磁盘 > 90% 时，自动记录告警日志
•	✅ 日志安全分析：检测 SSH 暴力破解攻击和系统 OOM（内存溢出）事件
•	✅ 自动巡检：一键检查磁盘空间、内存和关键服务是否正常
•	✅ 生成巡检报告：自动输出 Markdown 格式的报告，便于存档和分享
•	✅ SSH 批量运维：通过配置文件管理多台远程主机，一条命令批量执行操作
•	✅ 模块化设计：代码结构清晰，适合学习 Node.js 后端开发
──────────────────────────────────────────────────
📁 项目目录结构（每个文件的作用）
首先，请确保你已经下载了项目并进入项目根目录（比如 server-monitor/）。项目的文件结构如下（你可以用 tree 命令查看，但这里我们直接用树形图表示）：

server-monitor/

│

├── server.js                  # 主程序入口，启动 Web 服务器，加载各个功能模块

├── package.json               # Node.js 项目配置文件，记录依赖库和启动脚本

│

├── routes/                    # 路由模块（处理来自网页/终端的请求）

│   ├── metrics.js             # 负责提供系统指标（CPU/内存等）和历史数据查询

│   ├── logs.js                # 负责调用 Shell 脚本分析日志文件

│   ├── reports.js             # 负责执行巡检并生成报告

│   └── ops.js                 # 负责接收远程操作命令，批量执行 SSH

│

├── db/                        # 数据库相关

│   └── database.js            # 初始化 SQLite 数据库，自动建表

│

├── scripts/                   # Shell 脚本（实现底层 Linux 命令操作）

│   ├── analyze_logs.sh        # 用 grep/awk 分析 /var/log/auth.log 和 syslog

│   ├── patrol_check.sh        # 巡检脚本：检查磁盘、内存、服务状态

│   ├── generate_report.sh     # 根据系统信息生成 Markdown 巡检报告

│   └── ssh_batch_exec.sh      # 根据 config/hosts.conf 远程执行命令

│

├── config/                    # 配置文件

│   └── hosts.conf             # 远程主机列表（别名、用户名@IP地址）

│

├── test/                      # 测试脚本（验证程序是否正常工作）

│   ├── test_metrics.sh        # 测试系统指标 API

│   └── test_logs.sh           # 测试日志分析 API

│

└── logs/                      # 运行时生成的日志和报告（程序会自动创建）

    └── reports/               # 存放生成的巡检报告（.md 文件）



──────────────────────────────────────────────────
🛠️ 环境要求（你需要准备什么）
•	一台 Linux 电脑或服务器（Ubuntu/Debian/CentOS 等，也可使用 Windows 的 WSL 子系统）
•	Node.js 版本 ≥ 14（推荐 18+）
•	npm（通常随 Node.js 一起安装）
•	基本的 Linux 命令权限（部分脚本可能需要 root 权限读取系统日志）
•	可选：stress 工具（用于模拟高 CPU 测试，非必须）
•	可选：jq 工具（用于格式化测试输出的 JSON，非必须）
──────────────────────────────────────────────────
🚀 安装步骤（一步一步来）
1. 下载项目到 Linux 电脑
如果你已经拿到了项目文件夹，直接进入该目录即可。如果没有，可以用 git clone 或直接解压。
2. 进入项目目录
打开终端（命令行），进入项目根目录。例如：

cd ~/server-monitor



3. 安装依赖（让程序跑起来需要的库）
执行下面的命令安装 Node.js 依赖：

npm install



如果提示 npm 命令不存在，说明你的系统还没有安装 Node.js。请用下面的命令安装（以 Ubuntu/Debian 为例）：

sudo apt update

sudo apt install nodejs npm



4. 给 Shell 脚本添加执行权限
所有 .sh 后缀的脚本必须具有执行权限，否则程序无法调用它们。在项目根目录依次运行：

chmod +x scripts/*.sh

chmod +x test/*.sh



5. 创建必要的文件夹（避免程序出错）
虽然程序会自动创建，但手动创建更稳妥：

mkdir -p logs/reports



6. 配置远程主机（如果需要使用 SSH 批量操作）
打开 config/hosts.conf，按照里面的格式修改为你自己的远程主机。如果没有远程主机需求，可以不用修改。
──────────────────────────────────────────────────
🏃 运行程序
在项目根目录，输入以下命令启动服务：

node server.js



如果看到类似以下提示，说明启动成功：

✅ Server monitor running on http://localhost:3001



注意：
•	程序启动后，终端会被占用，你可以使用 Ctrl+C 停止程序。
•	如果想在后台运行，可以使用 nohup node server.js & 或者安装 pm2。
──────────────────────────────────────────────────
🔌 功能接口（API）快速参考
服务启动后，可以通过浏览器或 curl 命令访问这些地址：
功能	请求方式	地址	说明
实时指标	GET	http://localhost:3001/api/system/metrics	获取当前 CPU、内存、磁盘、负载
历史指标	GET	http://localhost:3001/api/system/metrics/history?hours=2	查询最近 2 小时（可改）的历史数据
日志分析	GET	http://localhost:3001/api/logs/analysis	分析 SSH 攻击和 OOM 事件
巡检报告	GET	http://localhost:3001/api/reports/latest	执行一次巡检并获取最新报告
SSH 批量操作	POST	http://localhost:3001/api/ops/execute	需要传入 JSON 参数（见下方示例）
SSH 批量操作示例（使用 curl）：

curl -X POST http://localhost:3001/api/ops/execute \

  -H "Content-Type: application/json" \

  -d '{"command": "uptime", "hosts": ["web1"]}'



──────────────────────────────────────────────────
🧪 运行测试（检验是否安装正确）
确保服务正在运行（node server.js），然后打开另一个终端，进入项目根目录，依次执行：
测试 1：系统指标和历史记录

bash test/test_metrics.sh



如果看到 JSON 格式的 CPU、内存等数据，并且历史数据也返回，说明指标模块正常。
测试 2：日志分析

bash test/test_logs.sh



如果返回 SSH 失败和 OOM 事件的统计数据（可能都是 0），说明日志分析模块正常。
小技巧：如果输出了凌乱的 JSON，可以安装 jq 工具来美化显示：

sudo apt install jq



──────────────────────────────────────────────────
❓ 常见问题（FAQ）
1. 启动时提示 `Cannot find module 'express'`
说明依赖没有安装，请在项目根目录执行 npm install。
2. 获取的 CPU 使用率始终为 0
这可能是因为 top 命令的输出格式在你的系统中略有不同。可以手动运行 top -bn1 | grep '%Cpu' 看看输出的行是什么样的，然后我们可以调整 routes/metrics.js 中的 awk 逻辑。临时解决方法：在终端执行 top -bn1 查看第 3 行（Cpu(s):），确认数字的列号，修改 $2 + $4 为正确的列号。
3. 日志分析返回错误或空数组
•	如果是 WSL 或虚拟机，可能没有 /var/log/auth.log 文件，脚本会返回空数组，这是正常的。
•	要看到真实的 SSH 攻击数据，你需要在真实的 Linux 服务器上运行，并确保 /var/log/auth.log 可读（可能需要 sudo 权限）。你可以用 sudo node server.js 启动，但出于安全考虑，也可以修改脚本将 AUTH_LOG 路径改为其他日志文件。
4. `jq: command not found`
不影响程序运行，只是测试脚本中用来美化 JSON 输出的工具。可以安装它：sudo apt install jq，或者直接去掉测试脚本中的 | jq。
5. 如何停止程序？
在运行 node server.js 的终端中按 Ctrl + C。
──────────────────────────────────────────────────
🧰 技术栈（给想深入学习的同学）
•	后端框架：Node.js + Express
•	数据库：SQLite（使用 better-sqlite3 驱动）
•	Linux 命令：top、free、df、grep、awk、sed、ssh
•	Shell 脚本：实现日志分析、巡检、报告生成
•	其他：SSH 批量管理、Git 版本控制、systemd 服务化
──────────────────────────────────────────────────
📝 后续可以自己扩展的功能
•	添加邮件/钉钉告警
•	使用 crontab 定时生成巡检报告
•	把数据展示做成网页仪表盘
•	添加 CPU 温度、网络流量等指标
•	做成 systemd 服务，开机自启
──────────────────────────────────────────────────
祝你学习顺利，答辩成功！如果还有任何疑问，欢迎随时提出。