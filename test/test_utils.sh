#!/bin/bash

# test_utils.sh - Utilities for testing the context script (TAP-compliant)

# Function to run a test and output TAP-compliant results
# Usage: run_test "test_description" "command_to_run"
run_test() {
    local description="$1"
    local command="$2"
    local skip_reason="${3:-}"
    
    local test_number=$((test_number + 1))
    
    # Skip test if reason provided
    if [ -n "$skip_reason" ]; then
        echo "ok $test_number # SKIP $description - $skip_reason"
        return 0
    fi
    
    # Create temporary files for command output and error
    local output_file
    output_file=$(mktemp)
    local error_file
    error_file=$(mktemp)
    
    # Run the command
    eval "$command" > "$output_file" 2> "$error_file"
    local status=$?
    
    local output
    output=$(cat "$output_file")
    local error
    error=$(cat "$error_file")
    
    # Handle the result
    if [ $status -eq 0 ]; then
        echo "ok $test_number - $description"
    else
        echo "not ok $test_number - $description"
        echo "# Command: $command"
        
        if [ -n "$output" ]; then
            echo "# Output:"
            echo "${output//$'\n'/$'\n'#  }"  # Use parameter expansion instead of sed
        fi
        
        if [ -n "$error" ]; then
            echo "# Error:"
            echo "${error//$'\n'/$'\n'#  }"  # Use parameter expansion instead of sed
        fi
        
        # Save the failure status for the exit code
        failures=$((failures + 1))
    fi
    
    # Clean up temporary files
    rm -f "$output_file" "$error_file"
    
    return $status
}

# Function to create a temporary directory for tests
# Usage: create_test_dir
create_test_dir() {
    local tmp_dir
    tmp_dir=$(mktemp -d -t "context-test-XXXXXX")
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
    
    local test_number=$((test_number + 1))
    
    if eval "$condition"; then
        echo "ok $test_number - $description"
    else
        echo "not ok $test_number - $description"
        echo "# Failed condition: $condition"
        failures=$((failures + 1))
    fi
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
    local current_size
    current_size=$(wc -c < "$file_path")
    local remaining_bytes=$((size_bytes - current_size))
    
    if [ $remaining_bytes -gt 0 ]; then
        # Add remaining bytes to reach desired size
        dd if=/dev/zero bs=1 count=$remaining_bytes >> "$file_path" 2>/dev/null
    fi
    
    # Verify the file is the right size
    local final_size
    final_size=$(wc -c < "$file_path")
    if [ "$final_size" -ne "$size_bytes" ]; then
        echo "# Warning: Created file size ($final_size) doesn't match requested size ($size_bytes)" >&2
    fi
}
