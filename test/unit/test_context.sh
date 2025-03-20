#!/bin/bash

# test_context.sh - Comprehensive tests for the context CLI tool (TAP-compliant)

# Get the directory where this test script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$TEST_DIR/.." && pwd)"

# Source test utilities
source "test/test_utils.sh"

# Initialize variables
test_number=0
failures=0

# Print TAP plan
echo "1..8"

# Create a temporary directory for this test
test_dir=$(create_test_dir)
echo "# Using temporary directory: $test_dir"

# Setup test files
mkdir -p "$test_dir/src"
echo "// Test file 1 - identifiable content" > "$test_dir/src/file1.js"
echo "// Test file 2 - identifiable content" > "$test_dir/src/file2.js"
mkdir -p "$test_dir/node_modules"
echo "// Should be excluded - node_modules content" > "$test_dir/node_modules/exclude_me.js"

# Setup test file with comments for basic tests
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

# Create a larger file for size tests
echo "This is a large test file that should be more than 3KB in size." > "$test_dir/large.txt"
dd if=/dev/zero bs=1 count=3500 >> "$test_dir/large.txt" 2>/dev/null

# Create a smaller file for size tests
echo "This is a small test file that should be less than 2KB in size." > "$test_dir/small.txt"
dd if=/dev/zero bs=1 count=500 >> "$test_dir/small.txt" 2>/dev/null

# Ensure context script is executable
chmod +x "$PROJECT_ROOT/context"

echo "# Section 1: Argument Parsing Tests"

# Test 1: Help option
help_output=$("$PROJECT_ROOT/context" --help 2>&1)
if echo "$help_output" | grep -q "Usage:"; then
    echo "ok $((test_number+=1)) - help option displays usage"
else
    echo "not ok $((test_number+=1)) - help option displays usage"
    echo "# Help output did not contain 'Usage:'"
    failures=$((failures + 1))
fi

# Test 2: No ls-files option
nolsfiles_output=$(cd "$test_dir" && "$PROJECT_ROOT/context" test.js --no-ls-files 2>&1)
if ! echo "$nolsfiles_output" | grep -q "Repository Files"; then
    echo "ok $((test_number+=1)) - no-ls-files option hides repository files"
else
    echo "not ok $((test_number+=1)) - no-ls-files option hides repository files"
    echo "# Output still contained 'Repository Files' despite --no-ls-files"
    failures=$((failures + 1))
fi

# Test 3: Invalid option
if ! "$PROJECT_ROOT/context" --invalid-option >/dev/null 2>&1; then
    echo "ok $((test_number+=1)) - invalid option causes error"
else
    echo "not ok $((test_number+=1)) - invalid option causes error"
    echo "# Command with invalid option did not fail as expected"
    failures=$((failures + 1))
fi

echo "# Section 2: File Processing Tests"

# Test 4: Basic file inclusion
if cd "$test_dir" && "$PROJECT_ROOT/context" src/file1.js | grep -q "Test file 1"; then
    echo "ok $((test_number+=1)) - basic file inclusion"
else
    echo "not ok $((test_number+=1)) - basic file inclusion"
    echo "# Command failed: cd $test_dir && $PROJECT_ROOT/context src/file1.js"
    failures=$((failures + 1))
fi

# Test 5: File pattern inclusion
if cd "$test_dir" && "$PROJECT_ROOT/context" src/file2.js | grep -q "Test file 2"; then
    echo "ok $((test_number+=1)) - file pattern inclusion"
else
    echo "not ok $((test_number+=1)) - file pattern inclusion"
    echo "# Command failed: cd $test_dir && $PROJECT_ROOT/context src/file2.js"
    failures=$((failures + 1))
fi

# Test 6: Exclude pattern
output=$(cd "$test_dir" && "$PROJECT_ROOT/context" src/file1.js --exclude="node_modules/" 2>&1)
if ! echo "$output" | grep -q "node_modules content"; then
    echo "ok $((test_number+=1)) - exclude pattern"
else
    echo "not ok $((test_number+=1)) - exclude pattern"
    echo "# Output contained excluded content"
    failures=$((failures + 1))
fi

# Test 7: Multiple file arguments
output=$(cd "$test_dir" && "$PROJECT_ROOT/context" src/file1.js src/file2.js 2>&1)
if echo "$output" | grep -q "Test file 1" && echo "$output" | grep -q "Test file 2"; then
    echo "ok $((test_number+=1)) - multiple file arguments"
else
    echo "not ok $((test_number+=1)) - multiple file arguments"
    echo "# Output did not contain both test files"
    failures=$((failures + 1))
fi

# Test 8: Max size limit not exceeded
small_output=$(cd "$test_dir" && "$PROJECT_ROOT/context" small.txt --max-size=2KB 2>&1)
# Check command status directly instead of using $?
if "$PROJECT_ROOT/context" small.txt --max-size=2KB >/dev/null 2>&1; then
    echo "ok $((test_number+=1)) - max size limit not exceeded"
else
    echo "not ok $((test_number+=1)) - max size limit not exceeded"
    echo "# Command failed unexpectedly"
    echo "# Output: $small_output"
    failures=$((failures + 1))
fi

# Clean up
echo "# Tests completed, cleaning up"
cleanup_test_dir "$test_dir"

# Exit with success if all tests passed
exit $failures
