#!/bin/bash

# test_git_context.sh - Comprehensive tests for the git-context CLI tool (TAP-compliant)

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
echo "1..9"

# Create a temporary directory for this test
test_dir=$(create_test_dir)
echo "# Using temporary directory: $test_dir"

# Setup a minimal git repository
mkdir -p "$test_dir/repo"
cd "$test_dir/repo" || exit 1
git init > /dev/null 2>&1
git config --local user.email "test@example.com"
git config --local user.name "Test User"

# Create a test file and make an initial commit
echo "Initial content" > test_file.txt
git add test_file.txt
git commit -m "Initial commit" > /dev/null 2>&1

# Make a change to test file for detecting diffs
echo "Modified content" >> test_file.txt
git add test_file.txt

# Create test prompt files
mkdir -p "$test_dir/repo/prompts"
# Don't create default prompts, they'll be used from script directory
echo "Custom prompt content" > "$test_dir/repo/custom_prompt.txt"

# Ensure git-context script is executable
chmod +x "$PROJECT_ROOT/git-context"

echo "# Section 1: Argument Parsing Tests"

# Test 1: Help option
help_output=$("$PROJECT_ROOT/git-context" --help 2>&1)
if echo "$help_output" | grep -q "Usage:"; then
    echo "ok $((test_number+=1)) - help option displays usage"
else
    echo "not ok $((test_number+=1)) - help option displays usage"
    echo "# Help output did not contain 'Usage:'"
    failures=$((failures + 1))
fi

# Test 2: No-prompt option
no_prompt_output=$(cd "$test_dir/repo" || exit 1 && "$PROJECT_ROOT/git-context" --no-prompt 2>&1)
if ! echo "$no_prompt_output" | grep -q "Commit Message Guidance"; then
    echo "ok $((test_number+=1)) - no-prompt option suppresses guidance"
else
    echo "not ok $((test_number+=1)) - no-prompt option suppresses guidance"
    echo "# Output contained 'Commit Message Guidance' despite --no-prompt"
    failures=$((failures + 1))
fi

# Test 3: Invalid option
if ! "$PROJECT_ROOT/git-context" --invalid-option >/dev/null 2>&1; then
    echo "ok $((test_number+=1)) - invalid option causes error"
else
    echo "not ok $((test_number+=1)) - invalid option causes error"
    echo "# Command with invalid option did not fail as expected"
    failures=$((failures + 1))
fi

echo "# Section 2: Output Format Tests"

# Make a change to test file for diff output
cd "$test_dir/repo" || exit 1
echo "Modified for diff" > test_file.txt

# Test 4: Check for Git Status section
output=$(cd "$test_dir/repo" || exit 1 && "$PROJECT_ROOT/git-context" 2>&1)
if echo "$output" | grep -q "## Git Status"; then
    echo "ok $((test_number+=1)) - output contains Git Status section"
else
    echo "not ok $((test_number+=1)) - output contains Git Status section"
    echo "# Output did not contain Git Status section"
    failures=$((failures + 1))
fi

# Test 5: Check for Files Changed section
if echo "$output" | grep -q "## Files Changed"; then
    echo "ok $((test_number+=1)) - output contains Files Changed section"
else
    echo "not ok $((test_number+=1)) - output contains Files Changed section"
    echo "# Output did not contain Files Changed section"
    failures=$((failures + 1))
fi

# Test 6: Check for Recent Commits section
if echo "$output" | grep -q "## Recent Commits"; then
    echo "ok $((test_number+=1)) - output contains Recent Commits section"
else
    echo "not ok $((test_number+=1)) - output contains Recent Commits section"
    echo "# Output did not contain Recent Commits section"
    failures=$((failures + 1))
fi

# Test 7: Check if output is in markdown format
if echo "$output" | grep -q "^#" && echo "$output" | grep -q "\`\`\`"; then
    echo "ok $((test_number+=1)) - output is in markdown format"
else
    echo "not ok $((test_number+=1)) - output is in markdown format"
    echo "# Output doesn't appear to be in markdown format"
    failures=$((failures + 1))
fi

echo "# Section 3: Prompt Handling Tests"

# Test 8: Default prompt
prompt_output=$(cd "$test_dir/repo" || exit 1 && "$PROJECT_ROOT/git-context" 2>&1)
if echo "$prompt_output" | grep -q "Based on the changes above"; then
    echo "ok $((test_number+=1)) - default prompt is included"
else
    echo "not ok $((test_number+=1)) - default prompt is included"
    echo "# Output did not contain default prompt content"
    echo "# Output: $(echo "$prompt_output" | grep -A 2 -B 2 "Commit Message Guidance" || echo "No guidance section found")"
    failures=$((failures + 1))
fi

# Test 9: Custom prompt file
custom_output=$(cd "$test_dir/repo" || exit 1 && "$PROJECT_ROOT/git-context" --prompt=custom_prompt.txt 2>&1)
if echo "$custom_output" | grep -q "Custom prompt content"; then
    echo "ok $((test_number+=1)) - custom prompt file is used"
else
    echo "not ok $((test_number+=1)) - custom prompt file is used"
    echo "# Output did not contain custom prompt content"
    echo "# Output: $(echo "$custom_output" | grep -A 2 -B 2 "Commit Message Guidance" || echo "No guidance section found")"
    failures=$((failures + 1))
fi

# Clean up
echo "# Tests completed, cleaning up"
cleanup_test_dir "$test_dir"

# Exit with success if all tests passed
exit $failures
