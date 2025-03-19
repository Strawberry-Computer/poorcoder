# `git-context` - Minimalist Git Context Generator

## Overview

The `git-context` tool generates essential git-related context to help LLMs create meaningful commit messages. This simplified version focuses on providing only the most useful information for commit message generation.

## Usage

```bash
./git-context [options] > commit_context.txt
```

## Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `--recent-commits=<num>` | Show most recent N commits for context | 3 |
| `--prompt=<file>` | Use custom commit message prompt from file | "prompts/commit_prompt.txt" |
| `--no-prompt` | Don't include commit message prompt | False |

## Output

The tool outputs git context information in markdown format, which includes:

1. Git status summary
2. Git diff of uncommitted changes against HEAD
3. List of files changed with their status
4. Recent commit messages for style reference
5. Commit message guidance from prompts/commit_prompt.txt

## Examples

### Basic Usage

Generate context for a commit message:

```bash
./git-context > commit_context.txt
```

### Conventional Commits

Use the conventional commits format guidance included in the repository:

```bash
./git-context --prompt=prompts/conventional_commit.txt > commit_context.txt
```

This uses the pre-defined conventional commit format guidance from the prompts directory.

### Without Prompt

Generate context without the commit message guidance:

```bash
./git-context --no-prompt > commit_context.txt
```

### Adjust Number of Recent Commits

Show more or fewer recent commits:

```bash
./git-context --recent-commits=5 > commit_context.txt
```

## Customization

The commit message prompt template is stored in `prompts/commit_prompt.txt` and can be customized to your project's needs.

For conventional commits or other specialized formats, create a custom prompt file and specify it with the `--prompt=` option.

## Workflow Integration

Typical workflow:

1. Make changes to your code
2. Run `./git-context > commit_context.txt`
3. Send commit_context.txt to an LLM to generate a commit message
4. Use the generated message with `git commit -m "generated message"`

## Pipeline Examples

```bash
# Generate commit message and use it directly (using an LLM CLI tool)
git commit -am "$(./git-context | llm -m openrouter/anthropic/claude-3.5-haiku)"

# Generate commit message but edit it before committing
git commit -am "$(./git-context | llm -m openrouter/anthropic/claude-3.5-haiku)" -e

# Generate a conventional commit message with editing option
git commit -am "$(./git-context --prompt=prompts/conventional_commit.txt | llm -m openrouter/anthropic/claude-3.5-haiku)" -e
```

The `-e` or `--edit` option opens the commit message in your default editor, allowing you to review, edit, or cancel the commit if needed.
