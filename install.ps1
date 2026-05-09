# ============================================
# AI 协同开发工作流 - 一键安装脚本
# 默认安装到当前工作空间（推荐）
# 使用 -ToUser 参数可额外安装到用户级目录
# ============================================

param(
    [switch]$Uninstall,
    [switch]$ToUser
)

$ErrorActionPreference = "Stop"
$OutputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::new()

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

if ($Uninstall) {
    Write-Host "[卸载] 正在移除工作空间级文件..."
    $workspace = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(".")
    @(
        "$workspace\.github\agents\orchestrator.agent.md",
        "$workspace\.github\agents\executor.agent.md",
        "$workspace\.github\prompts\new-workflow.prompt.md"
    ) | ForEach-Object {
        if (Test-Path $_) { Remove-Item $_ -Force; Write-Host "  已删除: $_" }
    }

    Write-Host "[卸载] 正在移除用户级文件..."
    $up = "$env:APPDATA\Code\User\prompts"
    @(
        "$up\orchestrator.agent.md",
        "$up\executor.agent.md",
        "$up\new-workflow.prompt.md"
    ) | ForEach-Object {
        if (Test-Path $_) { Remove-Item $_ -Force; Write-Host "  已删除: $_" }
    }
    Remove-Item "$up\agents" -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item "$up\prompts" -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "[完成] 卸载成功"
    exit 0
}

# 确定目标项目（默认当前目录）
$targetProject = $args[0]
if (-not $targetProject) { $targetProject = "." }
$targetProject = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($targetProject)

Write-Host "[安装] 目标项目: $targetProject"

# ---- 1. 工作空间级安装（通用，推荐） ----
New-Item -ItemType Directory -Force -Path "$targetProject\.github\agents"  | Out-Null
New-Item -ItemType Directory -Force -Path "$targetProject\.github\prompts" | Out-Null
New-Item -ItemType Directory -Force -Path "$targetProject\.vscode"         | Out-Null
New-Item -ItemType Directory -Force -Path "$targetProject\workflow\completed" | Out-Null

Copy-Item "$SCRIPT_DIR\.github\agents\orchestrator.agent.md"        "$targetProject\.github\agents\"   -Force
Copy-Item "$SCRIPT_DIR\.github\agents\executor.agent.md"            "$targetProject\.github\agents\"   -Force
Copy-Item "$SCRIPT_DIR\.github\prompts\new-workflow.prompt.md"     "$targetProject\.github\prompts\"  -Force
Copy-Item "$SCRIPT_DIR\.github\copilot-instructions.md"             "$targetProject\.github\"          -Force
Copy-Item "$SCRIPT_DIR\.vscode\settings.json"                       "$targetProject\.vscode\"          -Force
Copy-Item "$SCRIPT_DIR\workflow\tasks.md"                           "$targetProject\workflow\"         -Force
Copy-Item "$SCRIPT_DIR\workflow\current-task.md"                    "$targetProject\workflow\"         -Force
Copy-Item "$SCRIPT_DIR\README.md"                                   "$targetProject\"                  -Force

Write-Host "  [OK] 工作空间级安装完成"

# ---- 2. 用户级安装（可选，不一定生效） ----
if ($ToUser) {
    $up = "$env:APPDATA\Code\User\prompts"
    Write-Host "[安装] 额外安装到用户级: $up"
    New-Item -ItemType Directory -Force -Path $up | Out-Null
    Copy-Item "$SCRIPT_DIR\.github\agents\orchestrator.agent.md"   $up -Force
    Copy-Item "$SCRIPT_DIR\.github\agents\executor.agent.md"       $up -Force
    Copy-Item "$SCRIPT_DIR\.github\prompts\new-workflow.prompt.md" $up -Force
    Write-Host "  [OK] 用户级安装完成"
}

Write-Host "`n[完成] 安装成功!"
Write-Host "重启 VS Code, 打开此工作空间, 即可使用:"
Write-Host "  - /new-workflow - 启动工作流"
Write-Host "  - @orchestrator - 切换到编排器"
Write-Host "  - @executor - 切换到执行器"
Write-Host "`n提示: 安装到其他项目: .\install.ps1 D:\other-project"
