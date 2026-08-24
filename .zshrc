# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Prompt is handled by Starship (see below) — disable the oh-my-zsh theme.
ZSH_THEME=""

# zsh-syntax-highlighting must be the last plugin in the list.
plugins=(git zsh-autosuggestions zsh-completions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

export EDITOR='vim'

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/pbernardo/.lmstudio/bin"
# End of LM Studio CLI section

. "$HOME/.local/bin/env"

# --- Modern CLI tools ---------------------------------------------------

# eza (better ls)
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first'
alias la='eza -la --icons --group-directories-first'
alias lt='eza --tree --icons --level=2'

# bat (better cat)
export BAT_THEME="Nord"
alias cat='bat --paging=never --style=plain'

# fzf (fuzzy finder) key bindings + completion
source <(fzf --zsh)

# zoxide (smarter cd) — use `z` to jump to frecent directories
eval "$(zoxide init zsh)"

# Starship prompt
eval "$(starship init zsh)"
