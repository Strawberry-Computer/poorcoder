#!/bin/bash

# test_apply_md_multiple_blocks.sh - Tests for handling multiple code blocks (TAP-compliant)

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
echo "1..2"

# Create a temporary directory for this test
test_dir=$(create_test_dir)
echo "# Using temporary directory: $test_dir"

# Create test files
echo "Original content 1" > "$test_dir/file1.txt"
echo "Original content 2" > "$test_dir/file2.txt"

# Create test markdown content with multiple code blocks
cat > "$test_dir/test_input.md" << EOF
# Test Markdown

This is a test markdown file with multiple code blocks.

\`\`\`txt file1.txt
Updated content 1
\`\`\`

Some text in between code blocks.

\`\`\`txt file2.txt
Updated content 2
\`\`\`

Another code block with a different language:

\`\`\`js file3.js
// This is JavaScript content
console.log("Hello world");
\`\`\`
EOF

# Ensure apply-md script is executable
chmod +x "$PROJECT_ROOT/apply-md"

# Test 1: Multiple file updates
output=$(cd "$test_dir" && cat test_input.md | "$PROJECT_ROOT/apply-md" --create-missing 2>&1)
if grep -q "Updated content 1" "$test_dir/file1.txt" && grep -q "Updated content 2" "$test_dir/file2.txt"; then
    echo "ok $((test_number+=1)) - multiple file updates"
else
    echo "not ok $((test_number+=1)) - multiple file updates"
    echo "# Files were not updated correctly"
    echo "# Output: $output"
    failures=$((failures + 1))
fi

# Test 2: Language specification is handled correctly
if [ -f "$test_dir/file3.js" ] && grep -q "Hello world" "$test_dir/file3.js"; then
    echo "ok $((test_number+=1)) - language specification handled correctly"
else
    echo "not ok $((test_number+=1)) - language specification handled correctly"
    echo "# File with language specification not created or updated correctly"
    echo "# Output: $output"
    failures=$((failures + 1))
fi

# Clean up
echo "# Tests completed, cleaning up"
cleanup_test_dir "$test_dir"

# Exit with success if all tests passed
exit $failures
