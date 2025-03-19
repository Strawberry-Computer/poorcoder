#!/bin/bash

# test_git_output_format.sh - Tests for git-context output format (TAP-compliant)

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
echo "1..5"

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

# Make a change to test file
echo "Modified content" >> test_file.txt

# Ensure git-context script is executable
chmod +x "$PROJECT_ROOT/git-context"

# Test 1: Check for Git Status section
output=$("$PROJECT_ROOT/git-context" 2>&1)
if echo "$output" | grep -q "## Git Status"; then
    echo "ok $((test_number+=1)) - output contains Git Status section"
else
    echo "not ok $((test_number+=1)) - output contains Git Status section"
    echo "# Output did not contain Git Status section"
    failures=$((failures + 1))
fi

# Test 2: Check for Current Changes section
if echo "$output" | grep -q "## Current Changes (Diff)"; then
    echo "ok $((test_number+=1)) - output contains Current Changes section"
else
    echo "not ok $((test_number+=1)) - output contains Current Changes section"
    echo "# Output did not contain Current Changes section"
    failures=$((failures + 1))
fi

# Test 3: Check for Files Changed section
if echo "$output" | grep -q "## Files Changed"; then
    echo "ok $((test_number+=1)) - output contains Files Changed section"
else
    echo "not ok $((test_number+=1)) - output contains Files Changed section"
    echo "# Output did not contain Files Changed section"
    failures=$((failures + 1))
fi

# Test 4: Check for Recent Commits section
if echo "$output" | grep -q "## Recent Commits"; then
    echo "ok $((test_number+=1)) - output contains Recent Commits section"
else
    echo "not ok $((test_number+=1)) - output contains Recent Commits section"
    echo "# Output did not contain Recent Commits section"
    failures=$((failures + 1))
fi

# Test 5: Check if output is in markdown format
if echo "$output" | grep -q "^#" && echo "$output" | grep -q "^```"; then
    echo "ok $((test_number+=1)) - output is in markdown format"
else
    echo "not ok $((test_number+=1)) - output is in markdown format"
    echo "# Output doesn't appear to be in markdown format"
    failures=$((failures + 1))
fi

# Clean up
echo "# Tests completed, cleaning up"
cleanup_test_dir "$test_dir"

# Exit with success if all tests passed
exit $failures
