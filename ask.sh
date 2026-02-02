#!/bin/bash
# ask.sh - Prompt a model with given text and context
# Usage: ask.sh <engine> <model-id> <prompt-text> [--context <context-path>] [opt-model-parameters]

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check for required arguments
if [ $# -lt 3 ]; then
    echo "Usage: $0 <engine> <model-id> <prompt-text> [--context <context-path>] [opt-model-parameters]" >&2
    echo "  Engines: ollama[:custom_uri], claude, copilot" >&2
    exit 1
fi

ENGINE_SPEC="$1"
MODEL_ID="$2"
PROMPT_TEXT="$3"
shift 3

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
elif [[ "$ENGINE_SPEC" == "print" ]]; then
    ENGINE="print"
else
    echo "Error: Unknown engine '$ENGINE_SPEC'" >&2
    echo "Supported engines: ollama[:custom_uri], claude, copilot, print" >&2
    exit 1
fi

# Parse optional arguments
CONTEXT_PATH=""
EXTRA_ARGS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --context)
            CONTEXT_PATH="$2"
            shift 2
            ;;
        *)
            EXTRA_ARGS+=("$1")
            shift
            ;;
    esac
done

# Call engine-specific ask script
case "$ENGINE" in
    ollama)
        "$SCRIPT_DIR/ask_ollama.sh" "$CUSTOM_URI" "$MODEL_ID" "$PROMPT_TEXT" "$CONTEXT_PATH" "${EXTRA_ARGS[@]}"
        ;;
    claude)
        "$SCRIPT_DIR/ask_claude.sh" "$MODEL_ID" "$PROMPT_TEXT" "$CONTEXT_PATH" "${EXTRA_ARGS[@]}"
        ;;
    copilot)
        "$SCRIPT_DIR/ask_copilot.sh" "$MODEL_ID" "$PROMPT_TEXT" "$CONTEXT_PATH" "${EXTRA_ARGS[@]}"
        ;;
    print)
        # Simple print engine - just echoes the prompt text
        echo "$PROMPT_TEXT"
        ;;
    *)
        echo "Error: Engine '$ENGINE' not implemented" >&2
        exit 1
        ;;
esac
