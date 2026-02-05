#!/usr/bin/env bash
set -euo pipefail

need() { command -v "$1" >/dev/null 2>&1; }

echo "[0/8] Detecting package manager..."
if need apt; then
    PKG=apt
elif need dnf; then
    PKG=dnf
elif need pacman; then
    PKG=pacman
else
    echo "Unsupported package manager. Install dependencies manually."
    exit 1
fi

echo "[1/8] Updating package database..."
case "$PKG" in
    apt)    sudo apt update ;;
    dnf)    sudo dnf check-update || true ;;
    pacman) sudo pacman -Sy ;;
esac

echo "[2/8] Installing core developer tools..."
case "$PKG" in
    apt)
        sudo apt install -y neovim git tmux nodejs npm python3 python3-pip ripgrep curl
        ;;
    dnf)
        sudo dnf install -y neovim git tmux nodejs npm python3 python3-pip ripgrep curl
        ;;
    pacman)
        sudo pacman -Syu --noconfirm neovim git tmux nodejs npm python python-pip ripgrep curl
        ;;
esac

echo "[3/8] Installing LSP servers & formatters..."
case "$PKG" in
    apt)
        sudo apt install -y clang-format llvm
        sudo npm install -g pyright
        pip3 install --user black
        ;;
    dnf)
        sudo dnf install -y clang-tools-extra llvm
        sudo npm install -g pyright
        pip3 install --user black
        ;;
    pacman)
        sudo pacman -S --noconfirm clang llvm
        sudo npm install -g pyright
        pip install --user black
        ;;
esac

echo "[4/8] Installing optional tools..."
case "$PKG" in
    apt)
        sudo apt install -y fzf fd-find
        ;;
    dnf)
        sudo dnf install -y fzf fd-find
        ;;
    pacman)
        sudo pacman -S --noconfirm fzf fd
        ;;
esac

echo "[5/8] Installing lazy.nvim..."
if [ ! -d "$HOME/.local/share/nvim/lazy/lazy.nvim" ]; then
  git clone https://github.com/folke/lazy.nvim.git \
    ~/.local/share/nvim/lazy/lazy.nvim
fi

echo "[6/8] Linking Neovim config..."
mkdir -p ~/.config/nvim
cp -f "$(dirname "$0")/../nvim/init.lua" ~/.config/nvim/init.lua

echo "[7/8] Bootstrapping Neovim plugins..."
nvim --headless +qa || true

echo "[8/8] Installing Treesitter parsers..."
nvim --headless -c "TSUpdate" +qa || true

echo "Setup complete. Launch Neovim with: nvim"
