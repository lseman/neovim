# Neovim Keymap Cheatsheet

- Generated: 2026-03-01 08:08:23
- Buffer: [No Name]
- Filetype: none

## Normal

| Key | Description | Scope | Action |
| --- | --- | --- | --- |
| ` R` | Send entire buffer via slime | global | `lua/callback` |
| ` ch` | Health check | global | `<Cmd>HealthCheck<CR>` |
| ` cl` | LSP Info | global | `lua/callback` |
| ` cs` | Symbols | global | `lua/callback` |
| ` fK` | Find: Generated Keymap Cheatsheet | global | `lua/callback` |
| ` fW` | Find: Write Keymap Cheatsheet | global | `lua/callback` |
| ` mr` | Restart Molten kernel | global | `<Cmd>MoltenRestart<CR>` |
| ` pa` | Run with args | global | `lua/callback` |
| ` ph` | Run from history | global | `lua/callback` |
| ` pi` | Python interactive | global | `lua/callback` |
| ` pr` | Repeat last run | global | `lua/callback` |
| ` pt` | Toggle Python terminal | global | `lua/callback` |
| ` py` | Run Python file | global | `lua/callback` |
| ` rr` | Reload full config | global | `lua/callback` |
| ` rs` | Send current cell to IPython | global | `lua/callback` |
| ` tr` | Reset IPython session | global | `lua/callback` |
| ` tt` | Open IPython terminal | global | `lua/callback` |
| ` tx` | Close IPython terminal | global | `lua/callback` |
| ` xL` | Location List | global | `lua/callback` |
| ` xQ` | Quickfix List | global | `lua/callback` |
| ` xX` | Buffer Diagnostics | global | `lua/callback` |
| ` xx` | Diagnostics (Trouble) | global | `lua/callback` |
| `&` | :help &-default | global | `:&&<CR>` |
| `,` | Buffers | global | `lua/callback` |
| `.` | Live grep | global | `lua/callback` |
| `;` | Find files | global | `lua/callback` |
| `<C-1>` | Buffer 1 | global | `lua/callback` |
| `<C-2>` | Buffer 2 | global | `lua/callback` |
| `<C-3>` | Buffer 3 | global | `lua/callback` |
| `<C-4>` | Buffer 4 | global | `lua/callback` |
| `<C-5>` | Buffer 5 | global | `lua/callback` |
| `<C-6>` | Buffer 6 | global | `lua/callback` |
| `<C-7>` | Buffer 7 | global | `lua/callback` |
| `<C-8>` | Buffer 8 | global | `lua/callback` |
| `<C-9>` | Buffer 9 | global | `lua/callback` |
| `<C-A>` | Select all | global | `<Esc>ggVG` |
| `<C-B>` | Nabla popup | global | `lua/callback` |
| `<C-E>` | Toggle NvimTree | global | `lua/callback` |
| `<C-F>` | Fuzzy find in current buffer | global | `lua/callback` |
| `<C-H>` | Find and Replace | global | `lua/callback` |
| `<C-L>` | :help CTRL-L-default | global | `<Cmd>nohlsearch\|diffupdate\|normal! <C-L><CR>` |
| `<C-Q>` | Quit (confirm if modified) | global | `lua/callback` |
| `<C-S>` | Save file | global | `<Cmd>update<CR>` |
| `<C-W><C-D>` | Show diagnostics under the cursor | global | `<C-W>d` |
| `<C-W>d` | Show diagnostics under the cursor | global | `lua/callback` |
| `<F4>` | Select current # %% cell | global | `lua/callback` |
| `<F5>` | Run current # %% cell | global | `lua/callback` |
| `<F7>` | Smart build | global | `lua/callback` |
| `Y` | :help Y-default | global | `y$` |
| `[ ` | Add empty line above cursor | global | `lua/callback` |
| `[<C-L>` | :lpfile | global | `lua/callback` |
| `[<C-Q>` | :cpfile | global | `lua/callback` |
| `[<C-T>` | :ptprevious | global | `lua/callback` |
| `[A` | :rewind | global | `lua/callback` |
| `[B` | :brewind | global | `lua/callback` |
| `[D` | Jump to the first diagnostic in the current buffer | global | `lua/callback` |
| `[L` | :lrewind | global | `lua/callback` |
| `[Q` | :crewind | global | `lua/callback` |
| `[T` | :trewind | global | `lua/callback` |
| `[a` | :previous | global | `lua/callback` |
| `[b` | :bprevious | global | `lua/callback` |
| `[d` | Jump to the previous diagnostic in the current buffer | global | `lua/callback` |
| `[l` | :lprevious | global | `lua/callback` |
| `[q` | :cprevious | global | `lua/callback` |
| `[t` | :tprevious | global | `lua/callback` |
| `\` | File explorer | global | `lua/callback` |
| `] ` | Add empty line below cursor | global | `lua/callback` |
| `]<C-L>` | :lnfile | global | `lua/callback` |
| `]<C-Q>` | :cnfile | global | `lua/callback` |
| `]<C-T>` | :ptnext | global | `lua/callback` |
| `]A` | :last | global | `lua/callback` |
| `]B` | :blast | global | `lua/callback` |
| `]D` | Jump to the last diagnostic in the current buffer | global | `lua/callback` |
| `]L` | :llast | global | `lua/callback` |
| `]Q` | :clast | global | `lua/callback` |
| `]T` | :tlast | global | `lua/callback` |
| `]a` | :next | global | `lua/callback` |
| `]b` | :bnext | global | `lua/callback` |
| `]d` | Jump to the next diagnostic in the current buffer | global | `lua/callback` |
| `]l` | :lnext | global | `lua/callback` |
| `]q` | :cnext | global | `lua/callback` |
| `]t` | :tnext | global | `lua/callback` |
| `gO` | vim.lsp.buf.document_symbol() | global | `lua/callback` |
| `gc` | Toggle comment | global | `lua/callback` |
| `gcc` | Toggle comment line | global | `lua/callback` |
| `gra` | vim.lsp.buf.code_action() | global | `lua/callback` |
| `gri` | vim.lsp.buf.implementation() | global | `lua/callback` |
| `grn` | vim.lsp.buf.rename() | global | `lua/callback` |
| `grr` | vim.lsp.buf.references() | global | `lua/callback` |
| `grt` | vim.lsp.buf.type_definition() | global | `lua/callback` |
| `gx` | Opens filepath or URI under cursor with the system handler (file explorer, web browser, …) | global | `lua/callback` |

## Insert

| Key | Description | Scope | Action |
| --- | --- | --- | --- |
| `<C-A>` | Select all | global | `<Esc>ggVG` |
| `<C-F>` | Fuzzy find in current buffer | global | `lua/callback` |
| `<C-Q>` | Quit (confirm if modified) | global | `lua/callback` |
| `<C-S>` | Save file | global | `<Cmd>update<CR>` |
| `<C-U>` | :help i_CTRL-U-default | global | `<C-G>u<C-U>` |
| `<C-W>` | :help i_CTRL-W-default | global | `<C-G>u<C-W>` |
| `<Left>` | Smart left – jump to previous line if at start | global | `lua/callback` |
| `<Right>` | Smart right – jump to next line if at end | global | `lua/callback` |
| `<S-Tab>` | vim.snippet.jump if active, otherwise <S-Tab> | global | `lua/callback` |
| `<Tab>` | Copilot accept / next completion / tab | global | `lua/callback` |

## Visual

| Key | Description | Scope | Action |
| --- | --- | --- | --- |
| `#` | :help v_#-default | global | `lua/callback` |
| `*` | :help v_star-default | global | `lua/callback` |
| `<C-A>` | Select all | global | `<Esc>ggVG` |
| `<C-Q>` | Quit (confirm if modified) | global | `lua/callback` |
| `<C-S>` | Save file | global | `<Cmd>update<CR>` |
| `@` | :help v_@-default | global | `mode() ==# 'V' ? ':normal! @'.getcharstr().'<CR>' : '@'` |
| `Q` | :help v_Q-default | global | `mode() ==# 'V' ? ':normal! @<C-R>=reg_recorded()<CR><CR>' : 'Q'` |
| `an` | vim.lsp.buf.selection_range(vim.v.count1) | global | `lua/callback` |
| `gc` | Toggle comment | global | `lua/callback` |
| `gra` | vim.lsp.buf.code_action() | global | `lua/callback` |
| `gx` | Opens filepath or URI under cursor with the system handler (file explorer, web browser, …) | global | `lua/callback` |
| `in` | vim.lsp.buf.selection_range(-vim.v.count1) | global | `lua/callback` |

## Visual (Select)

| Key | Description | Scope | Action |
| --- | --- | --- | --- |
| `#` | :help v_#-default | global | `lua/callback` |
| `*` | :help v_star-default | global | `lua/callback` |
| `<C-A>` | Select all | global | `<Esc>ggVG` |
| `<C-Q>` | Quit (confirm if modified) | global | `lua/callback` |
| `<C-S>` | Save file | global | `<Cmd>update<CR>` |
| `@` | :help v_@-default | global | `mode() ==# 'V' ? ':normal! @'.getcharstr().'<CR>' : '@'` |
| `Q` | :help v_Q-default | global | `mode() ==# 'V' ? ':normal! @<C-R>=reg_recorded()<CR><CR>' : 'Q'` |
| `an` | vim.lsp.buf.selection_range(vim.v.count1) | global | `lua/callback` |
| `gc` | Toggle comment | global | `lua/callback` |
| `gra` | vim.lsp.buf.code_action() | global | `lua/callback` |
| `gx` | Opens filepath or URI under cursor with the system handler (file explorer, web browser, …) | global | `lua/callback` |
| `in` | vim.lsp.buf.selection_range(-vim.v.count1) | global | `lua/callback` |

## Operator-pending

| Key | Description | Scope | Action |
| --- | --- | --- | --- |
| `an` | vim.lsp.buf.selection_range(vim.v.count1) | global | `lua/callback` |
| `gc` | Comment textobject | global | `lua/callback` |
| `in` | vim.lsp.buf.selection_range(-vim.v.count1) | global | `lua/callback` |

