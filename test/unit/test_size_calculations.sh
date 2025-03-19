#!/bin/bash

# test_size_calculations.sh - Tests for size calculation and truncation (TAP-compliant)

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
echo "1..4"

# Create a temporary directory for this test
test_dir=$(create_test_dir)
echo "# Using temporary directory: $test_dir"

# Setup test files with meaningful content
echo "This is a small test file that should be less than 2KB in size." > "$test_dir/small.txt"
dd if=/dev/zero bs=1 count=1000 >> "$test_dir/small.txt" 2>/dev/null

# Create a larger file
echo "This is a large test file that should be more than 2KB in size." > "$test_dir/large.txt"
dd if=/dev/zero bs=1 count=4000 >> "$test_dir/large.txt" 2>/dev/null

# Ensure context script is executable
chmod +x "$PROJECT_ROOT/context"

# Test 1: Max size limit not exceeded
TEST_NUMBER_INTERNAL=$((TEST_NUMBER_INTERNAL + 1))
if cd "$test_dir" && "$PROJECT_ROOT/context" small.txt --max-size=2KB > /dev/null; then
    echo "ok $TEST_NUMBER_INTERNAL - max size limit not exceeded"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "not ok $TEST_NUMBER_INTERNAL - max size limit not exceeded"
    echo "# Command failed unexpectedly"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 2: Max size limit exceeded
TEST_NUMBER_INTERNAL=$((TEST_NUMBER_INTERNAL + 1))
if ! cd "$test_dir" && "$PROJECT_ROOT/context" small.txt large.txt --max-size=2KB > /dev/null 2>&1; then
    echo "ok $TEST_NUMBER_INTERNAL - max size limit exceeded"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "not ok $TEST_NUMBER_INTERNAL - max size limit exceeded"
    echo "# Command succeeded when it should have failed"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 3: File truncation
TEST_NUMBER_INTERNAL=$((TEST_NUMBER_INTERNAL + 1))
truncation_output=$(cd "$test_dir" && "$PROJECT_ROOT/context" large.txt --truncate-large=2KB 2>&1)
if echo "$truncation_output" | grep -q "File truncated"; then
    echo "ok $TEST_NUMBER_INTERNAL - file truncation"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "not ok $TEST_NUMBER_INTERNAL - file truncation"
    echo "# Output did not contain truncation message"
    echo "# Output: $(echo "$truncation_output" | grep -A 2 -B 2 "large.txt" || echo "No content found")"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 4: Human readable size display
TEST_NUMBER_INTERNAL=$((TEST_NUMBER_INTERNAL + 1))
size_output=$(cd "$test_dir" && "$PROJECT_ROOT/context" small.txt --show-file-sizes 2>&1)
if echo "$size_output" | grep -q "Size:"; then
    echo "ok $TEST_NUMBER_INTERNAL - human readable size display"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "not ok $TEST_NUMBER_INTERNAL - human readable size display"
    echo "# Output did not contain size information"
    echo "# Output: $size_output"
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
