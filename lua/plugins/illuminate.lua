return {
  "RRethy/vim-illuminate",
  event = { "BufReadPost", "BufNewFile" },
  keys = {
    { "]]", desc = "Illuminate: Next reference" },
    { "[[", desc = "Illuminate: Prev reference" },
    { "]r", desc = "Illuminate: Next reference" },
    { "[r", desc = "Illuminate: Prev reference" },
    { "<leader>hi", function() require("illuminate").toggle()        end, desc = "Illuminate: Toggle global" },
    { "<leader>ht", function() require("illuminate").toggle_buf()    end, desc = "Illuminate: Toggle buffer" },
    { "<leader>hp", function() require("illuminate").pause()         end, desc = "Illuminate: Pause" },
    { "<leader>hr", function() require("illuminate").resume()        end, desc = "Illuminate: Resume" },
    { "<leader>hf", function() require("illuminate").toggle_freeze_buf() end, desc = "Illuminate: Freeze buffer" },
  },

  opts = {
    -- Timing
    delay = 130,                      -- fast enough to feel responsive, slow enough to avoid jitter
    under_cursor = true,
    min_count_to_highlight = 2,

    -- Providers in priority order (lsp > treesitter > regex)
    providers = {
      "lsp",
      "treesitter",
      "regex",
    },

    -- Modes where illumination is usually unwanted
    modes_denylist = { "i", "c", "t", "r", "R", "v", "V", "\22" },

    -- Filetypes to completely disable (UI / special buffers)
    filetypes_denylist = {
      "dirvish", "fugitive", "NvimTree", "neo-tree", "TelescopePrompt", "TelescopeResults",
      "Trouble", "mason", "lazy", "alpha", "dashboard", "help", "qf", "toggleterm",
      "harpoon", "DressingSelect", "notify", "noice", "WhichKey", "oil", "log",
      "gitcommit", "markdown", "txt", "terminal",
    },

    -- Large files
    large_file_cutoff = 3500,         -- lines
    large_file_overrides = nil,       -- we handle pausing via autocmd instead

    -- Regex tweaks
    providers_regex_syntax_denylist = { "Comment", "String", "Character", "Number", "Boolean" },
    case_insensitive_regex = true,
  },

  config = function(_, opts)
    local illuminate = require("illuminate")
    illuminate.configure(opts)

    -- ── Navigation keymaps (support count with vim.v.count1) ────────────────
    local function map(key, direction)
      vim.keymap.set("n", key, function()
        illuminate["goto_" .. direction .. "_reference"](false)
      end, {
        desc = "Illuminate: " .. direction:gsub("^%l", string.upper) .. " reference",
        silent = true,
      })
    end

    map("]]", "next")
    map("[[", "prev")
    map("]r", "next")
    map("[r", "prev")

    -- ── Subtle highlight setup (links to LSP when possible) ─────────────────
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("IlluminateHighlightSetup", { clear = true }),
      callback = function()
        local function set_hl(name, val)
          vim.api.nvim_set_hl(0, name, vim.tbl_extend("force", { default = true }, val))
        end

        -- Prefer LSP semantic tokens links when available
        set_hl("IlluminatedWordText",  { link = "LspReferenceText",  default = true })
        set_hl("IlluminatedWordRead",  { link = "LspReferenceRead",  default = true })
        set_hl("IlluminatedWordWrite", { link = "LspReferenceWrite", default = true })

        -- Fallback subtle style (used when no LSP reference exists)
        set_hl("IlluminatedWord", {
          bg = "#3c3836",           -- gruvbox dark gray (or your colorscheme equivalent)
          underline = true,
          sp = "#fabd2f",           -- subtle yellow undercurl
        })

        -- Slightly stronger for word under cursor
        set_hl("IlluminatedWordUnderCursor", {
          bg = "#504945",
          underline = true,
          sp = "#fe8019",           -- orange undercurl
          bold = true,
        })
      end,
    })

    -- ── Auto-pause illumination in very large files ─────────────────────────
    local paused_large = {}  -- avoid spamming notify

    vim.api.nvim_create_autocmd("BufReadPost", {
      group = vim.api.nvim_create_augroup("IlluminateLargeFilePause", { clear = true }),
      callback = function(args)
        local buf = args.buf
        if vim.bo[buf].buftype ~= "" then return end

        local lines = vim.api.nvim_buf_line_count(buf)
        if lines > opts.large_file_cutoff and not paused_large[buf] then
          vim.defer_fn(function()
            if vim.api.nvim_buf_is_valid(buf) then
              illuminate.pause_buf(buf)
              -- vim.notify("Illumination paused (large file > " .. opts.large_file_cutoff .. " lines)", vim.log.levels.INFO)
              paused_large[buf] = true
            end
          end, 150)
        end
      end,
    })

    -- Optional: resume when buffer size changes dramatically (rare)
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = vim.api.nvim_create_augroup("IlluminateLargeFileResume", { clear = true }),
      callback = function(args)
        local buf = args.buf
        if paused_large[buf] and vim.api.nvim_buf_line_count(buf) <= opts.large_file_cutoff then
          illuminate.resume_buf(buf)
          paused_large[buf] = nil
        end
      end,
    })
  end,
}