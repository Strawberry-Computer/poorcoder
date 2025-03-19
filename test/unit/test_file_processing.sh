#!/bin/bash

# test_file_processing.sh - Tests for file processing functionality

# Get the directory where this test script is located
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_ROOT="$(cd "$TEST_DIR/.." && pwd)"

# Source test utilities
source "$TEST_DIR/test_utils.sh"

# Create a temporary directory for this test
test_dir=$(create_test_dir)

# Setup test files
mkdir -p "$test_dir/src"
echo "// Test file 1" > "$test_dir/src/file1.js"
echo "// Test file 2" > "$test_dir/src/file2.js"
mkdir -p "$test_dir/node_modules"
echo "// Should be excluded" > "$test_dir/node_modules/exclude_me.js"

# Test 1: Basic file inclusion
echo "Testing basic file inclusion"
run_test "basic_file_inclusion" "cd $test_dir && $PROJECT_ROOT/context --files=src/file1.js | grep -q 'Test file 1'"

# Test 2: File pattern inclusion
echo "Testing file pattern inclusion"
run_test "file_pattern_inclusion" "cd $test_dir && $PROJECT_ROOT/context --files='src/*.js' | grep -q 'Test file 2'"

# Test 3: Exclude pattern
echo "Testing exclude pattern"
run_test "exclude_pattern" "cd $test_dir && $PROJECT_ROOT/context --files='**/*.js' --exclude='node_modules/**' | grep -qv 'Should be excluded'"

# Test 4: Multiple file patterns
echo "Testing multiple file patterns"
run_test "multiple_file_patterns" "cd $test_dir && $PROJECT_ROOT/context --files='src/file1.js' --files='src/file2.js' | grep -q 'Test file 1' && cd $test_dir && $PROJECT_ROOT/context --files='src/file1.js' --files='src/file2.js' | grep -q 'Test file 2'"

# Clean up
cleanup_test_dir "$test_dir"
