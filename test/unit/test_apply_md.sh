#!/bin/bash

# test_apply_md.sh - Comprehensive tests for the apply-md CLI tool (TAP-compliant)

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
echo "1..10"

# Create a temporary directory for this test
test_dir=$(create_test_dir)
echo "# Using temporary directory: $test_dir"

# Create test file for basic tests
echo "Original content" > "$test_dir/test_file.txt"

# Create test markdown content for basic tests
cat > "$test_dir/test_input.md" << EOF
# Test Markdown

This is a test markdown file with code blocks.

\`\`\`txt test_file.txt
Updated content
\`\`\`
EOF

# Create test markdown with multiple code blocks
cat > "$test_dir/multiple_blocks.md" << EOF
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

# Create test markdown content with reference to non-existent files
cat > "$test_dir/missing_files.md" << EOF
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

echo "# Section 1: Argument Parsing Tests"

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
if ! "$PROJECT_ROOT/apply-md" --invalid-option >/dev/null 2>&1 && echo "$invalid_output" | grep -q "Unknown parameter"; then
    echo "ok $((test_number+=1)) - invalid option causes error"
else
    echo "not ok $((test_number+=1)) - invalid option causes error"
    echo "# Command with invalid option did not fail as expected"
    echo "# Output: $invalid_output"
    failures=$((failures + 1))
fi

# Test 3: Combined arguments
output=$(cd "$test_dir" && "$PROJECT_ROOT/apply-md" --dry-run --verbose < test_input.md 2>&1)
if echo "$output" | grep -q "DRY RUN" && echo "$output" | grep -q "Starting markdown code application"; then
    echo "ok $((test_number+=1)) - combined arguments work correctly"
else
    echo "not ok $((test_number+=1)) - combined arguments work correctly"
    echo "# Combined arguments did not produce expected output"
    echo "# Output: $output"
    failures=$((failures + 1))
fi

echo "# Section 2: Basic Functionality Tests"

# Create test files for basic functionality
echo "Original content" > "$test_dir/file1.txt"
echo "Original content" > "$test_dir/file2.txt"

# Test 4: Basic file update
if cd "$test_dir" && "$PROJECT_ROOT/apply-md" < test_input.md && grep -q "Updated content" test_file.txt; then
    echo "ok $((test_number+=1)) - basic file update"
else
    echo "not ok $((test_number+=1)) - basic file update"
    echo "# File was not updated correctly"
    failures=$((failures + 1))
fi

# Test 5: Dry run mode
echo "Original content" > "$test_dir/test_file.txt"
output=$(cd "$test_dir" && "$PROJECT_ROOT/apply-md" --dry-run < test_input.md 2>&1)
if grep -q "Original content" "$test_dir/test_file.txt" && echo "$output" | grep -q "Would update file"; then
    echo "ok $((test_number+=1)) - dry run mode"
else
    echo "not ok $((test_number+=1)) - dry run mode"
    echo "# Dry run modified the file or didn't show the correct output"
    echo "# Output: $output"
    failures=$((failures + 1))
fi

# Test 6: Verbose mode
output=$(cd "$test_dir" && "$PROJECT_ROOT/apply-md" --verbose < test_input.md 2>&1)
if echo "$output" | grep -q "Starting markdown code application"; then
    echo "ok $((test_number+=1)) - verbose mode"
else
    echo "not ok $((test_number+=1)) - verbose mode"
    echo "# Verbose mode didn't display expected output"
    echo "# Output: $output"
    failures=$((failures + 1))
fi

echo "# Section 3: Create Missing Files Tests"

# Test 7: Without create-missing flag
output=$(cd "$test_dir" && "$PROJECT_ROOT/apply-md" < missing_files.md 2>&1)
if [ ! -f "$test_dir/new_file.txt" ] && echo "$output" | grep -q "Warning: File does not exist"; then
    echo "ok $((test_number+=1)) - without create-missing flag"
else
    echo "not ok $((test_number+=1)) - without create-missing flag"
    echo "# File was created when it shouldn't have been or warning not shown"
    echo "# Output: $output"
    failures=$((failures + 1))
fi

# Test 8: With create-missing flag
output=$(cd "$test_dir" && "$PROJECT_ROOT/apply-md" --create-missing < missing_files.md 2>&1)
if [ -f "$test_dir/new_file.txt" ] && [ -f "$test_dir/src/new_folder/script.js" ]; then
    echo "ok $((test_number+=1)) - with create-missing flag"
else
    echo "not ok $((test_number+=1)) - with create-missing flag"
    echo "# Files were not created correctly"
    echo "# Output: $output"
    failures=$((failures + 1))
fi

echo "# Section 4: Multiple Blocks Tests"

# Test 9: Multiple file updates
output=$(cd "$test_dir" && "$PROJECT_ROOT/apply-md" --create-missing < multiple_blocks.md 2>&1)
if grep -q "Updated content 1" "$test_dir/file1.txt" && grep -q "Updated content 2" "$test_dir/file2.txt"; then
    echo "ok $((test_number+=1)) - multiple file updates"
else
    echo "not ok $((test_number+=1)) - multiple file updates"
    echo "# Files were not updated correctly"
    echo "# Output: $output"
    failures=$((failures + 1))
fi

# Test 10: Language specification is handled correctly
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
