# Fish completion for lh command
# Install: copy to ~/.config/fish/completions/

# Disable file completion by default
complete -c lh -f

# Commands
complete -c lh -n "__fish_use_subcommand" -a "install" -d "Install an engine"
complete -c lh -n "__fish_use_subcommand" -a "login" -d "Login to an engine"
complete -c lh -n "__fish_use_subcommand" -a "ask" -d "Prompt a model"
complete -c lh -n "__fish_use_subcommand" -a "list" -d "List available models"
complete -c lh -n "__fish_use_subcommand" -a "render" -d "Process .lmd files"
complete -c lh -n "__fish_use_subcommand" -a "help" -d "Show help message"

# Engines for install/login/list
complete -c lh -n "__fish_seen_subcommand_from install login list" -a "ollama" -d "Local Ollama models"
complete -c lh -n "__fish_seen_subcommand_from install login list" -a "claude" -d "Anthropic Claude API"
complete -c lh -n "__fish_seen_subcommand_from install login list" -a "copilot" -d "GitHub Copilot API"
complete -c lh -n "__fish_seen_subcommand_from install login list" -a "all" -d "All engines"

# Engines for ask command
complete -c lh -n "__fish_seen_subcommand_from ask; and not __fish_seen_subcommand_from ollama claude copilot" -a "ollama" -d "Local Ollama models"
complete -c lh -n "__fish_seen_subcommand_from ask; and not __fish_seen_subcommand_from ollama claude copilot" -a "claude" -d "Anthropic Claude API"
complete -c lh -n "__fish_seen_subcommand_from ask; and not __fish_seen_subcommand_from ollama claude copilot" -a "copilot" -d "GitHub Copilot API"

# Models for Ollama
function __lh_ollama_models
    if command -sq ollama
        ollama list 2>/dev/null | awk 'NR>1 {print $1}'
    end
end
complete -c lh -n "__fish_seen_subcommand_from ask; and __fish_seen_subcommand_from ollama" -a "(__lh_ollama_models)" -d "Ollama model"

# Models for Claude
complete -c lh -n "__fish_seen_subcommand_from ask; and __fish_seen_subcommand_from claude" -a "claude-sonnet-4-5" -d "Claude Sonnet 4.5"
complete -c lh -n "__fish_seen_subcommand_from ask; and __fish_seen_subcommand_from claude" -a "claude-3-5-sonnet-20241022" -d "Claude 3.5 Sonnet"
complete -c lh -n "__fish_seen_subcommand_from ask; and __fish_seen_subcommand_from claude" -a "claude-3-5-haiku-20241022" -d "Claude 3.5 Haiku"
complete -c lh -n "__fish_seen_subcommand_from ask; and __fish_seen_subcommand_from claude" -a "claude-3-opus-20240229" -d "Claude 3 Opus"

# Models for Copilot
complete -c lh -n "__fish_seen_subcommand_from ask; and __fish_seen_subcommand_from copilot" -a "claude-sonnet-4.5" -d "Claude Sonnet 4.5"
complete -c lh -n "__fish_seen_subcommand_from ask; and __fish_seen_subcommand_from copilot" -a "claude-opus-4.5" -d "Claude Opus 4.5"
complete -c lh -n "__fish_seen_subcommand_from ask; and __fish_seen_subcommand_from copilot" -a "claude-haiku-4.5" -d "Claude Haiku 4.5"
complete -c lh -n "__fish_seen_subcommand_from ask; and __fish_seen_subcommand_from copilot" -a "gpt-4" -d "GPT-4"
complete -c lh -n "__fish_seen_subcommand_from ask; and __fish_seen_subcommand_from copilot" -a "gpt-4o" -d "GPT-4 Optimized"
complete -c lh -n "__fish_seen_subcommand_from ask; and __fish_seen_subcommand_from copilot" -a "gemini-2.5-pro" -d "Gemini 2.5 Pro"

# Options for ask command
complete -c lh -n "__fish_seen_subcommand_from ask" -l context -d "Context file or directory" -r
complete -c lh -n "__fish_seen_subcommand_from ask" -l output -d "Output file" -r
complete -c lh -n "__fish_seen_subcommand_from ask" -l log -d "Log file" -r

# File completion for render command (.lmd files)
complete -c lh -n "__fish_seen_subcommand_from render" -F -a "*.lmd"
