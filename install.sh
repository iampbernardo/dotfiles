#!/usr/bin/env bash
# Bootstrap del setup de terminal en una Mac nueva.
# Uso: ./install.sh
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Homebrew"
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

echo "==> Paquetes (Brewfile)"
brew bundle --file="$DOTFILES_DIR/Brewfile"

echo "==> uv (Python package manager)"
if ! command -v uv &>/dev/null; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

echo "==> oh-my-zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no KEEP_ZSHRC=yes CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "==> Plugins de zsh"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
for plugin in zsh-autosuggestions zsh-syntax-highlighting zsh-completions; do
  target="$ZSH_CUSTOM/plugins/$plugin"
  if [ ! -d "$target" ]; then
    git clone --quiet "https://github.com/zsh-users/$plugin" "$target"
  fi
done

echo "==> Enlazando dotfiles (stow)"
cd "$DOTFILES_DIR"
stow .

echo "==> Modelos locales de Ollama (ver ollama/, .zshrc: ai-up/ai-down/ai-status)"
if command -v ollama &>/dev/null; then
  ollama serve >/tmp/ollama-install.log 2>&1 &
  OLLAMA_INSTALL_PID=$!
  sleep 2
  ollama pull qwen2.5-coder:3b-instruct
  ollama pull qwen3:4b-instruct
  ollama pull qwen3:8b
  ollama create qwen2.5-coder:3b-agent -f "$DOTFILES_DIR/ollama/Modelfile.qwen2.5-coder-3b-agent"
  ollama create qwen3:4b-agent -f "$DOTFILES_DIR/ollama/Modelfile.qwen3-4b-agent"
  ollama create qwen3:8b-agent -f "$DOTFILES_DIR/ollama/Modelfile.qwen3-8b-agent"
  kill "$OLLAMA_INSTALL_PID"
fi

echo "==> mlx-lm para Ornith 1.5 9B (ver .zshrc: om-up/om-down/om-status, alias oc-ornith/ornith)"
if [[ "$(uname -m)" == "arm64" ]]; then
  uv tool install mlx-lm --quiet
  # Los pesos (~5GB) se descargan solos en el primer om-up/ornith, no aquí.
fi

echo "==> Ajustes de macOS (Dock, Finder, teclado, capturas)"
"$DOTFILES_DIR/macos-defaults.sh"

echo "==> Listo. Abre Ghostty (o una terminal nueva) para verlo."
