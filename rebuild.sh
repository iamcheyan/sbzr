#!/bin/bash
# Rime 输入法重建脚本
# 功能：删除 build 目录并重新编译所有配置

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置目录
RIME_DIR="${1:-$HOME/.local/share/fcitx5/rime}"
BUILD_DIR="$RIME_DIR/build"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Rime 输入法重建脚本${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 检查目录是否存在
if [ ! -d "$RIME_DIR" ]; then
    echo -e "${RED}错误：配置目录不存在: $RIME_DIR${NC}"
    exit 1
fi

echo -e "${YELLOW}配置目录: $RIME_DIR${NC}"
echo ""

# 检查 build 目录是否存在
if [ -d "$BUILD_DIR" ]; then
    # 计算 build 目录大小
    BUILD_SIZE=$(du -sh "$BUILD_DIR" 2>/dev/null | cut -f1)
    echo -e "${YELLOW}检测到 build 目录，大小: $BUILD_SIZE${NC}"
    echo -e "${YELLOW}正在删除 build 目录...${NC}"
    rm -rf "$BUILD_DIR"
    echo -e "${GREEN}✓ build 目录已删除${NC}"
else
    echo -e "${YELLOW}build 目录不存在，跳过删除步骤${NC}"
fi

echo ""
echo -e "${BLUE}开始重新编译...${NC}"
echo ""

# 运行 rime_deployer
if command -v rime_deployer &> /dev/null; then
    echo -e "${YELLOW}运行: rime_deployer --build $RIME_DIR${NC}"
    echo ""
    
    # 运行编译并捕获输出
    if rime_deployer --build "$RIME_DIR" 2>&1 | tee /tmp/rime_build.log; then
        echo ""
        echo -e "${GREEN}✓ 编译完成！${NC}"
    else
        echo ""
        echo -e "${RED}✗ 编译过程中出现错误${NC}"
        echo -e "${YELLOW}详细日志已保存到: /tmp/rime_build.log${NC}"
        exit 1
    fi
else
    echo -e "${RED}错误：未找到 rime_deployer 命令${NC}"
    echo -e "${YELLOW}请确保已安装 fcitx5-rime${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}编译结果统计：${NC}"

# 检查 build 目录
if [ -d "$BUILD_DIR" ]; then
    BUILD_SIZE=$(du -sh "$BUILD_DIR" 2>/dev/null | cut -f1)
    BIN_COUNT=$(find "$BUILD_DIR" -name "*.bin" 2>/dev/null | wc -l)
    SCHEMA_COUNT=$(find "$BUILD_DIR" -name "*.schema.yaml" 2>/dev/null | wc -l)
    
    echo -e "  ${GREEN}build 目录大小: $BUILD_SIZE${NC}"
    echo -e "  ${GREEN}二进制文件数量: $BIN_COUNT${NC}"
    echo -e "  ${GREEN}配置文件数量: $SCHEMA_COUNT${NC}"
    
    # 列出主要的二进制文件
    echo ""
    echo -e "${BLUE}主要编译文件：${NC}"
    find "$BUILD_DIR" -name "*.bin" -type f -exec ls -lh {} \; 2>/dev/null | \
        awk '{printf "  %s %s\n", $5, $9}' | head -10
else
    echo -e "${RED}  build 目录未创建，编译可能失败${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}重建完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}提示：如果输入法未正常工作，请重启 Fcitx5${NC}"
echo -e "${YELLOW}重启命令: killall fcitx5 && fcitx5 &${NC}"
