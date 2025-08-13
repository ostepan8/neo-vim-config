
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
    echo "❌ Unsupported package manager. Install dependencies manually."
    exit 1
fi

echo "[1/8] Updating package database..."
case "$PKG" in
    apt)
        sudo apt update
        sudo apt install -y neovim git tmux nodejs npm python3 python3-pip ripgrep clang-format curl
        sudo npm install -g pyright
        pip3 install --user black
        sudo apt install -y llvm
        ;;
    dnf)
        sudo dnf install -y neovim git tmux nodejs npm python3 python3-pip ripgrep clang-tools-extra curl
        sudo npm install -g pyright
        pip3 install --user black
        sudo dnf install -y llvm
        ;;
    pacman)
        sudo pacman -Syu --noconfirm neovim git tmux nodejs npm python python-pip ripgrep clang curl llvm
        sudo npm install -g pyright
        pip install --user black
        ;;
esac

echo "[2/8] Installing optional tools..."
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

echo "[3/8] Installing lazy.nvim..."
if [ ! -d "$HOME/.local/share/nvim/lazy/lazy.nvim" ]; then
  git clone https://github.com/folke/lazy.nvim.git \
    ~/.local/share/nvim/lazy/lazy.nvim
fi

echo "[4/8] Linking Neovim config..."
mkdir -p ~/.config/nvim
cp -f "$(dirname "$0")/../nvim/init.lua" ~/.config/nvim/init.lua

echo "[5/8] Bootstrapping Neovim plugins..."
nvim +q --headless || true

echo "[6/8] Installing Treesitter parsers..."
nvim -c "TSUpdate" +q

echo "✅ Setup complete. Launch Neovim with: nvim"
