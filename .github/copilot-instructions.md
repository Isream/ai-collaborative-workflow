# AI Collaborative Development Workflow

This workspace uses a **two-agent collaborative workflow** for software development:

| Role | AI Model | VS Code Tool | Responsibility |
|------|----------|-------------|----------------|
| 🎯 **Orchestrator** | Codex | Codex Extension / Copilot Agent | Task decomposition, assignment, validation |
| 🔨 **Executor** | DeepSeek V4 Pro | GitHub Copilot Chat | Task implementation |

## 📁 Key Files

| File | Purpose |
|------|---------|
| `workflow/tasks.md` | Master task board |
| `workflow/current-task.md` | Active task (bridge between agents) |
| `workflow/completed/` | Archive of done tasks |
| `.github/agents/orchestrator.agent.md` | Orchestrator agent definition |
| `.github/agents/executor.agent.md` | Executor agent definition |

## 🔄 How to Use

1. Open Copilot Chat, type `/new-workflow` and describe your project
2. The Orchestrator will decompose it into tasks
3. Switch to the Executor agent and say "execute the current task"
4. After execution, switch back to Orchestrator for validation
5. Repeat steps 3-4 until all tasks complete

## 🏷️ Agent Invocation

- In Copilot Chat, use the agent picker dropdown or type `@orchestrator` / `@executor`
- You can also use `/new-workflow` to start fresh
