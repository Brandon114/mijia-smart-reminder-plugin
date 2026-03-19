#!/bin/bash

# 米家智能提醒插件 - 安装脚本
# 版本: 1.0.0

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 插件信息
PLUGIN_NAME="mijia-smart-reminder"
VERSION="1.0.0"
AUTHOR="WorkBuddy 社区"
LICENSE="MIT"

# 输出函数
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查命令是否存在
check_command() {
    if ! command -v "$1" &> /dev/null; then
        print_error "需要安装 $1 工具"
        exit 1
    fi
}

# 显示横幅
show_banner() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}   米家智能提醒插件 - 安装向导${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "插件名称: $PLUGIN_NAME"
    echo "版本: $VERSION"
    echo "作者: $AUTHOR"
    echo "许可证: $LICENSE"
    echo ""
}

# 环境检测
check_environment() {
    print_info "检测运行环境..."
    
    # 检查操作系统
    OS="$(uname -s)"
    if [[ "$OS" != "Darwin" ]] && [[ "$OS" != "Linux" ]]; then
        print_warning "仅支持 macOS 和 Linux 系统"
        print_info "当前系统: $OS"
    fi
    
    # 检查必要工具
    check_command "curl"
    check_command "jq"
    
    # 检查 WorkBuddy/Codebuddy 目录
    if [ -d "$HOME/.workbuddy" ]; then
        BUDDY_TYPE="WorkBuddy"
        BUDDY_DIR="$HOME/.workbuddy"
    elif [ -d "$HOME/.codebuddy" ]; then
        BUDDY_TYPE="Codebuddy"
        BUDDY_DIR="$HOME/.codebuddy"
    else
        print_error "未找到 WorkBuddy 或 Codebuddy 安装目录"
        print_info "请先安装 WorkBuddy 或 Codebuddy"
        exit 1
    fi
    
    print_success "环境检测完成"
    print_info "检测到 $BUDDY_TYPE，目录: $BUDDY_DIR"
}

# 安装插件
install_plugin() {
    print_info "安装插件..."
    
    # 插件安装目录
    PLUGINS_DIR="$BUDDY_DIR/plugins"
    INSTALL_DIR="$PLUGINS_DIR/$PLUGIN_NAME"
    
    # 创建插件目录
    mkdir -p "$PLUGINS_DIR"
    
    # 检查是否已安装
    if [ -d "$INSTALL_DIR" ]; then
        print_warning "插件已存在，将进行更新"
        read -p "是否继续？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "安装取消"
            exit 0
        fi
    fi
    
    # 复制插件文件
    print_info "复制插件文件..."
    
    # 获取当前脚本所在目录
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
    
    # 复制文件
    cp -r "$SCRIPT_DIR/"* "$INSTALL_DIR" 2>/dev/null || true
    
    # 设置权限
    chmod +x "$INSTALL_DIR/scripts/"*.sh 2>/dev/null || true
    chmod +x "$INSTALL_DIR/skills/$PLUGIN_NAME/scripts/"*.sh 2>/dev/null || true
    
    # 创建数据目录
    mkdir -p "$INSTALL_DIR/data/logs"
    
    print_success "插件文件复制完成"
}

# 配置插件
configure_plugin() {
    print_info "配置插件..."
    
    INSTALL_DIR="$BUDDY_DIR/plugins/$PLUGIN_NAME"
    CONFIG_FILE="$INSTALL_DIR/data/config.json"
    
    # 检查是否需要配置
    if [ -f "$CONFIG_FILE" ]; then
        print_info "已存在配置文件"
        return 0
    fi
    
    print_info "启动配置向导..."
    echo ""
    
    # 创建基本配置文件
    cat > "$CONFIG_FILE" << EOF
{
  "version": "$VERSION",
  "mijia": {
    "status": "not_configured",
    "configured": false,
    "last_check": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  },
  "settings": {
    "auto_check": true,
    "check_interval": 300,
    "default_volume": 60,
    "language": "zh-CN"
  }
}
EOF
    
    print_success "基础配置已创建"
    print_info "您可以使用 /mijia-setup 进行详细配置"
}

# 注册插件
register_plugin() {
    print_info "注册插件..."
    
    # 创建插件注册信息
    REGISTER_FILE="$BUDDY_DIR/plugins/installed-plugins.json"
    
    if [ ! -f "$REGISTER_FILE" ]; then
        cat > "$REGISTER_FILE" << EOF
{
  "plugins": {}
}
EOF
    fi
    
    # 更新注册信息（使用 jq）
    if command -v jq > /dev/null 2>&1; then
        jq ".plugins.\"$PLUGIN_NAME\" = {
            \"name\": \"$PLUGIN_NAME\",
            \"version\": \"$VERSION\",
            \"installed_at\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
            \"type\": \"$BUDDY_TYPE\",
            \"enabled\": true
        }" "$REGISTER_FILE" > "$REGISTER_FILE.tmp" && mv "$REGISTER_FILE.tmp" "$REGISTER_FILE"
    fi
    
    print_success "插件注册完成"
}

# 验证安装
verify_installation() {
    print_info "验证安装..."
    
    INSTALL_DIR="$BUDDY_DIR/plugins/$PLUGIN_NAME"
    
    # 检查关键文件
    if [ ! -f "$INSTALL_DIR/plugin.json" ]; then
        print_error "plugin.json 文件缺失"
        exit 1
    fi
    
    if [ ! -f "$INSTALL_DIR/skills/$PLUGIN_NAME/SKILL.md" ]; then
        print_error "SKILL.md 文件缺失"
        exit 1
    fi
    
    if [ ! -d "$INSTALL_DIR/scripts" ]; then
        print_error "scripts 目录缺失"
        exit 1
    fi
    
    # 检查脚本执行权限
    if [ -f "$INSTALL_DIR/scripts/install.sh" ]; then
        if [ ! -x "$INSTALL_DIR/scripts/install.sh" ]; then
            print_warning "设置脚本执行权限..."
            chmod +x "$INSTALL_DIR/scripts/install.sh"
        fi
    fi
    
    print_success "安装验证通过"
}

# 显示完成信息
show_completion() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✓ 插件安装完成！${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    print_success "插件已成功安装到：$BUDDY_DIR/plugins/$PLUGIN_NAME"
    
    echo ""
    echo "📋 插件包含以下功能："
    echo "  ✅ 5 个命令："
    echo "    • /mijia-setup - 配置米家账号"
    echo "    • /mijia-add - 创建新提醒"
    echo "    • /mijia-list - 查看提醒列表"
    echo "    • /mijia-status - 检查设备状态"
    echo "    • /mijia-broadcast - 手动播报提醒"
    echo ""
    echo "  ✅ 1 个智能助理："
    echo "    • mijia-assistant - 对话式交互"
    echo ""
    echo "  ✅ 1 个自动化任务："
    echo "    • 每分钟检查提醒并播报"
    echo ""
    
    echo "🚀 快速开始："
    echo "  1. 重启 WorkBuddy/Codebuddy"
    echo "  2. 运行命令：/mijia-setup"
    echo "  3. 配置米家账号信息"
    echo "  4. 开始创建提醒"
    echo ""
    
    echo "🔧 常用命令："
    echo "  /mijia-setup        配置账号"
    echo "  /mijia-add          添加提醒"
    echo "  /mijia-list         查看提醒"
    echo "  /mijia-status       检查状态"
    echo ""
    
    echo "📚 更多帮助："
    echo "  查看插件目录下的 README.md"
    echo ""
    
    print_info "安装时间：$(date)"
}

# 主安装流程
main() {
    show_banner
    
    # 环境检测
    check_environment
    
    # 安装插件
    install_plugin
    
    # 基础配置
    configure_plugin
    
    # 注册插件
    register_plugin
    
    # 验证安装
    verify_installation
    
    # 显示完成信息
    show_completion
}

# 执行主函数
main "$@"

exit 0