#!/bin/bash
# ask_copilot.sh - Prompt a model via Copilot CLI
# Usage: ask_copilot.sh <model-id> <prompt-text> <context-path> [extra-args...]

set -e

MODEL_ID="$1"
PROMPT_TEXT="$2"
CONTEXT_PATH="$3"
shift 3

# Check if copilot CLI is available
if ! command -v copilot &> /dev/null; then
    echo "Error: copilot command not found" >&2
    echo "Install from: https://github.com/features/copilot" >&2
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

# Build copilot command
# Use -p/--prompt for non-interactive mode, --allow-all-tools to avoid prompts
CMD=(copilot --prompt "$FULL_PROMPT" --allow-all-tools)

# Add model selection if specified
if [ -n "$MODEL_ID" ]; then
    CMD+=(--model "$MODEL_ID")
fi

# Add extra arguments
CMD+=("$@")

# Execute copilot command and filter output
# Redirect stdin to /dev/null to prevent consuming parent script's stdin
# Filter out execution log lines (lines starting with ✓, ✗, $, ↪, or other tool output markers)
TEMP_OUTPUT=$(mktemp)
trap "rm -f $TEMP_OUTPUT" EXIT

if ! "${CMD[@]}" </dev/null > "$TEMP_OUTPUT" 2>&1; then
    # On error, show the full output to stderr
    cat "$TEMP_OUTPUT" >&2
    echo "Error: copilot command failed" >&2
    exit 1
fi

# Filter the output to remove execution log lines
# Keep only lines that are actual content (not tool execution logs)
# Strategy: Remove copilot's execution trace, keep only the final output
#
# The copilot CLI with --allow-all-tools outputs execution traces interspersed with content.
# We need to identify and remove:
# - Tool execution status lines (✓, ✗)
# - Command output markers ($, ↪)
# - Meta-commentary ("Let me...", "I'll...", "Now...", "Based on...")
# - Partial command outputs (lines with just fragments)

# First pass: remove obvious execution log patterns and API usage stats
sed -E \
    -e '/^[[:space:]]*(✓|✗)/d' \
    -e '/^[[:space:]]*\$/d' \
    -e '/^[[:space:]]*↪/d' \
    -e '/^[[:space:]]*Let me /d' \
    -e '/^[[:space:]]*I'"'"'ll /d' \
    -e '/^[[:space:]]*Now /d' \
    -e '/^[[:space:]]*First,? /d' \
    -e '/^[[:space:]]*Perfect!/d' \
    -e '/^[[:space:]]*Great!/d' \
    -e '/^[[:space:]]*<command/d' \
    -e '/^[[:space:]]*Based on .* (documentation|examples|analysis|review)/d' \
    -e '/^[[:space:]]*[Hh]ere is (a|an|the)/d' \
    -e '/^[[:space:]]*Find .* (files?|directories|examples)/d' \
    -e '/^[[:space:]]*View .* (files?|sample|examples)/d' \
    -e '/^[[:space:]]*Read .* (files?|documentation)/d' \
    -e '/^[[:space:]]*Check .* (files?|for)/d' \
    -e '/^[[:space:]]*head -[0-9]/d' \
    -e '/^[[:space:]]*===";/d' \
    -e '/.* to (generate|create) (a|an|the) .* markdown/d' \
    -e '/.* enough information to/d' \
    -e '/^Total usage est:/d' \
    -e '/^Total duration/d' \
    -e '/^Total code changes:/d' \
    -e '/^Usage by model:/d' \
    -e '/^[[:space:]]+claude-/d' \
    -e '/^[[:space:]]+gpt-/d' \
    "$TEMP_OUTPUT" | \
    # Remove leading empty lines
    sed -e '/./,$!d' | \
    # Remove "---" separator if it appears at the start
    sed -e '1{/^---$/d;}'
