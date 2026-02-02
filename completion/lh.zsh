#compdef lh
# Zsh completion for lh command
# Install: copy to a directory in your $fpath (e.g., /usr/local/share/zsh/site-functions/)

_lh() {
    local -a commands engines
    commands=(
        'install:Install an engine'
        'login:Login to an engine'
        'ask:Prompt a model'
        'list:List available models'
        'render:Process .lmd files'
        'help:Show help message'
    )

    engines=(
        'ollama:Local Ollama models'
        'claude:Anthropic Claude API'
        'copilot:GitHub Copilot API'
        'all:All engines'
    )

    _arguments -C \
        '1: :->command' \
        '*:: :->args'

    case $state in
        command)
            _describe 'command' commands
            ;;
        args)
            case $words[1] in
                install|login|list)
                    _describe 'engine' engines
                    ;;
                ask)
                    case $CURRENT in
                        2)
                            _describe 'engine' engines
                            ;;
                        3)
                            case $words[2] in
                                ollama)
                                    if (( $+commands[ollama] )); then
                                        local -a models
                                        models=(${(f)"$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')"})
                                        _describe 'model' models
                                    fi
                                    ;;
                                claude)
                                    local -a models
                                    models=(
                                        'claude-sonnet-4-5:Claude Sonnet 4.5'
                                        'claude-3-5-sonnet-20241022:Claude 3.5 Sonnet'
                                        'claude-3-5-haiku-20241022:Claude 3.5 Haiku'
                                        'claude-3-opus-20240229:Claude 3 Opus'
                                    )
                                    _describe 'model' models
                                    ;;
                                copilot)
                                    local -a models
                                    models=(
                                        'claude-sonnet-4.5:Claude Sonnet 4.5'
                                        'claude-opus-4.5:Claude Opus 4.5'
                                        'claude-haiku-4.5:Claude Haiku 4.5'
                                        'gpt-4:GPT-4'
                                        'gpt-4o:GPT-4 Optimized'
                                        'gemini-2.5-pro:Gemini 2.5 Pro'
                                    )
                                    _describe 'model' models
                                    ;;
                            esac
                            ;;
                        *)
                            _arguments \
                                '--context[Context file or directory]:file:_files' \
                                '--output[Output file]:file:_files' \
                                '--log[Log file]:file:_files'
                            ;;
                    esac
                    ;;
                render)
                    _files -g '*.lmd'
                    ;;
            esac
            ;;
    esac
}

_lh "$@"
