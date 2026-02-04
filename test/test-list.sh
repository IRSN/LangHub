#!/bin/bash
# Test script for list scripts (list.sh, list_claude.sh, list_copilot.sh, list_ollama.sh)

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

# Engine filter (optional argument)
ENGINE_FILTER="${1:-all}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Helper function to print test results
pass() {
    echo -e "${GREEN}✓${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

skip() {
    echo -e "${YELLOW}⊘${NC} $1 (skipped)"
}

echo "=== Testing list scripts (engine: $ENGINE_FILTER) ==="
echo ""

# Test list.sh
if [ "$ENGINE_FILTER" = "all" ]; then
    info "Test 1: list.sh basic execution"
    if ./list.sh > /dev/null 2>&1; then
        pass "list.sh executed successfully"
    else
        fail "list.sh failed to execute"
    fi

    info "Test 2: list.sh output format"
    OUTPUT=$(./list.sh 2>/dev/null)
    if echo "$OUTPUT" | grep -q "Available engines"; then
        pass "list.sh shows available engines"
        echo "   Output (first 10 lines):"
        echo "$OUTPUT" | head -10 | sed 's/^/     /'
    else
        fail "list.sh output format incorrect"
    fi
fi

# Test list_claude.sh
if [ "$ENGINE_FILTER" = "all" ] || [ "$ENGINE_FILTER" = "claude" ]; then
    info "Test 3: list_claude.sh execution"
    if ./claude/list_claude.sh > /dev/null 2>&1; then
        pass "list_claude.sh executed successfully"

        # Check if it returns model list
        OUTPUT=$(./claude/list_claude.sh 2>/dev/null)
        if [ -n "$OUTPUT" ]; then
            pass "list_claude.sh returns model list"
            echo "   Models (first 10 lines):"
            echo "$OUTPUT" | head -10 | sed 's/^/     /'
        else
            fail "list_claude.sh returns empty output"
        fi
    else
        skip "list_claude.sh failed (Claude API may not be configured)"
    fi
fi

# Test list_copilot.sh
if [ "$ENGINE_FILTER" = "all" ] || [ "$ENGINE_FILTER" = "copilot" ]; then
    info "Test 4: list_copilot.sh execution"
    if ./copilot/list_copilot.sh > /dev/null 2>&1; then
        pass "list_copilot.sh executed successfully"

        # Check if it returns model list
        OUTPUT=$(./copilot/list_copilot.sh 2>/dev/null)
        if [ -n "$OUTPUT" ]; then
            pass "list_copilot.sh returns model list"
            echo "   Models (first 10 lines):"
            echo "$OUTPUT" | head -10 | sed 's/^/     /'
        else
            fail "list_copilot.sh returns empty output"
        fi
    else
        skip "list_copilot.sh failed (GitHub Copilot may not be configured)"
    fi
fi

# Test list_ollama.sh
if [ "$ENGINE_FILTER" = "all" ] || [ "$ENGINE_FILTER" = "ollama" ]; then
    info "Test 5: list_ollama.sh execution"
    if ./ollama/list_ollama.sh > /dev/null 2>&1; then
        pass "list_ollama.sh executed successfully"

        # Check if it returns model list
        OUTPUT=$(./ollama/list_ollama.sh 2>/dev/null)
        if [ -n "$OUTPUT" ]; then
            pass "list_ollama.sh returns model list"
            echo "   Models (first 10 lines):"
            echo "$OUTPUT" | head -10 | sed 's/^/     /'
        else
            fail "list_ollama.sh returns empty output"
        fi
    else
        skip "list_ollama.sh failed (Ollama may not be running)"
    fi

    # Test list_ollama.sh with custom URI
    info "Test 6: list_ollama.sh with custom URI"
    if ./ollama/list_ollama.sh http://localhost:11434 > /dev/null 2>&1; then
        pass "list_ollama.sh accepts custom URI"
    else
        skip "list_ollama.sh with custom URI failed (Ollama may not be running)"
    fi
fi

echo ""
echo "=== Test Summary ==="
echo -e "Passed: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "Failed: ${RED}${TESTS_FAILED}${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
