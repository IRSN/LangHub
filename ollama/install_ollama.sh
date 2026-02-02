#!/bin/bash
# install_ollama.sh - Install Ollama for LangHub
# Usage: ./install_ollama.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Main installation
print_header "Installing Ollama..."

if command_exists ollama; then
    print_warning "Ollama is already installed"
    ollama --version
    exit 0
fi

print_header "Installing Ollama via official script..."
curl -fsSL https://ollama.com/install.sh | sh

if command_exists ollama; then
    print_success "Ollama installed successfully"
    ollama --version
    echo ""
    print_header "Next steps:"
    echo "1. Pull a model: ollama pull qwen2.5-coder:7b"
    echo "2. List models: ./lh list ollama"
    echo "3. Test: ./lh ask ollama qwen2.5-coder:7b \"Hello\""
else
    print_error "Ollama installation failed"
    exit 1
fi
