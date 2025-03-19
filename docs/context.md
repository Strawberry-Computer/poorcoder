# `context` - Simplified Code Context Generator

## Overview

The `context` tool extracts relevant code from your codebase to send to an LLM (Large Language Model). It creates focused snapshots of your code for more accurate AI assistance with a streamlined interface.

## Usage

```bash
# Using file patterns
./context --include="src/*.js" --exclude="*.test.js" > context.md

# Using direct patterns as arguments
./context "src/*.js" "README.md" > context.md

# Including git information
./context --include="src/*.js" --git > context.md
