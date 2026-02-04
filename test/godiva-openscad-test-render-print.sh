#!/bin/bash
# Test script using print engine for local testing without LLMs

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

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

cleanup() {
    rm -f godiva-openscad-ollama.md godiva-openscad-claude.md godiva-openscad-copilot.md
    rm -f godiva-openscad-test-render-print.md
    rm -rf output/
}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Godiva OpenSCAD Test (Print Engine)${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

cleanup

info "Test 1: Render with print engine"
if ../render.sh godiva-openscad-test-render-print.lmd > godiva-openscad-test-render-print.md 2>/dev/null; then
    pass "Rendering completed"
else
    fail "Rendering failed"
fi

info "Test 2: Verify output created"
if [ -f "godiva-openscad-test-render-print.md" ] && [ -s "godiva-openscad-test-render-print.md" ]; then
    pass "Output file created ($(wc -c < godiva-openscad-test-render-print.md) bytes)"
else
    fail "Output file not created or empty"
fi

info "Test 3: Extract individual engine outputs"
sed -n '/## Ollama Generation/,/## Claude Generation/p' godiva-openscad-test-render-print.md | head -n -1 > godiva-openscad-ollama.md
sed -n '/## Claude Generation/,/## Copilot Generation/p' godiva-openscad-test-render-print.md | head -n -1 > godiva-openscad-claude.md
sed -n '/## Copilot Generation/,$p' godiva-openscad-test-render-print.md > godiva-openscad-copilot.md

if [ -s godiva-openscad-ollama.md ] && [ -s godiva-openscad-claude.md ] && [ -s godiva-openscad-copilot.md ]; then
    pass "All engine outputs extracted"
else
    fail "Failed to extract all outputs"
fi

info "Test 4: Verify OpenSCAD syntax"
for engine in ollama claude copilot; do
    if [ -f "godiva-openscad-${engine}.md" ]; then
        if grep -qE '(module|cube|cylinder|sphere|translate|rotate)' "godiva-openscad-${engine}.md"; then
            pass "${engine}: Valid OpenSCAD syntax"
            echo "   Preview (first 5 lines of code):"
            grep -E '(module|cube|cylinder|difference)' "godiva-openscad-${engine}.md" | head -5 | sed 's/^/     /'
        else
            fail "${engine}: Missing OpenSCAD syntax"
        fi
    fi
done

info "Test 5: Verify log files"
LOG_COUNT=$(ls output/godiva-*.log 2>/dev/null | wc -l)
if [ "$LOG_COUNT" -ge 3 ]; then
    pass "All log files created"
else
    fail "Log files missing ($LOG_COUNT of 3)"
fi

info "Test 6: Compare sizes"
echo "   Output sizes:"
for engine in ollama claude copilot; do
    [ -f "godiva-openscad-${engine}.md" ] && echo "     ${engine}: $(wc -c < godiva-openscad-${engine}.md) bytes"
done

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Test Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "Passed: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "Failed: ${RED}${TESTS_FAILED}${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed.${NC}"
    exit 1
fi
