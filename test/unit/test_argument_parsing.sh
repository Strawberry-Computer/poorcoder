#!/bin/bash

# test_argument_parsing.sh - Tests for command-line argument parsing (TAP-compliant)

# Get the directory where this test script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$TEST_DIR/.." && pwd)"

# Source test utilities
source "$TEST_DIR/test_utils.sh"

# Initialize test counters for this file
TESTS_PASSED=0
TESTS_FAILED=0
TEST_NUMBER_INTERNAL=0

# Print TAP plan
echo "1..4"  # Reduced from 5 to 4 tests

# Create a temporary directory for this test
test_dir=$(create_test_dir)
echo "# Using temporary directory: $test_dir"

# Setup test file with comments for summary test
cat > "$test_dir/test.js" << EOF
// Test file header
// This is a description
// A third comment line
// And one more comment
function test() {
  // This is a function
  console.log("Hello");
}
EOF

# Ensure context script is executable
chmod +x "$PROJECT_ROOT/context"

# Test 1: Help option
TEST_NUMBER_INTERNAL=$((TEST_NUMBER_INTERNAL + 1))
help_output=$("$PROJECT_ROOT/context" --help 2>&1)
if echo "$help_output" | grep -q "Usage:"; then
    echo "ok $TEST_NUMBER_INTERNAL - help option displays usage"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "not ok $TEST_NUMBER_INTERNAL - help option displays usage"
    echo "# Help output did not contain 'Usage:'"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 2: Summary option
TEST_NUMBER_INTERNAL=$((TEST_NUMBER_INTERNAL + 1))
summary_output=$(cd "$test_dir" && "$PROJECT_ROOT/context" test.js --summary 2>&1)
if echo "$summary_output" | grep -q "Summary:"; then
    echo "ok $TEST_NUMBER_INTERNAL - summary option displays summary"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "not ok $TEST_NUMBER_INTERNAL - summary option displays summary"
    echo "# Summary output did not contain 'Summary:'"
    echo "# Output: $summary_output"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 3: No ls-files option
TEST_NUMBER_INTERNAL=$((TEST_NUMBER_INTERNAL + 1))
nolsfiles_output=$(cd "$test_dir" && "$PROJECT_ROOT/context" test.js --no-ls-files 2>&1)
if ! echo "$nolsfiles_output" | grep -q "Repository Files"; then
    echo "ok $TEST_NUMBER_INTERNAL - no-ls-files option hides repository files"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "not ok $TEST_NUMBER_INTERNAL - no-ls-files option hides repository files"
    echo "# Output still contained 'Repository Files' despite --no-ls-files"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 4: Invalid option (previously Test 5)
TEST_NUMBER_INTERNAL=$((TEST_NUMBER_INTERNAL + 1))
if ! "$PROJECT_ROOT/context" --invalid-option >/dev/null 2>&1; then
    echo "ok $TEST_NUMBER_INTERNAL - invalid option causes error"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "not ok $TEST_NUMBER_INTERNAL - invalid option causes error"
    echo "# Command with invalid option did not fail as expected"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Clean up
echo "# Tests completed, cleaning up"
cleanup_test_dir "$test_dir"

# Update test results file
echo "PASSED:$TESTS_PASSED" > "$TEST_DIR/test_results.txt"
echo "FAILED:$TESTS_FAILED" >> "$TEST_DIR/test_results.txt"

# Exit with success if all tests passed
if [ $TESTS_FAILED -eq 0 ]; then
    exit 0
else
    exit 1
fi
