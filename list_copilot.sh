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

# List available models using copilot CLI
# The copilot CLI should handle authentication automatically
copilot --list-models 2>/dev/null || {
    echo "Error: Could not list models" >&2
    echo "Make sure you're logged in: copilot login" >&2
    exit 1
}
