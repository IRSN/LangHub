#!/bin/bash
# install_claude.sh - Install Claude CLI for LangHub
# Usage: ./install_claude.sh

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
print_header "Installing Claude CLI..."

if command_exists claude; then
    print_warning "Claude CLI is already installed"
    claude --version 2>&1 || echo "Claude CLI installed"
    exit 0
fi

print_header "Installing Claude CLI via official script..."
curl -fsSL https://claude.ai/install.sh | bash

if command_exists claude; then
    print_success "Claude CLI installed successfully"
    claude --version 2>&1 || echo "Claude CLI installed"
    echo ""
    print_header "Next steps:"
    echo "1. Run: ./login.sh claude"
    echo "2. List models: ./lh list claude"
    echo "3. Test: ./lh ask claude claude-3-5-sonnet-20241022 \"Hello\""
else
    print_error "Claude CLI installation failed"
    echo ""
    print_header "Alternative: Use via GitHub Copilot"
    echo "If you have a GitHub Copilot subscription, you can access Claude models:"
    echo "  ./install.sh copilot"
    echo "  ./lh ask copilot claude-sonnet-4.5 \"Your prompt\""
    exit 1
fi
