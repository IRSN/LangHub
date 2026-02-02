#!/bin/bash
# lmd2md.sh - Process .lmd files and call language models, outputting markdown
# Usage: lmd2md.sh <input.lmd> > output.md
#
# Features:
# - Parses .lmd files containing LLM prompt snippets
# - Supports variable substitution in snippets: $context
# - Processes snippets through various LLM engines (ollama, claude, copilot, print)
# - Outputs markdown to stdout (use shell redirection > to save)
# - Optionally logs model messages to files when log= parameter is specified
#
# LMD snippet format:
# ```<engine>, model=<model-id>, context=<path>, log=<logfile>
# Your prompt here. Use $context variable which will be substituted
# with the actual context path specified in the header.
# ```
#
# Example:
# ```copilot, model=claude-sonnet-4.5, context=lib/, log=summary.log
# Summarize the documentation in $context
# ```
#
# Engines:
# - ollama[:custom_uri] : Local Ollama models
# - claude : Anthropic Claude via API
# - copilot : GitHub Copilot
# - print : Simple echo (no model required, useful for reference content)

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default: quiet mode (hide processing logs unless log= is specified)
QUIET_MODE=true

# Check for required argument
if [ $# -lt 1 ]; then
    echo "Usage: $0 <input.lmd> [--verbose] > output.md" >&2
    echo "  Processes a .lmd file and outputs markdown to stdout" >&2
    echo "  --verbose : Show processing logs to stderr (default: quiet)" >&2
    echo "  Note: Processing logs are always written to log files when log= is specified" >&2
    exit 1
fi

INPUT_FILE="$1"
shift

# Parse optional arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --verbose|-v)
            QUIET_MODE=false
            shift
            ;;
        --quiet|-q)
            # Legacy support - quiet is now the default
            QUIET_MODE=true
            shift
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

# Check input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found" >&2
    exit 1
fi

if [ "$QUIET_MODE" = false ]; then
    echo "Processing $INPUT_FILE..." >&2
fi

# Temporary files for processing
TEMP_FILE=$(mktemp)
MARKDOWN_OUTPUT=$(mktemp)
trap "rm -f $TEMP_FILE $MARKDOWN_OUTPUT" EXIT

# State variables
IN_CODE_BLOCK=false
ENGINE=""
MODEL_ID=""
CONTEXT_PATH=""
LOG_FILE=""
PROMPT_TEXT=""
BLOCK_COUNT=0

# Function to substitute variables in text
substitute_vars() {
    local text="$1"
    local context="$2"

    # Substitute $context variable
    text="${text//\$context/$context}"

    echo "$text"
}

# Read the input file line by line
# Note: || [ -n "$line" ] handles files without trailing newline
while IFS= read -r line || [ -n "$line" ]; do
    if [[ "$line" =~ ^\`\`\` ]]; then
        if [ "$IN_CODE_BLOCK" = false ]; then
            # Start of code block
            IN_CODE_BLOCK=true
            PROMPT_TEXT=""

            # Parse metadata from the first line
            # Format: ```<engine>, model=<model-id>, context=<path>, log=<logfile>
            metadata="${line#\`\`\`}"

            # Extract engine
            ENGINE=$(echo "$metadata" | sed 's/,.*//' | xargs)

            # Extract model
            if [[ "$metadata" =~ model=([^,]+) ]]; then
                MODEL_ID=$(echo "${BASH_REMATCH[1]}" | xargs)
            else
                MODEL_ID=""
            fi

            # Extract context
            if [[ "$metadata" =~ context=([^,]+) ]]; then
                CONTEXT_PATH=$(echo "${BASH_REMATCH[1]}" | xargs)
            else
                CONTEXT_PATH=""
            fi

            # Extract log
            if [[ "$metadata" =~ log=([^,]+) ]]; then
                LOG_FILE=$(echo "${BASH_REMATCH[1]}" | xargs)
            else
                LOG_FILE=""
            fi

        else
            # End of code block - process it
            IN_CODE_BLOCK=false
            BLOCK_COUNT=$((BLOCK_COUNT + 1))

            # Substitute variables in prompt text
            PROMPT_TEXT=$(substitute_vars "$PROMPT_TEXT" "$CONTEXT_PATH")

            # Validate required fields (model ID not required for print engine)
            if [ -z "$ENGINE" ] || [ -z "$PROMPT_TEXT" ]; then
                echo "Warning: Skipping block $BLOCK_COUNT - missing required fields" >&2
                # Write placeholder to markdown output
                echo "" >> "$MARKDOWN_OUTPUT"
                echo "<!-- Skipped block $BLOCK_COUNT: missing required fields -->" >> "$MARKDOWN_OUTPUT"
                echo "" >> "$MARKDOWN_OUTPUT"
                continue
            fi
            
            # For non-print engines, model ID is required
            if [ "$ENGINE" != "print" ] && [ -z "$MODEL_ID" ]; then
                echo "Warning: Skipping block $BLOCK_COUNT - model ID required for engine '$ENGINE'" >&2
                # Write placeholder to markdown output
                echo "" >> "$MARKDOWN_OUTPUT"
                echo "<!-- Skipped block $BLOCK_COUNT: missing required fields -->" >> "$MARKDOWN_OUTPUT"
                echo "" >> "$MARKDOWN_OUTPUT"
                continue
            fi

            # Determine log file path and create parent directory if needed
            if [ -n "$LOG_FILE" ]; then
                FULL_LOG_PATH="$LOG_FILE"
                # Create parent directory for log file if it doesn't exist
                LOG_DIR=$(dirname "$FULL_LOG_PATH")
                if [ "$LOG_DIR" != "." ] && [ ! -d "$LOG_DIR" ]; then
                    mkdir -p "$LOG_DIR"
                fi
            else
                FULL_LOG_PATH=""
            fi

            # Write processing logs to log file if specified, otherwise respect QUIET_MODE
            if [ -n "$FULL_LOG_PATH" ]; then
                {
                    echo ""
                    echo "=== Processing block $BLOCK_COUNT ==="
                    echo "Engine: $ENGINE"
                    echo "Model: $MODEL_ID"
                    echo "Context: ${CONTEXT_PATH:-none}"
                    echo "Log: $FULL_LOG_PATH"
                    echo ""
                } >> "$FULL_LOG_PATH"
            elif [ "$QUIET_MODE" = false ]; then
                echo "" >&2
                echo "=== Processing block $BLOCK_COUNT ===" >&2
                echo "Engine: $ENGINE" >&2
                echo "Model: $MODEL_ID" >&2
                echo "Context: ${CONTEXT_PATH:-none}" >&2
                echo "Log: stderr" >&2
                echo "" >&2
            fi

            # Build ask.sh command
            CMD=("$SCRIPT_DIR/ask.sh" "$ENGINE" "$MODEL_ID" "$PROMPT_TEXT")

            if [ -n "$CONTEXT_PATH" ]; then
                CMD+=(--context "$CONTEXT_PATH")
            fi

            # Execute the command and capture output
            MODEL_RESPONSE=$(mktemp)
            trap "rm -f $TEMP_FILE $MARKDOWN_OUTPUT $MODEL_RESPONSE" EXIT

            # Redirect logs if specified
            if [ -n "$FULL_LOG_PATH" ]; then
                if "${CMD[@]}" > "$MODEL_RESPONSE" 2>> "$FULL_LOG_PATH"; then
                    echo "✓ Block $BLOCK_COUNT completed successfully" >> "$FULL_LOG_PATH"
                    EXECUTION_SUCCESS=true
                else
                    echo "✗ Block $BLOCK_COUNT failed" >> "$FULL_LOG_PATH"
                    EXECUTION_SUCCESS=false
                fi
            else
                # No log file - let stderr pass through to parent's stderr if not in quiet mode
                if [ "$QUIET_MODE" = false ]; then
                    if "${CMD[@]}" > "$MODEL_RESPONSE" 2>&2; then
                        echo "✓ Block $BLOCK_COUNT completed successfully" >&2
                        EXECUTION_SUCCESS=true
                    else
                        echo "✗ Block $BLOCK_COUNT failed" >&2
                        EXECUTION_SUCCESS=false
                    fi
                else
                    # Quiet mode - suppress stderr
                    if "${CMD[@]}" > "$MODEL_RESPONSE" 2>/dev/null; then
                        EXECUTION_SUCCESS=true
                    else
                        EXECUTION_SUCCESS=false
                    fi
                fi
            fi

            if [ "$EXECUTION_SUCCESS" = true ]; then
                # Use the captured response (raw content)
                cat "$MODEL_RESPONSE" >> "$MARKDOWN_OUTPUT"
                echo "" >> "$MARKDOWN_OUTPUT"
            else
                echo "" >> "$MARKDOWN_OUTPUT"
                echo "<!-- Block $BLOCK_COUNT failed -->" >> "$MARKDOWN_OUTPUT"
                echo "Error processing block" >> "$MARKDOWN_OUTPUT"
                echo "" >> "$MARKDOWN_OUTPUT"
                exit 1
            fi

            rm -f "$MODEL_RESPONSE"
        fi
    elif [ "$IN_CODE_BLOCK" = true ]; then
        # Accumulate prompt text
        if [ -n "$PROMPT_TEXT" ]; then
            PROMPT_TEXT+=$'\n'
        fi
        PROMPT_TEXT+="$line"
    else
        # Regular markdown line - add to output
        echo "$line" >> "$MARKDOWN_OUTPUT"
    fi
done < "$INPUT_FILE"

if [ "$QUIET_MODE" = false ]; then
    echo "" >&2
    echo "=== Processing complete ===" >&2
    echo "Processed $BLOCK_COUNT code block(s)" >&2
fi

# Output the processed markdown to stdout
cat "$MARKDOWN_OUTPUT"
