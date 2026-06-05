#!/bin/bash

# 服务器监控服务安装脚本
# 支持系统级和用户级服务安装
# 版本: v2.1 (增强健壮性)

set -e  # 遇到错误立即退出

SERVICE_NAME="server-monitor"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_FILE="${SCRIPT_DIR}/${SERVICE_NAME}.service"
SERVER_FILE="${SCRIPT_DIR}/server.js"

# 颜色输出函数
print_info() {
    echo -e "\e[32m[INFO]\e[0m $1"
}

print_warn() {
    echo -e "\e[33m[WARN]\e[0m $1"
}

print_error() {
    echo -e "\e[31m[ERROR]\e[0m $1"
}

print_success() {
    echo -e "\e[32m[SUCCESS]\e[0m $1"
}

# 显示帮助信息
show_help() {
    cat << EOF
用法: $0 [选项]

选项:
  -h, --help          显示此帮助信息
  -u, --user          安装为用户服务 (不需要sudo)
  -s, --system        安装为系统服务 (需要sudo，默认)
  --uninstall         卸载服务
  --status            查看服务状态
  --logs              查看服务日志

示例:
  $0                  # 安装为系统服务
  $0 --user           # 安装为用户服务
  $0 --uninstall      # 卸载服务
EOF
}

# 检查依赖
check_dependencies() {
    print_info "检查系统依赖..."

    # 检查Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js未安装，请先安装Node.js"
        print_info "Ubuntu/Debian: sudo apt install nodejs npm"
        print_info "CentOS/RHEL: sudo yum install nodejs npm"
        exit 1
    fi

    local node_version=$(node --version)
    print_info "Node.js版本: $node_version"

    # 检查npm
    if ! command -v npm &> /dev/null; then
        print_error "npm未安装，请先安装npm"
        exit 1
    fi

    # 检查必要文件
    if [ ! -f "$SERVER_FILE" ]; then
        print_error "server.js文件不存在: $SERVER_FILE"
        exit 1
    fi

    if [ ! -f "$SERVICE_FILE" ]; then
        print_error "服务文件不存在: $SERVICE_FILE"
        exit 1
    fi

    # 检查项目目录是否存在
    if [ ! -d "$SCRIPT_DIR" ]; then
        print_error "项目目录 $SCRIPT_DIR 不存在"
        exit 1
    fi

    print_success "依赖检查通过"
}

# 安装npm依赖
install_npm_dependencies() {
    print_info "检查npm依赖..."

    cd "$SCRIPT_DIR"

    if [ ! -f "package.json" ]; then
        print_info "创建package.json..."
        npm init -y > /dev/null
    fi

    # 检查 node_modules 是否存在，不存在则安装
    if [ ! -d "node_modules" ]; then
        print_info "安装npm依赖..."
        npm install
    else
        print_info "node_modules 已存在，跳过安装"
    fi

    print_success "npm依赖安装完成"
}

# 安装系统服务
install_system_service() {
    print_info "安装系统级服务..."

    if [ "$EUID" -ne 0 ]; then
        print_error "安装系统服务需要root权限，请使用sudo运行"
        exit 1
    fi

    # 停止现有服务（如果存在）
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        print_info "停止现有服务..."
        systemctl stop "$SERVICE_NAME"
    fi

    # 复制服务文件
    local system_service_file="/etc/systemd/system/${SERVICE_NAME}.service"
    cp "$SERVICE_FILE" "$system_service_file"

    # 替换占位符
    if grep -q "YOUR_USERNAME" "$system_service_file"; then
        sed -i "s|YOUR_USERNAME|$USER|g" "$system_service_file"
        print_info "已替换用户名占位符为 $USER"
    else
        print_warn "服务文件中未找到 YOUR_USERNAME 占位符"
    fi

    if grep -q "/path/to/server_monitor" "$system_service_file"; then
        sed -i "s|/path/to/server_monitor|$SCRIPT_DIR|g" "$system_service_file"
        print_info "已替换项目路径占位符为 $SCRIPT_DIR"
    else
        print_warn "服务文件中未找到路径占位符"
    fi

    # 注入环境变量（告警日志路径与运行模式）
    if ! grep -q "Environment=ALERT_LOG" "$system_service_file"; then
        sed -i "/^ExecStart=/a Environment=ALERT_LOG=/var/log/server-monitor-alert.log\nEnvironment=NODE_ENV=production" "$system_service_file"
        print_info "已添加环境变量 ALERT_LOG 和 NODE_ENV"
    else
        print_info "环境变量已存在，跳过注入"
    fi

    print_info "服务文件已更新并复制到 /etc/systemd/system/"

    # 重新加载systemd
    systemctl daemon-reload

    # 启用并启动服务（允许启动失败继续给出提示）
    systemctl enable "$SERVICE_NAME" 2>/dev/null || print_warn "无法设置为开机自启，可能缺少权限"
    systemctl start "$SERVICE_NAME"
    if [ $? -ne 0 ]; then
        print_error "服务启动失败，请运行 'sudo journalctl -u $SERVICE_NAME' 查看详细日志"
        exit 1
    fi

    # 健康检查（等待2秒后尝试访问API）
    sleep 2
    if command -v curl &> /dev/null; then
        if curl -s http://localhost:3001/api/system/metrics > /dev/null 2>&1; then
            print_success "系统服务已成功启动，API 可访问"
        else
            print_warn "服务已启动但API暂时无响应，可稍后检查或查看端口占用"
        fi
    else
        print_info "未安装 curl，跳过 API 健康检查"
    fi

    print_success "系统服务安装完成"
}

# 安装用户服务
install_user_service() {
    print_info "安装用户级服务..."

    # 创建用户systemd目录
    local user_service_dir="$HOME/.config/systemd/user"
    mkdir -p "$user_service_dir"

    # 复制服务文件
    local user_service_file="$user_service_dir/${SERVICE_NAME}.service"
    cp "$SERVICE_FILE" "$user_service_file"

    # 修改用户服务文件（删除 User= 行，更新 WorkingDirectory）
    sed -i "/^User=/d" "$user_service_file"
    sed -i "s|WorkingDirectory=.*|WorkingDirectory=$SCRIPT_DIR|" "$user_service_file"

    # 注入环境变量（用户服务建议使用 /tmp 日志路径避免权限问题）
    if ! grep -q "Environment=ALERT_LOG" "$user_service_file"; then
        sed -i "/^ExecStart=/a Environment=ALERT_LOG=/tmp/server-monitor-alert.log\nEnvironment=NODE_ENV=production" "$user_service_file"
        print_info "已添加环境变量 ALERT_LOG (使用/tmp目录) 和 NODE_ENV"
    else
        print_info "环境变量已存在，跳过注入"
    fi

    print_info "服务文件已复制到 $user_service_file"

    # 重新加载用户systemd
    systemctl --user daemon-reload

    # 启用 lingering（允许用户服务在会话关闭后继续运行）
    if command -v loginctl &> /dev/null; then
        sudo loginctl enable-linger "$USER" 2>/dev/null || print_warn "无法启用用户 lingering，服务可能在用户注销后停止"
    fi

    # 停止现有用户服务（如果存在）
    if systemctl --user is-active --quiet "$SERVICE_NAME"; then
        print_info "停止现有用户服务..."
        systemctl --user stop "$SERVICE_NAME"
    fi

    # 启用并启动用户服务
    systemctl --user enable "$SERVICE_NAME" 2>/dev/null || print_warn "无法设置为用户级开机自启"
    systemctl --user start "$SERVICE_NAME"
    if [ $? -ne 0 ]; then
        print_error "用户服务启动失败，请运行 'journalctl --user -u $SERVICE_NAME' 查看详细日志"
        exit 1
    fi

    # 健康检查
    sleep 2
    if command -v curl &> /dev/null; then
        if curl -s http://localhost:3001/api/system/metrics > /dev/null 2>&1; then
            print_success "用户服务已成功启动，API 可访问"
        else
            print_warn "服务已启动但API暂时无响应，请确认端口未被占用或稍后重试"
        fi
    else
        print_info "未安装 curl，跳过 API 健康检查"
    fi

    print_success "用户服务安装完成"
}

# 卸载服务
uninstall_service() {
    print_info "卸载服务..."

    local uninstalled=false

    # 尝试卸载系统服务
    if [ -f "/etc/systemd/system/${SERVICE_NAME}.service" ]; then
        if [ "$EUID" -eq 0 ]; then
            systemctl stop "$SERVICE_NAME" 2>/dev/null || true
            systemctl disable "$SERVICE_NAME" 2>/dev/null || true
            rm -f "/etc/systemd/system/${SERVICE_NAME}.service"
            systemctl daemon-reload
            print_success "系统服务已卸载"
            uninstalled=true
        else
            print_warn "发现系统服务但没有root权限，请使用sudo卸载"
        fi
    fi

    # 尝试卸载用户服务
    local user_service_file="$HOME/.config/systemd/user/${SERVICE_NAME}.service"
    if [ -f "$user_service_file" ]; then
        systemctl --user stop "$SERVICE_NAME" 2>/dev/null || true
        systemctl --user disable "$SERVICE_NAME" 2>/dev/null || true
        rm -f "$user_service_file"
        systemctl --user daemon-reload
        print_success "用户服务已卸载"
        uninstalled=true
    fi

    if [ "$uninstalled" = false ]; then
        print_warn "未找到已安装的服务"
    fi
}

# 查看服务状态
show_status() {
    print_info "查看服务状态..."

    # 检查系统服务
    if [ -f "/etc/systemd/system/${SERVICE_NAME}.service" ]; then
        echo "=== 系统服务状态 ==="
        systemctl status "$SERVICE_NAME" --no-pager || true
        echo
    fi

    # 检查用户服务
    if [ -f "$HOME/.config/systemd/user/${SERVICE_NAME}.service" ]; then
        echo "=== 用户服务状态 ==="
        systemctl --user status "$SERVICE_NAME" --no-pager || true
        echo
    fi

    # 检查端口占用
    print_info "检查端口3001占用情况..."
    if command -v netstat &> /dev/null; then
        netstat -tlnp | grep :3001 || echo "端口3001未被占用"
    elif command -v ss &> /dev/null; then
        ss -tlnp | grep :3001 || echo "端口3001未被占用"
    fi
}

# 查看日志
show_logs() {
    print_info "查看服务日志..."

    # 检查哪个服务在运行
    if systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
        echo "=== 系统服务日志 ==="
        journalctl -u "$SERVICE_NAME" -f --no-pager
    elif systemctl --user is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
        echo "=== 用户服务日志 ==="
        journalctl --user -u "$SERVICE_NAME" -f --no-pager
    else
        print_warn "服务未运行，显示最近的日志记录..."
        journalctl -u "$SERVICE_NAME" --no-pager -n 50 2>/dev/null || \
        journalctl --user -u "$SERVICE_NAME" --no-pager -n 50 2>/dev/null || \
        print_error "未找到日志记录"
    fi
}

# 主函数
main() {
    local install_type="system"
    local action="install"

    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -u|--user)
                install_type="user"
                shift
                ;;
            -s|--system)
                install_type="system"
                shift
                ;;
            --uninstall)
                action="uninstall"
                shift
                ;;
            --status)
                action="status"
                shift
                ;;
            --logs)
                action="logs"
                shift
                ;;
            *)
                print_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done

    echo "========================================"
    echo "     服务器监控服务安装脚本 v2.1"
    echo "========================================"
    echo

    case $action in
        install)
            check_dependencies
            install_npm_dependencies

            if [ "$install_type" = "user" ]; then
                install_user_service
                echo
                print_info "用户服务管理命令："
                print_info "  查看状态: systemctl --user status $SERVICE_NAME"
                print_info "  启动服务: systemctl --user start $SERVICE_NAME"
                print_info "  停止服务: systemctl --user stop $SERVICE_NAME"
                print_info "  重启服务: systemctl --user restart $SERVICE_NAME"
                print_info "  查看日志: journalctl --user -u $SERVICE_NAME -f"
                print_info "  禁用服务: systemctl --user disable $SERVICE_NAME"
            else
                install_system_service
                echo
                print_info "系统服务管理命令："
                print_info "  查看状态: sudo systemctl status $SERVICE_NAME"
                print_info "  启动服务: sudo systemctl start $SERVICE_NAME"
                print_info "  停止服务: sudo systemctl stop $SERVICE_NAME"
                print_info "  重启服务: sudo systemctl restart $SERVICE_NAME"
                print_info "  查看日志: sudo journalctl -u $SERVICE_NAME -f"
                print_info "  禁用服务: sudo systemctl disable $SERVICE_NAME"
            fi

            echo
            print_info "服务API地址: http://localhost:3001/api/system/metrics"
            show_status
            ;;
        uninstall)
            uninstall_service
            ;;
        status)
            show_status
            ;;
        logs)
            show_logs
            ;;
    esac
}

# 运行主函数
main "$@"