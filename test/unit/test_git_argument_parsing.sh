#!/bin/bash

# test_git_argument_parsing.sh - Tests for git-context command-line argument parsing (TAP-compliant)

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

# Ensure git-context script is executable
chmod +x "$PROJECT_ROOT/git-context"

# Test 1: Help option
help_output=$("$PROJECT_ROOT/git-context" --help 2>&1)
if echo "$help_output" | grep -q "Usage:"; then
    echo "ok $((test_number+=1)) - help option displays usage"
else
    echo "not ok $((test_number+=1)) - help option displays usage"
    echo "# Help output did not contain 'Usage:'"
    failures=$((failures + 1))
fi

# Test 2: Recent commits option
# Modify the file and make additional commits
echo "Second commit content" >> test_file.txt
git add test_file.txt
git commit -m "Second commit" > /dev/null 2>&1
echo "Third commit content" >> test_file.txt
git add test_file.txt
git commit -m "Third commit" > /dev/null 2>&1

# Check that --recent-commits=1 only shows one commit
recent_commits_output=$("$PROJECT_ROOT/git-context" --recent-commits=1 2>&1)
if echo "$recent_commits_output" | grep -q "Recent Commits" && 
   [ $(echo "$recent_commits_output" | grep -c "commit") -eq 1 ]; then
    echo "ok $((test_number+=1)) - recent-commits option limits commit count"
else
    echo "not ok $((test_number+=1)) - recent-commits option limits commit count"
    echo "# Output did not show exactly 1 commit with --recent-commits=1"
    echo "# Output: $recent_commits_output"
    failures=$((failures + 1))
fi

# Test 3: No-prompt option
no_prompt_output=$("$PROJECT_ROOT/git-context" --no-prompt 2>&1)
if ! echo "$no_prompt_output" | grep -q "Commit Message Guidance"; then
    echo "ok $((test_number+=1)) - no-prompt option suppresses guidance"
else
    echo "not ok $((test_number+=1)) - no-prompt option suppresses guidance"
    echo "# Output contained 'Commit Message Guidance' despite --no-prompt"
    failures=$((failures + 1))
fi

# Test 4: Invalid option
if ! "$PROJECT_ROOT/git-context" --invalid-option >/dev/null 2>&1; then
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
