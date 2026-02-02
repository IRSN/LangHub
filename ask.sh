#!/bin/bash
# ask.sh - Prompt a model with given text and context
# Usage: ask.sh <engine> <model-id> <prompt-text> [--context <context-path>] [opt-model-parameters]

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Discover available engines
discover_engines() {
    find "$SCRIPT_DIR" -mindepth 1 -maxdepth 1 -type d -name '[!.]*' ! -name 'test' ! -name 'completion' -printf '%f\n' | sort
}

# Check for required arguments
if [ $# -lt 3 ]; then
    engines=$(discover_engines | tr '\n' ', ' | sed 's/, $//')
    echo "Usage: $0 <engine> <model-id> <prompt-text> [--context <context-path>] [opt-model-parameters]" >&2
    echo "  Available engines: $engines" >&2
    echo "  (use engine:custom_uri for custom URIs, e.g., ollama:http://server:11434)" >&2
    exit 1
fi

ENGINE_SPEC="$1"
MODEL_ID="$2"
PROMPT_TEXT="$3"
shift 3

# Parse engine specification
if [[ "$ENGINE_SPEC" == *:* ]]; then
    # Custom URI syntax: engine:uri
    ENGINE="${ENGINE_SPEC%%:*}"
    CUSTOM_URI="${ENGINE_SPEC#*:}"
elif [[ "$ENGINE_SPEC" == "print" ]]; then
    ENGINE="print"
else
    ENGINE="$ENGINE_SPEC"
    CUSTOM_URI=""
fi

# Special handling for ollama default URI
if [[ "$ENGINE" == "ollama" ]] && [[ -z "$CUSTOM_URI" ]]; then
    CUSTOM_URI="http://localhost:11434"
fi

# Validate engine exists (unless it's the special "print" engine)
if [[ "$ENGINE" != "print" ]] && [[ ! -d "$SCRIPT_DIR/$ENGINE" ]]; then
    echo "Error: Unknown engine '$ENGINE_SPEC'" >&2
    engines=$(discover_engines | tr '\n' ', ' | sed 's/, *$//')
    echo "Available engines: $engines, print" >&2
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
if [[ "$ENGINE" == "print" ]]; then
    # Simple print engine - just echoes the prompt text
    echo "$PROMPT_TEXT"
elif [[ -f "$SCRIPT_DIR/$ENGINE/ask_${ENGINE}.sh" ]]; then
    # Call engine-specific script with custom URI if provided
    if [[ -n "$CUSTOM_URI" ]]; then
        "$SCRIPT_DIR/$ENGINE/ask_${ENGINE}.sh" "$CUSTOM_URI" "$MODEL_ID" "$PROMPT_TEXT" "$CONTEXT_PATH" "${EXTRA_ARGS[@]}"
    else
        "$SCRIPT_DIR/$ENGINE/ask_${ENGINE}.sh" "$MODEL_ID" "$PROMPT_TEXT" "$CONTEXT_PATH" "${EXTRA_ARGS[@]}"
    fi
else
    echo "Error: Engine '$ENGINE' does not have an ask script" >&2
    exit 1
fi
