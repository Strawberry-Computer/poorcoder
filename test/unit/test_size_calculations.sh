#!/bin/bash

# test_size_calculations.sh - Tests for size calculation and truncation

# Get the directory where this test script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$TEST_DIR/.." && pwd)"

# Source test utilities
source "$TEST_DIR/test_utils.sh"

# Test description
echo "Testing size calculations and truncation"

# Create a temporary directory for this test
test_dir=$(create_test_dir)
echo "Using temporary directory: $test_dir"

# Setup test files
create_test_file "$test_dir/small.txt" 1024  # 1KB file
create_test_file "$test_dir/large.txt" 5120  # 5KB file

# Ensure context script is executable
chmod +x "$PROJECT_ROOT/context"

# Test 1: Max size limit not exceeded
echo "Testing max size limit not exceeded"
run_test "max_size_not_exceeded" "cd \"$test_dir\" && \"$PROJECT_ROOT/context\" --files=\"small.txt\" --max-size=2KB"

# Test 2: Max size limit exceeded
echo "Testing max size limit exceeded"
max_size_exceeded_test="cd \"$test_dir\" && ! \"$PROJECT_ROOT/context\" --files=\"small.txt\" --files=\"large.txt\" --max-size=2KB"
run_test "max_size_exceeded" "$max_size_exceeded_test"

# Test 3: File truncation
echo "Testing file truncation"
result=$(cd "$test_dir" && "$PROJECT_ROOT/context" --files="large.txt" --truncate-large=2KB)
run_test "file_truncation" "echo \"$result\" | grep -q '\[File truncated due to size limit\]'"

# Test 4: Human readable size display
echo "Testing human readable size display"
result=$(cd "$test_dir" && "$PROJECT_ROOT/context" --files="small.txt" --show-file-sizes)
run_test "human_readable_size" "echo \"$result\" | grep -q 'Size: 1 KB'"

# Clean up
echo "Cleaning up temporary directory"
cleanup_test_dir "$test_dir"

# Exit with success
exit 0
