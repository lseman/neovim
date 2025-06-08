return {
  'RRethy/vim-illuminate',
  event = { "BufReadPost", "BufNewFile" },

  keys = {
    { "]]", desc = "Next Reference" },
    { "[[", desc = "Previous Reference" },
    { "]r", desc = "Next Reference" },
    { "[r", desc = "Previous Reference" },
    { "<leader>hi", function() require("illuminate").toggle() end, desc = "Toggle Illumination" },
    { "<leader>ht", function() require("illuminate").toggle_buf() end, desc = "Toggle Buffer Illumination" },
    { "<leader>hp", function() require("illuminate").pause() end, desc = "Pause Illumination" },
    { "<leader>hr", function() require("illuminate").resume() end, desc = "Resume Illumination" },
    { "<leader>hf", function() require("illuminate").toggle_freeze_buf() end, desc = "Freeze Buffer Illumination" },
  },

  opts = {
    delay = 100,
    large_file_cutoff = 3000,
    large_file_overrides = {
      providers = { "lsp", "treesitter" },
      delay = 200,
      min_count_to_highlight = 2,
    },
    modes_denylist = { "i", "t", "c", "r", "R", "v", "V", "\x16" },
    filetypes_denylist = {
      "dirvish", "fugitive", "NvimTree", "TelescopePrompt", "Trouble",
      "mason", "lazy", "alpha", "dashboard", "help", "qf", "toggleterm",
      "harpoon", "DressingSelect", "neo-tree", "notify", "noice", "WhichKey",
      "wildmenu", "gitcommit", "oil", "log", "txt", "markdown"
    },
    under_cursor = true,
    min_count_to_highlight = 2,
    providers = { "lsp", "treesitter", "regex" },
    providers_regex_syntax_denylist = {
      "Comment", "String", "Number", "Boolean", "Character", "Constant",
      "Special", "Identifier", "PreProc", "Todo",
    },
    case_insensitive_regex = true,
  },

  config = function(_, opts)
    local illuminate = require("illuminate")
    illuminate.configure(opts)

    -- #### Key Mappings (with buffer override support)
    local function map(key, dir, buffer)
      vim.keymap.set("n", key, function()
        illuminate["goto_" .. dir .. "_reference"](false)
      end, {
        desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference",
        buffer = buffer,
        silent = true,
        noremap = true,
      })
    end

    map("]]", "next")
    map("[[", "prev")
    map("]r", "next")
    map("[r", "prev")

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("IlluminateMapping", { clear = true }),
      callback = function()
        local buf = vim.api.nvim_get_current_buf()
        map("]]", "next", buf)
        map("[[", "prev", buf)
        map("]r", "next", buf)
        map("[r", "prev", buf)
      end,
    })

    -- #### Highlight Setup
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("IlluminateHighlight", { clear = true }),
      callback = function()
        local set = function(name, opts)
          opts.default = true
          vim.api.nvim_set_hl(0, name, opts)
        end

        -- Link to LSP highlights if defined
        set("IlluminatedWordText", { link = "LspReferenceText" })
        set("IlluminatedWordRead", { link = "LspReferenceRead" })
        set("IlluminatedWordWrite", { link = "LspReferenceWrite" })

        -- Fallback highlights
        set("IlluminatedWord", {
          bg = "#3c3836",
          fg = "NONE",
        })
        set("IlluminatedWordUnderCursor", {
          bg = "#504945",
          fg = "NONE",
          bold = true,
        })
      end,
    })

    -- #### Large File Optimization
    vim.api.nvim_create_autocmd("BufReadPre", {
      group = vim.api.nvim_create_augroup("IlluminatePerformance", { clear = true }),
      callback = function(args)
        local size = vim.fn.getfsize(args.match)
        if size > opts.large_file_cutoff * 1024 then
          illuminate.pause_buf()
          vim.notify("Illumination paused (file > " .. opts.large_file_cutoff .. " KB)", vim.log.levels.INFO)
        end
      end,
    })
  end,
}
