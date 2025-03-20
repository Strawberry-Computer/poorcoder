# Minimalistic AI Coding Assistant

A collection of lightweight Bash scripts to enhance your coding workflow with AI assistance. These tools integrate seamlessly with your terminal workflow, allowing you to leverage AI models without disrupting your development process.

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
# Using file patterns
./context --include="src/*.js" --exclude="*.test.js" > context.md

# Using direct patterns as arguments
./context "src/*.js" "README.md" > context.md

# Including git information
./context --include="src/*.js" --git > context.md
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
./git-context --recent-commits=5 --prompt=prompts/conventional_commit.txt > commit_context.txt
```

[See full documentation for git-context](./docs/git-context.md)

## Usage Workflows

### Unix-style Pipelines

These tools are designed to work seamlessly in Unix pipelines, allowing you to create powerful workflows with minimal effort:

```bash
# Copy code context directly to clipboard (macOS)
./context --include="src/api/*.js" | pbcopy

# Generate and apply code changes directly from clipboard (macOS)
pbpaste | ./apply-md

# Auto-generate commit message using an LLM CLI tool
git commit -am "$(./git-context | llm -m openrouter/anthropic/claude-3.5-haiku)" -e

# Stream context to an LLM and apply changes in one command
./context --include="src/components/Button.js" | llm "Refactor this component to use hooks" | ./apply-md
```

### Scenario: Bug Fix Workflow

Let's walk through a complete workflow for fixing a bug:

1. Identify the files involved in the bug:
   ```bash
   # Generate context for the relevant files
   ./context --include="src/utils/validation.js" --include="src/components/Form.js" | pbcopy
   ```

2. Paste the context into your preferred AI assistant's web UI with your request:
   "There's a bug where form validation fails when empty strings are submitted. Please fix it."

3. Copy the AI's response and apply the suggested changes:
   ```bash
   pbpaste | ./apply-md --dry-run  # Preview changes
   pbpaste | ./apply-md            # Apply changes
   ```

4. Generate an appropriate commit message:
   ```bash
   # Auto-generate semantically meaningful commit message
   ./git-context | llm "Generate a conventional commit message" | git commit -F -
   
   # Or with manual editing
   git commit -am "$(./git-context | llm "Write a commit message")" -e
   ```

### Scenario: Code Refactoring with Git Integration

When working on larger refactoring tasks:

1. Generate context with git history for better understanding:
   ```bash
   ./context --include="src/utils/parser.js" --git > parser_context.txt
   ```

2. Send the context to an LLM with your request (e.g., "Refactor this parser to improve performance")

3. Apply the suggested changes:
   ```bash
   # Save LLM response to response.md or pipe directly
   cat response.md | ./apply-md --dry-run
   cat response.md | ./apply-md
   ```

4. Generate commit context and message in one step:
   ```bash
   git commit -am "$(./git-context --prompt=prompts/conventional_commit.txt | llm "Generate a detailed commit message")" -e
   ```

## Customization

All prompts used in the scripts are stored in the `prompts/` directory as text files, making them easy to customize for your specific needs.

### Custom Prompts

You can create your own prompt templates for different scenarios:

```bash
# Create a custom prompt for code review
echo "Please review this code and identify potential bugs and security issues." > prompts/review_prompt.txt

# Use your custom prompt with the context generator
./context --include="src/*.js" | cat - prompts/review_prompt.txt | llm
```

### Integration with Other Tools

These scripts are designed to work with various LLM CLI tools and other Unix utilities:

- **LLM CLI tools**: `llm`, `sgpt`, `chatgpt-cli`, etc.
- **Clipboard utilities**: `pbcopy`/`pbpaste` (macOS), `xclip` (Linux)
- **Text processing**: `sed`, `awk`, `grep`, etc.
- **Version control**: `git`

## Contributing

Contributions are welcome! Feel free to submit a pull request or open an issue to suggest improvements.

## License

The Unlicense (public domain)
