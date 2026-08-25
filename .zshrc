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

# lazygit (git TUI)
alias lg='lazygit'

# btop (system monitor)
alias top='btop'

# Starship prompt
eval "$(starship init zsh)"

# fastfetch — banner de sistema al abrir una terminal nueva
if [[ -o interactive ]] && command -v fastfetch &>/dev/null; then
  fastfetch
fi

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

# Qwen Code PATH block begin
export PATH='/Users/pbernardo/.local/bin':$PATH
# Qwen Code PATH block end

# --- Local AI (Ollama / Qwen Code) --------------------------------------

# Start Ollama on demand (not a login service — keeps idle RAM free)
ai-up() {
  if curl -s -o /dev/null http://localhost:11434/api/version; then
    echo "Ollama already running."
    return 0
  fi
  ollama serve > /tmp/ollama-serve.log 2>&1 &
  disown
  for i in $(seq 1 20); do
    curl -s -o /dev/null http://localhost:11434/api/version && { echo "Ollama up."; return 0; }
    sleep 0.5
  done
  echo "Ollama didn't come up — check /tmp/ollama-serve.log"
}

ai-down() {
  pkill -f "ollama serve" && echo "Ollama stopped." || echo "Ollama wasn't running."
}

ai-status() {
  if curl -s -o /dev/null http://localhost:11434/api/version; then
    echo "Ollama: running"
    ollama ps
  else
    echo "Ollama: not running"
  fi
}

ai-restart() { ai-down; sleep 1; ai-up; }

# Qwen Code model switches
# qwen3:4b-agent  -> local, fast, ~3GB RAM, default. Non-thinking (instruct)
#                    checkpoint tuned for agent use — safe default for
#                    sensitive code.
# qwen3:8b-agent  -> local, higher quality, ~5-6GB RAM. Hybrid thinking model
#                    (no non-thinking 8b tag exists), so it's slower and can
#                    still ramble on some prompts. Close heavy apps first.
# qwen-coder-plus -> cloud (Alibaba Dashscope) — non-sensitive projects only.
#                    Needs DASHSCOPE_API_KEY (the old free Qwen OAuth tier
#                    was discontinued 2026-04-15).
alias qwen-fast='ai-up >/dev/null; qwen --model qwen3:4b-agent'
alias qwen-quality='ai-up >/dev/null; qwen --model qwen3:8b-agent'
qwen-cloud() {
  if [[ -z "$DASHSCOPE_API_KEY" ]]; then
    echo "Set DASHSCOPE_API_KEY first, e.g.: export DASHSCOPE_API_KEY=sk-..."
    return 1
  fi
  qwen --model qwen3-coder-plus
}
