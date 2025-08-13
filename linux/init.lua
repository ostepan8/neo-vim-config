
#!/usr/bin/env bash
set -euo pipefail

echo "[0/8] Checking for Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "[1/8] Updating Homebrew..."
brew update

echo "[2/8] Installing core developer tools..."
brew install neovim git tmux node python ripgrep

echo "[3/8] Installing LSP servers & formatters..."
brew install pyright llvm black clang-format

echo "[4/8] Installing optional tools..."
brew install lazygit fzf fd gh

echo "[5/8] Installing lazy.nvim..."
if [ ! -d "$HOME/.local/share/nvim/lazy/lazy.nvim" ]; then
  git clone https://github.com/folke/lazy.nvim.git \
    ~/.local/share/nvim/lazy/lazy.nvim
fi

echo "[6/8] Linking Neovim config..."
mkdir -p ~/.config/nvim
cp -f "$(dirname "$0")/../nvim/init.lua" ~/.config/nvim/init.lua

echo "[7/8] Bootstrapping Neovim plugins..."
nvim +q --headless || true

echo "[8/8] Installing Treesitter parsers..."
nvim -c "TSUpdate" +q

echo "✅ Setup complete. Launch Neovim with: nvim"
