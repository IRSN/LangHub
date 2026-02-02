#!/bin/bash
# list_copilot.sh - List available Copilot CLI models
# Usage: list_copilot.sh

set -e

# Check if copilot CLI is available
if ! command -v copilot &> /dev/null; then
    echo "Error: copilot command not found" >&2
    echo "Install from: https://github.com/features/copilot" >&2
    exit 1
fi

# Note: GitHub API doesn't currently expose a copilot models endpoint
# If gh CLI and jq are available and authenticated, we could query in the future
# For now, we parse the copilot --help output which is reliable and fast

# Get available models from copilot help
# Extract model choices from the help output
MODELS=$(copilot --help 2>&1 | grep -A 2 "model <model>" | grep '"' | sed 's/^[^"]*"//; s/"[^"]*$//; s/", "/\n/g' | sort -u)

if [ -z "$MODELS" ]; then
    echo "Error: Could not detect available models" >&2
    exit 1
fi

# Option 1: Quick listing without verification (fast)
# Just output the models from help
echo "$MODELS"

# Option 2: Verify each model (slow, commented out by default)
# Uncomment below to verify models actually work
# verified_models=""
# while IFS= read -r model; do
#     [ -z "$model" ] && continue
#     if echo "test" | copilot --model "$model" --prompt "say ok" > /dev/null 2>&1; then
#         verified_models="${verified_models}${model}\n"
#     fi
# done <<< "$MODELS"
# echo -e "$verified_models" | grep -v '^$'
