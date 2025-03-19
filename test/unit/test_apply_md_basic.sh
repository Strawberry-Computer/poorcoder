#!/bin/bash

# test_apply_md_basic.sh - Basic tests for apply-md functionality (TAP-compliant)

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
echo "1..3"

# Create a temporary directory for this test
test_dir=$(create_test_dir)
echo "# Using temporary directory: $test_dir"

# Create test file
echo "Original content" > "$test_dir/test_file.txt"

# Create test markdown content
cat > "$test_dir/test_input.md" << EOF
# Test Markdown

This is a test markdown file with code blocks.

\`\`\`txt test_file.txt
Updated content
\`\`\`
EOF

# Ensure apply-md script is executable
chmod +x "$PROJECT_ROOT/apply-md"

# Test 1: Basic file update
if cd "$test_dir" && cat test_input.md | "$PROJECT_ROOT/apply-md" && grep -q "Updated content" test_file.txt; then
    echo "ok $((test_number+=1)) - basic file update"
else
    echo "not ok $((test_number+=1)) - basic file update"
    echo "# File was not updated correctly"
    failures=$((failures + 1))
fi

# Test 2: Dry run mode
echo "Original content" > "$test_dir/test_file.txt"
output=$(cd "$test_dir" && cat test_input.md | "$PROJECT_ROOT/apply-md" --dry-run 2>&1)
if grep -q "Original content" "$test_dir/test_file.txt" && echo "$output" | grep -q "Would update file"; then
    echo "ok $((test_number+=1)) - dry run mode"
else
    echo "not ok $((test_number+=1)) - dry run mode"
    echo "# Dry run modified the file or didn't show the correct output"
    echo "# Output: $output"
    failures=$((failures + 1))
fi

# Test 3: Verbose mode
output=$(cd "$test_dir" && cat test_input.md | "$PROJECT_ROOT/apply-md" --verbose 2>&1)
if echo "$output" | grep -q "Starting markdown code application"; then
    echo "ok $((test_number+=1)) - verbose mode"
else
    echo "not ok $((test_number+=1)) - verbose mode"
    echo "# Verbose mode didn't display expected output"
    echo "# Output: $output"
    failures=$((failures + 1))
fi

# Clean up
echo "# Tests completed, cleaning up"
cleanup_test_dir "$test_dir"

# Exit with success if all tests passed
exit $failures
