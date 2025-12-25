#!/bin/bash
# 强制推送到 GitHub 仓库的脚本（非交互式）
# 使用方法: ./push_to_github.sh

set -e

REPO_URL="https://github.com/iamcheyan/sbzr.git"
REPO_DIR="/home/tetsuya/.config/ibus/rime"

cd "$REPO_DIR"

echo "=== 检查 git 是否安装 ==="
if ! command -v git &> /dev/null; then
    echo "错误: git 未安装"
    echo "请先运行: sudo apt install git"
    exit 1
fi

echo "=== 初始化 git 仓库（如果尚未初始化） ==="
if [ ! -d .git ]; then
    git init
    echo "Git 仓库已初始化"
fi

echo "=== 配置 git 用户信息（如果需要） ==="
if [ -z "$(git config user.name)" ]; then
    git config user.name "tetsuya"
    echo "已设置 git user.name = tetsuya"
fi
if [ -z "$(git config user.email)" ]; then
    git config user.email "tetsuya@debian"
    echo "已设置 git user.email = tetsuya@debian"
fi

echo "=== 添加远程仓库 ==="
if git remote | grep -q "^origin$"; then
    git remote set-url origin "$REPO_URL"
    echo "已更新远程仓库地址为: $REPO_URL"
else
    git remote add origin "$REPO_URL"
    echo "已添加远程仓库: $REPO_URL"
fi

echo "=== 添加所有文件 ==="
git add .

echo "=== 提交更改 ==="
git commit -m "更新 Rime 配置: 修复 key_binder 和 numbered_mode_switch 错误" || echo "没有更改需要提交，或已是最新状态"

echo "=== 强制推送到远程仓库（覆盖远程内容） ==="
echo "警告: 这将覆盖远程仓库 https://github.com/iamcheyan/sbzr.git 的所有内容！"
echo "正在执行强制推送..."

# 尝试推送到 main 分支，如果失败则尝试 master，如果都失败则创建新分支
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")
if [ -z "$CURRENT_BRANCH" ]; then
    git checkout -b main 2>/dev/null || git branch main
    git checkout main
    CURRENT_BRANCH="main"
fi

git push -f -u origin "$CURRENT_BRANCH" 2>&1 || {
    echo "尝试推送到 main 分支..."
    git push -f -u origin main 2>&1 || {
        echo "尝试推送到 master 分支..."
        git push -f -u origin master 2>&1 || {
            echo "错误: 推送失败，请检查网络连接和仓库权限"
            exit 1
        }
    }
}

echo "✅ 强制推送完成！"
echo "仓库地址: $REPO_URL"
