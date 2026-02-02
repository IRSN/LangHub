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

# Discover available engines
discover_engines() {
    find "$SCRIPT_DIR" -mindepth 1 -maxdepth 1 -type d -name '[!.]*' ! -name 'test' ! -name 'completion' -printf '%f\n' | sort
}

# Show usage
show_usage() {
    echo "LangHub Engine Authenticator"
    echo ""
    echo "Usage: ./login.sh [engine]"
    echo ""
    echo "Available engines:"
    while IFS= read -r engine; do
        if [[ -f "$SCRIPT_DIR/$engine/login_${engine}.sh" ]]; then
            echo "  $engine"
        fi
    done < <(discover_engines)
    echo "  all       - Authenticate with all engines"
    echo ""
    echo "Examples:"
    echo "  ./login.sh claude       # Login to Claude"
    echo "  ./login.sh copilot      # Login to GitHub Copilot"
    echo "  ./login.sh all          # Login to all engines"
    echo ""
    echo "Note: Make sure engines are installed first (./install.sh)"
    echo "Use engine:uri syntax for custom URIs (e.g., ollama:http://server:11434)"
}

# Login function for any engine
login_engine() {
    local engine="$1"
    local custom_uri="$2"
    
    if [[ -f "$SCRIPT_DIR/$engine/login_${engine}.sh" ]]; then
        if [[ -n "$custom_uri" ]]; then
            "$SCRIPT_DIR/$engine/login_${engine}.sh" "$custom_uri"
        else
            "$SCRIPT_DIR/$engine/login_${engine}.sh"
        fi
    else
        print_warning "Engine '$engine' does not have a login script"
        return 1
    fi
}

# Main login logic
main() {
    if [ $# -eq 0 ]; then
        show_usage
        exit 1
    fi

    local engine_spec="$1"
    local failed=0

    # Parse engine specification (for engine:uri syntax)
    local engine=""
    local custom_uri=""
    
    if [[ "$engine_spec" == *:* ]]; then
        engine="${engine_spec%%:*}"
        custom_uri="${engine_spec#*:}"
    else
        engine="$engine_spec"
    fi
    
    # Special handling for ollama default URI
    if [[ "$engine" == "ollama" ]] && [[ -z "$custom_uri" ]]; then
        custom_uri="http://localhost:11434"
    fi

    if [[ "$engine" == "all" ]]; then
        print_header "Authenticating all engines..."
        echo ""
        
        # Login to all discovered engines
        local first=true
        while IFS= read -r eng; do
            if [[ "$first" == false ]]; then
                echo ""
                echo "========================================"
                echo ""
            fi
            first=false
            
            # Special handling for ollama default URI
            if [[ "$eng" == "ollama" ]]; then
                login_engine "$eng" "http://localhost:11434" || true
            else
                login_engine "$eng" || true
            fi
        done < <(discover_engines)
        
        echo ""
        print_success "Authentication process complete!"
    elif [[ "$engine" == "help" ]] || [[ "$engine" == "--help" ]] || [[ "$engine" == "-h" ]]; then
        show_usage
        exit 0
    elif [[ -d "$SCRIPT_DIR/$engine" ]]; then
        # Login to specific engine
        login_engine "$engine" "$custom_uri" || failed=1
    else
        print_error "Unknown engine: $engine"
        show_usage
        exit 1
    fi

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
