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

echo "==> Inicializando configuración de Pi"
git -C "$DOTFILES_DIR" submodule update --init --recursive
npm install -g --ignore-scripts @earendil-works/pi-coding-agent@0.85.1
make -C "$DOTFILES_DIR/my-pi" link

echo "==> Enlazando dotfiles (stow)"
cd "$DOTFILES_DIR"
# .stow-local-ignore keeps docs/ and its design exports in this repository.
stow .

echo "==> Ajustes de macOS (Dock, Finder, teclado, capturas)"
"$DOTFILES_DIR/macos-defaults.sh"

echo "==> Listo. Abre Ghostty (o una terminal nueva) para verlo."
