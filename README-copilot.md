# GitHub Copilot Provider

Access multiple LLM models (Claude, GPT, Gemini) via GitHub Copilot CLI.

## Requirements

- **GitHub Copilot subscription** ($10/month or $100/year)
- **Copilot CLI** installed
- Internet connection

## Why GitHub Copilot?

GitHub Copilot provides:
- **Fixed monthly cost**: $10/month for unlimited usage
- **Multiple models**: Claude, GPT-4, Gemini, and more
- **No per-token billing**: Use as much as you want
- **Easy authentication**: Via Copilot CLI

## Setup

### 1. Subscribe to GitHub Copilot

1. Visit: https://github.com/features/copilot
2. Choose a plan:
   - **Individual**: $10/month or $100/year
   - **Business**: $19/user/month
3. Complete payment setup

### 2. Install Copilot CLI

Follow the installation instructions at: https://github.com/features/copilot

### 3. Verify Setup

```bash
# List available models
scripts/list.sh copilot
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

**Note:** Model availability may change. Use `scripts/list.sh copilot` to see current models.

## Usage

### List Available Models

```bash
scripts/list.sh copilot
```

### Prompt a Model

```bash
# Simple prompt
scripts/ask.sh copilot claude-sonnet-4.5 "Write a hello world program in Python"

# With context
scripts/ask.sh copilot claude-sonnet-4.5 "Explain this code" --context lib/README.md

# Save output to file
scripts/ask.sh copilot gpt-4 "Summarize the documentation" \
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
scripts/render.sh src/input.lmd
```

## Pricing

**GitHub Copilot Individual:**
- $10/month or $100/year
- **Unlimited usage** of all models
- No per-token charges

**GitHub Copilot Business:**
- $19/user/month
- Same unlimited usage
- Additional enterprise features

This makes Copilot very cost-effective for heavy usage compared to pay-per-token APIs.

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
scripts/list.sh copilot

# Use one from the list
```

## Advantages

- **Fixed cost**: $10/month for unlimited usage
- **Multiple providers**: Access Claude, GPT, Gemini with one subscription
- **No token counting**: Use as much as you want
- **Easy setup**: Simple CLI authentication
- **High quality**: Access to latest Claude and GPT models

## Limitations

- **Subscription required**: $10/month minimum
- **Internet required**: Must be online
- **GitHub dependency**: Tied to GitHub account and service
- **Model selection**: Limited to what GitHub provides
- **CLI required**: Must have Copilot CLI installed

## Best Practices

### Security

1. **Protect your authentication:**
   - Keep your Copilot CLI session secure
   - Log out on shared systems: `copilot logout`

2. **Monitor usage:**
   - Check your Copilot subscription status regularly
   - Review billing at: https://github.com/settings/billing

### Cost Optimization

Since usage is unlimited:
- **Use the best model for the job**: No reason to compromise on quality
- **Prefer claude-sonnet-4.5**: Best balance of speed and quality
- **Use gpt-4 for specific needs**: When GPT is better suited

### Model Selection

- **Documentation/Analysis**: `claude-sonnet-4.5`
- **Code generation**: `gpt-4o` or `claude-sonnet-4.5`
- **Fast iterations**: `claude-haiku-4.5`
- **Maximum quality**: `claude-opus-4.5`

## Comparison with Direct APIs

### vs Direct Claude CLI

| Feature | Copilot | Direct Claude CLI |
|---------|---------|------------------|
| Cost | $10/month unlimited | Pay-per-use or $20/month |
| Setup | Copilot CLI | Claude CLI |
| Models | Via GitHub | Direct access |
| Best for | High volume | Low/medium volume |

### vs Ollama

| Feature | Copilot | Ollama |
|---------|---------|--------|
| Cost | $10/month | Free |
| Quality | Excellent | Good |
| Speed | Fast (cloud) | Fast (local) |
| Privacy | Data sent to cloud | Fully local |
| Setup | Easy | Medium |

## When to Use Copilot

**Choose Copilot when:**
- You need high-quality models (Claude, GPT-4)
- You have high usage volume (>$10/month worth)
- You want predictable costs
- You already have a Copilot subscription

**Choose alternatives when:**
- You need complete privacy (→ use Ollama)
- You have very low usage (→ use direct Claude CLI)
- You're on a tight budget (→ use Ollama)
- You need offline access (→ use Ollama)
