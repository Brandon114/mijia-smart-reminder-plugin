#!/bin/bash

# 米家智能提醒插件 - 打包脚本
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
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
PACKAGE_NAME="${PLUGIN_NAME}-v${VERSION}-${TIMESTAMP}.zip"

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
    echo -e "${BLUE}   米家智能提醒插件 - 打包工具${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "插件名称: $PLUGIN_NAME"
    echo "版本: $VERSION"
    echo "打包时间: $TIMESTAMP"
    echo "输出文件: $PACKAGE_NAME"
    echo ""
}

# 清理临时文件
cleanup_temp() {
    print_info "清理临时文件..."
    
    # 清理可能的临时目录
    rm -rf "/tmp/${PLUGIN_NAME}_pack" 2>/dev/null || true
    rm -rf "./${PLUGIN_NAME}_pack" 2>/dev/null || true
    
    print_success "临时文件清理完成"
}

# 准备打包目录
prepare_package() {
    print_info "准备打包目录..."
    
    # 创建临时打包目录
    PACK_DIR="/tmp/${PLUGIN_NAME}_pack/${PLUGIN_NAME}"
    mkdir -p "$PACK_DIR"
    
    # 获取当前目录
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
    
    # 复制插件文件（排除不需要的文件）
    print_info "复制插件文件..."
    
    # 复制核心文件
    cp -r "$SCRIPT_DIR/plugin.json" "$PACK_DIR/"
    cp -r "$SCRIPT_DIR/README.md" "$PACK_DIR/"
    cp -r "$SCRIPT_DIR/CHANGELOG.md" "$PACK_DIR/"
    
    # 复制目录结构
    cp -r "$SCRIPT_DIR/commands" "$PACK_DIR/"
    cp -r "$SCRIPT_DIR/skills" "$PACK_DIR/"
    cp -r "$SCRIPT_DIR/agents" "$PACK_DIR/"
    cp -r "$SCRIPT_DIR/automations" "$PACK_DIR/"
    cp -r "$SCRIPT_DIR/scripts" "$PACK_DIR/"
    cp -r "$SCRIPT_DIR/assets" "$PACK_DIR/"
    
    # 创建空目录（如果不存在）
    mkdir -p "$PACK_DIR/hooks"
    mkdir -p "$PACK_DIR/data"
    
    # 设置文件权限
    print_info "设置文件权限..."
    find "$PACK_DIR" -name "*.sh" -exec chmod +x {} \;
    find "$PACK_DIR" -name "*.md" -exec chmod 644 {} \;
    find "$PACK_DIR" -name "*.json" -exec chmod 644 {} \;
    find "$PACK_DIR" -name "*.yaml" -exec chmod 644 {} \;
    find "$PACK_DIR" -name "*.toml" -exec chmod 644 {} \;
    
    # 创建安装说明文件
    cat > "$PACK_DIR/INSTALL.md" << EOF
# 安装说明

## 🚀 快速安装

### 方法一：使用安装脚本（推荐）
\`\`\`bash
# 1. 解压插件包
unzip ${PACKAGE_NAME}

# 2. 进入插件目录
cd ${PLUGIN_NAME}

# 3. 运行安装脚本
bash scripts/install.sh
\`\`\`

### 方法二：手动安装
\`\`\`bash
# 1. 解压插件包
unzip ${PACKAGE_NAME}

# 2. 复制到插件目录
cp -r ${PLUGIN_NAME} ~/.workbuddy/plugins/

# 3. 重启 WorkBuddy/Codebuddy
\`\`\`

## 📋 系统要求

- **操作系统**: macOS 10.15+ 或 Linux
- **工具依赖**: curl, jq
- **WorkBuddy/Codebuddy**: 版本 2.0.0+

## 🔧 首次使用

1. 重启 WorkBuddy/Codebuddy
2. 运行命令: \`/mijia-setup\`
3. 配置米家账号信息
4. 开始创建提醒

## 📚 更多信息

- 完整文档: README.md
- 更新日志: CHANGELOG.md
- 命令列表: 查看 README.md 中的命令部分

## 🆘 技术支持

如有问题，请查看插件目录下的文档或联系开发者。
EOF
    
    print_success "打包目录准备完成: $PACK_DIR"
}

# 创建压缩包
create_zip() {
    print_info "创建压缩包..."
    
    # 进入临时目录的父目录
    cd "/tmp/${PLUGIN_NAME}_pack"
    
    # 创建 ZIP 文件
    if command -v zip > /dev/null 2>&1; then
        zip -rq "$PACKAGE_NAME" "$PLUGIN_NAME"
        
        if [ $? -eq 0 ]; then
            # 移动回原始目录
            mv "$PACKAGE_NAME" "$SCRIPT_DIR/"
            FINAL_PATH="$SCRIPT_DIR/$PACKAGE_NAME"
            
            # 获取文件大小
            FILE_SIZE=$(du -h "$FINAL_PATH" | cut -f1)
            
            print_success "压缩包创建完成"
            print_info "文件: $FINAL_PATH"
            print_info "大小: $FILE_SIZE"
            
            # 显示压缩包内容
            echo ""
            echo "📦 压缩包内容："
            zipinfo -1 "$FINAL_PATH" | head -20
            echo "  ... (共 $(zipinfo -t "$FINAL_PATH" | awk '{print $2}') 个文件)"
            
        else
            print_error "创建压缩包失败"
            exit 1
        fi
    else
        print_error "需要安装 zip 工具"
        print_info "请安装: brew install zip 或 apt-get install zip"
        exit 1
    fi
}

# 验证压缩包
verify_package() {
    print_info "验证压缩包..."
    
    FINAL_PATH="$SCRIPT_DIR/$PACKAGE_NAME"
    
    # 检查文件是否存在
    if [ ! -f "$FINAL_PATH" ]; then
        print_error "压缩包文件不存在"
        exit 1
    fi
    
    # 检查文件大小
    MIN_SIZE=10240  # 至少 10KB
    ACTUAL_SIZE=$(stat -f%z "$FINAL_PATH" 2>/dev/null || stat -c%s "$FINAL_PATH" 2>/dev/null)
    
    if [ "$ACTUAL_SIZE" -lt "$MIN_SIZE" ]; then
        print_warning "压缩包大小异常 ($ACTUAL_SIZE 字节)"
    else
        print_success "压缩包大小正常 ($ACTUAL_SIZE 字节)"
    fi
    
    # 检查 ZIP 文件完整性
    if zip -T "$FINAL_PATH" > /dev/null 2>&1; then
        print_success "ZIP 文件完整性验证通过"
    else
        print_error "ZIP 文件完整性验证失败"
        exit 1
    fi
    
    # 显示统计信息
    echo ""
    echo "📊 打包统计："
    echo "  • 插件名称: $PLUGIN_NAME"
    echo "  • 版本: $VERSION"
    echo "  • 打包时间: $TIMESTAMP"
    echo "  • 文件大小: $(du -h "$FINAL_PATH" | cut -f1)"
    echo "  • 文件数量: $(zipinfo -t "$FINAL_PATH" | awk '{print $2}')"
    echo "  • 输出路径: $FINAL_PATH"
}

# 显示完成信息
show_completion() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✓ 插件打包完成！${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    FINAL_PATH="$SCRIPT_DIR/$PACKAGE_NAME"
    
    print_success "插件已成功打包"
    echo ""
    
    echo "📦 打包结果："
    echo "  文件: $PACKAGE_NAME"
    echo "  大小: $(du -h "$FINAL_PATH" | cut -f1)"
    echo "  路径: $FINAL_PATH"
    echo ""
    
    echo "🚀 分发步骤："
    echo "  1. 分享 $PACKAGE_NAME 文件"
    echo "  2. 用户解压后运行 install.sh"
    echo "  3. 或直接复制到插件目录"
    echo ""
    
    echo "🔧 安装命令示例："
    echo "  unzip $PACKAGE_NAME"
    echo "  cd $PLUGIN_NAME"
    echo "  bash scripts/install.sh"
    echo ""
    
    echo "📚 包含文件："
    echo "  ✅ plugin.json - 插件配置文件"
    echo "  ✅ README.md - 说明文档"
    echo "  ✅ CHANGELOG.md - 更新日志"
    echo "  ✅ commands/ - 5个命令"
    echo "  ✅ skills/ - 完整技能"
    echo "  ✅ agents/ - 智能助手"
    echo "  ✅ scripts/ - 安装脚本"
    echo "  ✅ assets/ - 图标资源"
    echo ""
    
    print_info "打包时间：$(date)"
}

# 主打包流程
main() {
    show_banner
    
    # 清理临时文件
    cleanup_temp
    
    # 准备打包目录
    prepare_package
    
    # 创建压缩包
    create_zip
    
    # 验证压缩包
    verify_package
    
    # 清理临时文件
    cleanup_temp
    
    # 显示完成信息
    show_completion
}

# 执行主函数
main "$@"

exit 0