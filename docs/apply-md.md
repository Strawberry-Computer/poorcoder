# `apply-md` - Markdown Code Applier

## Overview

The `apply-md` tool extracts code blocks from markdown (typically LLM responses) and applies them to your filesystem. This simplified version focuses on core functionality without the complexity of advanced features.

## Usage

```bash
cat llm_response.md | ./apply-md --dry-run --verbose
```

## Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `--dry-run` | Preview changes without applying them | False |
| `--create-missing` | Create files that don't exist | False |
| `--verbose` | Show detailed output about changes | False |
| `--help`, `-h` | Show help message | - |

## How It Works

1. The tool reads markdown content from stdin
2. It looks for code blocks that specify a filename (e.g., ```javascript src/utils.js)
3. It extracts the code from these blocks
4. It applies the code to the corresponding files in your filesystem

## Examples

### Basic Usage

Apply changes directly from an LLM response:

```bash
cat llm_response.md | ./apply-md
```

### Dry Run

Preview changes without applying them:

```bash
cat llm_response.md | ./apply-md --dry-run --verbose
```

### Creating New Files

Allow creating files that don't exist:

```bash
cat llm_response.md | ./apply-md --create-missing
```

## Expected Markdown Format

The script expects code blocks in this format:

```markdown
    ```javascript src/utils.js
    function add(a, b) {
      return a + b;
    }
    ```
```

The language specification is optional, but the filename is required.

## Tips

- Always use `--dry-run` first to preview changes
- Use `--verbose` to see detailed information about changes
- When creating new files, ensure the `--create-missing` flag is set
