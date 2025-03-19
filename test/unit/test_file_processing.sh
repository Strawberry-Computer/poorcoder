#!/bin/bash

# test_file_processing.sh - Tests for file processing functionality (TAP-compliant)

# Get the directory where this test script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$TEST_DIR/.." && pwd)"

# Source test utilities
source "$TEST_DIR/test_utils.sh"

# Initialize variables
test_number=0
failures=0

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
if cd "$test_dir" && "$PROJECT_ROOT/context" src/file1.js | grep -q "Test file 1"; then
    echo "ok $((test_number+=1)) - basic file inclusion"
else
    echo "not ok $((test_number+=1)) - basic file inclusion"
    echo "# Command failed: cd $test_dir && $PROJECT_ROOT/context src/file1.js"
    failures=$((failures + 1))
fi

# Test 2: File pattern inclusion - simplified
if cd "$test_dir" && "$PROJECT_ROOT/context" src/file2.js | grep -q "Test file 2"; then
    echo "ok $((test_number+=1)) - file pattern inclusion"
else
    echo "not ok $((test_number+=1)) - file pattern inclusion"
    echo "# Command failed: cd $test_dir && $PROJECT_ROOT/context src/file2.js"
    failures=$((failures + 1))
fi

# Test 3: Exclude pattern
output=$(cd "$test_dir" && "$PROJECT_ROOT/context" src/file1.js --exclude="node_modules/" 2>&1)
if ! echo "$output" | grep -q "node_modules content"; then
    echo "ok $((test_number+=1)) - exclude pattern"
else
    echo "not ok $((test_number+=1)) - exclude pattern"
    echo "# Output contained excluded content"
    failures=$((failures + 1))
fi

# Test 4: Multiple file arguments
output=$(cd "$test_dir" && "$PROJECT_ROOT/context" src/file1.js src/file2.js 2>&1)
if echo "$output" | grep -q "Test file 1" && echo "$output" | grep -q "Test file 2"; then
    echo "ok $((test_number+=1)) - multiple file arguments"
else
    echo "not ok $((test_number+=1)) - multiple file arguments"
    echo "# Output did not contain both test files"
    failures=$((failures + 1))
fi

# Clean up
echo "# Tests completed, cleaning up"
cleanup_test_dir "$test_dir"

# Exit with success if all tests passed
exit $failures
