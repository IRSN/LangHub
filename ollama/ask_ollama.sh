#!/bin/bash
# ask_ollama.sh - Prompt an Ollama model
# Usage: ask_ollama.sh <uri> <model-id> <prompt-text> <context-path> [extra-args...]

set -e

URI="$1"
MODEL_ID="$2"
PROMPT_TEXT="$3"
CONTEXT_PATH="$4"
shift 4

# Determine if we should bypass proxy for localhost
# Check if URI is localhost/127.0.0.1
CURL_OPTS=()
if [[ "$URI" =~ ^https?://(localhost|127\.0\.0\.1)(:[0-9]+)?(/.*)?$ ]]; then
    # Using localhost URI - bypass proxy to avoid connection issues
    CURL_OPTS+=(--noproxy "*")
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

# Create JSON payload
# Escape special characters in the prompt
ESCAPED_PROMPT=$(echo "$FULL_PROMPT" | jq -Rs .)
PAYLOAD=$(cat <<EOF
{
  "model": "$MODEL_ID",
  "prompt": $ESCAPED_PROMPT,
  "stream": false
}
EOF
)

# Make API request
response=$(curl -s "${CURL_OPTS[@]}" -X POST "$URI/api/generate" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD" 2>&1)

# Check for errors
if [ $? -ne 0 ]; then
    echo "Error: Failed to connect to Ollama at $URI" >&2
    exit 1
fi

# Extract response text
if command -v jq &> /dev/null; then
    result=$(echo "$response" | jq -r '.response // .error // "Error: Unknown response format"')
else
    # Fallback parsing
    result=$(echo "$response" | grep -o '"response":"[^"]*"' | sed 's/"response":"//g' | sed 's/"//g' | sed 's/\\n/\n/g')
fi

# Check for errors in response
if echo "$response" | grep -q '"error"'; then
    echo "Error from Ollama: $result" >&2
    exit 1
fi

# Output result
echo "$result"
