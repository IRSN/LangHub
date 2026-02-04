#!/bin/bash
# list_claude.sh - List available Claude models for Claude CLI
# Usage: list_claude.sh

set -e

# Check if claude CLI is available
if ! command -v claude &> /dev/null; then
    echo "Error: claude command not found" >&2
    echo "Install from: https://docs.anthropic.com/claude/docs/claude-cli" >&2
    exit 1
fi

# Fetch model configuration from official Claude Code documentation
DOC_URL="https://code.claude.com/docs/en/model-config.md"
DOC_CONTENT=$(curl -s "$DOC_URL" 2>&1)

if [ $? -eq 0 ] && [ -n "$DOC_CONTENT" ]; then
    # Extract model aliases from the table
    # Look for lines like: | **`sonnet`** | description
    ALIASES=$(echo "$DOC_CONTENT" | grep -E '^\|.*\*\*`[^`]+`\*\*' | grep -oE '`[^`]+`' | tr -d '`' | sort -u)
    
    # Extract full model names (e.g., claude-sonnet-4-5-20250929)
    FULL_MODELS=$(echo "$DOC_CONTENT" | grep -oE 'claude-[a-z0-9]+-[0-9]+-[0-9]+-[0-9]{8}' | sort -u)
    
    # Also extract simplified forms like claude-sonnet-4-5
    SIMPLE_MODELS=$(echo "$DOC_CONTENT" | grep -oE 'claude-[a-z0-9]+-[0-9]+-[0-9]+' | grep -v '[0-9]{8}' | sort -u)
    
    # Combine all results
    ALL_MODELS=$(echo -e "$ALIASES\n$FULL_MODELS\n$SIMPLE_MODELS" | grep -v '^$' | sort -u)
    
    if [ -n "$ALL_MODELS" ]; then
        echo "$ALL_MODELS"
        exit 0
    fi
fi

# Fallback: try to extract from claude --help
HELP_OUTPUT=$(claude --help 2>&1)
HELP_MODELS=$(echo "$HELP_OUTPUT" | grep -oE "'(claude-[a-z0-9-]+|sonnet|opus|haiku)'" | tr -d "'" | sort -u)

if [ -n "$HELP_MODELS" ]; then
    echo "$HELP_MODELS"
    exit 0
fi

# Last resort: hardcoded list (updated as of Feb 2025)
echo "Warning: Using fallback model list" >&2
cat <<EOF
claude-3-7-sonnet-20250219
claude-3-7-sonnet
claude-3-haiku-20240307
claude-3-haiku
sonnet
opus
haiku
default
opusplan
EOF
