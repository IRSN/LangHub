#!/bin/bash
# Test script for Godiva OpenSCAD generation with Claude

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
    rm -f godiva-openscad-claude.md
    rm -rf output/
}

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}  Godiva OpenSCAD Test - Claude${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

cleanup

info "Test 1: Render with Claude"
if ../render.sh godiva-openscad-claude.lmd > godiva-openscad-claude.md 2>/dev/null; then
    pass "Rendering completed"
else
    fail "Rendering failed"
fi

info "Test 2: Verify output created"
if [ -f "godiva-openscad-claude.md" ] && [ -s "godiva-openscad-claude.md" ]; then
    pass "Output file created ($(wc -c < godiva-openscad-claude.md) bytes)"
    echo "   Preview (first 10 lines):"
    head -10 godiva-openscad-claude.md | sed 's/^/     /'
else
    fail "Output file not created or empty"
fi

info "Test 3: Verify OpenSCAD code is in the markdown"
if grep -qE '```(openscad|scad)' godiva-openscad-claude.md; then
    pass "OpenSCAD code block found in markdown"
    # Extract and validate the actual OpenSCAD code (check entire block)
    if sed -n '/```\(openscad\|scad\)/,/```/p' godiva-openscad-claude.md | grep -qE '(module|cube|cylinder|sphere|translate|rotate|difference|union)'; then
        pass "Valid OpenSCAD syntax inside markdown"
        echo "   Code preview:"
        grep -A 5 -E '```(openscad|scad)' godiva-openscad-claude.md | head -6 | sed 's/^/     /'
    else
        fail "No valid OpenSCAD code inside the markdown block"
    fi
else
    fail "No OpenSCAD code block in markdown (expected \`\`\`openscad or \`\`\`scad)"
fi

info "Test 4: Verify log file"
if [ -f "output/godiva-claude.log" ]; then
    pass "Log file created"
else
    fail "Log file missing"
fi

echo ""
echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}  Test Summary${NC}"
echo -e "${BLUE}======================================${NC}"
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
