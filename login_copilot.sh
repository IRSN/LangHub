#!/bin/bash
# login_copilot.sh - Authenticate with GitHub Copilot CLI for LangHub
# Usage: ./login_copilot.sh

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

# Main
print_header "Logging in to GitHub Copilot CLI..."

if ! command_exists copilot; then
    print_error "Copilot CLI is not installed"
    print_warning "Run: ./install.sh copilot"
    exit 1
fi

print_header "Initiating Copilot login..."
print_warning "This will open your browser for authentication"
echo ""

if copilot auth login; then
    print_success "Copilot authentication successful!"
else
    print_error "Copilot authentication failed"
    exit 1
fi

print_header "Verifying Copilot subscription..."

# Test Copilot access by listing models
echo ""
if "$SCRIPT_DIR/lh" list copilot >/dev/null 2>&1; then
    print_success "GitHub Copilot is active and accessible!"

    echo ""
    print_header "Available models:"
    "$SCRIPT_DIR/lh" list copilot || true

    echo ""
    print_header "Next steps:"
    echo "1. List models: ./lh list copilot"
    echo "2. Test: ./lh ask copilot claude-sonnet-4.5 \"Hello\""
    echo "3. Check subscription: https://github.com/settings/copilot"
else
    print_error "GitHub Copilot subscription not active"
    print_warning "Subscribe at: https://github.com/features/copilot"
    print_warning "Cost: \$10/month or \$100/year"
    exit 1
fi
