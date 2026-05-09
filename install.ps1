# ============================================
# AI 协同开发工作流 — 一键安装脚本
# 将 Agent 和 Prompt 安装到用户级目录
# 支持 Windows / macOS / Linux
# ============================================

param(
    [switch]$Uninstall  # 使用 -Uninstall 参数来卸载
)

$ErrorActionPreference = "Stop"

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

Write-Host "VS Code Prompts 目录: $VSCODE_PROMPTS" -ForegroundColor Cyan

# 源文件路径（脚本所在目录为项目根目录）
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

if ($Uninstall) {
    Write-Host "`n🗑️  正在卸载..." -ForegroundColor Yellow
    $targets = @(
        "$VSCODE_PROMPTS\agents\orchestrator.agent.md",
        "$VSCODE_PROMPTS\agents\executor.agent.md",
        "$VSCODE_PROMPTS\prompts\new-workflow.prompt.md"
    )
    foreach ($t in $targets) {
        if (Test-Path $t) {
            Remove-Item $t -Force
            Write-Host "  已删除: $t" -ForegroundColor Red
        }
    }
    Write-Host "`n✅ 卸载完成" -ForegroundColor Green
    exit 0
}

Write-Host "`n📦 正在安装 AI 协同工作流..." -ForegroundColor Green

# 创建目标目录
$agentDir = "$VSCODE_PROMPTS\agents"
$promptDir = "$VSCODE_PROMPTS\prompts"
New-Item -ItemType Directory -Force -Path $agentDir | Out-Null
New-Item -ItemType Directory -Force -Path $promptDir | Out-Null

# 复制 Agent 文件
$agentSource = "$SCRIPT_DIR\.github\agents"
Copy-Item "$agentSource\orchestrator.agent.md" -Destination $agentDir -Force
Write-Host "  ✅ orchestrator.agent.md" -ForegroundColor Green
Copy-Item "$agentSource\executor.agent.md" -Destination $agentDir -Force
Write-Host "  ✅ executor.agent.md" -ForegroundColor Green

# 复制 Prompt 文件
Copy-Item "$SCRIPT_DIR\.github\prompts\new-workflow.prompt.md" -Destination $promptDir -Force
Write-Host "  ✅ new-workflow.prompt.md" -ForegroundColor Green

# 复制项目级指令到目标项目（如果指定了目标目录）
$targetProject = $args[0]
if ($targetProject) {
    # 将相对路径转为绝对路径（目录不存在也能正确解析）
    $targetProject = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($targetProject)
    
    # 创建目标子目录
    New-Item -ItemType Directory -Force -Path "$targetProject\.github" | Out-Null
    New-Item -ItemType Directory -Force -Path "$targetProject\.vscode" | Out-Null
    New-Item -ItemType Directory -Force -Path "$targetProject\workflow\completed" | Out-Null

    Copy-Item "$SCRIPT_DIR\.github\copilot-instructions.md" -Destination "$targetProject\.github\" -Force
    Copy-Item "$SCRIPT_DIR\.vscode\settings.json" -Destination "$targetProject\.vscode\" -Force
    
    Copy-Item "$SCRIPT_DIR\workflow\tasks.md" -Destination "$targetProject\workflow\" -Force
    Copy-Item "$SCRIPT_DIR\workflow\current-task.md" -Destination "$targetProject\workflow\" -Force
    
    Write-Host "  ✅ 项目文件已复制到: $targetProject" -ForegroundColor Green
}

Write-Host "`n🎉 安装完成！" -ForegroundColor Green
Write-Host "现在在任何 VS Code 工作空间中打开 Copilot Chat，就能使用："
Write-Host "  • /new-workflow — 启动工作流" -ForegroundColor Cyan
Write-Host "  • @orchestrator — 切换到编排器" -ForegroundColor Cyan
Write-Host "  • @executor — 切换到执行器" -ForegroundColor Cyan
