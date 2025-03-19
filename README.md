# Minimalistic AI Coding Assistant

A collection of lightweight Bash scripts to enhance your coding workflow with AI assistance.

## Overview

This repository contains three main tools:

1. **`context`** - Extracts code context to send to an LLM
2. **`apply-md`** - Applies code changes from LLM's markdown response
3. **`git-context`** - Generates git context for AI-assisted commit messages

## Installation

Simply clone this repository and make the scripts executable:

```bash
git clone https://github.com/yourusername/ai-coding-assistant.git
cd ai-coding-assistant
chmod +x context apply-md git-context
```

You can either use the scripts directly from this folder or add them to your PATH for global access.

## Scripts

### 1. `context` - Code Context Generator

Generates contextual information from a codebase to send to an LLM.

```bash
./context --files="src/components/*.js" --exclude="*.test.js" --max-size=300KB --depth=2 --include-git > context.txt
```

[See full documentation for context](./docs/context.md)

### 2. `apply-md` - Markdown Code Applier

Extracts code blocks from markdown and applies changes to your filesystem.

```bash
cat llm_response.md | ./apply-md --dry-run --verbose
```

[See full documentation for apply-md](./docs/apply-md.md)

### 3. `git-context` - Git Context Generator

Generates git-related context to help LLMs create meaningful commit messages.

```bash
./git-context --diff --recent-commits=2 --prompt --conventional > commit_context.txt
```

[See full documentation for git-context](./docs/git-context.md)

## Usage Workflows

### Scenario: Code Refactoring

1. Generate context from your code:
   ```bash
   ./context --files="src/utils/parser.js" --depth=1 > parser_context.txt
   ```

2. Send the context to an LLM with your request (e.g., "Refactor this parser to improve performance")

3. Apply the suggested changes:
   ```bash
   # Save LLM response to response.md or pipe directly
   cat response.md | ./apply-md --dry-run
   cat response.md | ./apply-md
   ```

4. Generate commit context:
   ```bash
   ./git-context --diff --prompt > commit_context.txt
   ```

5. Get a commit message from the LLM and commit your changes

## Customization

All prompts used in the scripts are stored in the `prompts/` directory as text files, making them easy to customize for your specific needs.

## Contributing

Contributions are welcome! Feel free to submit a pull request or open an issue to suggest improvements.

## License

The Unlicense (public domain)
