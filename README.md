# LangHub

**A unified shell-based system for prompting various LLM providers from markdown files.**

LangHub provides a simple, consistent interface to interact with multiple AI language models through a single set of scripts. Process .lmd (LLM Markdown) files to generate documentation, analyze code, or automate AI-powered workflows.

## Features

- **Unified Interface**: Single API for Ollama, Claude, and GitHub Copilot
- **.lmd File Processing**: Define AI workflows in markdown with embedded prompts
- **Context Support**: Automatically include files/directories as context
- **Provider Flexibility**: Switch between local and cloud models easily
- **Shell-Based**: Pure bash scripts, no additional dependencies beyond provider tools
- **Extensible**: Easy to add new providers

## Quick Start

### 1. Choose a Provider

- **[Ollama](README-ollama.md)** - Free, local, good for testing
- **[Claude](README-claude.md)** - Pay-per-use, excellent quality
- **[Copilot](README-copilot.md)** - $10/month subscription, multiple models

### 2. Set Up Your Provider

Follow the setup instructions in the provider's README:

**Ollama (easiest to start):**
```bash
# Install and start Ollama
brew install ollama  # or: curl -fsSL https://ollama.ai/install.sh | sh
ollama pull qwen2.5-coder:7b

# List models
./lh list ollama
```

**Claude (best quality):**
```bash
# Install Claude CLI from https://docs.anthropic.com/claude/docs/claude-cli
# Login to Claude
claude login

# List models
./lh list claude
```

**Copilot (best value for high usage):**
```bash
# Subscribe at https://github.com/features/copilot
# Install Copilot CLI and login
copilot login

# List models
./lh list copilot
```

### 3. Use LangHub

**Using the unified entrypoint (recommended):**
```bash
# List available models
./lh list <engine>

# Prompt a model
./lh ask <engine> <model-id> "Your prompt text"

# Process .lmd files
./lh render input.lmd > output.md
```

**Or use individual scripts:**
```bash
./list.sh <engine>
./ask.sh <engine> <model-id> "Your prompt text"
./render.sh input.lmd > output.md
```

## Installation

### Clone the Repository

```bash
git clone https://github.com/yourusername/langhub.git
cd langhub
chmod +x lh *.sh
```

### As a Git Submodule

Add LangHub to your project:

```bash
git submodule add https://github.com/yourusername/langhub.git scripts
cd scripts
chmod +x lh *.sh
```

Then use it in your project:
```bash
scripts/lh ask ollama qwen2.5-coder:7b "Your prompt"
```

## Script Overview

### Unified Entrypoint

- **`lh <command> [args...]`** - Main entrypoint for all LangHub commands
  - `lh list <engine>` - List available models
  - `lh ask <engine> <model-id> <prompt> [options]` - Prompt a model
  - `lh render <file.lmd>` - Process .lmd files
  - `lh help` - Show help message

### Core Scripts

You can also use the individual scripts directly:

- **`list.sh <engine>`** - List available models for a provider
- **`ask.sh <engine> <model-id> <prompt> [options]`** - Prompt a model
- **`render.sh <file.lmd>`** - Process .lmd files to markdown

### Provider Scripts

Each provider has two scripts:

- **`list_<engine>.sh`** - List models for that provider
- **`ask_<engine>.sh`** - Prompt models for that provider

Current providers:
- `ollama` - Local Ollama models
- `claude` - Anthropic Claude API
- `copilot` - GitHub Copilot API

## Usage Examples

### Example 1: Simple Prompt

```bash
# Using Ollama (free, local)
./lh ask ollama qwen2.5-coder:7b "Write a Python function to calculate factorial"

# Using Claude (best quality)
./lh ask claude claude-3-5-sonnet-20241022 "Explain quantum computing"

# Using Copilot (unlimited usage)
./lh ask copilot claude-sonnet-4.5 "Refactor this code for better performance"
```

### Example 2: With Context

```bash
# Provide context from a directory
./lh ask ollama qwen2.5-coder:7b "Summarize the documentation" --context lib/

# Provide context from a file
./lh ask claude claude-3-5-sonnet-20241022 "Explain this" --context README.md
```

### Example 3: Process .lmd File

Create a `.lmd` file (e.g., `prompts.lmd`):

```markdown
# My Analysis

\`\`\`ollama, model=qwen2.5-coder:7b, log=ollama.log
Provide a brief summary of the key features.
\`\`\`

\`\`\`claude, model=claude-3-5-sonnet-20241022, context=lib/, log=claude.log
Analyze the code architecture and suggest improvements.
\`\`\`

\`\`\`copilot, model=claude-sonnet-4.5, context=lib/, log=copilot.log
Generate comprehensive documentation for this codebase.
\`\`\`
```

Process it:

```bash
./lh render prompts.lmd > output.md
```

This will:
1. Execute each code block with the specified model
2. Replace code blocks with model responses in the output
3. Save logs to the specified files (optional)

## .lmd File Format

`.lmd` files are markdown files with special code blocks for LLM prompts:

```markdown
\`\`\`<engine>, model=<model-id>, context=<path>, log=<logfile>
<prompt text>
\`\`\`
```

### Parameters

- **`<engine>`** (required): Provider to use
  - `ollama`, `ollama:http://custom:11434`
  - `claude`
  - `copilot`
  - `print` (for testing, just echoes the prompt)

- **`model=<model-id>`** (required for non-print engines): Model identifier
  - Ollama: `qwen2.5-coder:7b`, `mistral:7b`, etc.
  - Claude: `claude-3-5-sonnet-20241022`, etc.
  - Copilot: `claude-sonnet-4.5`, `gpt-4`, etc.

- **`context=<path>`** (optional): Context files/directory
  - File: `context=README.md`
  - Directory: `context=lib/` (loads all .md, .txt, .rst files)

- **`log=<logfile>`** (optional): Log file for model messages
  - Relative or absolute path
  - Directory will be created if it doesn't exist

## Directory Structure

```
langhub/
├── README.md                 # This file
├── README-ollama.md         # Ollama setup guide
├── README-claude.md         # Claude setup guide
├── README-copilot.md        # Copilot setup guide
│
├── lh                       # Unified entrypoint (recommended)
│
├── list.sh                  # Main: list models
├── ask.sh                   # Main: prompt models
├── render.sh                # Main: process .lmd files
│
├── list_ollama.sh          # Ollama: list models
├── ask_ollama.sh           # Ollama: prompt models
│
├── list_claude.sh          # Claude: list models
├── ask_claude.sh           # Claude: prompt models
│
├── list_copilot.sh         # Copilot: list models
├── ask_copilot.sh          # Copilot: prompt models
│
└── test/                   # Test suite
    ├── tests.sh            # Run all tests
    ├── test-list.sh        # Test list scripts
    ├── test-ask.sh         # Test ask scripts
    └── test-render.sh      # Test render script
```

## Provider Comparison

| Provider | Cost | Setup | Quality | Speed | Privacy |
|----------|------|-------|---------|-------|---------|
| **Ollama** | Free | Easy | Good | Fast | Excellent (local) |
| **Claude** | Pay-per-use | Easy | Excellent | Fast | Good (cloud) |
| **Copilot** | $10/month | Medium | Excellent | Fast | Good (cloud) |

### Recommendations

**For getting started:**
- Use **Ollama** with `qwen2.5-coder:7b` (free, easy)

**For production quality:**
- Use **Claude** `claude-3-5-sonnet-20241022` (best quality)
- Or **Copilot** `claude-sonnet-4.5` (fixed cost)

**For high volume:**
- Use **Copilot** (unlimited usage for $10/month)

**For privacy/offline:**
- Use **Ollama** (completely local)

## Dependencies

### Required
- `bash` (any recent version)
- `curl` (for HTTP requests)

### Optional but Recommended
- `jq` (for better JSON parsing and error messages)
  ```bash
  # Install jq
  sudo apt install jq        # Debian/Ubuntu
  brew install jq            # macOS
  ```

### Provider-Specific
- **Ollama**: Ollama installed and running
- **Claude**: Claude CLI installed and authenticated
- **Copilot**: Copilot CLI installed and authenticated

## Testing

Run the test suite:

```bash
cd test
./tests.sh
```

Run individual test suites:
```bash
./test-list.sh      # Test list scripts
./test-ask.sh       # Test ask scripts
./test-render.sh    # Test render script
```

## Troubleshooting

### General Issues

**"Permission denied" when running scripts:**
```bash
chmod +x *.sh
```

**"jq: command not found" warnings:**
```bash
# Install jq for better error handling (optional)
sudo apt install jq  # or: brew install jq
```

### Provider-Specific Issues

See the provider README files for detailed troubleshooting:
- [Ollama troubleshooting](README-ollama.md#troubleshooting)
- [Claude troubleshooting](README-claude.md#troubleshooting)
- [Copilot troubleshooting](README-copilot.md#troubleshooting)

## Advanced Usage

### Custom Ollama URI

```bash
# Use Ollama on a different host
./lh list ollama:http://192.168.1.100:11434
./lh ask ollama:http://192.168.1.100:11434 qwen2.5-coder:7b "Your prompt"
```

### Authentication

```bash
# Authenticate with providers (one-time setup)
claude login      # For Claude
copilot login     # For Copilot

# Ollama usually doesn't need authentication (runs locally)
```

### Batch Processing

```bash
# Process multiple .lmd files
for file in *.lmd; do
    echo "Processing $file..."
    ./lh render "$file" > "${file%.lmd}.md"
done
```

## Contributing

Contributions are welcome! To add a new provider:

1. Create `list_<provider>.sh` and `ask_<provider>.sh`
2. Update `list.sh` and `ask.sh` to include the new provider
3. Create `README-<provider>.md` documentation
4. Add tests in `test/test-ask.sh` and `test/test-list.sh`
5. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for more details.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Author

Created for processing LLM Markdown (.lmd) files in AI-powered documentation workflows.

## Related Projects

- [Ollama](https://ollama.ai/) - Run LLMs locally
- [Anthropic Claude](https://www.anthropic.com/) - Claude AI models
- [GitHub Copilot](https://github.com/features/copilot) - AI pair programmer
