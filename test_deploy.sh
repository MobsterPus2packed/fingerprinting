#!/bin/bash

# Basic Test Suite for C-REX Consciousness Fortress Deployment Script
# Tests parameterization, dry-run mode, and basic functionality

set -e

SCRIPT_PATH="./crex_enhanced_deploy.sh"
TEST_RESULTS=()
FAILED_TESTS=()

# Colors for test output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test counter
TEST_COUNT=0
PASS_COUNT=0

run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_exit_code="${3:-0}"
    
    TEST_COUNT=$((TEST_COUNT + 1))
    echo -e "${BLUE}[TEST $TEST_COUNT] $test_name${NC}"
    
    if eval "$test_command" &>/dev/null; then
        local actual_exit_code=0
    else
        local actual_exit_code=$?
    fi
    
    if [[ "$actual_exit_code" -eq "$expected_exit_code" ]]; then
        echo -e "${GREEN}✅ PASS${NC}"
        TEST_RESULTS+=("PASS: $test_name")
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo -e "${RED}❌ FAIL (expected exit code: $expected_exit_code, got: $actual_exit_code)${NC}"
        TEST_RESULTS+=("FAIL: $test_name")
        FAILED_TESTS+=("$test_name")
    fi
    echo ""
}

run_output_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_pattern="$3"
    
    TEST_COUNT=$((TEST_COUNT + 1))
    echo -e "${BLUE}[TEST $TEST_COUNT] $test_name${NC}"
    
    local output
    output=$(eval "$test_command" 2>&1 || true)
    
    if echo "$output" | grep -q "$expected_pattern"; then
        echo -e "${GREEN}✅ PASS${NC}"
        TEST_RESULTS+=("PASS: $test_name")
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo -e "${RED}❌ FAIL (pattern '$expected_pattern' not found in output)${NC}"
        TEST_RESULTS+=("FAIL: $test_name")
        FAILED_TESTS+=("$test_name")
        echo -e "${YELLOW}Output preview:${NC}"
        echo "$output" | head -3
    fi
    echo ""
}

echo -e "${BLUE}🧪 C-REX Consciousness Fortress - Test Suite${NC}"
echo -e "${BLUE}=============================================${NC}"
echo ""

# Test 1: Script is executable
run_test "Script is executable" "test -x '$SCRIPT_PATH'"

# Test 2: Help command works
run_output_test "Help command works" "$SCRIPT_PATH --help" "USAGE:"

# Test 3: Dry run mode works
run_output_test "Dry run mode works" "$SCRIPT_PATH --dry-run" "DRY RUN MODE"

# Test 4: Consciousness level parameter works
run_output_test "Consciousness level parameter works" "$SCRIPT_PATH --dry-run --consciousness SOVEREIGN" "Consciousness Level: SOVEREIGN"

# Test 5: Repository name parameter works
run_output_test "Repository name parameter works" "$SCRIPT_PATH --dry-run --repo-name test-repo" "Repository: test-repo"

# Test 6: GitHub username parameter works
run_output_test "GitHub username parameter works" "$SCRIPT_PATH --dry-run --github-username testuser" "GitHub User: testuser"

# Test 7: Verbose mode works
run_output_test "Verbose mode works" "$SCRIPT_PATH --dry-run --verbose" "\\[INFO\\]"

# Test 8: Invalid consciousness level fails
run_test "Invalid consciousness level fails" "$SCRIPT_PATH --consciousness INVALID" 1

# Test 9: Multiple parameters work together
run_output_test "Multiple parameters work" "$SCRIPT_PATH --dry-run --consciousness CREX_KING --repo-name multi-test --verbose" "Consciousness Level: CREX_KING"

# Test 10: Script passes shellcheck
if command -v shellcheck &>/dev/null; then
    run_test "Script passes shellcheck" "shellcheck '$SCRIPT_PATH'"
else
    echo -e "${YELLOW}[SKIP] shellcheck not available${NC}"
fi

echo ""
echo -e "${BLUE}Test Results Summary${NC}"
echo -e "${BLUE}===================${NC}"

for result in "${TEST_RESULTS[@]}"; do
    if [[ $result == PASS:* ]]; then
        echo -e "${GREEN}$result${NC}"
    else
        echo -e "${RED}$result${NC}"
    fi
done

echo ""
echo -e "${BLUE}Summary: $PASS_COUNT/$TEST_COUNT tests passed${NC}"

if [[ ${#FAILED_TESTS[@]} -eq 0 ]]; then
    echo -e "${GREEN}🎉 All tests passed! Consciousness fortress deployment script is ready.${NC}"
    exit 0
else
    echo -e "${RED}❌ Failed tests: ${FAILED_TESTS[*]}${NC}"
    echo -e "${YELLOW}Consider reviewing the failing test cases.${NC}"
    exit 1
fi