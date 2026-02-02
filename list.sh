#!/bin/bash
# list.sh - List available models for a given engine
# Usage: list.sh <engine>
#   where <engine> can be: ollama[:custom_uri], claude, copilot

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check for required argument
if [ $# -lt 1 ]; then
    # No argument - list all available engines
    echo "Available engines:"
    echo ""

    # Try each engine and show results
    echo "=== Ollama ==="
    if "$SCRIPT_DIR/list_ollama.sh" 2>/dev/null; then
        :
    else
        echo "(not available)"
    fi
    echo ""

    echo "=== Claude ==="
    if "$SCRIPT_DIR/list_claude.sh" 2>/dev/null; then
        :
    else
        echo "(not available)"
    fi
    echo ""

    echo "=== Copilot ==="
    if "$SCRIPT_DIR/list_copilot.sh" 2>/dev/null; then
        :
    else
        echo "(not available)"
    fi

    exit 0
fi

ENGINE_SPEC="$1"

# Parse engine specification
if [[ "$ENGINE_SPEC" == ollama:* ]]; then
    ENGINE="ollama"
    CUSTOM_URI="${ENGINE_SPEC#ollama:}"
elif [[ "$ENGINE_SPEC" == "ollama" ]]; then
    ENGINE="ollama"
    CUSTOM_URI="http://localhost:11434"
elif [[ "$ENGINE_SPEC" == "claude" ]]; then
    ENGINE="claude"
elif [[ "$ENGINE_SPEC" == "copilot" ]]; then
    ENGINE="copilot"
else
    echo "Error: Unknown engine '$ENGINE_SPEC'" >&2
    echo "Supported engines: ollama[:custom_uri], claude, copilot" >&2
    exit 1
fi

# Call engine-specific list script
case "$ENGINE" in
    ollama)
        "$SCRIPT_DIR/list_ollama.sh" "$CUSTOM_URI"
        ;;
    claude)
        "$SCRIPT_DIR/list_claude.sh"
        ;;
    copilot)
        "$SCRIPT_DIR/list_copilot.sh"
        ;;
    *)
        echo "Error: Engine '$ENGINE' not implemented" >&2
        exit 1
        ;;
esac
