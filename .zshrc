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

# --- Local AI (Ollama) ---------------------------------------------------

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

# Local model shortcuts (Qwen Code and Aider were removed; these just
# start Ollama and drop you into `ollama run` directly).
# "-base" = stock pulled checkpoint. Plain name = the tuned "-agent"
# Modelfile variant (40960 ctx, sampling tweaks — see ollama/Modelfile.*).
alias qwen-coder='ai-up >/dev/null; ollama run qwen2.5-coder:3b-agent'      # coder line, lightest (~2GB)
alias qwen-coder-base='ai-up >/dev/null; ollama run qwen2.5-coder:3b-instruct'
alias qwen-fast='ai-up >/dev/null; ollama run qwen3:4b-agent'              # general Qwen3, ~2.5GB
alias qwen-fast-base='ai-up >/dev/null; ollama run qwen3:4b-instruct'
alias qwen-quality='ai-up >/dev/null; ollama run qwen3:8b-agent'           # general Qwen3, ~5.2GB
alias qwen-quality-base='ai-up >/dev/null; ollama run qwen3:8b'

# opencode — agent CLI with a real TUI + tool-calling, multi-provider.
# Config: .config/opencode/opencode.json registers the same 6 Ollama
# models above under the "ollama" provider (no API key needed locally).
alias oc-coder='ai-up >/dev/null; opencode -m ollama/qwen2.5-coder:3b-agent'
alias oc-fast='ai-up >/dev/null; opencode -m ollama/qwen3:4b-agent'
alias oc-quality='ai-up >/dev/null; opencode -m ollama/qwen3:8b-agent'

# --- Local AI (MLX / Ornith) ----------------------------------------------

# A/B candidate for qwen3:8b-agent's "quality" slot — separate port and
# backend (Apple's MLX instead of Ollama/llama.cpp) so it doesn't disturb
# anything above until it's proven out the same way Qwen3 was.
om-up() {
  if curl -s -o /dev/null http://127.0.0.1:8080/v1/models; then
    echo "MLX server already running."
    return 0
  fi
  mlx_lm.server \
    --model ornith-ai/Ornith-1.5-9B-MLX-4bit \
    --host 127.0.0.1 \
    --port 8080 \
    --prefill-step-size 1024 \
    > /tmp/mlx-server.log 2>&1 &
  disown
  # First run also downloads the ~5GB weights, so give it more room than
  # ai-up's Ollama wait before giving up.
  for i in $(seq 1 60); do
    curl -s -o /dev/null http://127.0.0.1:8080/v1/models && { echo "MLX server up."; return 0; }
    sleep 1
  done
  echo "MLX server didn't come up — check /tmp/mlx-server.log"
}

om-down() {
  pkill -f "mlx_lm.server" && echo "MLX server stopped." || echo "MLX server wasn't running."
}

om-status() {
  if curl -s -o /dev/null http://127.0.0.1:8080/v1/models; then
    echo "MLX server: running (port 8080)"
  else
    echo "MLX server: not running"
  fi
}

om-restart() { om-down; sleep 1; om-up; }

# Direct chat, no server — for quick A/B testing against qwen-quality.
alias ornith='mlx_lm.chat --model ornith-ai/Ornith-1.5-9B-MLX-4bit'

# opencode via the MLX server. Config: .config/opencode/opencode.json
# registers this model under the "mlx" provider.
alias oc-ornith='om-up >/dev/null; opencode -m mlx/ornith-ai/Ornith-1.5-9B-MLX-4bit'
