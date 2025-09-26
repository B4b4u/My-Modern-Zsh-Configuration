# ~/.zshrc

# ------------------------------------------------------------------------------
# 1. ENVIRONMENT & HISTORY
# ------------------------------------------------------------------------------

# Set the directory for Zinit and its plugins
export ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Set history file and parameters
export HISTSIZE=5000
export SAVEHIST=5000
export HISTFILE="${HOME}/.zsh_history"

# Shell options for history
setopt APPEND_HISTORY      # Append to the history file
setopt SHARE_HISTORY       # Share history between all sessions
setopt HIST_IGNORE_SPACE   # Ignore commands that start with a space
setopt HIST_IGNORE_ALL_DUPS # Remove all duplicate entries
setopt HIST_SAVE_NO_DUPS   # Don't save duplicate entries
setopt EXTENDED_HISTORY    # Save timestamp and duration of commands

# ------------------------------------------------------------------------------
# 2. ZINIT PLUGIN MANAGER & COMPLETION INIT
# ------------------------------------------------------------------------------

# Download Zinit if it's not already there
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Load Zinit
source "${ZINIT_HOME}/zinit.zsh"

# Initialize the modern completion system FIRST
autoload -Uz compinit && compinit

# --- Zsh Plugins ---
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# --- Oh My Zsh Snippets ---
# These are lightweight parts of Oh My Zsh, loaded without the bloat.
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# Replay completion cache
zinit cdreplay -q

# ------------------------------------------------------------------------------
# 3. COMPLETION STYLING
# ------------------------------------------------------------------------------

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' # Case-insensitive completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no # Do not use select menu for completion
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# ------------------------------------------------------------------------------
# 4. KEYBINDINGS
# ------------------------------------------------------------------------------

# Use emacs keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region # Alt+W to delete a word

# ------------------------------------------------------------------------------
# 5. CUSTOM PROMPT
# ------------------------------------------------------------------------------

setopt PROMPT_SUBST

# --- Prompt Helper Functions ---
# Executed before each command to capture the start time
preexec() {
    start_time=$SECONDS
}

# Git information
git_prompt_info() {
    local branch status
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        branch=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null)
        status=$(git status --porcelain 2>/dev/null)
        if [[ -n $status ]]; then
            echo "%F{magenta}[$branch*]%f" # Branch with modifications (magenta)
        else
            echo "%F{magenta}[$branch]%f"  # Clean branch (magenta)
        fi
    fi
}

# SSH connection indicator
ssh_prompt_info() {
    [[ -n $SSH_CONNECTION ]] && echo "%F{red}[SSH]%f" # [SSH] in red
}

# Root user indicator
sudo_prompt_info() {
    [[ $EUID -eq 0 ]] && echo "%F{red}[ROOT]%f" # [ROOT] in red
}
 
# --- Main Prompt Assembly (executed before each prompt) ---
precmd() {
    echo # Adds a blank line before the prompt for readability

    # Calculate execution time of the last command
    local start_time=${start_time:-$SECONDS} # Ensure start_time is initialized
    local duration=$((SECONDS - start_time))
    local exec_time_str=""
    if (( duration >= 5 )); then
        local h m s
        h=$((duration / 3600))
        m=$(( (duration % 3600) / 60 ))
        s=$((duration % 60))
        exec_time_str=$(printf "%02d:%02d:%02d" $h $m $s)
        exec_time_str="%F{244}($exec_time_str)%f " # Format as (HH:MM:SS) in grey
    fi

    local sep="%F{244}|%f" # Light grey separator

    # Assemble the Left Prompt (PROMPT) using a literal newline
    PROMPT="%K{238}(%B%F{white}${HOST%%.*}%f%b ${sep} %B%F{green}%n%f%b ${sep} %F{yellow}%~%f$(git_prompt_info)$(ssh_prompt_info)$(sudo_prompt_info))%k
%F{cyan}>%f "
    
    # Assemble the Right Prompt (RPROMPT)
    RPROMPT="%K{238}(%F{cyan}$(date '+%Y-%m-%d') ${sep} $(date '+%H:%M')%f ${exec_time_str})%k"
}

# Continuation prompt for multi-line commands
PROMPT2='%F{cyan}>>%f '

# ------------------------------------------------------------------------------
# 6. EXTERNAL TOOLS & INTEGRATIONS
# ------------------------------------------------------------------------------

# fzf integration
eval "$(fzf --zsh)"

# zoxide integration (replaces `cd`)
eval "$(zoxide init --cmd cd zsh)"

# pipx path (created by `pipx`)
export PATH="$PATH:$HOME/.local/bin"

# conda integration (managed by 'conda init')
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

# Source personal aliases file if it exists
if [ -f ~/.zsh_aliases ]; then
    source ~/.zsh_aliases
fi

# Run fastfetch on startup
fastfetch
