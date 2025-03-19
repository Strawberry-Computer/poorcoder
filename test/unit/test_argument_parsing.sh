#!/bin/bash

# test_argument_parsing.sh - Tests for command-line argument parsing

# Get the directory where this test script is located
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_ROOT="$(cd "$TEST_DIR/.." && pwd)"

# Source test utilities
source "$TEST_DIR/test_utils.sh"

# Create a temporary directory for this test
test_dir=$(create_test_dir)

# Setup test file
echo "// Test file" > "$test_dir/test.js"

# Test 1: Help option
echo "Testing help option"
run_test "help_option" "$PROJECT_ROOT/context --help | grep -q 'Usage:'"

# Test 2: Summary option
echo "Testing summary option"
run_test "summary_option" "cd $test_dir && $PROJECT_ROOT/context --files=test.js --summary | grep -q 'Summary:'"

# Test 3: No ls-files option
echo "Testing no ls-files option"
run_test "no_ls_files_option" "cd $test_dir && $PROJECT_ROOT/context --files=test.js --no-ls-files | grep -qv 'Repository Files'"

# Test 4: Verbose option
echo "Testing verbose option with non-existent file"
output=$(cd $test_dir && $PROJECT_ROOT/context --files=nonexistent.js --verbose 2>&1 || true)
run_test "verbose_option" "echo '$output' | grep -q 'Warning: File not found:'"

# Test 5: Invalid option
echo "Testing invalid option"
run_test "invalid_option" "! $PROJECT_ROOT/context --invalid-option 2>/dev/null"

# Clean up
cleanup_test_dir "$test_dir"
