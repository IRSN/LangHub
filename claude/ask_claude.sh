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

# Build claude command
# Use --print for non-interactive mode, --dangerously-skip-permissions to avoid prompts
# Add current directory by default to avoid permission prompts
CURRENT_DIR="$(pwd)"
CMD=(claude --print --dangerously-skip-permissions --add-dir "$CURRENT_DIR")

# Add context using --add-dir option
if [ -n "$CONTEXT_PATH" ]; then
    if [ -d "$CONTEXT_PATH" ]; then
        # Get absolute path for directory
        abs_path="$(cd "$CONTEXT_PATH" && pwd)"
        # Only add if it's different from current directory
        if [ "$abs_path" != "$CURRENT_DIR" ]; then
            CMD+=(--add-dir "$abs_path")
        fi
        # Instruct Claude to read files in the directory
        FULL_PROMPT="The directory $abs_path contains relevant context files. Please read the files in this directory before proceeding with this task:

$PROMPT_TEXT"
    elif [ -f "$CONTEXT_PATH" ]; then
        # Get absolute path for file
        abs_path="$(cd "$(dirname "$CONTEXT_PATH")" && pwd)/$(basename "$CONTEXT_PATH")"
        # For files, add the parent directory and reference the file in the prompt
        parent_dir="$(dirname "$abs_path")"
        # Only add if parent directory is different from current directory
        if [ "$parent_dir" != "$CURRENT_DIR" ]; then
            CMD+=(--add-dir "$parent_dir")
        fi
        # Instruct Claude to read the specific file
        FULL_PROMPT="The file $abs_path contains relevant context. Please read it before proceeding with this task:

$PROMPT_TEXT"
    else
        echo "Warning: Context path '$CONTEXT_PATH' not found" >&2
        FULL_PROMPT="$PROMPT_TEXT"
    fi
else
    FULL_PROMPT="$PROMPT_TEXT"
fi

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
