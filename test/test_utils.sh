#!/bin/bash

# test_utils.sh - Utilities for testing the context script (TAP-compliant)

# Get the directory where the test_utils.sh script is located
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Initialize test counters
TESTS_PASSED=0
TESTS_FAILED=0
TEST_NUMBER_INTERNAL=0

# Function to update test result counts
update_test_results() {
    echo "PASSED:$TESTS_PASSED" > "$TEST_DIR/test_results.txt"
    echo "FAILED:$TESTS_FAILED" >> "$TEST_DIR/test_results.txt"
}

# Function to run a test and output TAP-compliant results
# Usage: run_test "test_description" "command_to_run"
run_test() {
    local description="$1"
    local command="$2"
    local skip_reason="${3:-}"
    
    TEST_NUMBER_INTERNAL=$((TEST_NUMBER_INTERNAL + 1))
    
    # Skip test if reason provided
    if [ -n "$skip_reason" ]; then
        echo "ok $TEST_NUMBER_INTERNAL # SKIP $description - $skip_reason"
        return 0
    fi
    
    # Create temporary files for command output and error
    local output_file=$(mktemp)
    local error_file=$(mktemp)
    
    # Run the command
    eval "$command" > "$output_file" 2> "$error_file"
    local status=$?
    
    local output=$(cat "$output_file")
    local error=$(cat "$error_file")
    
    # Handle the result
    if [ $status -eq 0 ]; then
        echo "ok $TEST_NUMBER_INTERNAL - $description"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "not ok $TEST_NUMBER_INTERNAL - $description"
        echo "# Command: $command"
        
        if [ -n "$output" ]; then
            echo "# Output:"
            echo "$output" | sed 's/^/#  /'
        fi
        
        if [ -n "$error" ]; then
            echo "# Error:"
            echo "$error" | sed 's/^/#  /'
        fi
        
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    
    # Clean up temporary files
    rm -f "$output_file" "$error_file"
    update_test_results
    
    return $status
}

# Function to create a temporary directory for tests
# Usage: create_test_dir
create_test_dir() {
    local tmp_dir=$(mktemp -d -t "context-test-XXXXXX")
    echo "$tmp_dir"
}

# Function to clean up a temporary directory
# Usage: cleanup_test_dir "$test_dir"
cleanup_test_dir() {
    local test_dir="$1"
    if [ -d "$test_dir" ]; then
        rm -rf "$test_dir"
    fi
}

# Function to print a message in TAP diagnostic format
# Usage: tap_diag "message"
tap_diag() {
    echo "# $1"
}

# Function to assert that a condition is true
# Usage: assert "test expr" "description"
assert() {
    local condition="$1"
    local description="$2"
    
    TEST_NUMBER_INTERNAL=$((TEST_NUMBER_INTERNAL + 1))
    
    if eval "$condition"; then
        echo "ok $TEST_NUMBER_INTERNAL - $description"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "not ok $TEST_NUMBER_INTERNAL - $description"
        echo "# Failed condition: $condition"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    
    update_test_results
}

# Function to create a test file with a specific size
# Usage: create_test_file "$dir/file.txt" 1024  # Creates a 1KB file
create_test_file() {
    local file_path="$1"
    local size_bytes="$2"
    
    # Create a file with human-readable content at the start
    echo "This is a test file created for context script testing." > "$file_path"
    echo "It contains exactly $size_bytes bytes of data." >> "$file_path"
    
    # Calculate how many bytes we need to add to reach the desired size
    local current_size=$(wc -c < "$file_path")
    local remaining_bytes=$((size_bytes - current_size))
    
    if [ $remaining_bytes -gt 0 ]; then
        # Add remaining bytes to reach desired size
        dd if=/dev/zero bs=1 count=$remaining_bytes >> "$file_path" 2>/dev/null
    fi
    
    # Verify the file is the right size
    local final_size=$(wc -c < "$file_path")
    if [ $final_size -ne $size_bytes ]; then
        echo "# Warning: Created file size ($final_size) doesn't match requested size ($size_bytes)" >&2
    fi
}

# Print TAP plan for individual test files
plan() {
    local count="$1"
    echo "1..$count"
}

# Export functions and variables for use in subshells
export -f run_test
export -f create_test_dir
export -f cleanup_test_dir
export -f tap_diag
export -f assert
export -f create_test_file
export -f plan
export -f update_test_results
