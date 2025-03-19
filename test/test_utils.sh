#!/bin/bash

# test_utils.sh - Utilities for testing the context script

# Initialize test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Get the directory where the test_utils.sh script is located
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$TEST_DIR/.." && pwd)"

# Function to run a test
# Usage: run_test "test_name" "command_to_run"
run_test() {
    local test_name=$1
    local command=$2
    
    echo -n "- Testing $test_name... "
    
    # Run the command and capture output and exit status
    output=$(eval $command 2>&1)
    status=$?
    
    if [ $status -eq 0 ]; then
        echo "PASSED"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "FAILED"
        echo "  Command: $command"
        echo "  Output: $output"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    
    return $status
}

# Function to create a temporary directory for tests
# Usage: create_test_dir
create_test_dir() {
    mktemp -d -t context-test-XXXXXX
}

# Function to clean up a temporary directory
# Usage: cleanup_test_dir "$test_dir"
cleanup_test_dir() {
    local test_dir=$1
    rm -rf "$test_dir"
}

# Function to assert that a string contains another string
# Usage: assert_contains "haystack" "needle"
assert_contains() {
    local haystack=$1
    local needle=$2
    
    if [[ "$haystack" == *"$needle"* ]]; then
        return 0
    else
        return 1
    fi
}

# Function to assert that a string does not contain another string
# Usage: assert_not_contains "haystack" "needle"
assert_not_contains() {
    local haystack=$1
    local needle=$2
    
    if [[ "$haystack" != *"$needle"* ]]; then
        return 0
    else
        return 1
    fi
}

# Function to create a test file with a specific size
# Usage: create_test_file "$dir/file.txt" 1024  # Creates a 1KB file
create_test_file() {
    local file_path=$1
    local size_bytes=$2
    
    dd if=/dev/zero of="$file_path" bs=1 count=$size_bytes status=none
}
