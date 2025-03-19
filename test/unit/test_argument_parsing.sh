#!/bin/bash

# test_argument_parsing.sh - Tests for command-line argument parsing

# Get the directory where this test script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$TEST_DIR/.." && pwd)"

# Source test utilities
source "$TEST_DIR/test_utils.sh"

# Test description
echo "Testing command-line argument parsing"

# Create a temporary directory for this test
test_dir=$(create_test_dir)
echo "Using temporary directory: $test_dir"

# Setup test file
echo "// Test file" > "$test_dir/test.js"

# Ensure context script is executable
chmod +x "$PROJECT_ROOT/context"

# Test 1: Help option
echo "Testing help option"
run_test "help_option" "\"$PROJECT_ROOT/context\" --help | grep -q 'Usage:'"

# Test 2: Summary option
echo "Testing summary option"
run_test "summary_option" "cd \"$test_dir\" && \"$PROJECT_ROOT/context\" --files=\"test.js\" --summary | grep -q 'Summary:'"

# Test 3: No ls-files option
echo "Testing no ls-files option"
run_test "no_ls_files_option" "cd \"$test_dir\" && \"$PROJECT_ROOT/context\" --files=\"test.js\" --no-ls-files | grep -qv 'Repository Files'"

# Test 4: Verbose option
echo "Testing verbose option with non-existent file"
output=$(cd "$test_dir" && "$PROJECT_ROOT/context" --files="nonexistent.js" --verbose 2>&1 || true)
run_test "verbose_option" "echo \"$output\" | grep -q 'Warning: File not found:'"

# Test 5: Invalid option
echo "Testing invalid option"
run_test "invalid_option" "! \"$PROJECT_ROOT/context\" --invalid-option 2>/dev/null"

# Clean up
echo "Cleaning up temporary directory"
cleanup_test_dir "$test_dir"

# Exit with success
exit 0
