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
scripts/list.sh claude
```

## Available Models

### Latest Models
- `claude-sonnet-4-5` - Claude Sonnet 4.5 (latest, most capable)
- `claude-3-5-sonnet-20241022` - Claude 3.5 Sonnet (Oct 2024)
- `claude-3-5-haiku-20241022` - Claude 3.5 Haiku (fastest)

### Previous Generation
- `claude-3-opus-20240229` - Claude 3 Opus (most capable, slower)
- `claude-3-sonnet-20240229` - Claude 3 Sonnet
- `claude-3-haiku-20240307` - Claude 3 Haiku (fastest, cheapest)

### Model Selection Guide

- **Best quality**: `claude-sonnet-4-5` or `claude-3-opus-20240229`
- **Balanced**: `claude-3-5-sonnet-20241022`
- **Fast/cheap**: `claude-3-5-haiku-20241022`

## Usage

### List Available Models

```bash
scripts/list.sh claude
```

### Prompt a Model

```bash
# Simple prompt
scripts/ask.sh claude claude-3-5-sonnet-20241022 "Write a hello world program in Python"

# With context
scripts/ask.sh claude claude-3-5-sonnet-20241022 "Explain this code" --context lib/README.md

# Save output to file
scripts/ask.sh claude claude-3-5-sonnet-20241022 "Summarize the documentation" \
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
scripts/render.sh src/input.lmd
```

## Pricing

Pricing depends on your Claude account and usage plan.

See latest pricing at: https://www.anthropic.com/pricing

Typical costs:
- **Pay-per-use**: $3-15 per million input tokens, $5-75 per million output tokens
- **Pro plan**: $20/month with included credits
- **Team plans**: Custom pricing

Usage is tracked through your Claude account. Check usage at: https://console.anthropic.com/settings/usage

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

- **Best quality**: State-of-the-art language understanding
- **Flexible pricing**: Pay-per-use or subscription options
- **Long context**: Supports up to 200K tokens context
- **Fast**: Low latency responses
- **Easy setup**: Simple CLI authentication

## Limitations

- **Cost**: Can be expensive for high-volume usage (pay-per-use)
- **Internet required**: Must be online
- **Subscription or usage-based**: Requires Claude account
- **Privacy**: Data sent to Anthropic servers
- **CLI required**: Must have Claude CLI installed

## Best Practices

### Cost Optimization

1. **Use appropriate models:**
   - Haiku for simple tasks
   - Sonnet for balanced quality/cost
   - Opus only when maximum quality needed

2. **Minimize context:**
   - Only include relevant context files
   - Avoid sending duplicate information

3. **Monitor usage:**
   - Check usage at https://console.anthropic.com/settings/usage
   - Set up billing alerts

### Security

1. **Protect your authentication:**
   - Keep your Claude CLI session secure
   - Log out on shared systems: `claude logout`

2. **Monitor usage:**
   - Check usage regularly at https://console.anthropic.com/settings/usage
   - Set up billing alerts in your account

3. **Privacy considerations:**
   - Data is sent to Anthropic servers
   - Review Anthropic's privacy policy for data handling details

## Alternative: Use via GitHub Copilot

If you have a GitHub Copilot subscription, you can access Claude models via the Copilot CLI:

```bash
# Use Copilot provider instead
scripts/ask.sh copilot claude-sonnet-4.5 "Your prompt"
```

See `README-copilot.md` for details.
