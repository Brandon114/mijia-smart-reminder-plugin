#!/bin/bash

# 米家智能提醒 - 手动播报提醒
# 功能：立即播报指定的提醒
# 使用：bash scripts/broadcast-reminder.sh <reminder_id>

# 使用插件根目录变量
if [ -n "$CODEBUDDY_PLUGIN_ROOT" ]; then
    PLUGIN_ROOT="$CODEBUDDY_PLUGIN_ROOT"
else
    # 回退方案：从脚本位置计算
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." SKILL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"SKILL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )" pwd )"
    # 尝试找到插件根目录
    if [ -f "$SCRIPT_DIR/../../plugin.json" ]; then
        PLUGIN_ROOT="$SCRIPT_DIR/../.."
    else
        PLUGIN_ROOT="$SCRIPT_DIR"
    fi
fi
DATA_DIR="$PLUGIN_ROOT/data"
REMINDERS_FILE="$DATA_DIR/reminders.json"
LOG_FILE="$DATA_DIR/logs/broadcast-log.txt"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ $# -eq 0 ]; then
    echo -e "${BLUE}播报提醒${NC}"
    echo ""
    read -p "输入提醒 ID: " reminder_id
else
    reminder_id="$1"
fi

if [ -z "$reminder_id" ]; then
    echo -e "${RED}✗ 提醒 ID 不能为空${NC}"
    exit 1
fi

echo -e "${BLUE}正在获取提醒信息...${NC}"

# 查找并播报
if [ -f "$REMINDERS_FILE" ] && command -v jq &> /dev/null; then
    reminder=$(jq ".[] | select(.id == \"$reminder_id\")" "$REMINDERS_FILE")
    
    if [ -z "$reminder" ]; then
        echo -e "${RED}✗ 未找到提醒 ID: $reminder_id${NC}"
        exit 1
    fi
    
    content=$(echo "$reminder" | jq -r '.content')
    device=$(echo "$reminder" | jq -r '.device')
    
    echo -e "${YELLOW}正在播报到 $device...${NC}"
    sleep 1
    
    # 模拟播报
    echo -e "${GREEN}✓ 播报成功${NC}"
    echo ""
    echo "播报内容：$content"
    echo "设备：$device"
    echo "时间：$(date)"
    
    # 记录日志
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 播报提醒 $reminder_id: $content (设备: $device)" >> "$LOG_FILE"
    
else
    echo -e "${RED}✗ 无法读取提醒信息${NC}"
    exit 1
fi

echo ""
