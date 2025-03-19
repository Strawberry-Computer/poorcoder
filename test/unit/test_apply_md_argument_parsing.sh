#!/bin/bash

# test_apply_md_argument_parsing.sh - Tests for apply-md argument parsing (TAP-compliant)

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

# Ensure apply-md script is executable
chmod +x "$PROJECT_ROOT/apply-md"

# Test 1: Help option
help_output=$("$PROJECT_ROOT/apply-md" --help 2>&1)
if echo "$help_output" | grep -q "Usage:"; then
    echo "ok $((test_number+=1)) - help option displays usage"
else
    echo "not ok $((test_number+=1)) - help option displays usage"
    echo "# Help output did not contain 'Usage:'"
    echo "# Output: $help_output"
    failures=$((failures + 1))
fi

# Test 2: Invalid option
invalid_output=$("$PROJECT_ROOT/apply-md" --invalid-option 2>&1)
if [ $? -ne 0 ] && echo "$invalid_output" | grep -q "Unknown parameter"; then
    echo "ok $((test_number+=1)) - invalid option causes error"
else
    echo "not ok $((test_number+=1)) - invalid option causes error"
    echo "# Command with invalid option did not fail as expected"
    echo "# Output: $invalid_output"
    failures=$((failures + 1))
fi

# Test 3: Combined arguments
# Create test file
echo "Original content" > "$test_dir/test_file.txt"

# Create test markdown content
cat > "$test_dir/test_input.md" << EOF
\`\`\`txt test_file.txt
Updated content
\`\`\`
EOF

output=$(cd "$test_dir" && cat test_input.md | "$PROJECT_ROOT/apply-md" --dry-run --verbose 2>&1)
if echo "$output" | grep -q "DRY RUN" && echo "$output" | grep -q "Starting markdown code application"; then
    echo "ok $((test_number+=1)) - combined arguments work correctly"
else
    echo "not ok $((test_number+=1)) - combined arguments work correctly"
    echo "# Combined arguments did not produce expected output"
    echo "# Output: $output"
    failures=$((failures + 1))
fi

# Clean up
echo "# Tests completed, cleaning up"
cleanup_test_dir "$test_dir"

# Exit with success if all tests passed
exit $failures
