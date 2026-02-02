#!/bin/bash
# Master test runner for all script tests

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Running All Script Tests${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Track overall results
TOTAL_PASSED=0
TOTAL_FAILED=0
SUITES_PASSED=0
SUITES_FAILED=0

# Run test-render.sh
echo -e "${BLUE}[1/3] Running render.sh tests...${NC}"
echo ""
if bash test-render.sh; then
    SUITES_PASSED=$((SUITES_PASSED + 1))
    echo ""
else
    SUITES_FAILED=$((SUITES_FAILED + 1))
    echo ""
fi

# Run test-list.sh
echo -e "${BLUE}[2/3] Running list scripts tests...${NC}"
echo ""
if bash test-list.sh; then
    SUITES_PASSED=$((SUITES_PASSED + 1))
    echo ""
else
    SUITES_FAILED=$((SUITES_FAILED + 1))
    echo ""
fi

# Run test-ask.sh
echo -e "${BLUE}[3/3] Running ask scripts tests...${NC}"
echo ""
if bash test-ask.sh; then
    SUITES_PASSED=$((SUITES_PASSED + 1))
    echo ""
else
    SUITES_FAILED=$((SUITES_FAILED + 1))
    echo ""
fi

# Final summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Overall Test Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "Test Suites Passed: ${GREEN}${SUITES_PASSED}/3${NC}"
echo -e "Test Suites Failed: ${RED}${SUITES_FAILED}/3${NC}"
echo ""

if [ $SUITES_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All test suites passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some test suites failed.${NC}"
    exit 1
fi
