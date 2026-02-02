#!/bin/bash
# install_copilot.sh - Install GitHub Copilot CLI for LangHub
# Usage: ./install_copilot.sh

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
print_header "Installing GitHub Copilot CLI..."

if command_exists copilot; then
    print_warning "GitHub Copilot CLI is already installed"
    copilot --version 2>&1 || echo "Copilot CLI installed"
    exit 0
fi

print_header "Installing GitHub Copilot CLI via official script..."
curl -fsSL https://gh.io/copilot-install | bash

if command_exists copilot; then
    print_success "GitHub Copilot CLI installed successfully"
    copilot --version 2>&1 || echo "Copilot CLI installed"
    echo ""
    print_warning "Next steps:"
    echo "1. Subscribe to GitHub Copilot at https://github.com/features/copilot"
    echo "   Cost: \$10/month or \$100/year"
    echo "2. Run: ./login.sh copilot"
    echo "3. Test with: ./lh list copilot"
else
    print_error "GitHub Copilot CLI installation failed"
    exit 1
fi
