#!/bin/bash

# test_git_prompt_handling.sh - Tests for git-context prompt handling (TAP-compliant)

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

# Setup a minimal git repository
mkdir -p "$test_dir/repo"
cd "$test_dir/repo"
git init > /dev/null 2>&1
git config --local user.email "test@example.com"
git config --local user.name "Test User"

# Create a test file and make an initial commit
echo "Initial content" > test_file.txt
git add test_file.txt
git commit -m "Initial commit" > /dev/null 2>&1

# Create test prompt files
mkdir -p "$test_dir/repo/prompts"
echo "Default prompt content" > "$test_dir/repo/prompts/commit_prompt.txt"
echo "Conventional commit content" > "$test_dir/repo/prompts/conventional_commit.txt"
echo "Custom prompt content" > "$test_dir/repo/custom_prompt.txt"

# Ensure git-context script is executable
chmod +x "$PROJECT_ROOT/git-context"

# Test 1: Default prompt
output=$("$PROJECT_ROOT/git-context" 2>&1)
if echo "$output" | grep -q "Default prompt content"; then
    echo "ok $((test_number+=1)) - default prompt is included"
else
    echo "not ok $((test_number+=1)) - default prompt is included"
    echo "# Output did not contain default prompt content"
    echo "# Output: $(echo "$output" | grep -A 2 -B 2 "Commit Message Guidance" || echo "No guidance section found")"
    failures=$((failures + 1))
fi

# Test 2: Custom prompt file
custom_output=$("$PROJECT_ROOT/git-context" --prompt=custom_prompt.txt 2>&1)
if echo "$custom_output" | grep -q "Custom prompt content"; then
    echo "ok $((test_number+=1)) - custom prompt file is used"
else
    echo "not ok $((test_number+=1)) - custom prompt file is used"
    echo "# Output did not contain custom prompt content"
    echo "# Output: $(echo "$custom_output" | grep -A 2 -B 2 "Commit Message Guidance" || echo "No guidance section found")"
    failures=$((failures + 1))
fi

# Test 3: Conventional commit prompt
conventional_output=$("$PROJECT_ROOT/git-context" --prompt=prompts/conventional_commit.txt 2>&1)
if echo "$conventional_output" | grep -q "Conventional commit content"; then
    echo "ok $((test_number+=1)) - conventional commit prompt is used"
else
    echo "not ok $((test_number+=1)) - conventional commit prompt is used"
    echo "# Output did not contain conventional commit content"
    echo "# Output: $(echo "$conventional_output" | grep -A 2 -B 2 "Commit Message Guidance" || echo "No guidance section found")"
    failures=$((failures + 1))
fi

# Clean up
echo "# Tests completed, cleaning up"
cleanup_test_dir "$test_dir"

# Exit with success if all tests passed
exit $failures
