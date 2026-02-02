# Claude Provider

Access Anthropic's Claude models via the Claude CLI.

## Requirements

- **Claude CLI** installed
- Internet connection

## Setup

### 1. Install Claude CLI

Follow the installation instructions at: https://docs.anthropic.com/claude/docs/claude-cli

### 2. Verify Setup

```bash
# List available models
./lh list claude
```

## Available Models

### Latest Models
- `claude-sonnet-4-5` - Claude Sonnet 4.5 (latest, most capable)
- `claude-3-5-sonnet-20241022` - Claude 3.5 Sonnet (Oct 2024)
- `claude-3-5-haiku-20241022` - Claude 3.5 Haiku (fastest)

### Previous Generation
- `claude-3-opus-20240229` - Claude 3 Opus (most capable, slower)
- `claude-3-sonnet-20240229` - Claude 3 Sonnet
- `claude-3-haiku-20240307` - Claude 3 Haiku (fastest)

### Model Selection Guide

- **Latest and most capable**: `claude-sonnet-4-5`
- **Previous generation most capable**: `claude-3-opus-20240229`
- **Balanced**: `claude-3-5-sonnet-20241022`
- **Fastest**: `claude-3-5-haiku-20241022`

## Usage

### List Available Models

```bash
./lh list claude
```

### Prompt a Model

```bash
# Simple prompt
./lh ask claude claude-3-5-sonnet-20241022 "Write a hello world program in Python"

# With context
./lh ask claude claude-3-5-sonnet-20241022 "Explain this code" --context lib/README.md

# Save output to file
./lh ask claude claude-3-5-sonnet-20241022 "Summarize the documentation" \
    --context lib/ --output summary.md
```

### Use in .lmd Files

```markdown
\`\`\`claude, model=claude-3-5-sonnet-20241022, context=lib/, output=result.md
Analyze the code and provide insights.
\`\`\`
```

Process the .lmd file:
```bash
./lh render src/input.lmd
```

## Configuration

### Max Tokens

Default: 100,000 tokens per request

To customize, you would need to modify `ask_claude.sh` or use model parameters.

### Temperature

Default: 0.7

Controls randomness (0.0 = deterministic, 1.0 = creative)

## Troubleshooting

### "claude command not found" Error

**Cause:** Claude CLI not installed or not in PATH

**Solution:**
1. Install Claude CLI: https://docs.anthropic.com/claude/docs/claude-cli
2. Verify installation: `which claude`
3. Restart your shell if needed

### Authentication Errors

**Cause:** Not logged in to Claude CLI

**Solution:**
```bash
# Log in to Claude CLI
claude login
```

### Network Errors

**Cause:** Internet connection issues or service outage

**Solution:**
1. Check internet connection
2. Verify Claude service status: https://status.anthropic.com/
3. Try again after a few minutes

## Advantages

- **State-of-the-art language understanding**
- **Long context**: Supports up to 200K tokens context
- **Fast**: Low latency responses
- **Easy setup**: Simple CLI authentication

## Limitations

- **Internet required**: Must be online
- **Requires Claude account**
- **Privacy**: Data sent to Anthropic servers
- **CLI required**: Must have Claude CLI installed

## Best Practices

### Usage Optimization

1. **Use appropriate models:**
   - Haiku for simple tasks
   - Sonnet for balanced performance
   - Opus for most complex tasks

2. **Minimize context:**
   - Only include relevant context files
   - Avoid sending duplicate information

### Security

1. **Protect your authentication:**
   - Keep your Claude CLI session secure
   - Log out on shared systems: `claude logout`

2. **Privacy considerations:**
   - Data is sent to Anthropic servers
   - Review Anthropic's privacy policy for data handling details


