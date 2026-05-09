---
description: "Start a new AI collaborative workflow: describe your project goal and the Orchestrator will decompose it into tasks"
agent: "agent"
argument-hint: "Describe what you want to build..."
---
🚀 **Start a new development workflow using the AI Collaborative System.**

## Instructions

The user wants to start a new project or feature. Your job as the Orchestrator is to:

1. Read `workflow/tasks.md` to check if there's an existing workflow
2. Ask the user clarifying questions if the goal is ambiguous
3. Break down the goal into well-defined sub-tasks
4. Populate `workflow/tasks.md` with the task breakdown
5. Assign the first task to `workflow/current-task.md`
6. Tell the user which task is ready and instruct them to switch to the **Executor (DeepSeek)** agent

## Important

- Keep tasks small and independently verifiable
- Each task should have clear acceptance criteria
- Prioritize tasks logically (dependencies first)
- Use the project's existing structure and conventions

## Project Goal

<!-- The user will describe their goal here when invoking this prompt -->
