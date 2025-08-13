
# change the name if you want
REPO=nv-cracked-mac
mkdir -p $REPO/{nvim,scripts}
cat > $REPO/.gitignore <<'EOF'
# nvim cache
.cache/
# mac files
.DS_Store
EOF

# Neovim config
cat > $REPO/nvim/init.lua <<'EOF'
-- =====================
--   BASIC SETTINGS
-- =====================
vim.g.mapleader = " " -- Space as leader
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true
vim.opt.updatetime = 300
vim.opt.signcolumn = "yes"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Load lazy.nvim
vim.opt.rtp:prepend("~/.local/share/nvim/lazy/lazy.nvim")

require("lazy").setup({

  -- FILE TREE
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
    end
  },

  -- FUZZY FINDER
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      vim.keymap.set("n", "<leader>f", ":Telescope find_files<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>g", ":Telescope live_grep<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>p", ":Telescope oldfiles<CR>", { noremap = true, silent = true })
    end
  },

  -- SYNTAX HIGHLIGHTING
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = { "python", "cpp", "lua" },
        highlight = { enable = true },
        indent = { enable = true }
      }
    end
  },

  -- GIT
  { "tpope/vim-fugitive" },
  {
    "lewis6991/gitsigns.nvim",
    config = function() require("gitsigns").setup() end
  },

  -- COMMENTS
  {
    "numToStr/Comment.nvim",
    config = function() require("Comment").setup() end
  },

  -- STATUSLINE
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup {
        options = { theme = "auto", section_separators = '', component_separators = '' }
      }
    end
  },

  -- WHICH-KEY
  {
    "folke/which-key.nvim",
    config = function() require("which-key").setup() end
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local on_attach = function(_, bufnr)
        local o = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, o)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, o)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, o)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, o)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, o)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, o)
      end
      lspconfig.pyright.setup { on_attach = on_attach }
      lspconfig.clangd.setup { on_attach = on_attach }
    end
  },

  -- AUTOCOMPLETE
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip"
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup {
        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" }
        })
      }
    end
  },

  -- FORMATTER (CONFORM)
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          python = { "black" },
          cpp = { "clang-format" },
        },
        format_on_save = { timeout_ms = 500, lsp_fallback = true },
      })
    end
  }

})
EOF

# mac installer
cat > $REPO/scripts/install_macos.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

echo "[1/5] Installing Homebrew deps..."
brew list neovim >/dev/null 2>&1 || brew install neovim
brew list ripgrep >/dev/null 2>&1 || brew install ripgrep
brew list pyright >/dev/null 2>&1 || brew install pyright
brew list llvm >/dev/null 2>&1 || brew install llvm
brew list black >/dev/null 2>&1 || brew install black
brew list clang-format >/dev/null 2>&1 || brew install clang-format
brew list gh >/dev/null 2>&1 || true

echo "[2/5] Installing lazy.nvim..."
if [ ! -d "$HOME/.local/share/nvim/lazy/lazy.nvim" ]; then
  git clone https://github.com/folke/lazy.nvim.git \
    ~/.local/share/nvim/lazy/lazy.nvim
fi

echo "[3/5] Linking Neovim config..."
mkdir -p ~/.config/nvim
cp -f "$(dirname "$0")/../nvim/init.lua" ~/.config/nvim/init.lua

echo "[4/5] Boot Neovim once to install plugins..."
nvim +q --headless || true

echo "[5/5] Treesitter parsers..."
nvim -c "TSUpdate" +q

echo "Done. Open Neovim with: nvim"
EOF
chmod +x $REPO/scripts/install_macos.sh

# README
cat > $REPO/README.md <<'EOF'
# nv-cracked-mac

Neovim config for macOS with:
- Space leader, Telescope, nvim-tree
- Treesitter
- LSP (pyright, clangd) + nvim-cmp
- Git (gitsigns, fugitive)
- `conform.nvim` autoformat on save (black, clang-format)

## Install (macOS)
```bash
./scripts/install_macos.sh
