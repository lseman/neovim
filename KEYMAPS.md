# Neovim Keymap Cheatsheet

- Updated: 2026-06-26
- Source: keymaps.lua + plugin keys blocks (snacks, gitsigns, molten, quarto, grug-far, neogit, conform, lspconfig, which-key)

> **⚠ Conflict**: `<leader>gd` — snacks.lua maps to Git Diff (Hunks), neogit.lua maps to DiffviewOpen. neogit wins (registered later).

---

## Normal

### Core

| Key | Description |
| --- | --- |
| `<C-s>` | Save file |
| `<C-q>` | Quit (confirm if modified) |
| `<C-z>` | Undo |
| `<C-S-z>` | Redo |
| `<C-a>` | Select all |

### Navigation / Windows

| Key | Description |
| --- | --- |
| `<C-Up>` | Resize window +2 rows |
| `<C-Down>` | Resize window -2 rows |
| `<C-Left>` | Resize window -2 cols |
| `<C-Right>` | Resize window +2 cols |
| `<C-t>` | Toggle terminal (bottom) |
| `<C-]>` | Next buffer |
| `<A-[>` | Previous buffer |
| `<C-1>`…`<C-9>` | Jump to buffer 1–9 |

### Text / Clipboard

| Key | Description |
| --- | --- |
| `<C-v>` | Paste from system clipboard |
| `<C-S-v>` | Paste before cursor |

### Search / Picker (Snacks)

| Key | Description |
| --- | --- |
| `;` | Smart find (files + recent) |
| `.` | Live grep (project) |
| `,` | Buffers |
| `<C-f>` | Fuzzy find in current buffer |
| `<C-S-f>` | Find in files (project grep, incl. hidden) |
| `\` | Toggle file explorer |
| `<C-e>` | Toggle file explorer |
| `<leader><space>` | Smart Find Files |
| `<leader>e` | File Explorer |
| `<leader>ff` | Find Files |
| `<leader>fg` | Grep (project) |
| `<leader>fb` | Buffers |
| `<leader>fc` | Config Files |
| `<leader>fG` | Git Files |
| `<leader>fp` | Projects |
| `<leader>fr` | Recent Files |
| `<leader>fs` | Document Symbols |
| `<leader>fS` | Workspace Symbols |
| `<leader>fd` | Diagnostics |
| `<leader>fh` | Help Pages |
| `<leader>fk` | Keymaps |
| `<leader>fn` | Notifications (picker) |
| `<leader>sf` | Frecency (cwd) |
| `<leader>sF` | Frecency (global) |
| `<leader>sB` | Grep Open Buffers |
| `<leader>sw` | Word under cursor |
| `<leader>s"` | Registers |
| `<leader>s/` | Search History |
| `<leader>sc` | Command History |
| `<leader>sC` | Commands |
| `<leader>sD` | Buffer Diagnostics |
| `<leader>sj` | Jumps |
| `<leader>sl` | Location List |
| `<leader>sm` | Marks |
| `<leader>sp` | Plugin Spec Search |
| `<leader>sq` | Quickfix List |
| `<leader>sR` | Resume Picker |
| `<leader>su` | Undo History |
| `<leader>st` | Todo |
| `<leader>sT` | Todo/Fix/Fixme |

### Quickfix

| Key | Description |
| --- | --- |
| `<leader>qg` | Grep to quickfix |
| `<leader>qd` | Diagnostics to quickfix |
| `<leader>qq` | Quit |
| `<leader>qQ` | Quit All |

### UI Toggles (Snacks)

| Key | Description |
| --- | --- |
| `<leader>us` | Toggle Spelling |
| `<leader>uw` | Toggle Wrap |
| `<leader>uL` | Toggle Relative Number |
| `<leader>ud` | Toggle Diagnostics |
| `<leader>ul` | Toggle Line Number |
| `<leader>uc` | Toggle Conceal |
| `<leader>uT` | Toggle Treesitter |
| `<leader>uh` | Toggle Inlay Hints |
| `<leader>ug` | Toggle Indent |
| `<leader>uW` | Toggle Word Highlight |
| `<leader>uP` | Toggle Profiler |
| `<leader>uC` | Colorschemes |
| `<leader>uM` | Refresh Mini Map |
| `<leader>um` | Toggle Mini Map |
| `<leader>u/` | Clear Search Highlight |
| `<leader>un` | Dismiss all notifications |

### Notifications

| Key | Description |
| --- | --- |
| `<leader>n` | Notification History |
| `<leader>nf` | Reveal File in Explorer |

### Scratch / Utility

| Key | Description |
| --- | --- |
| `<leader>.` | Toggle Scratch Buffer |
| `<leader>S` | Select Scratch Buffer |
| `<leader>:` | Command History |
| `<leader>z` | Zen Mode |
| `<leader>ch` | Config Health |
| `<leader>cR` | Rename File (Snacks) |
| `<C-b>` | Nabla popup (math preview) |
| `<F7>` | Select Copilot Chat model |
| `<F8>` | Show code actions |
| `<leader>ww` | Save |
| `<leader>wW` | Save All |

### Tabs

| Key | Description |
| --- | --- |
| `<leader>tn` | New tab |
| `<leader>tc` | Close tab |
| `<leader>to` | Only tab |

### LSP (buffer-local, set on attach)

| Key | Description |
| --- | --- |
| `gd` | Go to Definition |
| `gr` | References |
| `gI` | Implementation |
| `K` | Hover |
| `<leader>rn` | Rename |
| `<leader>sh` | Signature Help |
| `<leader>ds` | Document Symbols |
| `<leader>ws` | Workspace Symbols |
| `<leader>dl` | Line Diagnostics (float) |
| `[d` | Prev diagnostic |
| `]d` | Next diagnostic |
| `<leader>cl` | LSP Info |
| `<leader>cs` | Symbols |
| `gO` | Document Symbol (native) |
| `gra` | Code Action |
| `gri` | Implementation (native) |
| `grn` | Rename (native) |
| `grr` | References (native) |
| `grt` | Type Definition |
| `grx` | CodeLens Run |

### Format

| Key | Description |
| --- | --- |
| `<leader>fm` | Format buffer (Conform) |

### Search & Replace (grug-far)

| Key | Description |
| --- | --- |
| `<C-h>` | Search/replace in current file |
| `<leader>sr` | Search and replace |
| `<leader>rw` | Replace word under cursor |
| `<leader>rF` | Search and replace (scratch/transient) |
| `<leader>rr` | Reload init.lua |

### Git (Snacks + Neogit + Diffview)

| Key | Description |
| --- | --- |
| `<leader>gg` | Neogit Status |
| `<leader>gd` | Diffview Open *(shadows snacks git_diff)* |
| `<leader>gD` | Diffview Close |
| `<leader>gk` | Git Branches |
| `<leader>gl` | Git Log |
| `<leader>gL` | Git Log Line |
| `<leader>gf` | Git Log File |
| `<leader>gs` | Git Status (picker) |
| `<leader>gb` | Git Browse (line/repo) |
| `<leader>lg` | Lazygit |

### Git — Gitsigns (buffer-local)

| Key | Description |
| --- | --- |
| `]c` | Next hunk |
| `[c` | Prev hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hS` | Stage buffer |
| `<leader>hu` | Undo stage hunk |
| `<leader>hR` | Reset buffer |
| `<leader>hp` | Preview hunk inline |
| `<leader>hb` | Blame line (full) |
| `<leader>hd` | Diff this |
| `<leader>hD` | Diff this ~ |
| `<leader>tb` | Toggle line blame |
| `<leader>td` | Toggle show deleted |

### Molten / Notebooks

| Key | Description |
| --- | --- |
| `<leader>mi` | Molten Init (select kernel) |
| `<leader>ml` | Evaluate current line |
| `<leader>mo` | Show/enter output window |
| `<leader>mh` | Hide output window |
| `<leader>md` | Delete current cell output |
| `<leader>mr` | Re-evaluate cell |
| `<leader>ms` | Save Molten state |
| `<leader>mL` | Load Molten state |
| `<leader>mn` | Notebook mode |
| `<leader>mR` | Restart kernel (clear outputs) |
| `<leader>mI` | Interrupt kernel |
| `<leader>mm` | Run current `# %%` cell |
| `<F5>` | Run current `# %%` cell (Molten) |
| `<leader>mp` | Toggle Markdown render |

### Quarto (ft: quarto/qmd)

| Key | Description |
| --- | --- |
| `<leader>qa` | Activate LSP |
| `<leader>qp` | Preview |
| `<leader>qP` | Preview no watch |
| `<leader>qq` | Close preview |
| `<leader>qe` | Render |
| `<leader>qE` | Update preview |
| `<leader>qr` | Run cell |
| `<leader>qR` | Run above |
| `<leader>ql` | Run line |
| `<leader>qal` | Run all |
| `<leader>qn` | Next Python code block |
| `<leader>qN` | Previous Python code block |
| `<leader>q]` | Next code block |
| `<leader>q[` | Previous code block |
| `<C-CR>` | Run cell (Quarto) |
| `<F5>` | Run all cells (Quarto) *(overrides Molten F5 in .qmd)* |

### Python Runner (workflows.lua)

| Key | Description |
| --- | --- |
| `<leader>py` | Run Python file |
| `<leader>pa` | Run with args |
| `<leader>pi` | Python interactive |
| `<leader>pt` | Toggle Python terminal |
| `<leader>pr` | Repeat last run |
| `<leader>ph` | Run from history |

### Yank / Clipboard

| Key | Description |
| --- | --- |
| `<leader>y` | Yank to system clipboard (OSC52) |

### Diagnostics / Trouble

| Key | Description |
| --- | --- |
| `<leader>xx` | Diagnostics (Trouble) |
| `<leader>xX` | Buffer Diagnostics (Trouble) |
| `<leader>xt` | Todo (Trouble) |
| `<leader>xT` | Todo/Fix/Fixme (Trouble) |
| `<leader>xL` | Location List (Trouble) |
| `<leader>xQ` | Quickfix List (Trouble) |

### Navigation (jumps, lists)

| Key | Description |
| --- | --- |
| `]b` | Next buffer |
| `[b` | Prev buffer |
| `]q` | Next quickfix |
| `[q` | Prev quickfix |
| `]l` | Next location list |
| `[l` | Prev location list |
| `]t` | Next todo comment |
| `[t` | Prev todo comment |
| `]d` | Next diagnostic |
| `[d` | Prev diagnostic |
| `]c` | Next git hunk |
| `[c` | Prev git hunk |
| `-` | Open parent directory (Oil) |
| `s` | Flash Jump |
| `S` | Flash Treesitter |

### Comments / Operators

| Key | Description |
| --- | --- |
| `gc` | Toggle comment |
| `gcc` | Toggle comment line |
| `<leader>/` | Comment line |

### Treesitter text objects (normal)

| Key | Description |
| --- | --- |
| `]f` | Next function start |
| `[f` | Prev function start |
| `]c` | Next class start *(also: next git hunk — context-dependent)* |
| `[c` | Prev class start *(also: prev git hunk)* |
| `]a` | Next parameter |
| `[a` | Prev parameter |
| `]l` | Next loop |
| `[l` | Prev loop |
| `]o` | Next conditional |
| `[o` | Prev conditional |
| `<leader>a]` | Swap next parameter |
| `<leader>a[` | Swap prev parameter |
| `<leader>f]` | Swap next function |
| `<leader>f[` | Swap prev function |
| `<leader>df` | Peek function definition |
| `<leader>dF` | Peek class definition |

### Fidget / Progress

| Key | Description |
| --- | --- |
| `<leader>lh` | Fidget History |
| `<leader>lH` | Clear Fidget History |
| `<leader>lc` | Clear Active Progress |
| `<leader>lp` | Toggle LSP Progress HUD |

---

## Insert

| Key | Description |
| --- | --- |
| `<C-s>` | Save file |
| `<C-q>` | Quit (confirm if modified) |
| `<C-t>` | Toggle terminal |
| `<C-a>` | Select all |
| `<C-z>` | Undo |
| `<C-S-z>` | Redo |
| `<C-v>` | Paste from system clipboard |
| `<C-S-f>` | Find in files |
| `<Left>` | Smart left (wrap to prev line end) |
| `<Right>` | Smart right (wrap to next line start) |
| `<Tab>` | Copilot accept / next completion |
| `<S-Tab>` | Jump back in snippet |

---

## Visual

| Key | Description |
| --- | --- |
| `<C-c>` | Copy to system clipboard |
| `<C-v>` | Paste (replace selection, no yank) |
| `<C-s>` | Save |
| `<C-a>` | Select all |
| `<C-S-f>` | Find in files |
| `<Tab>` | Indent |
| `<S-Tab>` | Dedent |
| `<leader>sw` | Grep selection |
| `<leader>sr` | Search and replace selection |
| `<leader>mc` | Evaluate visual selection (Molten) |
| `<leader>jv` | Run visual as cell |
| `<leader>y` | Yank to system clipboard |
| `,qv` | Quarto: Run selection |
| `<leader>hs` | Stage selection (Gitsigns) |
| `<leader>hr` | Reset selection (Gitsigns) |
| `s` | Flash Jump |
| `S` | Flash Treesitter |
| `R` | Treesitter Search |
| `gc` | Toggle comment |

---

## Operator-pending

| Key | Description |
| --- | --- |
| `s` | Flash Jump |
| `S` | Flash Treesitter |
| `R` | Treesitter Search |
| `r` | Remote Flash |
| `gc` | Comment textobject |
| `af` / `if` | Function outer/inner |
| `ac` / `ic` | Class outer/inner |
| `aa` / `ia` | Parameter outer/inner |
| `al` / `il` | Loop outer/inner |
| `ao` / `io` | Conditional outer/inner |
| `ab` / `ib` | Block outer/inner |
| `am` / `a/` | Comment outer |
| `as` | Scope |
| `ih` | Gitsigns hunk (text object) |

---

## Terminal

| Key | Description |
| --- | --- |
| `<C-t>` | Toggle terminal |

---

## Command

| Key | Description |
| --- | --- |
| `<C-s>` | Toggle Flash (cmdline) |
