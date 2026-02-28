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
            if $name == "Read" then "  > Read [" + (.input.file_path // "" | split("/") | last) + "]"
            elif $name == "Edit" then "  > Edit [" + (.input.file_path // "" | split("/") | last) + "]"
            elif $name == "Write" then "  > Write [" + (.input.file_path // "" | split("/") | last) + "]"
            elif $name == "Bash" then "  > Bash [" + ((.input.command // "" )[:80]) + "]"
            elif $name == "Grep" then "  > Grep [" + (.input.pattern // "") + "]"
            elif $name == "Glob" then "  > Glob [" + (.input.pattern // "") + "]"
            elif ($name | startswith("mcp__claude-in-chrome__")) then "  > Chrome:" + ($name | ltrimstr("mcp__claude-in-chrome__"))
            else "  > " + $name
            end
          else empty end
        ' 2>/dev/null
        ;;
      result)
        turns=$(echo "$line" | jq -r '.num_turns // 0' 2>/dev/null)
        duration=$(echo "$line" | jq -r '(.duration_ms // 0) / 1000 | floor' 2>/dev/null)
        echo ""
        echo "  Done. ${turns} turns, ${duration}s"
        ;;
    esac
  done

  echo ""
  echo "--- End of iteration $i ---"
done

echo "Reached max iterations ($1)"
