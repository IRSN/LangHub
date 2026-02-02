#!/bin/bash
# login_ollama.sh - Check Ollama status for LangHub
# Usage: ./login_ollama.sh [custom_uri]
# Example: ./login_ollama.sh http://192.168.1.100:11434

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Helper functions
print_header() {
    echo -e "${BLUE}==>${NC} ${1}"
}

print_success() {
    echo -e "${GREEN}✓${NC} ${1}"
}

print_error() {
    echo -e "${RED}✗${NC} ${1}"
}

print_warning() {
    echo -e "${YELLOW}!${NC} ${1}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Parse arguments
OLLAMA_URI="${1:-http://localhost:11434}"

# Main
print_header "Checking Ollama status at $OLLAMA_URI..."

if ! command_exists ollama; then
    print_error "Ollama is not installed"
    print_warning "Run: ./install.sh ollama"
    exit 1
fi

print_success "Ollama does not require authentication"
print_header "Testing Ollama connection..."

# Check if Ollama service is running
if curl -s "$OLLAMA_URI/api/tags" >/dev/null 2>&1; then
    print_success "Ollama is running and accessible at $OLLAMA_URI"

    # List installed models
    print_header "Installed models:"
    if [[ "$OLLAMA_URI" == "http://localhost:11434" ]]; then
        "$SCRIPT_DIR/../lh" list ollama || true
    else
        "$SCRIPT_DIR/../lh" list "ollama:$OLLAMA_URI" || true
    fi

    echo ""
    print_header "Next steps:"
    echo "1. Pull models: ollama pull qwen2.5-coder:7b"
    if [[ "$OLLAMA_URI" == "http://localhost:11434" ]]; then
        echo "2. List models: ./lh list ollama"
        echo "3. Test: ./lh ask ollama qwen2.5-coder:7b \"Hello\""
    else
        echo "2. List models: ./lh list ollama:$OLLAMA_URI"
        echo "3. Test: ./lh ask ollama:$OLLAMA_URI qwen2.5-coder:7b \"Hello\""
    fi
else
    print_warning "Ollama service is not accessible at $OLLAMA_URI"
    
    # Only try to start if using localhost
    if [[ "$OLLAMA_URI" == "http://localhost:11434" ]]; then
        print_header "Starting Ollama service..."

        # Try to start Ollama
        ollama serve >/dev/null 2>&1 &
        sleep 2

        if curl -s "$OLLAMA_URI/api/tags" >/dev/null 2>&1; then
            print_success "Ollama service started successfully"
        else
            print_error "Failed to start Ollama service"
            print_warning "Try manually: ollama serve"
            exit 1
        fi
    else
        print_error "Cannot connect to Ollama at $OLLAMA_URI"
        print_warning "Make sure Ollama is running at the specified address"
        exit 1
    fi
fi
