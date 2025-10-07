# ~/.zshrc

# Add /usr/local/sbin to the PATH for user-installed binaries.
export PATH=$PATH:/usr/local/sbin


# ------------------------------------------------------------------------------
# 1. ENVIRONMENT & HISTORY
# ------------------------------------------------------------------------------

# Set the directory for Zinit and its plugins.
export ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Set history file and parameters.
export HISTSIZE=5000
export SAVEHIST=5000
export HISTFILE="${HOME}/.zsh_history"

# Shell options for history management.
setopt APPEND_HISTORY       # Append to the history file, don't overwrite.
setopt SHARE_HISTORY        # Share history between all running sessions.
setopt HIST_IGNORE_SPACE    # Ignore commands that start with a space.
setopt HIST_IGNORE_ALL_DUPS # Remove all duplicate entries from history.
setopt HIST_SAVE_NO_DUPS    # Don't save a new command if it's a duplicate of the last one.
setopt EXTENDED_HISTORY     # Save timestamp and duration of commands.


# ------------------------------------------------------------------------------
# 2. ZINIT PLUGIN MANAGER
# ------------------------------------------------------------------------------

# Load Zinit. It will automatically install if not present.
source "${ZINIT_HOME}/zinit.zsh"

# --- Zsh Plugins ---
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# --- Snippets from Oh My Zsh (lightweight) ---
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# --- Initialize the completion system ---
# Key change: we load compinit AFTER loading completion-related plugins.
autoload -Uz compinit && compinit

# Replay the completion cache.
zinit cdreplay -q


# ------------------------------------------------------------------------------
# 3. COMPLETION STYLING
# ------------------------------------------------------------------------------

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' # Case-insensitive completion.
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"  # Use LS_COLORS for completion highlighting.
zstyle ':completion:*' menu no                         # Disable menu selection for completion.

# Set fzf-tab previews for common commands.
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'


# ------------------------------------------------------------------------------
# 4. KEYBINDINGS
# ------------------------------------------------------------------------------

# Use emacs-style keybindings.
bindkey -e

# Custom keybindings for history search.
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# Custom keybinding for killing a word (Alt+W).
bindkey '^[w' kill-region


# ------------------------------------------------------------------------------
# 5. CUSTOM PROMPT
# ------------------------------------------------------------------------------

# Allow prompt substitutions.
setopt PROMPT_SUBST

# --- Prompt Helper Functions ---

# Executed before each command.
preexec() {
    # 1. Capture the start time for duration calculation.
    start_time=$SECONDS

    # 2. Make the previous prompt transient.
    #    Only run in an interactive terminal.
    [[ -t 1 ]] || return

    #    Get the original command line (before alias expansion).
    local command_line="$1"

    #    Build the simplified prompt string.
    local transient_prompt="%F{yellow}%~ %F{cyan}❯%f ${command_line}"

    #    Use terminal escape codes to redraw the prompt area.
    #    \e[2A -> Move cursor UP 2 lines.
    #    \r   -> Move cursor to the beginning of the line.
    #    \e[K -> Clear the line from the cursor to the end.
    #    \n   -> Move cursor DOWN 1 line.
    print -Pn '\e[2A\r\e[K'
    print -P "${transient_prompt}"
    print -Pn '\n\r\e[K'
}

# Gets Git status information for the prompt.
git_prompt_info() {
    local branch git_status
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        branch=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null)
        git_status=$(git status --porcelain 2>/dev/null)
        if [[ -n $git_status ]]; then
            echo "%F{magenta}[$branch*]%f" # Branch with modifications (*).
        else
            echo "%F{magenta}[$branch]%f"  # Clean branch.
        fi
    fi
}

# Shows an indicator if in an SSH session.
ssh_prompt_info() {
    [[ -n $SSH_CONNECTION ]] && echo "%F{red}[SSH]%f"
}

# Shows an indicator if running as root.
sudo_prompt_info() {
    [[ $EUID -eq 0 ]] && echo "%F{red}[ROOT]%f"
}

# --- Main Prompt Assembly (executed before each prompt) ---
precmd() {
    # Adds a blank line before the prompt for readability.
    echo

    # Calculate execution time of the last command.
    local start_time=${start_time:-$SECONDS}
    local duration=$((SECONDS - start_time))
    local exec_time_str=""
    if (( duration >= 1 )); then # Show for commands taking 1s or more.
        local h m s
        h=$((duration / 3600))
        m=$(( (duration % 3600) / 60 ))
        s=$((duration % 60))
        exec_time_str=$(printf "%02d:%02d:%02d" $h $m $s)
        exec_time_str="%F{244}($exec_time_str)%f " # Format as (HH:MM:SS) in grey.
    fi

    local sep="%F{244}|%f" # Light grey separator.

    # Assemble the Left Prompt (PROMPT) using a literal newline for a two-line prompt.
    PROMPT="%K{238}(%B%F{white}${HOST%%.*}%f%b ${sep} %B%F{green}%n%f%b ${sep} %F{yellow}%~%f$(git_prompt_info)$(ssh_prompt_info)$(sudo_prompt_info))%k
%F{cyan}>%f "

    # Assemble the Right Prompt (RPROMPT).
    RPROMPT="%K{238}(%F{cyan}$(date '+%Y-%m-%d | %H:%M')%f ${exec_time_str})%k"
}

# Continuation prompt for multi-line commands.
PROMPT2='%F{cyan}>>%f '


# ------------------------------------------------------------------------------
# 6. EXTERNAL TOOLS & INTEGRATIONS
# ------------------------------------------------------------------------------

# Zinit is now handling fzf integration cleanly.
# The old 'eval "$(fzf --zsh)"' is no longer needed.
# Add 'zinit light junegunn/fzf' to the plugin list to enable keybindings.

# zoxide integration (a smarter 'cd' command).
eval "$(zoxide init --cmd cd zsh)"

# Add pipx-installed tools to the PATH.
export PATH="$PATH:$HOME/.local/bin"

# This block is managed by 'conda init'.
# >>> conda initialize >>>
__conda_setup="$('$HOME/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# ------------------------------------------------------------------------------
# 7. ALIASES & STARTUP COMMAND
# ------------------------------------------------------------------------------

# Source personal aliases file if it exists.
if [ -f ~/.zsh_aliases ]; then
    source ~/.zsh_aliases
fi

fastfetch
