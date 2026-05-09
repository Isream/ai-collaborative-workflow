#!/usr/bin/env bash
# ============================================
# AI 协同开发工作流 — 一键安装脚本 (Linux/macOS)
# 将 Agent 和 Prompt 安装到用户级目录
# ============================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 检测 VS Code 用户 prompts 目录
detect_vscode_prompts_dir() {
    # 优先使用环境变量
    if [ -n "${VSCODE_USER_PROMPTS_FOLDER:-}" ]; then
        echo "$VSCODE_USER_PROMPTS_FOLDER"
        return
    fi

    local os_type
    os_type=$(uname -s)

    case "$os_type" in
        Linux*)     echo "$HOME/.config/Code/User/prompts" ;;
        Darwin*)    echo "$HOME/Library/Application Support/Code/User/prompts" ;;
        MINGW*|MSYS*|CYGWIN*)  echo "$APPDATA/Code/User/prompts" ;;
        *)          echo "$HOME/.config/Code/User/prompts" ;;
    esac
}

# 脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VSCODE_PROMPTS=$(detect_vscode_prompts_dir)

# 处理卸载
if [ "${1:-}" = "--uninstall" ] || [ "${1:-}" = "-u" ]; then
    echo -e "${YELLOW}🗑️  正在卸载...${NC}"
    rm -f "$VSCODE_PROMPTS/orchestrator.agent.md"
    rm -f "$VSCODE_PROMPTS/executor.agent.md"
    rm -f "$VSCODE_PROMPTS/new-workflow.prompt.md"
    # 清理遗留的旧路径
    rm -rf "$VSCODE_PROMPTS/agents" 2>/dev/null
    rm -rf "$VSCODE_PROMPTS/prompts" 2>/dev/null
    echo -e "${GREEN}✅ 卸载完成${NC}"
    exit 0
fi

echo -e "${CYAN}VS Code Prompts 目录: $VSCODE_PROMPTS${NC}"
echo ""
echo -e "${GREEN}📦 正在安装 AI 协同工作流...${NC}"

# 复制 Agent 文件（直接放根目录，不要子文件夹！）
cp "$SCRIPT_DIR/.github/agents/orchestrator.agent.md" "$VSCODE_PROMPTS/"
echo -e "  ${GREEN}✅ orchestrator.agent.md${NC}"

cp "$SCRIPT_DIR/.github/agents/executor.agent.md" "$VSCODE_PROMPTS/"
echo -e "  ${GREEN}✅ executor.agent.md${NC}"

# 复制 Prompt 文件
cp "$SCRIPT_DIR/.github/prompts/new-workflow.prompt.md" "$VSCODE_PROMPTS/"
echo -e "  ${GREEN}✅ new-workflow.prompt.md${NC}"

# 如果指定了目标项目，复制项目级文件
if [ -n "${1:-}" ] && [ "${1:-}" != "--uninstall" ] && [ "${1:-}" != "-u" ]; then
    TARGET_PROJECT="$1"
    if [ -d "$TARGET_PROJECT" ]; then
        mkdir -p "$TARGET_PROJECT/.github"
        mkdir -p "$TARGET_PROJECT/.vscode"
        mkdir -p "$TARGET_PROJECT/workflow/completed"

        cp "$SCRIPT_DIR/.github/copilot-instructions.md" "$TARGET_PROJECT/.github/"
        cp "$SCRIPT_DIR/.vscode/settings.json" "$TARGET_PROJECT/.vscode/"
        cp "$SCRIPT_DIR/workflow/tasks.md" "$TARGET_PROJECT/workflow/"
        cp "$SCRIPT_DIR/workflow/current-task.md" "$TARGET_PROJECT/workflow/"
        touch "$TARGET_PROJECT/workflow/completed/.gitkeep"

        echo -e "  ${GREEN}✅ 项目文件已复制到: $TARGET_PROJECT${NC}"
    else
        echo -e "  ${YELLOW}⚠️  目标项目路径无效，跳过项目级文件${NC}"
    fi
fi

echo ""
echo -e "${GREEN}🎉 安装完成！${NC}"
echo "现在在任何 VS Code 工作空间中打开 Copilot Chat，就能使用："
echo -e "  ${CYAN}• /new-workflow${NC} — 启动工作流"
echo -e "  ${CYAN}• @orchestrator${NC} — 切换到编排器"
echo -e "  ${CYAN}• @executor${NC} — 切换到执行器"
