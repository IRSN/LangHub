# Shell Completion for LangHub

This directory contains shell completion scripts for the `lh` command.

## Available Completions

- **`lh.bash`** - Bash completion
- **`lh.zsh`** - Zsh completion
- **`lh.fish`** - Fish completion

## Features

- **Command completion**: `install`, `login`, `ask`, `list`, `render`, `help`
- **Engine completion**: `ollama`, `claude`, `copilot`, `all`
- **Model completion**: Dynamically lists available models for each engine
  - Ollama: Queries `ollama list` for installed models
  - Claude: Suggests common Claude models
  - Copilot: Suggests common Copilot models
- **Option completion**: `--context`, `--output`, `--log`
- **File completion**: `.lmd` files for `render` command

## Installation

### Bash

**Temporary (current session only):**
```bash
source completion/lh.bash
```

**Permanent (user-specific):**
```bash
# Add to ~/.bashrc
echo "source $(pwd)/completion/lh.bash" >> ~/.bashrc
source ~/.bashrc
```

**System-wide (all users):**
```bash
sudo cp completion/lh.bash /etc/bash_completion.d/lh
# Reload bash completions or restart terminal
```

### Zsh

**Method 1: Add to fpath (recommended):**
```bash
# Add to ~/.zshrc
echo "fpath=($(pwd)/completion \$fpath)" >> ~/.zshrc
echo "autoload -Uz compinit && compinit" >> ~/.zshrc
source ~/.zshrc
```

**Method 2: Copy to standard location:**
```bash
# Copy to a directory in your fpath
cp completion/lh.zsh /usr/local/share/zsh/site-functions/_lh
# Reload completions
autoload -Uz compinit && compinit
```

### Fish

**User-specific installation:**
```bash
mkdir -p ~/.config/fish/completions
cp completion/lh.fish ~/.config/fish/completions/
# Completions are loaded automatically in new fish sessions
```

**System-wide installation:**
```bash
sudo cp completion/lh.fish /usr/share/fish/vendor_completions.d/
```

## Usage Examples

After installation, press Tab to trigger completions:

```bash
# Command completion
lh <Tab>
# Shows: install login ask list render help

# Engine completion
lh install <Tab>
# Shows: ollama claude copilot all

# Model completion (Ollama)
lh ask ollama <Tab>
# Shows: qwen2.5-coder:7b mistral:7b llama3.1:8b ... (your installed models)

# Model completion (Claude)
lh ask claude <Tab>
# Shows: claude-sonnet-4-5 claude-3-5-sonnet-20241022 claude-3-5-haiku-20241022 ...

# Model completion (Copilot)
lh ask copilot <Tab>
# Shows: claude-sonnet-4.5 gpt-4 gpt-4o gemini-2.5-pro ...

# File completion (.lmd files)
lh render <Tab>
# Shows: *.lmd files in current directory

# Option completion
lh ask ollama qwen2.5-coder:7b "prompt" --<Tab>
# Shows: --context --output --log
```

## Troubleshooting

### Bash: Completions not working

1. Ensure bash-completion is installed:
   ```bash
   # Debian/Ubuntu
   sudo apt install bash-completion

   # macOS (via Homebrew)
   brew install bash-completion@2
   ```

2. Check if completion is sourced:
   ```bash
   type _lh_completion
   # Should show: _lh_completion is a function
   ```

3. Try manually sourcing:
   ```bash
   source completion/lh.bash
   ```

### Zsh: Completions not working

1. Check if compinit is initialized:
   ```bash
   # Add to ~/.zshrc if not present
   autoload -Uz compinit && compinit
   ```

2. Clear completion cache:
   ```bash
   rm ~/.zcompdump*
   autoload -Uz compinit && compinit
   ```

3. Verify fpath includes completion directory:
   ```bash
   echo $fpath | grep -o '/path/to/langhub/completion'
   ```

### Fish: Completions not working

1. Check completions directory:
   ```bash
   echo $fish_complete_path
   # Should include ~/.config/fish/completions
   ```

2. Verify file is in place:
   ```bash
   ls ~/.config/fish/completions/lh.fish
   ```

3. Reload completions:
   ```bash
   fish_update_completions
   ```

## Testing

Test if completions are working:

```bash
# Type this and press Tab
lh <Tab>

# You should see: install login ask list render help
```

## Customization

### Adding Custom Models

**Bash:** Edit `lh.bash` and add models to the appropriate case statement:
```bash
claude)
    local models="claude-sonnet-4-5 your-custom-model"
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
    ;;
```

**Zsh:** Edit `lh.zsh` and add to the models array:
```zsh
models=(
    'claude-sonnet-4-5:Claude Sonnet 4.5'
    'your-custom-model:Your Custom Model'
)
```

**Fish:** Edit `lh.fish` and add complete commands:
```fish
complete -c lh -n "..." -a "your-custom-model" -d "Your Custom Model"
```

## Contributing

Improvements to completions are welcome! When adding new commands or options:

1. Update all three completion scripts (bash, zsh, fish)
2. Test on each shell
3. Update this README with new features
4. Submit a pull request

## License

Same as LangHub (MIT License)
