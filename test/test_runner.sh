#!/bin/bash

# test_runner.sh - Main test runner for context script

# Exit on error
set -e

# Get the directory where the test_runner.sh script is located
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$TEST_DIR/.." && pwd)"

# Source test utilities
source "$TEST_DIR/test_utils.sh"

# Print header
echo "===================================="
echo "Running tests for context script"
echo "===================================="

# Run all test files
for test_file in "$TEST_DIR"/unit/test_*.sh; do
    if [ -f "$test_file" ]; then
        echo ""
        echo "Running tests in $(basename "$test_file")"
        echo "------------------------------------"
        bash "$test_file"
        
        # Capture exit status
        test_status=$?
        if [ $test_status -ne 0 ]; then
            echo "Test file $(basename "$test_file") failed with status $test_status"
        fi
    fi
done

# Print summary
echo ""
echo "===================================="
echo "Test Results: $TESTS_PASSED passed, $TESTS_FAILED failed"
echo "===================================="

# Return non-zero exit code if any tests failed
if [ $TESTS_FAILED -gt 0 ]; then
    exit 1
fi

exit 0
