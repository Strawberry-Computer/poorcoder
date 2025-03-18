# `git-context` - Git Context Generator

## Overview

The `git-context` tool generates git-related context specifically to help LLMs create meaningful commit messages.

## Usage

```bash
./git-context --diff --recent-commits=2 --prompt --conventional > commit_context.txt
```

## Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `--diff` | Show uncommitted changes | True |
| `--no-diff` | Don't show uncommitted changes | False |
| `--staged` | Show only staged changes | False |
| `--unstaged` | Show only unstaged changes | False |
| `--recent-commits=<num>` | Show most recent N commits for context | 3 |
| `--files=<pattern>` | Include only files matching pattern | None |
| `--exclude=<pattern>` | Exclude files matching pattern | None |
| `--format=<format>` | Output format (md, json, text) | "md" |
| `--prompt` | Include commit message generation prompt | False |
| `--conventional` | Add conventional commit format guidance | False |
| `--project-context` | Include project name and description for context | False |
| `--branch-info` | Include current branch and related info | False |

## Output

The tool outputs git context information, which typically includes:

1. Git diff of uncommitted/staged changes
2. Information about files changed (stats)
3. Recent commit messages for style reference
4. Optional prompt to guide the LLM in generating a good commit message

## Examples

### Basic Usage

Generate context for a commit message:

```bash
./git-context > commit_context.txt
```

### Conventional Commits

Include guidance for conventional commit format:

```bash
./git-context --prompt --conventional > commit_context.txt
```

### With Project Context

Include project information for better context:

```bash
./git-context --project-context --branch-info > commit_context.txt
```

### Staged Changes Only

Only include changes that have been staged:

```bash
./git-context --staged --prompt > commit_context.txt
```

### JSON Output

Generate context in JSON format:

```bash
./git-context --format=json > commit_context.json
```

## Customization

The commit message prompt template is stored in `prompts/commit_prompt.txt` and can be customized to your project's needs.

If the `--conventional` flag is used, the tool will also include guidance from `prompts/conventional_commit.txt`.

## Workflow Integration

Typical workflow:

1. Make changes to your code
2. Stage changes with `git add`
3. Run `./git-context --staged --prompt > commit_context.txt`
4. Send commit_context.txt to an LLM to generate a commit message
5. Use the generated message with `git commit -m "generated message"`
