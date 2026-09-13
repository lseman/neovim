Run the LSP module regression checks without installing plugins or starting language servers:

```sh
nvim --headless -u NONE -i NONE -l tests/lsp-modules.lua
```

The checks use Neovim buffers and floating windows with mock LSP clients. They cover the lazy LSP configuration callback, rename submission/cancellation, UTF-16 positions, stale prepare responses, and signature triggers across multiple clients.

`lua/plugins/lsp/lspconfig.lua` requires both local helper modules when LSP configuration loads. They are not lazy.nvim plugin specifications:

- `interactive-rename.lua`: `<leader>rn` opens a rename prompt. Enter confirms; Escape cancels. The selected server's prepare-rename capability and position encoding are respected.
- `signature.lua`: installs automatic signature help on LSP attachment, using each attached server's trigger and retrigger characters. `<leader>sh` remains the manual signature-help shortcut.

Check the complete plugin spec tree using the installed Lazy parser:

```sh
nvim --headless -u NONE -i NONE -l tests/lazy-specs.lua
```

This does not install or initialize plugins. The LSP import in `config/lazy.lua` uses a named function to load the explicit list in `plugins/lsp.lua`. A string import would also scan `plugins/lsp/` and incorrectly treat the two helper modules as plugin specifications.
