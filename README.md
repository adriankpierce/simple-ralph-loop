# Simple Ralph Loop

A lightweight implementation of an autonomous coding loop for Claude Code using the CLI. This is not a task management framework, a PRD system, or a project management tool. It's a minimal, copy-and-adapt setup for running Claude in a headless loop that picks up work, does it, commits, and repeats — meant for testing and iterating on the loop itself.

There are some example files included that show what works well, but the core idea is simple: give Claude a spec, a feature list, and a prompt, then let it run.

## How It Works

```
ralph-start.sh runs N iterations
  └─ each iteration launches `claude -p` with your prompt
       └─ claude reads the spec + feature list
            └─ picks a feature, implements it, tests it, commits
                 └─ session ends, next iteration starts fresh
```

## Setup (Prework)

Before running the loop, you need two things in your target project repo.

### 1. Create an App Spec

You need an `app_spec.txt` that fully describes what you're building — tech stack, features, database schema, UI layout, design system, etc. The more detailed the spec, the better Claude performs across sessions.

The best way to create one is conversationally. Start a chat with Claude and say something like:

> I want to build [thorough explanation of what you want — full brain dump, ideally 500+ words].
>
> Here is a guide to writing an app spec: [paste contents of `example-app-spec-guide.md`]
>
> Can you digest this and interview me with as many questions as you can think of to get more detail? Once we have sufficient detail, we can write the full spec.

Then go back and forth. Claude will ask about tech stack choices, UI details, edge cases, data models — things you wouldn't think to specify upfront. This interview process is what turns a vague idea into a spec detailed enough for autonomous execution. It might take one chat or a few. Once you're both satisfied, have Claude write the full spec following the guide's structure.

See [`example-app-spec-guide.md`](example-app-spec-guide.md) for the app spec writing guide, and [`example-app-spec.txt`](example-app-spec.txt) for a finished example (a full claude.ai clone with chat, artifacts, projects, and settings).

### 2. Break the Spec into a Feature List

Once you have a spec, you need to decompose it into a `feature_list.json` — a flat list of testable features with steps and a `passes` boolean. This becomes the single source of truth for what Claude works on each iteration.

This is done by running Claude Code (interactively or headless) with a prompt that tells it to read the app spec and generate the feature list. See [`example-create-feature-list-prompt.md`](example-create-feature-list-prompt.md) for the prompt — you'd place your `app_spec.txt` in the repo first, then run this as the first session.

See [`example-feature_list.json`](example-feature_list.json) for the resulting output. Each entry looks like:

```json
{
  "category": "functional",
  "description": "User can log in with valid credentials",
  "steps": [
    "Step 1: Navigate to /login",
    "Step 2: Enter registered email",
    "Step 3: Enter correct password",
    "Step 4: Click login button",
    "Step 5: Verify redirect to /projects page"
  ],
  "passes": false
}
```

Claude flips `passes` to `true` after implementing and verifying each feature.

## Running the Loop

### Files to Copy

Copy these into your target project repo:

| File | Purpose |
|------|---------|
| `ralph-start.sh` | Main loop script — runs N iterations of Claude |
| `ralph-stop.sh` | Graceful stop — kills running loop and Claude process |
| `ralph-prompt.md` | The prompt Claude receives at the start of each session |

### Usage

```bash
# Copy files to your project
cp ralph-start.sh ralph-stop.sh /path/to/your/project/
mkdir -p /path/to/your/project/.claude/prompts
cp ralph-prompt.md /path/to/your/project/.claude/prompts/ralph.md

# Run 10 iterations using the default prompt location
cd /path/to/your/project
./ralph-start.sh 10

# Or specify a custom prompt file
./ralph-start.sh 10 ./my-prompt.md
```

The loop checks for a `STOP` file before each iteration — you can create one to stop gracefully after the current session finishes:

```bash
touch STOP
```

Or kill everything immediately:

```bash
./ralph-stop.sh
```

### What the Prompt Does

[`ralph-prompt.md`](ralph-prompt.md) tells Claude to:

1. Orient itself (read spec, feature list, progress notes, git log)
2. Start any servers if needed
3. Run verification tests on previously passing features
4. Pick the highest-priority failing feature
5. Implement and test it (including browser automation)
6. Update `feature_list.json` and commit
7. Write progress notes for the next session

Each iteration gets a completely fresh context window — no memory carries over except what's on disk.

### Output

`ralph-start.sh` streams a filtered view of what Claude is doing:

```
===============================
  Iteration 1 / 10
===============================

  > Read [feature_list.json]
  > Bash [npm run dev]
  > Chrome:navigate
  > Edit [ChatInput.tsx]
  > Chrome:get_screenshot
  > Bash [git commit -m "Implement streaming chat responses"]

  Done. 47 turns, 312s

--- End of iteration 1 ---
```

## Considerations and Next Steps

Things I'm thinking about for improving the loop:

**Better task selection and scoping.** Claude currently tries to do too much in a single session. It should be more conservative — pick a smaller slice of work and finish it cleanly rather than attempting multiple features and leaving things half-done.

**Sandbox mode.** Running with `--dangerously-skip-permissions` works but isn't ideal. Exploring proper sandbox execution for safer autonomous runs.

**Better print output.** The stream-json parsing in `ralph-start.sh` is functional but basic. Could be improved with better formatting, color coding, progress indicators, or a summary at the end of each iteration showing what changed.

**Midway intervention.** Currently there's no way to communicate with Claude mid-session. Some ideas:
- Give it a "tool" or file it checks periodically, where you can leave messages like "start wrapping up" or "focus on X instead"
- Use Claude Code hooks to inject context at specific points
- Use `max_turns` or similar to cap session length, then use the remaining budget for cleanup

**External task management integration.** The `feature_list.json` approach is simple but doesn't scale well for human collaboration. Integrating with Linear, GitHub Issues, or similar would make it easier to add tasks, track progress, and intervene without touching JSON files directly.

## Acknowledgments

The example prompts and app spec structure are adapted from Anthropic's [autonomous-coding quickstart](https://github.com/anthropics/claude-quickstarts/tree/main/autonomous-coding). Worth checking out as a reference for how they approach the same problem.
