#!/bin/bash
# Test script for render.sh

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Engine filter (optional argument) - render tests all engines in .lmd files
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

# Clean up any previous test outputs
cleanup() {
    rm -f printtest-render.md claudetest-render.md copilottest-render.md ollamatest-render.md
    rm -rf output/
}

# Setup
echo "=== Testing render.sh (engine: $ENGINE_FILTER) ==="
echo ""
cleanup

# Determine which test file to use based on engine filter
if [ "$ENGINE_FILTER" = "ollama" ]; then
    TEST_FILE="ollamatest-render.lmd"
elif [ "$ENGINE_FILTER" = "claude" ]; then
    TEST_FILE="claudetest-render.lmd"
elif [ "$ENGINE_FILTER" = "copilot" ]; then
    TEST_FILE="copilottest-render.lmd"
else
    TEST_FILE="printtest-render.lmd"
fi

OUTPUT_FILE="${TEST_FILE%.lmd}.md"

# Test 1: Basic execution
info "Test 1: Basic execution with $ENGINE_FILTER engine"
if ../render.sh "$TEST_FILE" > "$OUTPUT_FILE" 2>/dev/null; then
    pass "render.sh executed successfully"
else
    fail "render.sh failed to execute"
fi

# Test 2: Output file created
info "Test 2: Check if markdown output was created"
if [ -f "$OUTPUT_FILE" ]; then
    pass "Markdown output file created"
    echo "   Content (first 10 lines):"
    head -20 "$OUTPUT_FILE" | sed 's/^/     /'
else
    fail "Markdown output file not created"
fi

# Test 3: Log file created (only for printtest which has log directive)
if [ "$TEST_FILE" = "printtest-render.lmd" ]; then
    info "Test 3: Check if log file was created"
    if [ -f "output/test.log" ]; then
        pass "Log file created"
        echo "   Log content (first 10 lines):"
        head -20 output/test.log | sed 's/^/     /'
    else
        fail "Log file not created"
    fi

    # Test 4: Log directory auto-created
    info "Test 4: Check if log directory was auto-created"
    if [ -d "output" ]; then
        pass "Log directory auto-created"
    else
        fail "Log directory not auto-created"
    fi
fi

## No, remaining code blocks are still possible
# # Test 5: Content verification
# info "Test 5: Verify output content is raw (no code blocks)"
# if grep -q '```' "$OUTPUT_FILE"; then
#     fail "Output contains code blocks (should be raw)"
# else
#     pass "Output is raw content (no code blocks)"
# fi

# Test 5a: Check for no thinking blocks
info "Test 5a: Verify output has no thinking blocks"
if grep -q '<thinking>' "$OUTPUT_FILE"; then
    fail "Output contains thinking blocks (should be clean answer only)"
else
    pass "Output is clean (no thinking blocks)"
fi

# Test 5b: Check for no logging info
info "Test 5b: Verify output has no logging info"
if grep -qE '(DEBUG|INFO|WARN|ERROR|Log:|Logging)' "$OUTPUT_FILE"; then
    fail "Output contains logging info (should be clean answer only)"
else
    pass "Output is clean (no logging info)"
fi

# Test 6: Content correctness (only for printtest)
if [ "$TEST_FILE" = "printtest-render.lmd" ]; then
    info "Test 6: Verify markdown content includes prompt output"
    if grep -q "Hello, this is a simple test output" "$OUTPUT_FILE"; then
        pass "Markdown output contains expected content"
    else
        fail "Markdown output missing expected content"
    fi

    # Test 7: Markdown structure preserved
    info "Test 7: Verify markdown headers preserved"
    if grep -q "## Simple print test" "$OUTPUT_FILE" && grep -q "## Test with log file" "$OUTPUT_FILE"; then
        pass "Markdown headers preserved"
    else
        fail "Markdown headers not preserved"
    fi
fi

# Clean up
cleanup

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