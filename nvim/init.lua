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

  -- SYNTAX HIGHLIGHTING (nvim 0.11+ compatible)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      -- Modern treesitter setup for nvim 0.11+
      vim.treesitter.language.register("python", "python")
      vim.treesitter.language.register("cpp", "cpp")
      vim.treesitter.language.register("lua", "lua")

      -- Enable treesitter highlighting
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "python", "cpp", "lua", "javascript", "typescript", "rust", "go", "c" },
        callback = function()
          pcall(vim.treesitter.start)
        end
      })
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

  -- LSP (nvim 0.11+ native config)
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- LSP keymaps
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local bufnr = args.buf
          local o = { noremap = true, silent = true, buffer = bufnr }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, o)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, o)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, o)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, o)
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, o)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, o)
        end
      })

      -- Configure LSP servers using nvim 0.11+ API
      vim.lsp.config.pyright = {
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
        root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
      }

      vim.lsp.config.clangd = {
        cmd = { "clangd" },
        filetypes = { "c", "cpp", "objc", "objcpp" },
        root_markers = { "compile_commands.json", "compile_flags.txt", ".git" },
      }

      -- Enable the servers
      vim.lsp.enable({ "pyright", "clangd" })
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
