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

This does not install or initialize plugins. Every category import in `config/lazy.lua` uses a named function to load its explicit manifest. This prevents directory scanning from treating helper modules as plugin specifications. The parser check also verifies representative plugins from all six categories, including Flash, which must be listed explicitly.

Run all checks from the configuration root:

```sh
for test in tests/*.lua; do
    nvim --headless -u NONE -i NONE -l "$test" || exit
done
```

The dashboard check requires an installed `snacks.nvim`. The editor regression check requires an installed `conform.nvim`; it covers Markdown/Quarto hard breaks, formatter project discovery and fallback selection, parser installation, and reparse timer cleanup, cancellation, and size limits without running external formatters or installing parsers. The other checks cover the shortcut cheatsheet and theme picker using real Neovim buffers and windows.
