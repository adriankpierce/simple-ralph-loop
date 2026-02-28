#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <iterations> [prompt-file]"
  exit 1
fi

PROMPT_FILE="${2:-.claude/prompts/ralph.md}"
if [ ! -f "$PROMPT_FILE" ]; then
  echo "Prompt file not found: $PROMPT_FILE"
  exit 1
fi

for ((i=1; i<=$1; i++)); do
  if [ -f STOP ]; then
    echo "STOP file detected. Exiting after $((i-1)) iterations."
    rm -f STOP
    exit 0
  fi

  echo ""
  echo "==============================="
  echo "  Iteration $i / $1"
  echo "==============================="
  echo ""

  claude -p "$(cat "$PROMPT_FILE")" --output-format stream-json --verbose --dangerously-skip-permissions --chrome 2>&1 | while IFS= read -r line; do
    type=$(echo "$line" | jq -r '.type' 2>/dev/null) || continue

    case "$type" in
      assistant)
        echo "$line" | jq -r '
          .message.content[]? |
          if .type == "text" then "  " + .text
          elif .type == "tool_use" then
            .name as $name |
            if $name == "Read" then "  \u001b[33m> Read [\u001b[0m" + (.input.file_path // "" | split("/") | last) + "\u001b[33m]\u001b[0m"
            elif $name == "Edit" then "  \u001b[33m> Edit [\u001b[0m" + (.input.file_path // "" | split("/") | last) + "\u001b[33m]\u001b[0m"
            elif $name == "Write" then "  \u001b[33m> Write [\u001b[0m" + (.input.file_path // "" | split("/") | last) + "\u001b[33m]\u001b[0m"
            elif $name == "Bash" then "  \u001b[33m> Bash [\u001b[0m" + ((.input.command // "" )[:80]) + "\u001b[33m]\u001b[0m"
            elif $name == "Grep" then "  \u001b[33m> Grep [\u001b[0m" + (.input.pattern // "") + "\u001b[33m]\u001b[0m"
            elif $name == "Glob" then "  \u001b[33m> Glob [\u001b[0m" + (.input.pattern // "") + "\u001b[33m]\u001b[0m"
            elif ($name | startswith("mcp__claude-in-chrome__")) then "  \u001b[33m> Chrome:\u001b[0m" + ($name | ltrimstr("mcp__claude-in-chrome__"))
            else "  \u001b[33m> " + $name + "\u001b[0m"
            end
          else empty end
        ' 2>/dev/null
        ;;
      result)
        turns=$(echo "$line" | jq -r '.num_turns // 0' 2>/dev/null)
        duration=$(echo "$line" | jq -r '(.duration_ms // 0) / 1000 | floor' 2>/dev/null)
        echo ""
        echo -e "  \033[32mDone. ${turns} turns, ${duration}s\033[0m"
        ;;
    esac
  done

  echo ""
  echo "--- End of iteration $i ---"
done

echo "Reached max iterations ($1)"
