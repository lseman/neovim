# Neovim configuration

Personal Neovim setup for code, Markdown, and Quarto/Jupyter notebooks. Space is the leader; comma is the local leader. The default colorscheme is `ayu-mirage`.

## Requirements

- Neovim 0.12+ (the completion setup uses native LSP inline completion).
- Git for plugin installation; a Nerd Font for icons.
- Language servers and formatters for the languages you use. See `lua/plugins/lsp/lspconfig.lua` and `conform.lua` for the configured tools.
- Notebook workflows additionally need Python with `pynvim`, Jupyter kernels, and Jupytext; rendering Quarto documents needs the Quarto CLI.

Start `nvim` to bootstrap lazy.nvim and install missing plugins. The committed `lazy-lock.json` records plugin revisions. Use `:Lazy` to inspect plugins and `:checkhealth` to diagnose missing dependencies.

## Where things belong

```text
init.lua                       Startup order, leaders, default colorscheme
lua/config/
  bootstrap.lua                Find/install lazy.nvim and add it to runtimepath
  providers.lua                Select the Python host for remote plugins
  lazy.lua                     Plugin manager options and category imports
  options.lua                  Editor options
  autocmds.lua                  Editor lifecycle and buffer behavior
  keymaps.lua                  Global keyboard shortcuts
  diagnostics.lua              Diagnostic presentation
  highlight.lua                Shared highlight customizations
  dashboard.lua                Snacks dashboard layout and actions
  cheatsheet.lua               Interactive shortcut reference
  workflows.lua                Workflow commands and mappings
  cmp.lua, luasnip.lua          Completion options and snippets
  themes.lua, github-dark.lua  Theme picker and local theme implementation
  env.lua                      Environment status helpers
  runner.lua, molten_kernel.lua Python execution and notebook kernel helpers
lua/plugins/
  ui.lua, editor.lua, ...      Explicit category manifests
  ui/, editor/, ...            Individual plugin specifications
  lsp/interactive-rename.lua   Local LSP rename helper
  lsp/signature.lua            Local LSP signature helper
tests/                        Headless regression checks
```

Startup selects providers and bootstraps Lazy before loading editor options, plugins, autocommands, diagnostics, highlights, mappings, the cheatsheet, and workflows.

To add a plugin, put its spec in the appropriate category directory and add an import to that category's manifest. `config/lazy.lua` loads those manifests explicitly: files are not automatically enabled just because they sit in a category directory. Keep general UI configuration and shared editor helpers under `config/`; retain the existing LSP helper paths for compatibility.

Keep plugin-specific bindings with the plugin spec and global editor bindings in `config/keymaps.lua`. Consult [KEYMAPS.md](KEYMAPS.md) and the dashboard's shortcut cheatsheet for mappings; the Lua definitions are authoritative.

## Configured stack

| Area | Components |
| --- | --- |
| UI and search | Snacks dashboard, pickers, explorer and terminal; Which-key; Lualine; Ayu |
| Navigation | Oil, Harpoon, Flash |
| Editing | Treesitter, mini.map, Grug Far, TODO comments, render-markdown, Nabla, Kulala |
| Completion | blink.cmp, LuaSnip, nvim-autopairs |
| Language tooling | nvim-lspconfig, Mason, lazydev, Conform; local rename/signature helpers |
| AI | Claude Code integration and Copilot through native LSP inline completion |
| Git | Gitsigns and Snacks Git/Lazygit integrations |
| Notebooks | Molten, Jupytext, Quarto, Otter |

The Python provider tries the dedicated `stdpath("data")/python-host/bin/python` first, then available system Python candidates, selecting the first that imports `pynvim`. This keeps remote plugins independent of project virtual environments.

## Validation

See [tests/README.md](tests/README.md) for the headless checks. They exercise configuration behavior without installing plugins or starting real language servers; dashboard and plugin-spec checks require the corresponding plugins to be installed already.
