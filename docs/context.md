# `context` - Code Context Generator

## Overview

The `context` tool extracts relevant code and context from your codebase to send to an LLM (Large Language Model).

## Usage

```bash
# Using patterns
./context --files="src/components/*.js" --exclude="*.test.js" --max-size=300KB --format=md > context.txt

# Using direct file paths
./context src/app.js src/utils.js README.md > context.txt

# Including a prompt template
./context --prompt=prompts/context_prompt.txt app.js > context.txt
```

## Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `--files=<pattern>` | File pattern to include (e.g., "src/*.js") | None |
| Direct file arguments | Files or directories to include (e.g., app.js README.md) | None |
| `--exclude=<pattern>` | File pattern to exclude (e.g., "node_modules/**") | None |
| `--max-size=<size>` | Maximum context size in KB/MB (e.g., "500KB") | "500KB" |
| `--include-deps` | Include dependent files based on imports/requires | False |
| `--depth=<num>` | Dependency traversal depth | 1 |
| `--include-git` | Include git information (recent commits, authors) | False |
| `--git-depth=<num>` | Number of recent commits to include | 3 |
| `--format=<format>` | Output format (md, json, text) | "md" |
| `--summary` | Include short summary of each file | False |
| `--show-file-sizes` | Include file sizes in output | False |
| `--truncate-large=<size>` | Truncate files larger than specified size (e.g., "50KB") | None |
| `--prompt=<file>` | Include prompt template from specified file | None |

## Examples

### Basic Usage

Extract all JS files in the src directory:

```bash
./context --files="src/**/*.js" > code_context.md
```

### With Dependencies

Include imported/required files (1 level deep):

```bash
./context --files="src/components/Button.js" --include-deps > button_context.md
```

### Include Git Information

Generate context with git history:

```bash
./context --files="src/utils/*.js" --include-git --git-depth=5 > utils_context.md
```

### JSON Output

Get context in JSON format for programmatic usage:

```bash
./context --files="*.py" --format=json > context.json
```

## Customization

The script is designed to be simple and easy to modify. You can:

1. Add support for more languages in the dependency resolution
2. Modify the output format for your specific needs
3. Add additional metadata to the context generation

## Tips

- When working with LLMs, try to keep the context focused and relevant
- Use `--exclude` to filter out test files, build artifacts, etc.
- The `--summary` flag can help provide high-level context about each file
- If you hit token limits, use `--truncate-large` to limit file sizes
