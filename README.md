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

- **[Ollama](README-ollama.md)** - Local LLM runtime
- **[Claude](README-claude.md)** - Anthropic Claude API
- **[Copilot](README-copilot.md)** - GitHub Copilot CLI

### 2. Set Up Your Provider

**Ollama:**
```bash
# Install Ollama
./lh install ollama

# Pull a model
ollama pull qwen2.5-coder:7b

# Check status and list models
./lh login ollama
```

**Claude:**
```bash
# Install Claude CLI
./lh install claude

# Login to Claude (opens browser)
./lh login claude
```

**Copilot:**
```bash
# Subscribe at https://github.com/features/copilot

# Install Copilot CLI
./lh install copilot

# Login to Copilot (opens browser)
./lh login copilot
```

### 3. Use LangHub

```bash
# List available models
./lh list <engine>

# Prompt a model
./lh ask <engine> <model-id> "Your prompt text"

# Process .lmd files
./lh render input.lmd > output.md
```

**Example workflow:**
```bash
# Install and setup Ollama
./lh install ollama
ollama pull qwen2.5-coder:7b
./lh login ollama

# Use it
./lh ask ollama qwen2.5-coder:7b "Write a hello world in Python"
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

### Shell Completion

LangHub provides shell completion for the `lh` command to make it easier to use. Completions are available for Bash, Zsh, and Fish shells.

**Features:**
- Command completion (`install`, `login`, `ask`, `list`, `render`, `help`)
- Engine completion (`ollama`, `claude`, `copilot`, `all`)
- Model completion (dynamically lists available models for each engine)
- Option completion (`--context`, `--output`, `--log`)
- File completion for `.lmd` files in `render` command

**Installation:**

**Bash:**
```bash
# Temporary (current session only)
source completion/lh.bash

# Permanent (add to ~/.bashrc)
echo "source $(pwd)/completion/lh.bash" >> ~/.bashrc

# System-wide (requires sudo)
sudo cp completion/lh.bash /etc/bash_completion.d/lh
```

**Zsh:**
```bash
# Add to your fpath (add to ~/.zshrc)
fpath=($(pwd)/completion $fpath)
autoload -Uz compinit && compinit

# Or copy to a standard location
cp completion/lh.zsh /usr/local/share/zsh/site-functions/_lh
```

**Fish:**
```bash
# Copy to Fish completions directory
mkdir -p ~/.config/fish/completions
cp completion/lh.fish ~/.config/fish/completions/
```

**Usage:**

After installation, you can use Tab to complete commands, engines, and models:

```bash
lh <Tab>              # Shows: install login ask list render help
lh install <Tab>      # Shows: ollama claude copilot all
lh ask ollama <Tab>   # Shows: available Ollama models
lh ask claude <Tab>   # Shows: claude-sonnet-4-5, claude-3-5-sonnet-20241022, ...
lh render <Tab>       # Shows: *.lmd files
```

## Script Overview

### Unified Entrypoint

- **`lh <command> [args...]`** - Main entrypoint for all LangHub commands
  - `lh install <engine>` - Install an engine
  - `lh login <engine>` - Login/authenticate with an engine
  - `lh list <engine>` - List available models
  - `lh ask <engine> <model-id> <prompt> [options]` - Prompt a model
  - `lh render <file.lmd>` - Process .lmd files
  - `lh help` - Show help message

### Installation Scripts

Main installer and provider-specific scripts:

- **`install.sh <engine>`** - Main installer (routes to provider scripts)
- **`install_ollama.sh`** - Install Ollama (via `curl -fsSL https://ollama.com/install.sh | sh`)
- **`install_claude.sh`** - Install Claude CLI (via `curl -fsSL https://claude.ai/install.sh | bash`)
- **`install_copilot.sh`** - Install Copilot CLI (via `curl -fsSL https://gh.io/copilot-install | bash`)

### Login Scripts

Main login handler and provider-specific scripts:

- **`login.sh <engine>`** - Main login handler (routes to provider scripts)
- **`login_ollama.sh`** - Check Ollama status (no auth required)
- **`login_claude.sh`** - Authenticate with Claude (via `claude login`)
- **`login_copilot.sh`** - Authenticate with Copilot (via `copilot auth login`)

### Usage Scripts

Main scripts and provider-specific implementations:

- **`list.sh <engine>`** - List available models (routes to provider)
- **`ask.sh <engine> <model-id> <prompt> [options]`** - Prompt a model (routes to provider)
- **`render.sh <file.lmd>`** - Process .lmd files to markdown

Provider-specific scripts:
- **`list_<engine>.sh`** / **`ask_<engine>.sh`** - Provider implementations

Current providers:
- `ollama` - Local Ollama models
- `claude` - Anthropic Claude API
- `copilot` - GitHub Copilot API

## Usage Examples

### Example 1: Simple Prompt

```bash
# Using Ollama
./lh ask ollama qwen2.5-coder:7b "Write a Python function to calculate factorial"

# Using Claude
./lh ask claude claude-3-5-sonnet-20241022 "Explain quantum computing"

# Using Copilot
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

````markdown
# My Analysis

```ollama, model=qwen2.5-coder:7b, log=ollama.log
Provide a brief summary of the key features.
```

```claude, model=claude-3-5-sonnet-20241022, context=lib/, log=claude.log
Analyze the code architecture and suggest improvements.
```

```copilot, model=claude-sonnet-4.5, context=lib/, log=copilot.log
Generate comprehensive documentation for this codebase.
```
````

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

````markdown
```<engine>, model=<model-id>, context=<path>, log=<logfile>
<prompt text>
```
````

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
├── install.sh               # Main installer
├── install_ollama.sh        # Ollama installer
├── install_claude.sh        # Claude installer
├── install_copilot.sh       # Copilot installer
│
├── login.sh                 # Main login handler
├── login_ollama.sh          # Ollama status checker
├── login_claude.sh          # Claude authenticator
├── login_copilot.sh         # Copilot authenticator
│
├── list.sh                  # Main: list models
├── list_ollama.sh           # Ollama: list models
├── list_claude.sh           # Claude: list models
├── list_copilot.sh          # Copilot: list models
│
├── ask.sh                   # Main: prompt models
├── ask_ollama.sh            # Ollama: prompt models
├── ask_claude.sh            # Claude: prompt models
├── ask_copilot.sh           # Copilot: prompt models
│
├── render.sh                # Main: process .lmd files
│
├── completion/              # Shell completion scripts
│   ├── lh.bash              # Bash completion
│   ├── lh.zsh               # Zsh completion
│   └── lh.fish              # Fish completion
│
└── test/                    # Test suite
    ├── tests.sh             # Run all tests
    ├── test-list.sh         # Test list scripts
    ├── test-ask.sh          # Test ask scripts
    └── test-render.sh       # Test render script
```

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

### Installation and Authentication

```bash
# Install engines
./lh install ollama     # Install Ollama
./lh install claude     # Install Claude CLI
./lh install copilot    # Install Copilot CLI
./lh install all        # Install all engines

# Authenticate with engines
./lh login ollama       # Check Ollama status (no auth needed)
./lh login claude       # Login to Claude (browser auth)
./lh login copilot      # Login to Copilot (browser auth)
./lh login all          # Login to all engines

# Or use provider commands directly
ollama pull qwen2.5-coder:7b   # Pull Ollama model
claude login                    # Claude authentication
copilot auth login              # Copilot authentication
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

1. Create `install_<provider>.sh` - Installation script
2. Create `login_<provider>.sh` - Authentication script
3. Create `list_<provider>.sh` - List models script
4. Create `ask_<provider>.sh` - Prompt models script
5. Update `install.sh`, `login.sh`, `list.sh`, and `ask.sh` to include the new provider
6. Create `README-<provider>.md` - Provider documentation
7. Add tests in `test/test-ask.sh` and `test/test-list.sh`
8. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for more details.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Author

Created for processing LLM Markdown (.lmd) files in AI-powered documentation workflows.

## Related Projects

- [Ollama](https://ollama.ai/) - Run LLMs locally
- [Anthropic Claude](https://www.anthropic.com/) - Claude AI models
- [GitHub Copilot](https://github.com/features/copilot) - AI pair programmer
