# GitHub Copilot Provider

Access multiple LLM models (Claude, GPT, Gemini) via GitHub Copilot CLI.

## Requirements

- **GitHub Copilot subscription**
- **Copilot CLI** installed
- Internet connection

## Setup

### 1. Subscribe to GitHub Copilot

1. Visit: https://github.com/features/copilot
2. Choose a plan and complete setup

### 2. Install Copilot CLI

Follow the installation instructions at: https://github.com/features/copilot

### 3. Verify Setup

```bash
# List available models
./lh list copilot
```

## Available Models

### Claude (Anthropic)
- `claude-sonnet-4.5` - Claude Sonnet 4.5 (latest, recommended)
- `claude-opus-4.5` - Claude Opus (most capable)
- `claude-haiku-4.5` - Claude Haiku (fastest)

### GPT (OpenAI)
- `gpt-4` - GPT-4
- `gpt-4o` - GPT-4 Optimized
- `gpt-5` - GPT-5 (if available)

### Other
- `gemini-2.5-pro` - Google Gemini Pro
- `grok-code-fast-1` - xAI Grok

**Note:** Model availability may change. Use `./lh list copilot` to see current models.

## Usage

### List Available Models

```bash
./lh list copilot
```

### Prompt a Model

```bash
# Simple prompt
./lh ask copilot claude-sonnet-4.5 "Write a hello world program in Python"

# With context
./lh ask copilot claude-sonnet-4.5 "Explain this code" --context lib/README.md

# Save output to file
./lh ask copilot gpt-4 "Summarize the documentation" \
    --context lib/ --output summary.md
```

### Use in .lmd Files

```markdown
\`\`\`copilot, model=claude-sonnet-4.5, context=lib/, output=result.md
Analyze the code and provide insights.
\`\`\`
```

Or using the shorthand (engine defaults to copilot if not specified):

```markdown
\`\`\`claude, model=copilot-claude-sonnet-4.5, context=lib/, output=result.md
Analyze the code and provide insights.
\`\`\`
```

Process the .lmd file:
```bash
./lh render src/input.lmd
```

## Authentication

Authentication is handled automatically by the Copilot CLI when you have an active GitHub Copilot subscription.

If you encounter authentication issues:
```bash
# Log in again
copilot login
```

## Troubleshooting

### "copilot command not found" Error

**Cause:** Copilot CLI not installed or not in PATH

**Solution:**
1. Install Copilot CLI: https://github.com/features/copilot
2. Verify installation: `which copilot`
3. Restart your shell if needed

### "403 Forbidden" or Authentication Error

**Cause:** No active Copilot subscription or not logged in

**Solution:**
1. Check subscription: https://github.com/settings/copilot
2. Verify billing is current
3. Log in to Copilot CLI:
   ```bash
   copilot login
   ```
4. Subscribe if needed: https://github.com/features/copilot

### Network Errors

**Cause:** Internet connection issues or service outage

**Solution:**
1. Check internet connection
2. Verify GitHub service status
3. Try re-authenticating: `copilot login`

### Model Not Available

**Cause:** Model might be deprecated or not included in your subscription

**Solution:**
```bash
# List currently available models
./lh list copilot

# Use one from the list
```

## Advantages

- **Multiple providers**: Access Claude, GPT, Gemini with one subscription
- **Easy setup**: Simple CLI authentication
- **Access to latest models**: Latest Claude and GPT models

## Limitations

- **Subscription required**
- **Internet required**: Must be online
- **GitHub dependency**: Tied to GitHub account and service
- **Model selection**: Limited to what GitHub provides
- **CLI required**: Must have Copilot CLI installed

## Best Practices

### Security

1. **Protect your authentication:**
   - Keep your Copilot CLI session secure
   - Log out on shared systems: `copilot logout`

### Model Selection

- **Documentation/Analysis**: `claude-sonnet-4.5`
- **Code generation**: `gpt-4o` or `claude-sonnet-4.5`
- **Fast iterations**: `claude-haiku-4.5`
- **Complex tasks**: `claude-opus-4.5`
