#!/usr/bin/env bash
# ============================================
# AI 协同开发工作流 - 一键安装脚本 (Linux/macOS)
# 默认安装到当前工作空间（推荐）
# ============================================
set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 检测 VS Code 用户 prompts 目录
detect_user_prompts() {
    if [ -n "${VSCODE_USER_PROMPTS_FOLDER:-}" ]; then
        echo "$VSCODE_USER_PROMPTS_FOLDER"
        return
    fi
    case "$(uname -s)" in
        Linux*)  echo "$HOME/.config/Code/User/prompts" ;;
        Darwin*) echo "$HOME/Library/Application Support/Code/User/prompts" ;;
        *)       echo "$HOME/.config/Code/User/prompts" ;;
    esac
}

usage() {
    echo "用法: $0 [target-project] [--uninstall]"
    echo ""
    echo "  默认（无参数）: 安装到当前目录"
    echo "  <路径>:          安装到指定项目目录"
    echo "  --uninstall:     卸载"
    exit 0
}

# 处理卸载
if [ "${1:-}" = "--uninstall" ] || [ "${1:-}" = "-u" ]; then
    echo -e "${YELLOW}[卸载] 正在移除工作空间级文件...${NC}"
    for f in \
        ".github/agents/orchestrator.agent.md" \
        ".github/agents/executor.agent.md" \
        ".github/prompts/new-workflow.prompt.md"; do
        [ -f "$f" ] && rm -v "$f"
    done

    echo -e "${YELLOW}[卸载] 正在移除用户级文件...${NC}"
    UP=$(detect_user_prompts)
    for f in "orchestrator.agent.md" "executor.agent.md" "new-workflow.prompt.md"; do
        [ -f "$UP/$f" ] && rm -v "$UP/$f"
    done
    rm -rf "$UP/agents" "$UP/prompts" 2>/dev/null || true

    echo -e "${GREEN}[完成] 卸载成功${NC}"
    exit 0
fi

# 目标目录
TARGET="${1:-.}"
TARGET="$(cd "$TARGET" 2>/dev/null && pwd || echo "$TARGET")"

echo -e "${CYAN}[安装] 目标项目: $TARGET${NC}"

# ---- 1. 工作空间级安装 ----
mkdir -p "$TARGET/.github/agents"
mkdir -p "$TARGET/.github/prompts"
mkdir -p "$TARGET/.vscode"
mkdir -p "$TARGET/workflow/completed"

cp "$SCRIPT_DIR/.github/agents/orchestrator.agent.md"   "$TARGET/.github/agents/"
cp "$SCRIPT_DIR/.github/agents/executor.agent.md"       "$TARGET/.github/agents/"
cp "$SCRIPT_DIR/.github/prompts/new-workflow.prompt.md" "$TARGET/.github/prompts/"
cp "$SCRIPT_DIR/.github/copilot-instructions.md"        "$TARGET/.github/"
cp "$SCRIPT_DIR/.vscode/settings.json"                  "$TARGET/.vscode/"
cp "$SCRIPT_DIR/workflow/tasks.md"                      "$TARGET/workflow/"
cp "$SCRIPT_DIR/workflow/current-task.md"               "$TARGET/workflow/"
cp "$SCRIPT_DIR/README.md"                              "$TARGET/"

echo -e "  ${GREEN}[OK] 工作空间级安装完成${NC}"

# ---- 2. 可选: 用户级安装 ----
UP=$(detect_user_prompts)
if [ -d "$UP" ]; then
    echo -e "${CYAN}[安装] 检测到用户级目录: $UP${NC}"
    echo -e "${YELLOW}  注意: VS Code 1.119+ 可能不读取此路径${NC}"
    echo -n "  是否也安装到用户级? [y/N] "
    read -r ans
    if [ "$ans" = "y" ] || [ "$ans" = "Y" ]; then
        cp "$SCRIPT_DIR/.github/agents/orchestrator.agent.md"   "$UP/"
        cp "$SCRIPT_DIR/.github/agents/executor.agent.md"       "$UP/"
        cp "$SCRIPT_DIR/.github/prompts/new-workflow.prompt.md" "$UP/"
        echo -e "  ${GREEN}[OK] 用户级安装完成${NC}"
    fi
else
    mkdir -p "$UP" 2>/dev/null || true
    echo -e "${YELLOW}  提示: 用户级目录不存在, 跳过 (不影响使用)${NC}"
fi

echo ""
echo -e "${GREEN}[完成] 安装成功!${NC}"
echo "重启 VS Code, 打开此工作空间, 即可使用:"
echo -e "  ${CYAN}- /new-workflow${NC} - 启动工作流"
echo -e "  ${CYAN}- @orchestrator${NC} - 切换到编排器"
echo -e "  ${CYAN}- @executor${NC} - 切换到执行器"
echo ""
echo -e "提示: 安装到其他项目: $0 /path/to/other-project"
