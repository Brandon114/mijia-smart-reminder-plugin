#!/bin/bash

# 米家智能提醒插件 - 卸载脚本
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

# 显示横幅
show_banner() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}   米家智能提醒插件 - 卸载向导${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# 检测安装目录
detect_installation() {
    print_info "检测插件安装位置..."
    
    # 可能的安装目录
    POSSIBLE_DIRS=(
        "$HOME/.workbuddy/plugins/$PLUGIN_NAME"
        "$HOME/.codebuddy/plugins/$PLUGIN_NAME"
        "/usr/local/share/$PLUGIN_NAME"
        "/opt/$PLUGIN_NAME"
    )
    
    INSTALL_DIR=""
    BUDDY_TYPE=""
    
    for dir in "${POSSIBLE_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            INSTALL_DIR="$dir"
            
            if [[ "$dir" == *".workbuddy"* ]]; then
                BUDDY_TYPE="WorkBuddy"
            elif [[ "$dir" == *".codebuddy"* ]]; then
                BUDDY_TYPE="Codebuddy"
            fi
            
            print_success "找到插件安装目录: $INSTALL_DIR"
            print_info "插件类型: $BUDDY_TYPE"
            break
        fi
    done
    
    if [ -z "$INSTALL_DIR" ]; then
        print_error "未找到插件安装目录"
        print_info "插件可能未安装或安装在其他位置"
        exit 1
    fi
    
    echo "$INSTALL_DIR"
}

# 备份用户数据
backup_data() {
    local install_dir="$1"
    local backup_dir="$HOME/.${PLUGIN_NAME}_backup_$(date +%Y%m%d_%H%M%S)"
    
    print_info "备份用户数据..."
    
    if [ -d "$install_dir/data" ]; then
        mkdir -p "$backup_dir"
        cp -r "$install_dir/data" "$backup_dir/"
        
        if [ $? -eq 0 ]; then
            print_success "数据备份完成: $backup_dir"
            
            # 显示备份内容
            echo "备份包含以下文件："
            find "$backup_dir" -type f | sed 's|^|  • |'
            echo ""
        else
            print_warning "数据备份失败，继续卸载"
        fi
    else
        print_info "未找到用户数据目录，无需备份"
    fi
}

# 卸载插件
uninstall_plugin() {
    local install_dir="$1"
    
    print_info "开始卸载插件..."
    
    # 确认卸载
    echo "即将卸载以下插件："
    echo "  名称: $PLUGIN_NAME"
    echo "  目录: $install_dir"
    echo ""
    
    read -p "是否确认卸载？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "卸载取消"
        exit 0
    fi
    
    # 停止相关进程（如果有）
    print_info "停止相关进程..."
    pkill -f "mijia.*reminder" 2>/dev/null || true
    
    # 删除插件目录
    print_info "删除插件文件..."
    if rm -rf "$install_dir"; then
        print_success "插件文件已删除"
    else
        print_error "删除插件文件失败"
        print_info "请手动删除: $install_dir"
    fi
    
    # 清理插件注册信息
    cleanup_registry "$install_dir"
}

# 清理插件注册信息
cleanup_registry() {
    local install_dir="$1"
    
    print_info "清理插件注册信息..."
    
    # 检查可能的注册文件
    REGISTRY_FILES=(
        "$HOME/.workbuddy/plugins/installed-plugins.json"
        "$HOME/.codebuddy/plugins/installed-plugins.json"
    )
    
    for registry_file in "${REGISTRY_FILES[@]}"; do
        if [ -f "$registry_file" ] && command -v jq > /dev/null 2>&1; then
            # 从注册文件中移除插件
            if jq "del(.plugins.\"$PLUGIN_NAME\")" "$registry_file" > "$registry_file.tmp" 2>/dev/null; then
                mv "$registry_file.tmp" "$registry_file"
                print_success "已从注册文件移除: $(basename "$registry_file")"
            fi
        fi
    done
}

# 清理环境变量
cleanup_environment() {
    print_info "清理环境变量..."
    
    # 检查并清理可能的 shell 配置文件
    SHELL_FILES=(
        "$HOME/.bashrc"
        "$HOME/.bash_profile"
        "$HOME/.zshrc"
        "$HOME/.profile"
    )
    
    for shell_file in "${SHELL_FILES[@]}"; do
        if [ -f "$shell_file" ]; then
            # 移除插件相关的环境变量设置
            if grep -q "MIJIA_SMART_REMINDER" "$shell_file"; then
                sed -i '' '/MIJIA_SMART_REMINDER/d' "$shell_file" 2>/dev/null || true
                print_info "已清理 $shell_file 中的环境变量"
            fi
        fi
    done
}

# 显示卸载完成信息
show_completion() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✓ 插件卸载完成！${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    print_success "插件已成功卸载"
    echo ""
    
    echo "📋 已执行的操作："
    echo "  ✅ 停止相关进程"
    echo "  ✅ 备份用户数据"
    echo "  ✅ 删除插件文件"
    echo "  ✅ 清理注册信息"
    echo "  ✅ 清理环境变量"
    echo ""
    
    echo "⚠️  注意事项："
    echo "  1. 如需重新安装，请运行安装脚本"
    echo "  2. 备份数据位于 ~/.${PLUGIN_NAME}_backup_*"
    echo "  3. 重启 WorkBuddy/Codebuddy 使更改生效"
    echo ""
    
    echo "🔧 手动清理（如果需要）："
    echo "  1. 检查 ~/.workbuddy/plugins/ 或 ~/.codebuddy/plugins/"
    echo "  2. 删除残留的配置文件"
    echo "  3. 清理 shell 配置文件中的相关设置"
    echo ""
    
    print_info "卸载时间：$(date)"
}

# 主卸载流程
main() {
    show_banner
    
    # 检测安装目录
    INSTALL_DIR=$(detect_installation)
    
    # 备份用户数据
    backup_data "$INSTALL_DIR"
    
    # 卸载插件
    uninstall_plugin "$INSTALL_DIR"
    
    # 清理环境
    cleanup_environment
    
    # 显示完成信息
    show_completion
}

# 执行主函数
main "$@"

exit 0