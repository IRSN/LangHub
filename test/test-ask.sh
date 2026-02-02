#!/bin/bash
# Test script for ask scripts (ask.sh, ask_claude.sh, ask_copilot.sh, ask_ollama.sh)

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

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

# Test data
TEST_PROMPT="What is 2+2? Answer with just the number."
TEST_CONTEXT_FILE="test/test-context.txt"

# Setup
echo "=== Testing ask scripts ==="
echo ""

# Create test context file
mkdir -p test
echo "Context information: The answer to any math question should be calculated correctly." > "$TEST_CONTEXT_FILE"

# Test ask.sh with print engine
info "Test 1: ask.sh with print engine"
OUTPUT=$(./ask.sh print "" "$TEST_PROMPT" 2>/dev/null || echo "FAILED")
if [ "$OUTPUT" != "FAILED" ] && [ -n "$OUTPUT" ]; then
    pass "ask.sh with print engine works"

    if [ "$OUTPUT" = "$TEST_PROMPT" ]; then
        pass "Print engine echoes prompt correctly"
    else
        fail "Print engine output doesn't match input"
    fi

    # Check for no thinking blocks
    if echo "$OUTPUT" | grep -q '<thinking>'; then
        fail "Output contains thinking blocks (should be clean answer only)"
    else
        pass "Output is clean (no thinking blocks)"
    fi

    # Check for no logging info
    if echo "$OUTPUT" | grep -qE '(DEBUG|INFO|WARN|ERROR|Log:|Logging)'; then
        fail "Output contains logging info (should be clean answer only)"
    else
        pass "Output is clean (no logging info)"
    fi
else
    fail "ask.sh with print engine failed"
fi

# Test ask.sh with context
info "Test 2: ask.sh with context parameter"
OUTPUT=$(./ask.sh print "" "$TEST_PROMPT" --context "$TEST_CONTEXT_FILE" 2>/dev/null || echo "FAILED")
if [ "$OUTPUT" != "FAILED" ]; then
    pass "ask.sh accepts context parameter"
else
    fail "ask.sh failed with context parameter"
fi

# Test ask_ollama.sh (if Ollama is available)
info "Test 3: ask_ollama.sh execution"
OLLAMA_MODELS=$(./list_ollama.sh 2>/dev/null | head -1)
if [ -n "$OLLAMA_MODELS" ]; then
    FIRST_MODEL=$(echo "$OLLAMA_MODELS" | awk '{print $1}')
    OUTPUT=$(./ask_ollama.sh "http://localhost:11434" "$FIRST_MODEL" "Say 'test'" "" 2>/dev/null || echo "FAILED")
    if [ "$OUTPUT" != "FAILED" ] && [ -n "$OUTPUT" ]; then
        pass "ask_ollama.sh can query models"

        # Check for no thinking blocks
        if echo "$OUTPUT" | grep -q '<thinking>'; then
            fail "Ollama output contains thinking blocks (should be clean answer only)"
        else
            pass "Ollama output is clean (no thinking blocks)"
        fi

        # Check for no logging info
        if echo "$OUTPUT" | grep -qE '(DEBUG|INFO|WARN|ERROR|Log:|Logging)'; then
            fail "Ollama output contains logging info (should be clean answer only)"
        else
            pass "Ollama output is clean (no logging info)"
        fi
    else
        fail "ask_ollama.sh query failed"
    fi
else
    skip "ask_ollama.sh test (Ollama not available)"
fi

# Test ask_claude.sh (if Claude is available)
info "Test 4: ask_claude.sh execution"
if command -v claude &> /dev/null; then
    # Try to get available models
    CLAUDE_MODELS=$(./list_claude.sh 2>/dev/null | head -1)
    if [ -n "$CLAUDE_MODELS" ]; then
        FIRST_MODEL=$(echo "$CLAUDE_MODELS" | awk '{print $1}')
        OUTPUT=$(./ask_claude.sh "$FIRST_MODEL" "Say 'test'" "" 2>/dev/null || echo "FAILED")
        if [ "$OUTPUT" != "FAILED" ] && [ -n "$OUTPUT" ]; then
            pass "ask_claude.sh can query models"

            # Check for no thinking blocks
            if echo "$OUTPUT" | grep -q '<thinking>'; then
                fail "Claude output contains thinking blocks (should be clean answer only)"
            else
                pass "Claude output is clean (no thinking blocks)"
            fi

            # Check for no logging info
            if echo "$OUTPUT" | grep -qE '(DEBUG|INFO|WARN|ERROR|Log:|Logging)'; then
                fail "Claude output contains logging info (should be clean answer only)"
            else
                pass "Claude output is clean (no logging info)"
            fi
        else
            fail "ask_claude.sh query failed"
        fi
    else
        skip "ask_claude.sh test (Claude API not configured)"
    fi
else
    skip "ask_claude.sh test (claude command not found)"
fi

# Test ask_copilot.sh (if Copilot is available)
info "Test 5: ask_copilot.sh execution"
if command -v copilot &> /dev/null; then
    # Try to get available models
    COPILOT_MODELS=$(./list_copilot.sh 2>/dev/null | head -1)
    if [ -n "$COPILOT_MODELS" ]; then
        FIRST_MODEL=$(echo "$COPILOT_MODELS" | awk '{print $1}')
        OUTPUT=$(./ask_copilot.sh "$FIRST_MODEL" "Say 'test'" "" 2>/dev/null || echo "FAILED")
        if [ "$OUTPUT" != "FAILED" ] && [ -n "$OUTPUT" ]; then
            pass "ask_copilot.sh can query models"

            # Check for no thinking blocks
            if echo "$OUTPUT" | grep -q '<thinking>'; then
                fail "Copilot output contains thinking blocks (should be clean answer only)"
            else
                pass "Copilot output is clean (no thinking blocks)"
            fi

            # Check for no logging info
            if echo "$OUTPUT" | grep -qE '(DEBUG|INFO|WARN|ERROR|Log:|Logging)'; then
                fail "Copilot output contains logging info (should be clean answer only)"
            else
                pass "Copilot output is clean (no logging info)"
            fi
        else
            fail "ask_copilot.sh query failed"
        fi
    else
        skip "ask_copilot.sh test (Copilot models not available or not authenticated)"
    fi
else
    skip "ask_copilot.sh test (copilot command not found)"
fi

# Test ask.sh error handling
info "Test 6: ask.sh with invalid engine"
if ./ask.sh invalid_engine model_id "test" 2>/dev/null; then
    fail "ask.sh should fail with invalid engine"
else
    pass "ask.sh properly rejects invalid engine"
fi

# Test ask.sh argument validation
info "Test 7: ask.sh with missing arguments"
if ./ask.sh 2>/dev/null; then
    fail "ask.sh should fail with missing arguments"
else
    pass "ask.sh validates required arguments"
fi

# Cleanup
rm -f "$TEST_CONTEXT_FILE"
rmdir test 2>/dev/null || true

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
