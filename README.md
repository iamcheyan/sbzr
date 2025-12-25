# Rime 输入法配置

## 输入方案

- **声笔自然 (sbzr)**：基于声笔编码的中文输入法

## 配置说明

### 主要文件

- `default.custom.yaml` - 默认配置自定义
- `sbzr.schema.yaml` - 声笔自然输入方案
- `sbzr.custom.yaml` - 声笔自然自定义配置
- `key_bindings.yaml` - 按键绑定配置
- `key_bindings.custom.yaml` - 按键绑定自定义

### 依赖文件

- `sbxlm.yaml` - 声笔系列共用配置
- `sbyp.*` - 拼音反查
- `sbpy.*` - 拼音词典
- `lua/` - Lua 脚本
- `opencc/` - 简繁转换配置

## 安装方法

1. 将配置文件复制到 Rime 配置目录：
   ```bash
   # Linux (fcitx5/ibus)
   cp -r * ~/.local/share/fcitx5/rime/  # 或 ~/.config/ibus/rime/
   
   # macOS (Squirrel)
   cp -r * ~/Library/Rime/
   
   # Windows (Weasel)
   cp -r * %APPDATA%\Rime\
   ```

2. 重新部署配置：
   ```bash
   rime_deployer --build
   ```

## 目录说明

### build/ 目录（编译输出）

- **编译时生成**：由 `rime_deployer` 从 `*.dict.yaml` 编译生成
- **可重新生成**：删除后可以重新编译恢复
- **不包含个人数据**：所有用户共享的基础词典

### *.userdb/ 目录（用户词典）

- **运行时生成**：使用输入法时自动创建和更新
- **个人数据**：包含学习数据、词频统计、自定义词汇
- **不可恢复**：删除后个人数据会丢失（除非有备份）
- **已启用同步**：`.gitignore` 中已取消忽略，会同步到 Git 仓库

## Git 同步

### 同步的内容

- ✅ 所有配置文件（`.yaml`）
- ✅ `lua/` 目录（Lua 脚本）
- ✅ `opencc/` 目录（简繁转换）
- ✅ `*.userdb/` 目录（用户词典）

### 不同步的内容

- ❌ `build/` - 编译输出目录（可重新生成）
- ❌ `*.log` - 日志文件
- ❌ `lost/` - 丢失文件恢复目录

### 推送到 GitHub

```bash
cd ~/.config/ibus/rime  # 或你的 Rime 配置目录

# 初始化并推送
git init
git add .
git commit -m "Rime 输入法配置"
git remote add origin https://github.com/iamcheyan/sbzr.git
git branch -M main
git push -f -u origin main
```

## 注意事项

- `build/` 目录会被自动生成，不需要同步
- `*.userdb/` 目录包含个人学习数据，已启用同步
- 修改配置后需要运行 `rime_deployer --build` 重新编译
- 二进制文件（`.bin`, `.ldb`）无法在 GitHub 上查看差异

## 相关文件

- `rebuild.sh` - 重建脚本（删除 build 并重新编译）
- `.gitignore` - Git 忽略规则
- `push_to_github.sh` - 推送到 GitHub 的脚本
