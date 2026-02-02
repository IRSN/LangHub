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

# Discover available engines
discover_engines() {
    find "$SCRIPT_DIR" -mindepth 1 -maxdepth 1 -type d -name '[!.]*' ! -name 'test' ! -name 'completion' -printf '%f\n' | sort
}

# Show usage
show_usage() {
    echo "LangHub Engine Installer"
    echo ""
    echo "Usage: ./install.sh [engine]"
    echo ""
    echo "Available engines:"
    while IFS= read -r engine; do
        if [[ -f "$SCRIPT_DIR/$engine/install_${engine}.sh" ]]; then
            echo "  $engine"
        fi
    done < <(discover_engines)
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

    if [[ "$engine" == "all" ]]; then
        print_header "Installing all engines..."
        echo ""
        
        # Install all discovered engines
        while IFS= read -r eng; do
            if [[ -f "$SCRIPT_DIR/$eng/install_${eng}.sh" ]]; then
                "$SCRIPT_DIR/$eng/install_${eng}.sh" || failed=1
                echo ""
            fi
        done < <(discover_engines)
        
        if [ $failed -eq 0 ]; then
            print_success "All engines installed successfully!"
        else
            print_warning "Some engines require manual installation"
        fi
    elif [[ "$engine" == "help" ]] || [[ "$engine" == "--help" ]] || [[ "$engine" == "-h" ]]; then
        show_usage
        exit 0
    elif [[ -d "$SCRIPT_DIR/$engine" ]] && [[ -f "$SCRIPT_DIR/$engine/install_${engine}.sh" ]]; then
        # Install specific engine
        "$SCRIPT_DIR/$engine/install_${engine}.sh" || failed=1
    else
        print_error "Unknown engine: $engine"
        show_usage
        exit 1
    fi

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
