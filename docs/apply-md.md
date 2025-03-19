# `apply-md` - Markdown Code Applier

## Overview

The `apply-md` tool extracts code blocks from markdown (typically LLM responses) and applies them to your filesystem. It supports both relative and absolute paths, with absolute paths resolved relative to the git repository root when run within a git repository.

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
| `--verbose` | Show detailed output about changes, including git root detection | False |
| `--confirm` | Prompt for confirmation before applying each change | False |
| `--only-files=<pattern>` | Only apply changes to files matching pattern | None |
| `--ignore-files=<pattern>` | Ignore changes for files matching pattern | None |

## How It Works

1. The tool reads markdown content from stdin
2. If run within a git repository, it detects the repository root
3. It looks for code blocks that specify a filename (e.g., ```javascript src/utils.js or ```bash /apply-md)
4. Absolute paths (starting with /) are resolved relative to the git root when applicable
5. It extracts the code from these blocks
6. It applies the code to the corresponding files in your filesystem

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

### Using Absolute Paths

Apply changes using absolute paths relative to git root:

```bash
echo -e "```bash /scripts/test.sh\necho 'test'\n```" | ./apply-md --create-missing
```

## Expected Markdown Format

The script expects code blocks in these formats:

### Relative Path
```markdown
    ```javascript src/utils.js
    function add(a, b) {
      return a + b;
    }
    ```
```

### Absolute Path (from git root)
```markdown
    ```bash /scripts/deploy.sh
    #!/bin/bash
    echo "Deploying..."
    ```
```

The language specification is optional, but the filename is required. Absolute paths (starting with /) will be resolved relative to the git repository root when run within a git repository.

## Tips

- Always use `--dry-run` first to preview changes
- Use `--verbose` to see the detected git root and normalized paths
- Consider using `--backup` for important changes
- Use `--confirm` to review each change individually
- When using absolute paths, ensure you're running from within a git repository
- If not in a git repository, absolute paths will be treated as system paths

## Git Integration

When run within a git repository:
- Detects the repository root automatically
- Converts absolute paths (e.g., `/src/main.js`) to relative paths from the git root
- Shows the detected git root in verbose mode

If not in a git repository:
- Absolute paths are treated as system absolute paths
- A warning is shown in verbose mode
