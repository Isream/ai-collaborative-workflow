# ============================================
# AI 协同开发工作流 - 一键安装脚本
# 将 Agent 和 Prompt 安装到用户级目录
# 支持 Windows / macOS / Linux
# ============================================

param(
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"

# 输出编码设为 UTF-8
$OutputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::new()

# 获取用户 prompts 目录
$VSCODE_PROMPTS = $env:VSCODE_USER_PROMPTS_FOLDER

if (-not $VSCODE_PROMPTS) {
    if ($IsWindows -or $env:OS -eq "Windows_NT") {
        $VSCODE_PROMPTS = "$env:APPDATA\Code\User\prompts"
    } elseif ($IsMacOS) {
        $VSCODE_PROMPTS = "$env:HOME/Library/Application Support/Code/User/prompts"
    } else {
        $VSCODE_PROMPTS = "$env:HOME/.config/Code/User/prompts"
    }
}

Write-Host "VS Code Prompts 目录: $VSCODE_PROMPTS"

# 源文件路径
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

if ($Uninstall) {
    Write-Host "`n[卸载] 正在移除..."
    $targets = @(
        "$VSCODE_PROMPTS\agents\orchestrator.agent.md",
        "$VSCODE_PROMPTS\agents\executor.agent.md",
        "$VSCODE_PROMPTS\prompts\new-workflow.prompt.md"
    )
    foreach ($t in $targets) {
        if (Test-Path $t) {
            Remove-Item $t -Force
            Write-Host "  已删除: $t"
        }
    }
    Write-Host "`n[完成] 卸载成功"
    exit 0
}

Write-Host "`n[安装] 正在安装 AI 协同工作流..."

# 创建目标目录
$agentDir = "$VSCODE_PROMPTS\agents"
$promptDir = "$VSCODE_PROMPTS\prompts"
New-Item -ItemType Directory -Force -Path $agentDir | Out-Null
New-Item -ItemType Directory -Force -Path $promptDir | Out-Null

# 复制 Agent 文件
$agentSource = "$SCRIPT_DIR\.github\agents"
Copy-Item "$agentSource\orchestrator.agent.md" -Destination $agentDir -Force
Write-Host "  [OK] orchestrator.agent.md"
Copy-Item "$agentSource\executor.agent.md" -Destination $agentDir -Force
Write-Host "  [OK] executor.agent.md"

# 复制 Prompt 文件
Copy-Item "$SCRIPT_DIR\.github\prompts\new-workflow.prompt.md" -Destination $promptDir -Force
Write-Host "  [OK] new-workflow.prompt.md"

# 复制项目级文件（如果指定了目标目录）
$targetProject = $args[0]
if ($targetProject) {
    $targetProject = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($targetProject)

    New-Item -ItemType Directory -Force -Path "$targetProject\.github" | Out-Null
    New-Item -ItemType Directory -Force -Path "$targetProject\.vscode" | Out-Null
    New-Item -ItemType Directory -Force -Path "$targetProject\workflow\completed" | Out-Null

    Copy-Item "$SCRIPT_DIR\.github\copilot-instructions.md" -Destination "$targetProject\.github\" -Force
    Copy-Item "$SCRIPT_DIR\.vscode\settings.json" -Destination "$targetProject\.vscode\" -Force
    Copy-Item "$SCRIPT_DIR\workflow\tasks.md" -Destination "$targetProject\workflow\" -Force
    Copy-Item "$SCRIPT_DIR\workflow\current-task.md" -Destination "$targetProject\workflow\" -Force

    Write-Host "  [OK] 项目文件已复制到: $targetProject"
}

Write-Host "`n[完成] 安装成功!"
Write-Host "现在在任何 VS Code 工作空间中打开 Copilot Chat, 就能使用:"
Write-Host "  - /new-workflow - 启动工作流"
Write-Host "  - @orchestrator - 切换到编排器"
Write-Host "  - @executor - 切换到执行器"
