#!/bin/bash

# test_argument_parsing.sh - Tests for command-line argument parsing (TAP-compliant)

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

# Setup test file with comments for summary test
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

# Ensure context script is executable
chmod +x "$PROJECT_ROOT/context"

# Test 1: Help option
help_output=$("$PROJECT_ROOT/context" --help 2>&1)
if echo "$help_output" | grep -q "Usage:"; then
    echo "ok $((test_number+=1)) - help option displays usage"
else
    echo "not ok $((test_number+=1)) - help option displays usage"
    echo "# Help output did not contain 'Usage:'"
    failures=$((failures + 1))
fi

# Test 2: Summary option
summary_output=$(cd "$test_dir" && "$PROJECT_ROOT/context" test.js --summary 2>&1)
if echo "$summary_output" | grep -q "Summary:"; then
    echo "ok $((test_number+=1)) - summary option displays summary"
else
    echo "not ok $((test_number+=1)) - summary option displays summary"
    echo "# Summary output did not contain 'Summary:'"
    echo "# Output: $summary_output"
    failures=$((failures + 1))
fi

# Test 3: No ls-files option
nolsfiles_output=$(cd "$test_dir" && "$PROJECT_ROOT/context" test.js --no-ls-files 2>&1)
if ! echo "$nolsfiles_output" | grep -q "Repository Files"; then
    echo "ok $((test_number+=1)) - no-ls-files option hides repository files"
else
    echo "not ok $((test_number+=1)) - no-ls-files option hides repository files"
    echo "# Output still contained 'Repository Files' despite --no-ls-files"
    failures=$((failures + 1))
fi

# Test 4: Invalid option
if ! "$PROJECT_ROOT/context" --invalid-option >/dev/null 2>&1; then
    echo "ok $((test_number+=1)) - invalid option causes error"
else
    echo "not ok $((test_number+=1)) - invalid option causes error"
    echo "# Command with invalid option did not fail as expected"
    failures=$((failures + 1))
fi

# Clean up
echo "# Tests completed, cleaning up"
cleanup_test_dir "$test_dir"

# Exit with success if all tests passed
exit $failures
