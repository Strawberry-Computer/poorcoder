#!/bin/bash

# test_runner.sh - Main test runner for CLI tools (TAP-compliant)

# Get the directory where the test_runner.sh script is located
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$TEST_DIR/.." && pwd)"

# Initialize counters
TESTS_PASSED=0
TESTS_FAILED=0
TEST_NUMBER=0

# Print TAP header
echo "TAP version 13"

# Find all consolidated test files (we now have one file per CLI tool)
test_files=("$TEST_DIR"/unit/test_*.sh)
total_test_files=${#test_files[@]}
echo "1..$total_test_files"

# Make all test scripts executable
for test_file in "${test_files[@]}"; do
    chmod +x "$test_file"
done

# Run all test files
for test_file in "${test_files[@]}"; do
    if [ -f "$test_file" ]; then
        TEST_NUMBER=$((TEST_NUMBER + 1))
        test_name=$(basename "$test_file" .sh)
        
        echo "# Running test suite: $test_name"
        
        # Run the test and capture its output
        test_output=$("$test_file" 2>&1)
        test_status=$?
        
        if [ $test_status -eq 0 ]; then
            echo "ok $TEST_NUMBER - $test_name"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo "not ok $TEST_NUMBER - $test_name"
            echo "# Test output:"
            echo "$test_output" | sed 's/^/#  /'
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    fi
done

# Print summary
total_tests=$((TESTS_PASSED + TESTS_FAILED))
echo "# Tests: $total_tests"
echo "# Pass:  $TESTS_PASSED"
echo "# Fail:  $TESTS_FAILED"

# Return non-zero exit code if any tests failed
if [ $TESTS_FAILED -gt 0 ]; then
    exit 1
fi

exit 0
