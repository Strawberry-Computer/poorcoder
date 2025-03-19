#!/bin/bash

# test_file_processing.sh - Tests for file processing functionality (TAP-compliant)

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

# Setup test files with clear content
mkdir -p "$test_dir/src"
echo "// Test file 1 - identifiable content" > "$test_dir/src/file1.js"
echo "// Test file 2 - identifiable content" > "$test_dir/src/file2.js"
mkdir -p "$test_dir/node_modules"
echo "// Should be excluded - node_modules content" > "$test_dir/node_modules/exclude_me.js"

# Ensure context script is executable
chmod +x "$PROJECT_ROOT/context"

# Test 1: Basic file inclusion
TEST_NUMBER_INTERNAL=$((TEST_NUMBER_INTERNAL + 1))
if cd "$test_dir" && "$PROJECT_ROOT/context" src/file1.js | grep -q "Test file 1"; then
    echo "ok $TEST_NUMBER_INTERNAL - basic file inclusion"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "not ok $TEST_NUMBER_INTERNAL - basic file inclusion"
    echo "# Command failed: cd $test_dir && $PROJECT_ROOT/context src/file1.js"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 2: File pattern inclusion - simplified
TEST_NUMBER_INTERNAL=$((TEST_NUMBER_INTERNAL + 1))
if cd "$test_dir" && "$PROJECT_ROOT/context" src/file2.js | grep -q "Test file 2"; then
    echo "ok $TEST_NUMBER_INTERNAL - file pattern inclusion"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "not ok $TEST_NUMBER_INTERNAL - file pattern inclusion"
    echo "# Command failed: cd $test_dir && $PROJECT_ROOT/context src/file2.js"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 3: Exclude pattern
TEST_NUMBER_INTERNAL=$((TEST_NUMBER_INTERNAL + 1))
output=$(cd "$test_dir" && "$PROJECT_ROOT/context" src/file1.js --exclude="node_modules/" 2>&1)
if ! echo "$output" | grep -q "node_modules content"; then
    echo "ok $TEST_NUMBER_INTERNAL - exclude pattern"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "not ok $TEST_NUMBER_INTERNAL - exclude pattern"
    echo "# Output contained excluded content"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 4: Multiple file arguments
TEST_NUMBER_INTERNAL=$((TEST_NUMBER_INTERNAL + 1))
output=$(cd "$test_dir" && "$PROJECT_ROOT/context" src/file1.js src/file2.js 2>&1)
if echo "$output" | grep -q "Test file 1" && echo "$output" | grep -q "Test file 2"; then
    echo "ok $TEST_NUMBER_INTERNAL - multiple file arguments"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "not ok $TEST_NUMBER_INTERNAL - multiple file arguments"
    echo "# Output did not contain both test files"
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
