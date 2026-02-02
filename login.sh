#!/bin/bash
# login.sh - Authenticate with LLM engine providers for LangHub
# Usage: ./login.sh [engine]
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

# Login to Ollama
login_ollama() {
    "$SCRIPT_DIR/login_ollama.sh"
}

# Login to Claude
login_claude() {
    "$SCRIPT_DIR/login_claude.sh"
}

# Login to GitHub Copilot
login_copilot() {
    "$SCRIPT_DIR/login_copilot.sh"
}

# Show usage
show_usage() {
    echo "LangHub Engine Authenticator"
    echo ""
    echo "Usage: ./login.sh [engine]"
    echo ""
    echo "Available engines:"
    echo "  ollama    - Check Ollama status (no authentication needed)"
    echo "  claude    - Authenticate with Claude CLI"
    echo "  copilot   - Authenticate with GitHub Copilot CLI"
    echo "  all       - Authenticate with all engines"
    echo ""
    echo "Examples:"
    echo "  ./login.sh claude       # Login to Claude"
    echo "  ./login.sh copilot      # Login to GitHub Copilot"
    echo "  ./login.sh all          # Login to all engines"
    echo ""
    echo "Note: Make sure engines are installed first (./install.sh)"
}

# Main login logic
main() {
    if [ $# -eq 0 ]; then
        show_usage
        exit 1
    fi

    local engine="$1"
    local failed=0

    case "$engine" in
        ollama)
            login_ollama || failed=1
            ;;
        claude)
            login_claude || failed=1
            ;;
        copilot)
            login_copilot || failed=1
            ;;
        all)
            print_header "Authenticating all engines..."
            echo ""
            login_ollama || true
            echo ""
            echo "========================================"
            echo ""
            login_claude || true
            echo ""
            echo "========================================"
            echo ""
            login_copilot || true
            echo ""
            print_success "Authentication process complete!"
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

    if [ $failed -eq 0 ] && [ "$engine" != "all" ]; then
        echo ""
        print_success "Authentication complete for $engine!"
        echo ""
        print_header "Quick test commands:"
        echo "  ./lh list $engine"

        case "$engine" in
            ollama)
                echo "  ./lh ask $engine qwen2.5-coder:7b \"Write hello world\""
                ;;
            claude)
                echo "  ./lh ask $engine claude-3-5-sonnet-20241022 \"Write hello world\""
                ;;
            copilot)
                echo "  ./lh ask $engine claude-sonnet-4.5 \"Write hello world\""
                ;;
        esac
    fi

    exit $failed
}

main "$@"
