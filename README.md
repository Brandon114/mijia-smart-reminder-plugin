# 米家智能提醒插件 (Mijia Smart Reminder Plugin)

一个功能强大的 WorkBuddy/Codebuddy 插件，用于与米家智能设备（特别是小爱音箱）集成，实现定时语音提醒播报功能。

## ✨ 核心功能

- 🎯 **智能设备连接**：轻松连接米家账号和小爱音箱
- ⏰ **定时语音提醒**：支持多种时间格式（每天、工作日、每周、一次性）
- 🗣️ **自然语言交互**：通过对话创建和管理提醒
- 📱 **多设备支持**：可同时管理多个小爱音箱
- 🔄 **自动播报**：定时检查并播报到期的提醒
- 📊 **状态监控**：实时查看设备连接状态
- 🔒 **隐私保护**：所有配置和提醒数据本地存储

## 🚀 快速开始

### 安装插件

1. **下载插件包**
   ```bash
   # 从 GitHub 下载
   git clone https://github.com/workbuddy-plugins/mijia-smart-reminder.git
   ```

2. **安装到 WorkBuddy/Codebuddy**
   ```bash
   # 方法1：使用插件管理器
   /plugins install mijia-smart-reminder
   
   # 方法2：手动安装
   cp -r mijia-smart-reminder ~/.workbuddy/plugins/
   ```

3. **重启 WorkBuddy/Codebuddy**
   ```bash
   # 重启应用以加载插件
   ```

### 首次配置

1. **启动配置向导**
   ```bash
   /mijia-setup
   ```

2. **输入米家账号信息**
   - 米家账号（手机号/邮箱）
   - 密码（可选，建议使用 token）
   - 小爱音箱设备名称

3. **验证连接**
   - 插件会自动测试设备连接
   - 显示可用设备列表

## 📋 可用命令

| 命令 | 描述 | 示例 |
|------|------|------|
| `/mijia-setup` | 配置米家账号和设备 | `/mijia-setup` |
| `/mijia-add` | 添加新的定时提醒 | `/mijia-add "每天9点站会" --time "09:00" --repeat daily` |
| `/mijia-list` | 查看所有提醒 | `/mijia-list --status active` |
| `/mijia-status` | 检查设备状态 | `/mijia-status` |
| `/mijia-broadcast` | 手动播报提醒 | `/mijia-broadcast --id 1` |

## 🎯 使用示例

### 创建每日提醒
```bash
# 通过命令
/mijia-add "每天上午10点站会" --time "10:00" --repeat daily

# 通过对话
"帮我设置一个每天上午10点的站会提醒"
```

### 创建一次性提醒
```bash
/mijia-add "明天下午3点项目评审" --time "2024-03-20 15:00" --repeat once
```

### 查看所有提醒
```bash
/mijia-list --format table
```

## 🏗️ 插件架构

```
mijia-smart-reminder-plugin/
├── plugin.json              # 插件配置文件
├── README.md               # 说明文档
├── CHANGELOG.md           # 更新日志
├── commands/              # 命令定义
│   ├── mijia-setup.yaml
│   ├── mijia-add.yaml
│   ├── mijia-list.yaml
│   ├── mijia-status.yaml
│   └── mijia-broadcast.yaml
├── skills/                # 技能定义
│   └── mijia-smart-reminder/
│       ├── SKILL.md
│       ├── scripts/
│       └── data/
├── agents/                # 智能代理
│   └── mijia-assistant.md
├── hooks/                 # 插件钩子
│   └── pre-tool-use.md
├── automations/           # 自动化任务
│   └── mijia-reminder-checker.toml
├── scripts/               # 辅助脚本
│   └── install.sh
├── assets/                # 资源文件
│   ├── icon-dark.svg
│   ├── icon-light.svg
│   └── screenshots/
└── data/                  # 数据存储（运行时生成）
    ├── config.json
    ├── reminders.json
    └── logs/
```

## 🔧 技术特性

### 1. 智能设备连接
- 支持米家官方 API
- 设备自动发现
- 连接状态监控
- 断线自动重连

### 2. 提醒管理系统
- 多种时间格式支持
- 优先级管理
- 重复规则配置
- 历史记录查看

### 3. 语音播报引擎
- 自然语言合成优化
- 多设备广播
- 播报失败重试
- 播报日志记录

### 4. 数据安全
- 本地加密存储
- 敏感信息保护
- 数据备份恢复
- 隐私合规设计

## 📊 配置选项

### 配置文件位置
```
~/.workbuddy/plugins/mijia-smart-reminder/data/config.json
```

### 配置示例
```json
{
  "mijia": {
    "account": "user@example.com",
    "token": "your_mijia_token",
    "devices": [
      {
        "name": "客厅小爱音箱",
        "deviceId": "xxx",
        "type": "speaker"
      }
    ]
  },
  "reminders": {
    "checkInterval": 300,
    "maxRetries": 3,
    "defaultVolume": 70
  },
  "logging": {
    "level": "info",
    "maxSize": "10MB",
    "backupCount": 5
  }
}
```

## 🔄 自动化功能

### 定时检查提醒
插件会自动每5分钟检查一次到期的提醒，并自动播报。

### 事件触发
- 插件加载时自动恢复状态
- 设备连接状态变化时通知
- 提醒播报成功/失败时记录

## 🛠️ 开发指南

### 环境要求
1. WorkBuddy/Codebuddy >= 2.0.0
2. Bash 环境
3. curl 和 jq 工具

### 构建插件
```bash
# 克隆仓库
git clone https://github.com/workbuddy-plugins/mijia-smart-reminder.git
cd mijia-smart-reminder

# 安装依赖
npm install

# 构建插件
npm run build
```

### 测试插件
```bash
# 运行单元测试
npm test

# 运行集成测试
npm run test:integration
```

## 🤝 贡献指南

欢迎贡献代码！请遵循以下步骤：

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 开启 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 支持与反馈

- 问题报告：x1148894@foxmail.com
- 功能请求：x1148894@foxmail.com
- 文档：[Wiki](https://github.com/workbuddy-plugins/mijia-smart-reminder/wiki)

## 🙏 致谢

感谢以下开源项目：
- [WorkBuddy](https://www.codebuddy.cn/) - 强大的 AI 助手平台
- [MiJia API](https://github.com/aholstenson/miio) - 米家设备控制库
- 所有贡献者和用户

---

**开始使用** → [快速开始指南](docs/QUICKSTART.md)
**了解更多** → [详细配置文档](docs/CONFIGURATION.md)
**遇到问题** → [故障排除](docs/TROUBLESHOOTING.md)
