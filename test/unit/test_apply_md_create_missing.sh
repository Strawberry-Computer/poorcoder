#!/bin/bash

# test_apply_md_create_missing.sh - Tests for create-missing functionality (TAP-compliant)

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

# Create test markdown content with reference to a non-existent file
cat > "$test_dir/test_input.md" << EOF
# Test Markdown

This is a test markdown file with code blocks referencing files that don't exist.

\`\`\`txt new_file.txt
This is content for a new file
\`\`\`

\`\`\`js src/new_folder/script.js
// This is a JavaScript file in a new directory
function hello() {
  return "world";
}
\`\`\`
EOF

# Ensure apply-md script is executable
chmod +x "$PROJECT_ROOT/apply-md"

# Test 1: Without create-missing flag
output=$(cd "$test_dir" && cat test_input.md | "$PROJECT_ROOT/apply-md" 2>&1)
if [ ! -f "$test_dir/new_file.txt" ] && echo "$output" | grep -q "Warning: File does not exist"; then
    echo "ok $((test_number+=1)) - without create-missing flag"
else
    echo "not ok $((test_number+=1)) - without create-missing flag"
    echo "# File was created when it shouldn't have been or warning not shown"
    echo "# Output: $output"
    failures=$((failures + 1))
fi

# Test 2: With create-missing flag
output=$(cd "$test_dir" && cat test_input.md | "$PROJECT_ROOT/apply-md" --create-missing 2>&1)
if [ -f "$test_dir/new_file.txt" ] && [ -f "$test_dir/src/new_folder/script.js" ]; then
    echo "ok $((test_number+=1)) - with create-missing flag"
else
    echo "not ok $((test_number+=1)) - with create-missing flag"
    echo "# Files were not created correctly"
    echo "# Output: $output"
    failures=$((failures + 1))
fi

# Clean up
echo "# Tests completed, cleaning up"
cleanup_test_dir "$test_dir"

# Exit with success if all tests passed
exit $failures
