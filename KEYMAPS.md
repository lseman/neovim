# Neovim Keymap Cheatsheet

- Generated: 2026-07-17 07:49:07
- Buffer: [No Name]
- Filetype: snacks_dashboard

## Normal

| Key | Description | Scope | Action |
| --- | --- | --- | --- |
| `  ` | Smart Find Files | global | `lua/callback` |
| ` -` | Open yazi at the current file | global | `<Cmd>Yazi<CR>` |
| ` .` | Toggle Scratch Buffer | global | `lua/callback` |
| ` /` | Comment: toggle line | global | `gcc` |
| ` :` | Command History | global | `lua/callback` |
| ` S` | Select Scratch Buffer | global | `lua/callback` |
| ` a?` | avante: select model | global | `<Plug>(AvanteSelectModel)` |
| ` aB` | avante: add all open buffers | global | `<Plug>(AvanteAddAllBuffers)` |
| ` aC` | avante: toggle selection | global | `<Plug>(AvanteToggleSelection)` |
| ` aM` | avante: select ACP model | global | `<Plug>(AvanteSelectACPModel)` |
| ` aR` | avante: display repo map | global | `<Plug>(AvanteShowRepoMap)` |
| ` aS` | avante: stop | global | `<Plug>(AvanteStop)` |
| ` aa` | avante: ask | global | `<Plug>(AvanteAsk)` |
| ` ad` | avante: toggle debug | global | `<Plug>(AvanteToggleDebug)` |
| ` af` | avante: focus | global | `<Plug>(AvanteFocus)` |
| ` ah` | avante: select history | global | `<Plug>(AvanteSelectHistory)` |
| ` am` | avante: select ACP mode | global | `<Plug>(AvanteSelectACPMode)` |
| ` an` | avante: create new ask | global | `<Plug>(AvanteAskNew)` |
| ` ar` | avante: refresh | global | `<Plug>(AvanteRefresh)` |
| ` as` | avante: toggle suggestion | global | `<Plug>(AvanteToggleSuggestion)` |
| ` at` | avante: toggle | global | `<Plug>(AvanteToggle)` |
| ` az` | avante: toggle Zen Mode | global | `<Plug>(AvanteZenMode)` |
| ` bD` | Close other buffers | global | `lua/callback` |
| ` bd` | Close buffer | global | `lua/callback` |
| ` cR` | Rename File | global | `lua/callback` |
| ` ca` | Code Action | global | `lua/callback` |
| ` ch` | Config health | global | `<Cmd>ConfigHealth<CR>` |
| ` cw` | Open the file manager in nvim's working directory | global | `<Cmd>Yazi cwd<CR>` |
| ` e` | File Explorer | global | `lua/callback` |
| ` fG` | Git Files | global | `lua/callback` |
| ` fK` | Write Cheatsheet to Disk | global | `lua/callback` |
| ` fS` | Workspace Symbols | global | `lua/callback` |
| ` fW` | Write Cheatsheet to Disk | global | `lua/callback` |
| ` fb` | Buffers | global | `lua/callback` |
| ` fc` | Config Files | global | `lua/callback` |
| ` fd` | Diagnostics | global | `lua/callback` |
| ` ff` | Find Files | global | `lua/callback` |
| ` fg` | Grep (project) | global | `lua/callback` |
| ` fh` | Help Pages | global | `lua/callback` |
| ` fk` | Keymaps | global | `lua/callback` |
| ` fm` | Format buffer (Conform) | global | `lua/callback` |
| ` fn` | Notifications | global | `lua/callback` |
| ` fp` | Projects | global | `lua/callback` |
| ` fr` | Recent Files | global | `lua/callback` |
| ` fs` | Document Symbols | global | `lua/callback` |
| ` gL` | Git Log Line | global | `lua/callback` |
| ` gb` | Git Browse (line/repo) | global | `lua/callback` |
| ` gd` | Git Diff (Hunks) | global | `lua/callback` |
| ` gf` | Git Log File | global | `lua/callback` |
| ` gg` | Neogit Status | global | `lua/callback` |
| ` gk` | Git Branches | global | `lua/callback` |
| ` gl` | Git Log | global | `lua/callback` |
| ` gs` | Git Status | global | `lua/callback` |
| ` ha` | Harpoon: Add file | global | `lua/callback` |
| ` hc` | Harpoon: Clear all | global | `lua/callback` |
| ` hd` | Harpoon: Remove current | global | `lua/callback` |
| ` hm` | Harpoon: List | global | `lua/callback` |
| ` kR` | HTTP scratchpad | global | `lua/callback` |
| ` ka` | HTTP run all | global | `lua/callback` |
| ` kr` | HTTP request | global | `lua/callback` |
| ` lH` | Clear Fidget History | global | `lua/callback` |
| ` lc` | Clear Active Progress | global | `lua/callback` |
| ` lg` | Lazygit | global | `lua/callback` |
| ` lh` | Fidget History | global | `lua/callback` |
| ` lp` | Toggle LSP Progress HUD | global | `lua/callback` |
| ` mI` | Interrupt kernel | global | `<Cmd>MoltenInterrupt<CR>` |
| ` mL` | Load Molten state | global | `<Cmd>MoltenStateLoad<CR>` |
| ` mR` | Restart kernel (clear outputs) | global | `<Cmd>MoltenRestart!<CR>` |
| ` md` | Delete current cell output | global | `<Cmd>MoltenDelete<CR>` |
| ` mh` | Hide output window | global | `<Cmd>MoltenHideOutput<CR>` |
| ` mi` | Molten Init (select kernel) | global | `<Cmd>MoltenInit<CR>` |
| ` ml` | Evaluate current line | global | `lua/callback` |
| ` mm` | Run current %% cell | global | `lua/callback` |
| ` mn` | Notebook mode | global | `<Cmd>NotebookMode<CR>` |
| ` mo` | Show/enter output window | global | `<Cmd>MoltenShowOutput<CR>` |
| ` mp` | Toggle Markdown render | global | `<Cmd>RenderMarkdown toggle<CR>` |
| ` mr` | Re-evaluate cell | global | `<Cmd>MoltenReevaluateCell<CR>` |
| ` ms` | Save Molten state | global | `<Cmd>MoltenStateSave<CR>` |
| ` n` | Notification History | global | `lua/callback` |
| ` nf` | Reveal File | global | `lua/callback` |
| ` pa` | Run with args | global | `lua/callback` |
| ` ph` | Run from history | global | `lua/callback` |
| ` pi` | Python interactive | global | `lua/callback` |
| ` pr` | Repeat last run | global | `lua/callback` |
| ` pt` | Toggle Python terminal | global | `lua/callback` |
| ` py` | Run Python file | global | `lua/callback` |
| ` qE` | Quarto: Update preview | global | `lua/callback` |
| ` qN` | Quarto: Previous Python code block | global | `lua/callback` |
| ` qP` | Quarto: Preview no watch | global | `lua/callback` |
| ` qQ` | Quit All | global | `<Cmd>confirm qa<CR>` |
| ` qR` | Quarto: Run above | global | `lua/callback` |
| ` q[` | Quarto: Previous code block | global | `lua/callback` |
| ` q]` | Quarto: Next code block | global | `lua/callback` |
| ` qa` | Quarto: Activate LSP | global | `lua/callback` |
| ` qal` | Quarto: Run all | global | `lua/callback` |
| ` qd` | Diagnostics to quickfix | global | `lua/callback` |
| ` qe` | Quarto: Render | global | `lua/callback` |
| ` qg` | Grep to quickfix | global | `lua/callback` |
| ` ql` | Quarto: Run line | global | `lua/callback` |
| ` qn` | Quarto: Next Python code block | global | `lua/callback` |
| ` qp` | Quarto: Preview | global | `lua/callback` |
| ` qq` | Quit | global | `<Cmd>confirm q<CR>` |
| ` qr` | Quarto: Run cell | global | `lua/callback` |
| ` rF` | Search and replace scratch | global | `lua/callback` |
| ` rn` | Rename Symbol | global | `lua/callback` |
| ` rw` | Replace word | global | `lua/callback` |
| ` s"` | Registers | global | `lua/callback` |
| ` s/` | Search History | global | `lua/callback` |
| ` sB` | Grep Open Buffers | global | `lua/callback` |
| ` sC` | Commands | global | `lua/callback` |
| ` sD` | Buffer Diagnostics | global | `lua/callback` |
| ` sF` | Frecency (global) | global | `lua/callback` |
| ` sR` | Resume Picker | global | `lua/callback` |
| ` sT` | Todo/Fix/Fixme Quickfix | global | `lua/callback` |
| ` sf` | Frecency (cwd) | global | `lua/callback` |
| ` sj` | Jumps | global | `lua/callback` |
| ` sl` | Location List | global | `lua/callback` |
| ` sm` | Marks | global | `lua/callback` |
| ` sp` | Plugin Spec Search | global | `lua/callback` |
| ` sq` | Quickfix List | global | `lua/callback` |
| ` sr` | Search and replace | global | `lua/callback` |
| ` st` | Todo Quickfix | global | `lua/callback` |
| ` su` | Undo History | global | `lua/callback` |
| ` sw` | Word / Selection | global | `lua/callback` |
| ` u/` | Clear Search Highlight | global | `<Cmd>nohlsearch<CR>` |
| ` uC` | Colorschemes | global | `lua/callback` |
| ` uL` | Toggle Relative Number | global | `lua/callback` |
| ` uM` | Refresh Mini Map | global | `lua/callback` |
| ` uP` | Toggle Profiler | global | `lua/callback` |
| ` uT` | Toggle Treesitter Highlight | global | `lua/callback` |
| ` uW` | Toggle LSP Words | global | `lua/callback` |
| ` uc` | Toggle Conceal | global | `lua/callback` |
| ` ud` | Toggle Diagnostics | global | `lua/callback` |
| ` ug` | Toggle Indent Guides | global | `lua/callback` |
| ` uh` | Toggle Inlay Hints | global | `lua/callback` |
| ` ul` | Toggle Line Numbers | global | `lua/callback` |
| ` um` | Toggle Mini Map | global | `lua/callback` |
| ` un` | Dismiss all notifications | global | `lua/callback` |
| ` us` | Toggle Spelling | global | `lua/callback` |
| ` uw` | Toggle Wrap | global | `lua/callback` |
| ` wW` | Save All | global | `<Cmd>wa<CR>` |
| ` ww` | Save | global | `<Cmd>update<CR>` |
| ` xT` | Todo/Fix/Fixme (Trouble) | global | `lua/callback` |
| ` xt` | Todo (Trouble) | global | `lua/callback` |
| ` z` | Zen Mode | global | `lua/callback` |
| `&` | :help &-default | global | `:&&<CR>` |
| `,` | Buffers | global | `lua/callback` |
| `-` | Open parent directory | global | `<Plug>(nvim-dir-up)` |
| `.` | Live grep | global | `lua/callback` |
| `0` | Dashboard action | buffer | `lua/callback` |
| `1` | Dashboard action | buffer | `lua/callback` |
| `2` | Dashboard action | buffer | `lua/callback` |
| `3` | Dashboard action | buffer | `lua/callback` |
| `4` | Dashboard action | buffer | `lua/callback` |
| `5` | Dashboard action | buffer | `lua/callback` |
| `6` | Dashboard action | buffer | `lua/callback` |
| `7` | Dashboard action | buffer | `lua/callback` |
| `8` | Dashboard action | buffer | `lua/callback` |
| `9` | Dashboard action | buffer | `lua/callback` |
| `;` | Smart find | global | `lua/callback` |
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
| `<C-Bslash>` | pi-agent: abort | global | `<Cmd>PiAgentAbort<CR>` |
| `<C-Down>` | Resize down | global | `<Cmd>resize -2<CR>` |
| `<C-E>` | Toggle Explorer | global | `lua/callback` |
| `<C-F>` | Fuzzy find in current buffer | global | `lua/callback` |
| `<C-H>` | Window left | global | `<C-W>h` |
| `<C-J>` | Window down | global | `<C-W>j` |
| `<C-K>` | Window up | global | `<C-W>k` |
| `<C-L>` | Window right | global | `<C-W>l` |
| `<C-Left>` | Resize left | global | `<Cmd>vertical resize -2<CR>` |
| `<C-P>` | pi-agent: ask with context | global | `<Cmd>PiAgentAsk<CR>` |
| `<C-Q>` | Quit (confirm if modified) | global | `lua/callback` |
| `<C-Right>` | Resize right | global | `<Cmd>vertical resize +2<CR>` |
| `<C-S-F>` | Find in files | global | `lua/callback` |
| `<C-S-N>` | Harpoon: Next | global | `lua/callback` |
| `<C-S-P>` | Harpoon: Previous | global | `lua/callback` |
| `<C-S>` | Save file | global | `<Cmd>update<CR>` |
| `<C-T>` | Toggle terminal | global | `lua/callback` |
| `<C-Up>` | Resume the last yazi session | global | `<Cmd>Yazi toggle<CR>` |
| `<C-W><C-D>` | Show diagnostics under the cursor | global | `<C-W>d` |
| `<C-W>d` | Show diagnostics under the cursor | global | `lua/callback` |
| `<CR>` | Dashboard action | buffer | `lua/callback` |
| `<F10>` | Run all notebook cells (F10) | global | `lua/callback` |
| `<F2>` | Harpoon: Add file | global | `lua/callback` |
| `<F3>` | Harpoon: Remove current | global | `lua/callback` |
| `<F4>` | Harpoon: List | global | `lua/callback` |
| `<F5>` | Run current notebook cell (F5) | global | `lua/callback` |
| `<F6>` | Toggle avante | global | `<Cmd>AvanteToggle<CR>` |
| `<F7>` | Select Copilot Chat model | global | `lua/callback` |
| `<F8>` | Show code actions | global | `lua/callback` |
| `<Plug>(nvim-dir-open)` | Open directory entry | global | `lua/callback` |
| `<Plug>(nvim-dir-reload)` | Reload directory | global | `lua/callback` |
| `<Plug>(nvim-dir-up)` | Open parent directory | global | `lua/callback` |
| `<Plug>luasnip-delete-check` | LuaSnip: Removes current snippet from jumplist | global | `lua/callback` |
| `<Plug>luasnip-expand-repeat` | LuaSnip: Repeat last node expansion | global | `lua/callback` |
| `<S-Tab>` | Previous buffer | global | `lua/callback` |
| `<Tab>` | Next buffer | global | `lua/callback` |
| `S` | Flash Treesitter | global | `lua/callback` |
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
| `[d` | Previous diagnostic | global | `lua/callback` |
| `[l` | Previous location | global | `lua/callback` |
| `[q` | Previous quickfix | global | `lua/callback` |
| `[t` | Previous todo comment | global | `lua/callback` |
| `\` | Open yazi | global | `<Cmd>Yazi<CR>` |
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
| `]d` | Next diagnostic | global | `lua/callback` |
| `]l` | Next location | global | `lua/callback` |
| `]q` | Next quickfix | global | `lua/callback` |
| `]t` | Next todo comment | global | `lua/callback` |
| `c` | Dashboard action | buffer | `lua/callback` |
| `f` | Dashboard action | buffer | `lua/callback` |
| `g` | Dashboard action | buffer | `lua/callback` |
| `gO` | vim.lsp.buf.document_symbol() | global | `lua/callback` |
| `gc` | Toggle comment | global | `lua/callback` |
| `gcc` | Toggle comment line | global | `lua/callback` |
| `gra` | vim.lsp.buf.code_action() | global | `lua/callback` |
| `gri` | vim.lsp.buf.implementation() | global | `lua/callback` |
| `grn` | vim.lsp.buf.rename() | global | `lua/callback` |
| `grr` | vim.lsp.buf.references() | global | `lua/callback` |
| `grt` | vim.lsp.buf.type_definition() | global | `lua/callback` |
| `grx` | vim.lsp.codelens.run() | global | `lua/callback` |
| `gx` | Opens filepath or URI under cursor with the system handler (file explorer, web browser, …) | global | `lua/callback` |
| `h` | Dashboard action | buffer | `lua/callback` |
| `k` | Dashboard action | buffer | `lua/callback` |
| `l` | Dashboard action | buffer | `lua/callback` |
| `p` | Dashboard action | buffer | `lua/callback` |
| `q` | Dashboard action | buffer | `lua/callback` |
| `r` | Dashboard action | buffer | `lua/callback` |
| `s` | Flash Jump | global | `lua/callback` |

## Insert

| Key | Description | Scope | Action |
| --- | --- | --- | --- |
| `<C-A>` | Select all | global | `<Esc>ggVG` |
| `<C-J>` | Jump back in snippet | global | `lua/callback` |
| `<C-K>` | Expand or jump snippet | global | `lua/callback` |
| `<C-Q>` | Quit (confirm if modified) | global | `lua/callback` |
| `<C-S-F>` | Find in files | global | `lua/callback` |
| `<C-S>` | Save file | global | `<Cmd>update<CR>` |
| `<C-T>` | Toggle terminal | global | `lua/callback` |
| `<C-U>` | :help i_CTRL-U-default | global | `<C-G>u<C-U>` |
| `<C-W>` | :help i_CTRL-W-default | global | `<C-G>u<C-W>` |
| `<CR>` | autopairs completion confirm | global | `v:lua.require'nvim-autopairs'.completion_confirm()` |
| `<Left>` | Smart left – jump to previous line if at start | global | `lua/callback` |
| `<M-CR>` | [copilot] (panel) open | global | `lua/callback` |
| `<Plug>luasnip-delete-check` | LuaSnip: Removes current snippet from jumplist | global | `lua/callback` |
| `<Plug>luasnip-expand-or-jump` | LuaSnip: Expand or jump in the current snippet | global | `lua/callback` |
| `<Plug>luasnip-expand-repeat` | LuaSnip: Repeat last node expansion | global | `lua/callback` |
| `<Plug>luasnip-expand-snippet` | LuaSnip: Expand the current snippet | global | `lua/callback` |
| `<Plug>luasnip-jump-next` | LuaSnip: Jump to the next node | global | `lua/callback` |
| `<Plug>luasnip-jump-prev` | LuaSnip: Jump to the previous node | global | `lua/callback` |
| `<Plug>luasnip-next-choice` | LuaSnip: Change to the next choice from the choiceNode | global | `lua/callback` |
| `<Plug>luasnip-prev-choice` | LuaSnip: Change to the previous choice from the choiceNode | global | `lua/callback` |
| `<Right>` | Smart right – jump to next line if at end | global | `lua/callback` |
| `<S-Tab>` | vim.snippet.jump if active, otherwise <S-Tab> | global | `lua/callback` |
| `<Tab>` | vim.snippet.jump if active, otherwise <Tab> | global | `lua/callback` |

## Visual

| Key | Description | Scope | Action |
| --- | --- | --- | --- |
| ` -` | Open yazi at the current file | global | `<Cmd>Yazi<CR>` |
| ` /` | Comment: toggle selection | global | `gc` |
| ` aa` | avante: ask | global | `<Plug>(AvanteAsk)` |
| ` ae` | avante: edit | global | `<Plug>(AvanteEdit)` |
| ` an` | avante: create new ask | global | `<Plug>(AvanteAskNew)` |
| ` az` | avante: toggle Zen Mode | global | `<Plug>(AvanteZenMode)` |
| ` ca` | Code Action | global | `lua/callback` |
| ` mc` | Evaluate visual selection | global | `lua/callback` |
| ` qv` | Quarto: Run selection | global | `lua/callback` |
| ` sr` | Search and replace selection | global | `lua/callback` |
| ` sw` | Word / Selection | global | `lua/callback` |
| `#` | :help v_#-default | global | `lua/callback` |
| `*` | :help v_star-default | global | `lua/callback` |
| `<C-A>` | Select all | global | `<Esc>ggVG` |
| `<C-J>` | Jump back in snippet | global | `lua/callback` |
| `<C-K>` | Expand or jump snippet | global | `lua/callback` |
| `<C-P>` | pi-agent: ask about selection | global | `<Cmd>PiAgentAskSelection<CR>` |
| `<C-Q>` | Quit (confirm if modified) | global | `lua/callback` |
| `<C-S-F>` | Find in files | global | `lua/callback` |
| `<C-S>` | Save file | global | `<Cmd>update<CR>` |
| `<Plug>luasnip-expand-or-jump` | LuaSnip: Expand or jump in the current snippet | global | `lua/callback` |
| `<Plug>luasnip-expand-repeat` | LuaSnip: Repeat last node expansion | global | `lua/callback` |
| `<Plug>luasnip-expand-snippet` | LuaSnip: Expand the current snippet | global | `lua/callback` |
| `<Plug>luasnip-jump-next` | LuaSnip: Jump to the next node | global | `lua/callback` |
| `<Plug>luasnip-jump-prev` | LuaSnip: Jump to the previous node | global | `lua/callback` |
| `<Plug>luasnip-next-choice` | LuaSnip: Change to the next choice from the choiceNode | global | `lua/callback` |
| `<Plug>luasnip-prev-choice` | LuaSnip: Change to the previous choice from the choiceNode | global | `lua/callback` |
| `@` | :help v_@-default | global | `mode() ==# 'V' ? ':normal! @'.getcharstr().'<CR>' : '@'` |
| `Q` | :help v_Q-default | global | `mode() ==# 'V' ? ':normal! @<C-R>=reg_recorded()<CR><CR>' : 'Q'` |
| `R` | Treesitter Search | global | `lua/callback` |
| `S` | Flash Treesitter | global | `lua/callback` |
| `[N` | Select previous sibling node | global | `lua/callback` |
| `[n` | Select previous node | global | `lua/callback` |
| `]N` | Select next sibling node | global | `lua/callback` |
| `]n` | Select next node | global | `lua/callback` |
| `an` | Select parent (outer) node | global | `lua/callback` |
| `gc` | Toggle comment | global | `lua/callback` |
| `gra` | vim.lsp.buf.code_action() | global | `lua/callback` |
| `gx` | Opens filepath or URI under cursor with the system handler (file explorer, web browser, …) | global | `lua/callback` |
| `in` | Select child (inner) node | global | `lua/callback` |
| `s` | Flash Jump | global | `lua/callback` |

## Visual (Select)

| Key | Description | Scope | Action |
| --- | --- | --- | --- |
| ` -` | Open yazi at the current file | global | `<Cmd>Yazi<CR>` |
| ` /` | Comment: toggle selection | global | `gc` |
| ` aa` | avante: ask | global | `<Plug>(AvanteAsk)` |
| ` ae` | avante: edit | global | `<Plug>(AvanteEdit)` |
| ` an` | avante: create new ask | global | `<Plug>(AvanteAskNew)` |
| ` az` | avante: toggle Zen Mode | global | `<Plug>(AvanteZenMode)` |
| ` ca` | Code Action | global | `lua/callback` |
| ` mc` | Evaluate visual selection | global | `lua/callback` |
| ` qv` | Quarto: Run selection | global | `lua/callback` |
| ` sr` | Search and replace selection | global | `lua/callback` |
| ` sw` | Word / Selection | global | `lua/callback` |
| `#` | :help v_#-default | global | `lua/callback` |
| `*` | :help v_star-default | global | `lua/callback` |
| `<C-A>` | Select all | global | `<Esc>ggVG` |
| `<C-P>` | pi-agent: ask about selection | global | `<Cmd>PiAgentAskSelection<CR>` |
| `<C-Q>` | Quit (confirm if modified) | global | `lua/callback` |
| `<C-S-F>` | Find in files | global | `lua/callback` |
| `<C-S>` | Save file | global | `<Cmd>update<CR>` |
| `<Plug>luasnip-expand-repeat` | LuaSnip: Repeat last node expansion | global | `lua/callback` |
| `@` | :help v_@-default | global | `mode() ==# 'V' ? ':normal! @'.getcharstr().'<CR>' : '@'` |
| `Q` | :help v_Q-default | global | `mode() ==# 'V' ? ':normal! @<C-R>=reg_recorded()<CR><CR>' : 'Q'` |
| `R` | Treesitter Search | global | `lua/callback` |
| `S` | Flash Treesitter | global | `lua/callback` |
| `[N` | Select previous sibling node | global | `lua/callback` |
| `[n` | Select previous node | global | `lua/callback` |
| `]N` | Select next sibling node | global | `lua/callback` |
| `]n` | Select next node | global | `lua/callback` |
| `an` | Select parent (outer) node | global | `lua/callback` |
| `gc` | Toggle comment | global | `lua/callback` |
| `gra` | vim.lsp.buf.code_action() | global | `lua/callback` |
| `gx` | Opens filepath or URI under cursor with the system handler (file explorer, web browser, …) | global | `lua/callback` |
| `in` | Select child (inner) node | global | `lua/callback` |
| `s` | Flash Jump | global | `lua/callback` |

## Operator-pending

| Key | Description | Scope | Action |
| --- | --- | --- | --- |
| `<Plug>luasnip-expand-repeat` | LuaSnip: Repeat last node expansion | global | `lua/callback` |
| `R` | Treesitter Search | global | `lua/callback` |
| `S` | Flash Treesitter | global | `lua/callback` |
| `an` | Select parent (outer) node | global | `lua/callback` |
| `gc` | Comment textobject | global | `lua/callback` |
| `in` | Select child (inner) node | global | `lua/callback` |
| `r` | Remote Flash | global | `lua/callback` |
| `s` | Flash Jump | global | `lua/callback` |

## Terminal

| Key | Description | Scope | Action |
| --- | --- | --- | --- |
| `<C-T>` | Toggle terminal | global | `lua/callback` |

## Command

| Key | Description | Scope | Action |
| --- | --- | --- | --- |
| `<C-E>` | blink.cmp: Cancel | global | `lua/callback` |
| `<C-N>` | blink.cmp: Select Next | global | `lua/callback` |
| `<C-P>` | blink.cmp: Select Prev | global | `lua/callback` |
| `<C-S>` | Toggle Flash (cmdline) | global | `lua/callback` |
| `<C-Space>` | blink.cmp: Show | global | `lua/callback` |
| `<C-Y>` | blink.cmp: Select And Accept | global | `lua/callback` |
| `<End>` | blink.cmp: Hide | global | `lua/callback` |
| `<Left>` | blink.cmp: Select Prev | global | `lua/callback` |
| `<Plug>luasnip-delete-check` | LuaSnip: Removes current snippet from jumplist | global | `lua/callback` |
| `<Plug>luasnip-expand-repeat` | LuaSnip: Repeat last node expansion | global | `lua/callback` |
| `<Right>` | blink.cmp: Select Next | global | `lua/callback` |
| `<S-Tab>` | blink.cmp: <Custom Fn>, Select Prev | global | `lua/callback` |
| `<Tab>` | blink.cmp: Show And Insert Or Accept Single, Select Next | global | `lua/callback` |

