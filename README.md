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
init.lua                       Startup order and leaders
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
  env.lua                      Environment status helpers
  environment.lua              Project environment discovery and activation
  buffer.lua                   Shared buffer-size limits
  health.lua                   Native :checkhealth config checks
  reload.lua                   Reapply editor settings while preserving live state
  runner.lua, molten_kernel.lua Python execution and notebook kernel helpers
lua/plugins/
  ui.lua, editor.lua, ...      Explicit category manifests
  ui/, editor/, ...            Individual plugin specifications
  lsp/interactive-rename.lua   Local LSP rename helper
  lsp/signature.lua            Local LSP signature helper
  ui/themes.lua                Local theme plugin and Ayu dependency
local/theme-picker/
  lua/theme_picker/            Saved-theme state and on-demand swatch picker
  colors/github-dark.lua       Local colorscheme exposed through :colorscheme
tests/                        Headless regression checks
```

Startup selects providers and bootstraps Lazy before loading editor options, plugins, autocommands, diagnostics, highlights, mappings, the cheatsheet, and workflows.

The local `theme-picker` plugin restores the saved theme before other UI plugins load; its picker UI loads only when opened. Both `<leader>T` and `<leader>uC` open the same picker, with preview, cancellation, and persistent selection. Existing saved selections are retained. Snacks loads at startup so its dashboard and big-file hooks can observe the first buffer.

Neovim 0.12 provides native LSP on-type formatting (`vim.lsp.on_type_formatting.enable()`), which is opt-in and requires server support. Conform remains responsible for format-on-save, external formatter selection, and multi-step formatting such as Ruff fixes followed by Ruff formatting. Native `vim.pack` is available, but this configuration uses Lazy for dependency ordering, loading triggers, build hooks, and its management UI.

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

## Maintenance and runtime behavior

- `:ConfigHealth` (or `:checkhealth config`) checks configuration dependencies without loading optional plugins. `:HealthCheck` remains an alias.
- `:Rconf` reloads editor options, mappings, autocommands, diagnostics, highlights, and workflow commands. It preserves terminals and environment subscriptions. Restart Neovim after changing plugin specs, providers, or helper implementations.
- Python and notebook buffers discover project virtual environments on creation and entry. Leaving for a project without an environment restores the inherited environment. Version checks run asynchronously, once per discovered environment; the remote Python plugin host stays separate.
- Large-buffer guards use displayed content instead of notebook file size. Shared limits are 1 MiB for editor/LSP/formatting guards and 200 KiB for Tree-sitter work. Snacks uses the same 1 MiB threshold and also detects minified files.
- Mason installs the configured tool list; `vim.lsp.enable` owns server activation. Folding switches between LSP and Tree-sitter as clients attach and detach, including multiple windows.
- `:FormatDisable` / `:FormatEnable` control global format-on-save. Their bang forms change only the current buffer; formatting runs only when both scopes permit it.
- `:PyRunSelection` accepts explicit line ranges; visual selections use Neovim's region extraction. Python code and paths are escaped before reaching the shell. `:PyRunArgs` accepts shell argument syntax.

## Validation

See [tests/README.md](tests/README.md) for the headless checks. They exercise configuration behavior without installing plugins or starting real language servers; dashboard and plugin-spec checks require the corresponding plugins to be installed already.
