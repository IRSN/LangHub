#!/bin/bash
# Dedicated test script for Godiva OpenSCAD generation with all engines

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
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

# Clean up any previous outputs
cleanup() {
    rm -f godiva-openscad-ollama.md godiva-openscad-claude.md godiva-openscad-copilot.md
    rm -f godiva-openscad-test-render.md
    rm -rf output/
}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Godiva OpenSCAD Generation Test${NC}"
echo -e "${BLUE}  Testing all engines: ollama, claude, copilot${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

cleanup

# Test 1: Render the combined test file
info "Test 1: Render godiva-openscad-test-render.lmd"
if ../render.sh godiva-openscad-test-render.lmd > godiva-openscad-test-render.md 2>/dev/null; then
    pass "Rendering completed successfully"
else
    fail "Rendering failed"
fi

# Test 2: Check output file created
info "Test 2: Verify output file created"
if [ -f "godiva-openscad-test-render.md" ]; then
    pass "Output file created"
    echo "   File size: $(wc -c < godiva-openscad-test-render.md) bytes"
else
    fail "Output file not created"
fi

# Test 3: Extract individual engine outputs
info "Test 3: Extract individual engine outputs"

# Extract Ollama section
if grep -q "## Ollama Generation" godiva-openscad-test-render.md; then
    sed -n '/## Ollama Generation/,/## Claude Generation/p' godiva-openscad-test-render.md | head -n -1 > godiva-openscad-ollama.md
    pass "Extracted Ollama output"
else
    fail "Ollama section not found"
fi

# Extract Claude section
if grep -q "## Claude Generation" godiva-openscad-test-render.md; then
    sed -n '/## Claude Generation/,/## Copilot Generation/p' godiva-openscad-test-render.md | head -n -1 > godiva-openscad-claude.md
    pass "Extracted Claude output"
else
    fail "Claude section not found"
fi

# Extract Copilot section
if grep -q "## Copilot Generation" godiva-openscad-test-render.md; then
    sed -n '/## Copilot Generation/,$p' godiva-openscad-test-render.md > godiva-openscad-copilot.md
    pass "Extracted Copilot output"
else
    fail "Copilot section not found"
fi

# Test 4: Verify OpenSCAD syntax in each output
info "Test 4: Verify OpenSCAD syntax in outputs"

for engine in ollama claude copilot; do
    if [ -f "godiva-openscad-${engine}.md" ]; then
        if grep -qE '(module|cube|cylinder|sphere|translate|rotate)' "godiva-openscad-${engine}.md"; then
            pass "${engine}: Contains valid OpenSCAD syntax"
            echo "   Preview (first 10 lines):"
            head -10 "godiva-openscad-${engine}.md" | sed 's/^/     /'
        else
            fail "${engine}: Missing OpenSCAD syntax"
        fi
    else
        fail "${engine}: Output file not found"
    fi
done

# Test 5: Verify log files
info "Test 5: Verify log files created"

LOG_COUNT=$(ls output/godiva-*.log 2>/dev/null | wc -l)
if [ "$LOG_COUNT" -ge 3 ]; then
    pass "All log files created ($LOG_COUNT files)"
    echo "   Log files:"
    ls -lh output/godiva-*.log | awk '{print "     " $9 " (" $5 ")"}'
else
    skip "Some log files missing ($LOG_COUNT of 3)"
fi

# Test 6: Compare output sizes
info "Test 6: Compare output sizes"
echo "   Engine output sizes:"
for engine in ollama claude copilot; do
    if [ -f "godiva-openscad-${engine}.md" ]; then
        size=$(wc -c < "godiva-openscad-${engine}.md")
        echo "     ${engine}: ${size} bytes"
    fi
done

# Test 7: Verify no thinking blocks or logging info
info "Test 7: Verify clean output (no thinking blocks or logs)"

for engine in ollama claude copilot; do
    if [ -f "godiva-openscad-${engine}.md" ]; then
        if grep -q '<thinking>' "godiva-openscad-${engine}.md"; then
            fail "${engine}: Contains thinking blocks"
        else
            pass "${engine}: Clean output (no thinking blocks)"
        fi
    fi
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
    echo ""
    echo "Generated files:"
    echo "  - godiva-openscad-ollama.md"
    echo "  - godiva-openscad-claude.md"
    echo "  - godiva-openscad-copilot.md"
    echo "  - output/godiva-*.log"
    exit 0
else
    echo -e "${RED}✗ Some tests failed.${NC}"
    exit 1
fi
