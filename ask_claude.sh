#!/bin/bash
# ask_claude.sh - Prompt a Claude model via Claude CLI
# Usage: ask_claude.sh <model-id> <prompt-text> <context-path> [extra-args...]

set -e

MODEL_ID="$1"
PROMPT_TEXT="$2"
CONTEXT_PATH="$3"
shift 3

# Check if claude CLI is available
if ! command -v claude &> /dev/null; then
    echo "Error: claude command not found" >&2
    echo "Install from: https://docs.anthropic.com/claude/docs/claude-cli" >&2
    exit 1
fi

# Read context files if specified
CONTEXT=""
if [ -n "$CONTEXT_PATH" ]; then
    if [ -d "$CONTEXT_PATH" ]; then
        # Read all markdown, text, and code files in directory
        for file in "$CONTEXT_PATH"/*.md "$CONTEXT_PATH"/*.txt "$CONTEXT_PATH"/*.rst; do
            if [ -f "$file" ]; then
                CONTEXT+="$(cat "$file")"
                CONTEXT+=$'\n\n'
            fi
        done
    elif [ -f "$CONTEXT_PATH" ]; then
        # Read single file
        CONTEXT="$(cat "$CONTEXT_PATH")"
        CONTEXT+=$'\n\n'
    else
        echo "Warning: Context path '$CONTEXT_PATH' not found" >&2
    fi
fi

# Combine context and prompt
FULL_PROMPT="${CONTEXT}${PROMPT_TEXT}"

# Build claude command
# Use --print for non-interactive mode, --dangerously-skip-permissions to avoid prompts
CMD=(claude --print --dangerously-skip-permissions)

# Add model selection if specified
if [ -n "$MODEL_ID" ]; then
    CMD+=(--model "$MODEL_ID")
fi

# Add extra arguments
CMD+=("$@")

# Add the prompt
CMD+=("$FULL_PROMPT")

# Execute claude command
# Redirect stdin to /dev/null to prevent consuming parent script's stdin
# Do NOT merge stderr into stdout - let stderr pass through for logging
"${CMD[@]}" </dev/null

# Check exit code
if [ $? -ne 0 ]; then
    echo "Error: claude command failed" >&2
    exit 1
fi
