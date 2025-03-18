# `apply-md` - Markdown Code Applier

## Overview

The `apply-md` tool extracts code blocks from markdown (typically LLM responses) and applies them to your filesystem.

## Usage

```bash
cat llm_response.md | ./apply-md --dry-run --verbose
```

## Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `--dry-run` | Preview changes without applying them | False |
| `--create-missing` | Create files that don't exist | False |
| `--backup` | Create backup files before applying changes | False |
| `--backup-dir=<dir>` | Directory for backups | "./.backups" |
| `--file-marker=<regex>` | Regex to identify target files from markdown | "```[a-z]+ (.+)" |
| `--skip-unchanged` | Skip files with no changes | False |
| `--verbose` | Show detailed output about changes | False |
| `--confirm` | Prompt for confirmation before applying each change | False |
| `--only-files=<pattern>` | Only apply changes to files matching pattern | None |
| `--ignore-files=<pattern>` | Ignore changes for files matching pattern | None |

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

### With Backups

Make backups before applying changes:

```bash
cat llm_response.md | ./apply-md --backup
```

### Creating New Files

Allow creating files that don't exist:

```bash
cat llm_response.md | ./apply-md --create-missing
```

### Selective Application

Only apply changes to specific files:

```bash
cat llm_response.md | ./apply-md --only-files="*.js"
```

## Expected Markdown Format

The script expects code blocks in this format:

````
```javascript src/utils.js
function add(a, b) {
  return a + b;
}
```
````

The language specification is optional, but the filename is required.

## Tips

- Always use `--dry-run` first to preview changes
- Consider using `--backup` for important changes
- Use `--verbose` to see details about what's changing
- For complex changes, use `--confirm` to review each change individually
