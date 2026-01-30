return {
  "RRethy/vim-illuminate",
  event = { "BufReadPost", "BufNewFile" },

  keys = {
    { "]]", desc = "Next Reference" },
    { "[[", desc = "Previous Reference" },
    { "]r", desc = "Next Reference (illuminate)" },
    { "[r", desc = "Previous Reference (illuminate)" },
    { "<leader>hi", function() require("illuminate").toggle() end,        desc = "Toggle Illuminate" },
    { "<leader>ht", function() require("illuminate").toggle_buf() end,    desc = "Toggle Buffer Illuminate" },
    { "<leader>hp", function() require("illuminate").pause() end,         desc = "Pause Illuminate" },
    { "<leader>hr", function() require("illuminate").resume() end,        desc = "Resume Illuminate" },
    { "<leader>hf", function() require("illuminate").toggle_freeze_buf() end, desc = "Freeze Buffer Illuminate" },
  },

  opts = {
    -- Delay (ms) before highlighting
    delay = 120,

    -- Highlight under cursor even if count is low
    under_cursor = true,

    -- Minimum # of matches before highlighting
    min_count_to_highlight = 2,

    -- Providers in priority order
    providers = {
      "lsp",
      "treesitter",
      "regex",
    },

    -- Disable in these modes
    modes_denylist = { "i", "c", "t", "r", "R", "v", "V", "\22" },

    -- Disable in these filetypes (good list — you can add more UI buffers)
    filetypes_denylist = {
      "dirvish", "fugitive", "NvimTree", "neo-tree", "TelescopePrompt",
      "Trouble", "mason", "lazy", "alpha", "dashboard", "help", "qf",
      "toggleterm", "harpoon", "DressingSelect", "notify", "noice",
      "WhichKey", "wildmenu", "gitcommit", "oil", "log", "txt", "markdown",
    },

    -- Large file handling
    large_file_cutoff = 3000, -- lines
    large_file_overrides = {
      providers = { "lsp", "treesitter" }, -- regex is too slow on huge files
      delay = 300,
      min_count_to_highlight = 3,
    },

    -- Regex provider: avoid highlighting literals
    providers_regex_syntax_denylist = {
      "Comment", "String", "Character", "Number", "Boolean",
      "Constant", "Special", "Identifier", "PreProc", "Todo",
    },
    case_insensitive_regex = true,
  },

  config = function(_, opts)
    local illuminate = require("illuminate")

    -- Configure once
    illuminate.configure(opts)

    -- Navigation keymaps (plugin already supports count with vim.v.count1)
    local function map(key, direction)
      vim.keymap.set("n", key, function()
        illuminate["goto_" .. direction .. "_reference"](false)
      end, {
        desc = direction:gsub("^%l", string.upper) .. " Reference",
        silent = true,
      })
    end

    map("]]", "next")
    map("[[", "prev")
    map("]r", "next")
    map("[r", "prev")

    -- Optional: buffer-local remap only when illuminate is active
    vim.api.nvim_create_autocmd("User", {
      pattern = "IlluminateAttach",
      callback = function(args)
        local bufnr = args.data.buf
        -- You could add buffer-specific keys here if needed
      end,
    })

    -- ── Highlights ────────────────────────────────────────────────
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("IlluminateHighlights", { clear = true }),
      callback = function()
        local function set_hl(name, val)
          vim.api.nvim_set_hl(0, name, vim.tbl_extend("force", { default = true }, val))
        end

        -- Prefer linking to LSP references when available
        set_hl("IlluminatedWordText",  { link = "LspReferenceText",  default = true })
        set_hl("IlluminatedWordRead",  { link = "LspReferenceRead",  default = true })
        set_hl("IlluminatedWordWrite", { link = "LspReferenceWrite", default = true })

        -- Fallback subtle style (bg only, no fg change)
        set_hl("IlluminatedWord", {
          bg = "#3c3836",   -- dark gray (gruvbox dark)
          underline = true,
          sp = "#fabd2f",   -- subtle yellow undercurl
        })

        -- Under cursor highlight (slightly stronger)
        set_hl("IlluminatedWordUnderCursor", {
          bg = "#504945",
          bold = true,
          underline = true,
          sp = "#fe8019",
        })
      end,
    })

    -- ── Large file auto-pause ─────────────────────────────────────
    vim.api.nvim_create_autocmd("BufRead", {
      group = vim.api.nvim_create_augroup("IlluminateLargeFile", { clear = true }),
      callback = function(args)
        if vim.bo[args.buf].buftype ~= "" then return end

        local lines = vim.api.nvim_buf_line_count(args.buf)
        if lines > opts.large_file_cutoff then
          vim.defer_fn(function()
            illuminate.pause_buf(args.buf)
            -- vim.notify("Illumination paused (large file)", vim.log.levels.INFO)
          end, 100)
        end
      end,
    })
  end,
}