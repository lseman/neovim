# Neovim Configuration

A modern, state-of-the-art Neovim configuration built for productivity, featuring AI assistance, fast file search, and a polished UI.

## 🚀 Features

- **AI-Powered Development**: Cursor-like AI experience with `CopilotChat.nvim`
- **Blazing Fast File Search**: `fff.nvim` - the fastest and most accurate file search SDK
- **Modern Completion**: `blink.cmp` with `LuaSnip` and `nvim-autopairs`
- **Polished UI**: `snacks.nvim` dashboard, picker, explorer, and more
- **Intelligent Folding**: `nvim-ufo` with Treesitter provider
- **LSP & Formatting**: `conform.nvim` + `nvim-lint` for formatting and linting
- **Git Integration**: `gitsigns.nvim`, `neogit`, and `fugitive`
- **Notebook Support**: `molten.nvim`, `jupytext`, `quarto`, and `otter.nvim`
- **HTTP Client**: `kulala.nvim` for API testing
- **Markdown Preview**: `render-markdown.nvim` and `markdown-preview.nvim`

## 📦 Plugin List

### Core & Plugin Manager
- `folke/lazy.nvim` - Modern plugin manager for Neovim

### UI & Dashboard
- `folke/snacks.nvim` - QoL plugins (dashboard, picker, explorer, terminal, scratch, notifier)
- `folke/which-key.nvim` - Key binding helper
- `folke/tokyonight.nvim` / `catppuccin/nvim` / `sainnhe/everforest` / `EdenEast/nightfox.nvim` - Color schemes
- `nvim-lualine/lualine.nvim` - Statusline
- `nvim-tree/nvim-web-devicons.lua` - File icons
- `folke/trouble.nvim` - Diagnostics, quickfix, and loclist viewer
- `folke/todo-comments.nvim` - TODO/FIXME/HACK/NOTE highlighting and navigation
- `kevinhwang91/nvim-ufo` - Intelligent folding with Treesitter
- `stevearc/bqf.nvim` - Better quickfix window
- `j-hui/fidget.nvim` - LSP progress notifications
- `nacro90/numb.nvim` - Show number on statusline on motion

### Editor & Productivity
- `CopilotC-Nvim/CopilotChat.nvim` - GitHub Copilot chat integration
- `dmtrKovalenko/fff.nvim` - Freakin fast fuzzy file finder
- `folke/flash.nvim` - Navigate with search labels and enhanced character motions
- `saghen/blink.cmp` - Performant, batteries-included completion plugin
- `L3MON4D3/LuaSnip` - Snippet engine
- `windwp/nvim-autopairs` - Autopairs for Neovim
- `echasnovski/mini.nvim` - Library of independent Lua modules
- `echasnovski/mini.map` - Mini map integration
- `mfussenegger/nvim-dap` - Debug Adapter Protocol client
- `nvim-telescope/telescope.nvim` - Find, Filter, Preview, Pick
- `ibhagwan/fzf-lua` - Improved fzf.vim written in lua
- `stevearc/grug-far.nvim` - Global search and replace

### LSP & Formatting
- `neovim/nvim-lspconfig` - Quickstart configs for Nvim LSP
- `stevearc/conform.nvim` - Lightweight yet powerful formatter plugin
- `mfussenegger/nvim-lint` - Linting plugin
- `folke/lazydev.nvim` - Lua LSP for Neovim

### Git Integration
- `lewis6991/gitsigns.nvim` - Git integration for buffers
- `NeogitOrg/neogit` - Interactive Git interface for Neovim
- `pwntester/octo.nvim` - Edit and review GitHub issues and pull requests
- `tpope/vim-fugitive` - Git integration

### Navigation & File Management
- `ThePrimeagen/harpoon` - Mark and navigate files quickly
- `stevearc/oil.nvim` - Neovim file explorer: edit your filesystem like a buffer
- `nvim-neo-tree/neo-tree.nvim` - File system tree structure

### Notebooks & Data Science
- `kevinmcelroy/molten.nvim` - Jupyter kernel integration for Neovim
- `echasnovski/mini.nvim` (jupytext) - Jupyter notebook support
- `quarto-dev/quarto.nvim` - Quarto document support
- `jmbuhr/otter.nvim` - Jupyter notebook integration

### Terminal & Utilities
- `akinsho/toggleterm.nvim` - Manage multiple terminal windows
- `nvim-lua/plenary.nvim` - Lua utility functions

### HTTP & API Testing
- `mistweaverco/kulala.nvim` - HTTP request client for Neovim

### Markdown & Documentation
- `MeanderingProgrammer/render-markdown.nvim` - Improve viewing Markdown in Neovim
- `iamcco/markdown-preview.nvim` - Markdown preview plugin
- `OXY2DEV/markview.nvim` - Hackable markdown, Typst, latex, html previewer

## ⚙️ Main Configuration

### Key Settings
```lua
vim.g.mapleader = " "
vim.g.maplocalleader = ","
```

### Performance Options
- Lazy loading via `lazy.nvim`
- Disabled plugins: `gzip`, `tarPlugin`, `tohtml`, `tutor`, `zipPlugin`
- Change detection enabled (no notifications)
- Checker enabled (no notifications)

### Python Host Configuration
Pins the Neovim Python host to ensure remote plugins (e.g., `molten-nvim`) always find `pynvim`, regardless of project venvs.

## 🔑 Key Bindings

### Core Navigation
- `<C-s>` - Save file
- `<C-q>` - Quit (confirm if modified)
- `<C-z>` - Undo
- `<C-S-z>` - Redo
- `<C-h/j/k/l>` - Window navigation
- `<C-Up/Down/Left/Right>` - Resize windows

### File & Buffer Management
- `<C-]>` - Next buffer
- `<A-[>` - Previous buffer
- `<C-1>` to `<C-9>` - Jump to buffer 1-9
- `<leader>tn` - New tab
- `<leader>tc` - Close tab
- `<leader>to` - Tab only

### Search & Pickers (Snacks)
- `<Space>` - Smart find files
- `.` - Live grep
- `,` - Buffers
- `<C-S-f>` - Find in files
- `<C-e>` - Toggle Explorer
- `<C-f>` - Fuzzy find in current buffer

### fff.nvim (Fast File Search)
- `ff` - FFF file picker
- `fg` - FFF live grep

### AI & Assistant
### LSP & Code Actions
- `<F8>` - Show code actions
- `<leader>ca` - Code action
- `<leader>rn` - Rename symbol
- `<leader>fm` - Format buffer

### Git Operations
- `<leader>gs` - Git status
- `<leader>gd` - Git diff (hunks)
- `<leader>gb` - Git browse
- `<C-g>` / `<leader>lg` - Lazygit

### Troubleshooting & Diagnostics
- `<leader>xx` - Diagnostics (Trouble)
- `<leader>xX` - Buffer Diagnostics (Trouble)
- `<leader>cs` - Symbols (Trouble)
- `<leader>cl` - LSP Definitions/references (Trouble)
- `<leader>xL` - Location List (Trouble)
- `<leader>xQ` - Quickfix List (Trouble)

### TODO Comments
- `<leader>st` - Todo Quickfix
- `<leader>sT` - Todo/Fix/Fixme Quickfix

## 🎨 Themes & Colorschemes

Available color schemes:
- `ayu-mirage` (default)
- `ayu-dark`
- `ayu-light`
- `tokyonight`
- `catppuccin`
- `everforest`
- `nightfox`
- `kanagawa`

## 📝 Notebooks & Jupyter Support

The configuration includes comprehensive support for Jupyter notebooks and Quarto documents:

- **Molten**: Jupyter kernel integration with inline execution
- **Jupytext**: Sync notebooks with markdown files
- **Quarto**: Quarto document support with live preview
- **Otter**: Jupyter notebook integration for Neovim

## 🛠️ Development Setup

### Prerequisites
- Neovim 0.10.0 or higher
- Rust toolchain (for `fff.nvim` binary build)
- `curl` and `git` for downloads

### Installation

1. Clone the configuration:
```bash
git clone <repository-url> ~/.config/nvim
```

2. Start Neovim and let `lazy.nvim` install plugins:
```bash
nvim
```

3. Build the `fff.nvim` Rust backend (if not pre-built):
```bash
:Lazy sync
```

### Configuration Files Structure

```
~/.config/nvim/
├── init.lua                  # Main entry point
├── lua/
│   ├── config/
│   │   ├── lazy.lua          # Lazy.nvim configuration
│   │   ├── keymaps.lua       # Key bindings
│   │   ├── cmp.lua           # Completion configuration
│   │   └── ...
│   └── plugins/
│       ├── editor.lua        # Editor plugins
│       ├── ui.lua            # UI plugins
│       ├── lsp.lua           # LSP plugins
│       ├── git.lua           # Git plugins
│       ├── navigation.lua    # Navigation plugins
│       ├── notebooks.lua     # Notebook plugins
│       └── terminal.lua      # Terminal plugins
├── KEYMAPS.md                # Keymap cheatsheet
└── README.md                 # This file
```

## 🔄 Modern Stack

This configuration uses the current state-of-the-art Neovim ecosystem:

- **Completion**: `blink.cmp` + `LuaSnip` + `nvim-autopairs`
- **UI Framework**: `folke/snacks.nvim`
- **File Search**: `dmtrKovalenko/fff.nvim`
- **AI Integration**: `CopilotChat.nvim`
- **Formatting/Linting**: `stevearc/conform.nvim` + `mfussenegger/nvim-lint`
- **Folding**: `kevinhwang91/nvim-ufo` with Treesitter
- **Motion/Search**: `folke/flash.nvim`
- **Keymaps Help**: `folke/which-key.nvim`

## 📚 Documentation & Resources

- [lazy.nvim docs](https://github.com/folke/lazy.nvim)
- [blink.cmp docs](https://github.com/saghen/blink.cmp)
- [snacks.nvim docs](https://github.com/folke/snacks.nvim)
- [fff.nvim docs](https://github.com/dmtrKovalenko/fff.nvim)
---

*Last updated: July 2026*
