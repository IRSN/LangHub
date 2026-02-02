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

# Fetch available models from Anthropic docs
# Parse the models overview page to extract model IDs
models_html=$(curl -s "https://platform.claude.com/docs/en/about-claude/models/overview" 2>&1)

if [ $? -eq 0 ] && [ -n "$models_html" ]; then
    # Extract model IDs from the page
    # Look for patterns like claude-X-Y-YYYYMMDD or claude-X-Y
    models=$(echo "$models_html" | grep -oE 'claude-[a-z0-9-]+' | sort -u)

    if [ -n "$models" ]; then
        echo "$models"
        # Also add common aliases
        echo "sonnet"
        echo "opus"
        echo "haiku"
    else
        # Fallback to known models if parsing fails
        echo "Warning: Could not parse models from docs, using fallback list" >&2
        cat <<EOF
claude-sonnet-4-5-20250929
claude-haiku-4-5-20251001
claude-opus-4-5-20251101
claude-sonnet-4-5
claude-haiku-4-5
claude-opus-4-5
sonnet
opus
haiku
EOF
    fi
else
    # Network error or other issue - use fallback
    echo "Warning: Could not fetch models from docs, using fallback list" >&2
    cat <<EOF
claude-sonnet-4-5-20250929
claude-haiku-4-5-20251001
claude-opus-4-5-20251101
claude-sonnet-4-5
claude-haiku-4-5
claude-opus-4-5
sonnet
opus
haiku
EOF
fi
