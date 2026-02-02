#!/bin/bash
# list.sh - List available models for a given engine
# Usage: list.sh <engine>
#   where <engine> can be: ollama[:custom_uri], claude, copilot

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Discover available engines
discover_engines() {
    find "$SCRIPT_DIR" -mindepth 1 -maxdepth 1 -type d -name '[!.]*' ! -name 'test' ! -name 'completion' -printf '%f\n' | sort
}

# Check for required argument
if [ $# -lt 1 ]; then
    # No argument - list all available engines
    echo "Available engines:"
    echo ""

    # Try each discovered engine and show results
    while IFS= read -r engine; do
        if [[ -f "$SCRIPT_DIR/$engine/list_${engine}.sh" ]]; then
            echo "=== ${engine^} ==="
            if "$SCRIPT_DIR/$engine/list_${engine}.sh" 2>/dev/null; then
                :
            else
                echo "(not available)"
            fi
            echo ""
        fi
    done < <(discover_engines)

    exit 0
fi

ENGINE_SPEC="$1"

# Parse engine specification
if [[ "$ENGINE_SPEC" == *:* ]]; then
    # Custom URI syntax: engine:uri
    ENGINE="${ENGINE_SPEC%%:*}"
    CUSTOM_URI="${ENGINE_SPEC#*:}"
else
    ENGINE="$ENGINE_SPEC"
    CUSTOM_URI=""
fi

# Special handling for ollama default URI
if [[ "$ENGINE" == "ollama" ]] && [[ -z "$CUSTOM_URI" ]]; then
    CUSTOM_URI="http://localhost:11434"
fi

# Validate engine exists
if [[ ! -d "$SCRIPT_DIR/$ENGINE" ]]; then
    echo "Error: Unknown engine '$ENGINE_SPEC'" >&2
    engines=$(discover_engines | tr '\n' ', ' | sed 's/, $//')
    echo "Available engines: $engines" >&2
    exit 1
fi

# Call engine-specific list script
if [[ -f "$SCRIPT_DIR/$ENGINE/list_${ENGINE}.sh" ]]; then
    if [[ -n "$CUSTOM_URI" ]]; then
        "$SCRIPT_DIR/$ENGINE/list_${ENGINE}.sh" "$CUSTOM_URI"
    else
        "$SCRIPT_DIR/$ENGINE/list_${ENGINE}.sh"
    fi
else
    echo "Error: Engine '$ENGINE' does not have a list script" >&2
    exit 1
fi
