#!/bin/bash
# Bash completion for lh command
# Install: source this file or copy to /etc/bash_completion.d/

_lh_completion() {
    local cur prev words cword
    _init_completion || return

    local commands="install login ask list render help"
    local engines="ollama claude copilot all"

    # Complete first argument (command)
    if [ $cword -eq 1 ]; then
        COMPREPLY=($(compgen -W "$commands" -- "$cur"))
        return 0
    fi

    local command="${words[1]}"

    case "$command" in
        install|login|list)
            # Complete engine for install/login/list commands
            if [ $cword -eq 2 ]; then
                COMPREPLY=($(compgen -W "$engines" -- "$cur"))
            fi
            ;;
        ask)
            # Complete engine for ask command
            if [ $cword -eq 2 ]; then
                COMPREPLY=($(compgen -W "$engines" -- "$cur"))
            elif [ $cword -eq 3 ]; then
                # Complete model-id based on engine
                local engine="${words[2]}"
                case "$engine" in
                    ollama)
                        # Get ollama models if available
                        if command -v ollama >/dev/null 2>&1; then
                            local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
                            COMPREPLY=($(compgen -W "$models" -- "$cur"))
                        fi
                        ;;
                    claude)
                        # Common Claude models
                        local models="claude-sonnet-4-5 claude-3-5-sonnet-20241022 claude-3-5-haiku-20241022 claude-3-opus-20240229"
                        COMPREPLY=($(compgen -W "$models" -- "$cur"))
                        ;;
                    copilot)
                        # Common Copilot models
                        local models="claude-sonnet-4.5 claude-opus-4.5 claude-haiku-4.5 gpt-4 gpt-4o gemini-2.5-pro"
                        COMPREPLY=($(compgen -W "$models" -- "$cur"))
                        ;;
                esac
            elif [ $cword -ge 4 ]; then
                # Complete options
                local options="--context --output --log"
                COMPREPLY=($(compgen -W "$options" -- "$cur"))
            fi
            ;;
        render)
            # Complete .lmd files
            if [ $cword -eq 2 ]; then
                COMPREPLY=($(compgen -f -X '!*.lmd' -- "$cur"))
            fi
            ;;
    esac

    return 0
}

complete -F _lh_completion lh
