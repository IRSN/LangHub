#!/bin/bash
# install.sh - Install LLM engine providers for LangHub
# Usage: ./install.sh [engine]
# Engines: ollama, claude, copilot, all

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

# Install Ollama
install_ollama() {
    "$SCRIPT_DIR/install_ollama.sh"
}

# Install Claude CLI
install_claude() {
    "$SCRIPT_DIR/install_claude.sh"
}

# Install GitHub Copilot CLI
install_copilot() {
    "$SCRIPT_DIR/install_copilot.sh"
}

# Show usage
show_usage() {
    echo "LangHub Engine Installer"
    echo ""
    echo "Usage: ./install.sh [engine]"
    echo ""
    echo "Available engines:"
    echo "  ollama    - Install Ollama (free, local)"
    echo "  claude    - Install Claude CLI (pay-per-use or subscription)"
    echo "  copilot   - Install GitHub Copilot CLI (subscription required)"
    echo "  all       - Install all engines"
    echo ""
    echo "Examples:"
    echo "  ./install.sh ollama     # Install just Ollama"
    echo "  ./install.sh all        # Install all engines"
    echo ""
    echo "After installation, use ./login.sh to authenticate"
}

# Main installation logic
main() {
    if [ $# -eq 0 ]; then
        show_usage
        exit 1
    fi

    local engine="$1"
    local failed=0

    case "$engine" in
        ollama)
            install_ollama || failed=1
            ;;
        claude)
            install_claude || failed=1
            ;;
        copilot)
            install_copilot || failed=1
            ;;
        all)
            print_header "Installing all engines..."
            echo ""
            install_ollama || failed=1
            echo ""
            install_claude || failed=1
            echo ""
            install_copilot || failed=1
            echo ""
            if [ $failed -eq 0 ]; then
                print_success "All engines installed successfully!"
            else
                print_warning "Some engines require manual installation"
            fi
            ;;
        help|--help|-h)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown engine: $engine"
            show_usage
            exit 1
            ;;
    esac

    if [ $failed -eq 0 ]; then
        echo ""
        print_success "Installation complete!"
        echo ""
        print_header "Next steps:"
        echo "1. Run: ./login.sh $engine (if authentication required)"
        echo "2. Test: ./lh list $engine"
        echo "3. Use: ./lh ask $engine <model-id> \"Your prompt\""
    fi

    exit $failed
}

main "$@"
