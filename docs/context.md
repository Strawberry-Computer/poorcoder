# `context` - Code Context Generator

## Overview

The `context` tool extracts relevant code and context from your codebase to send to an LLM (Large Language Model). It helps create focused, comprehensive snapshots of your codebase for more accurate AI assistance.

## Usage

```bash
# Using patterns
./context --files="src/components/*.js" --exclude="*.test.js" --max-size=300KB > context.txt

# Using direct file paths
./context src/app.js src/utils.js README.md > context.txt

# Including git information and custom depth
./context --files="src/*.js" --include-git --git-depth=5 --depth=2 > context.txt
```

## Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `--files=<pattern>` | File pattern to include (e.g., "src/*.js") | None |
| Direct file arguments | Files to include (e.g., app.js README.md) | None |
| `--exclude=<pattern>` | File pattern to exclude (e.g., "node_modules/**") | None |
| `--max-size=<size>` | Maximum context size in KB/MB (e.g., "500KB") | "500KB" |
| `--depth=<num>` | Dependency traversal depth | 1 |
| `--include-git` | Include git information (recent commits, authors) | False |
| `--git-depth=<num>` | Number of recent commits to include | 3 |
| `--summary` | Include short summary of each file | False |
| `--show-file-sizes` | Include file sizes in output | False |
| `--truncate-large=<size>` | Truncate files larger than specified size (e.g., "50KB") | None |
| `--verbose` | Show verbose output during processing | False |
| `--ls-files` | Include git ls-files output | True |
| `--no-ls-files` | Don't include git ls-files output | False |
| `--ls-files-limit=<num>` | Limit the number of files shown in ls-files | 100 |
| `--help`, `-h` | Show help message | - |

## Examples

### Basic Usage

Extract all JS files in the src directory:

```bash
./context --files="src/**/*.js" > code_context.md
```

### Exclude Specific Files

Include all JavaScript files but exclude test files:

```bash
./context --files="src/**/*.js" --exclude="**/*.test.js" > context.md
```

### Custom Size Limits

Set maximum context size and truncate large files:

```bash
./context --files="src/*.js" --max-size=1MB --truncate-large=50KB > context.md
```

### Git Information

Generate context with git history:

```bash
./context --files="src/utils/*.js" --include-git --git-depth=5 > utils_context.md
```

### File Summary and Sizes

Include file summaries and size information:

```bash
./context --files="src/*.py" --summary --show-file-sizes > context.md
```

### Control Repository File Listing

Limit the number of files shown in the repository listing:

```bash
./context --files="src/main.js" --ls-files-limit=50 > context.md
```

Or disable the repository file listing completely:

```bash
./context --files="src/main.js" --no-ls-files > context.md
```

## Output Format

The tool generates markdown output with the following sections:

1. **Code Context** - The main header
2. **Files** - The content of each matched file
3. **Git Information** (if requested) - Recent commits and branch information
4. **Repository Files** - List of files in the git repository
5. **Instructions for LLM** (if available) - Instructions from a prompt template

## Tips

- Keep the context focused and relevant for the task at hand
- Use `--exclude` to filter out test files, build artifacts, and other non-essential files
- The `--summary` flag helps provide high-level context about each file
- If you hit token limits with your LLM, use `--truncate-large` to limit file sizes
- For large repositories, adjust `--ls-files-limit` to show only the most relevant files
