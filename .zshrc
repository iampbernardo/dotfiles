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

# --- Dotfiles (GNU Stow) -------------------------------------------------

alias dot='cd ~/dotfiles'

# Re-link everything and show what changed (safe to run anytime)
dotsync() {
  (cd ~/dotfiles && stow . && git status --short)
}

# Re-link, commit and push in one go. Usage: dotpush "mensaje del commit"
dotpush() {
  local msg="${1:-update dotfiles}"
  (cd ~/dotfiles && stow . && git add -A && git commit -m "$msg" && git push)
}

dothelp() {
  cat <<'EOF'
Gestión de ~/dotfiles (GNU Stow)

  dot              cd a ~/dotfiles
  dotsync          re-enlaza (stow .) y muestra qué cambió, sin commitear
  dotpush "msg"    re-enlaza + commit + push (mensaje opcional)
  dotbrew          regenera la sección "brew" del Brewfile
  dothelp          este mensaje

Para añadir un dotfile nuevo:
  1. mueve el archivo real a ~/dotfiles manteniendo su ruta relativa a $HOME
     (p.ej. ~/.config/tmux/tmux.conf -> ~/dotfiles/.config/tmux/tmux.conf)
  2. dotsync    (crea el symlink de vuelta a $HOME)
EOF
}

# Regenera las líneas `brew "..."` del Brewfile con lo que instalaste
# explícitamente (brew list --installed-on-request). Conserva tal cual
# los `tap`/`cask` existentes, que son curados a mano.
dotbrew() {
  local file="$HOME/dotfiles/Brewfile"
  local tmp
  tmp="$(mktemp)"

  {
    grep -E '^(tap|cask) ' "$file"
    echo ""
    echo "# --- brews (regenerado por dotbrew el $(date +%Y-%m-%d)) ---"
    brew list --installed-on-request --formula | sort | sed 's/^/brew "/;s/$/"/'
  } > "$tmp"

  mv "$tmp" "$file"
  echo "Brewfile regenerado. Revisa el diff antes de subir:"
  (cd ~/dotfiles && git diff Brewfile)
}
