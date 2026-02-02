#!/bin/bash
# login_claude.sh - Authenticate with Claude CLI for LangHub
# Usage: ./login_claude.sh

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
print_header "Logging in to Claude CLI..."

if ! command_exists claude; then
    print_error "Claude CLI is not installed"
    print_warning "Run: ./install.sh claude"
    print_warning "Or visit: https://docs.anthropic.com/claude/docs/claude-cli"
    exit 1
fi

print_header "Initiating Claude login..."
print_warning "This will open your browser for authentication"
echo ""

# Run Claude login
if claude login; then
    print_success "Claude authentication successful!"

    echo ""
    print_header "Testing Claude connection..."
    "$SCRIPT_DIR/lh" list claude || true

    echo ""
    print_header "Next steps:"
    echo "1. List models: ./lh list claude"
    echo "2. Test: ./lh ask claude claude-3-5-sonnet-20241022 \"Hello\""
    echo "3. Check usage: https://console.anthropic.com/settings/usage"
else
    print_error "Claude authentication failed"
    print_warning "Try again: claude login"
    exit 1
fi
