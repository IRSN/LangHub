#!/bin/bash
# list_ollama.sh - List available Ollama models
# Usage: list_ollama.sh <uri>

set -e

URI="${1:-http://localhost:11434}"

# Determine if we should bypass proxy for localhost
# Check if URI is localhost/127.0.0.1 and not a custom URI
CURL_OPTS=()
if [[ "$URI" =~ ^https?://(localhost|127\.0\.0\.1)(:[0-9]+)?(/.*)?$ ]] && [ $# -eq 0 ]; then
    # Using default localhost URI - bypass proxy to avoid connection issues
    CURL_OPTS+=(--noproxy "*")
fi

# Query Ollama API
response=$(curl -s "${CURL_OPTS[@]}" "$URI/api/tags" 2>&1)

# Check for errors
if [ $? -ne 0 ]; then
    echo "Error: Failed to connect to Ollama at $URI" >&2
    echo "Make sure Ollama is running: ollama serve" >&2
    exit 1
fi

# Parse JSON and extract model names
if command -v jq &> /dev/null; then
    # Use jq if available
    echo "$response" | jq -r '.models[]? | .name'
else
    # Fallback to basic parsing
    echo "$response" | grep -o '"name":"[^"]*"' | sed 's/"name":"//g' | sed 's/"//g'
fi

# Check if we got any models
if [ -z "$(echo "$response" | grep -o '"name"')" ]; then
    echo "No models found. Install models using: ollama pull <model-name>" >&2
    exit 1
fi
