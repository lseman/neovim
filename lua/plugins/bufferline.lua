return {
  "akinsho/bufferline.nvim",
  version = "*",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local bufferline = require("bufferline")
    local devicons = require("nvim-web-devicons")

    --- Keymap helper
    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { noremap = true, silent = true, desc = desc })
    end

    --- Custom buffer filter
    local function filter_valid_buffers(bufnr)
      local ft = vim.bo[bufnr].filetype
      local bt = vim.bo[bufnr].buftype
      local name = vim.api.nvim_buf_get_name(bufnr)
      local excluded = {
        qf = true, help = true, man = true, startuptime = true, checkhealth = true,
        NvimTree = true, ["neo-tree"] = true, TelescopePrompt = true, alpha = true,
        dashboard = true, lspinfo = true, ["lsp-installer"] = true, ["null-ls-info"] = true,
        toggleterm = true, Trouble = true, spectre_panel = true,
      }
      return not (excluded[ft] or bt == "quickfix" or bt == "terminal" or bt == "nofile" or (name == "" and not vim.bo[bufnr].modified))
    end

    --- Buffer groups
    local groups = {
      options = { toggle_hidden_on_enter = true },
      items = {
        {
          name = "Tests",
          highlight = { underline = true, sp = "blue" },
          matcher = function(buf)
            return buf.name:lower():match("test") or buf.name:lower():match("spec")
          end,
        },
        {
          name = "Documentation",
          highlight = { underline = true, sp = "green" },
          matcher = function(buf)
            local n = buf.name:lower()
            return n:match("%.md$") or n:match("%.txt$") or n:match("readme") or n:match("%.rst$")
          end,
        },
        {
          name = "Configuration",
          highlight = { underline = true, sp = "yellow" },
          matcher = function(buf)
            local n = buf.name:lower()
            return n:match("config") or n:match("%.json$") or n:match("%.toml$") or n:match("%.ya?ml$") or n:match("%.env")
          end,
        },
      },
    }

    --- Offsets for file explorers and tools
    local offsets = {
      { filetype = "NvimTree", text = "󰉋 File Explorer", text_align = "center", separator = true, highlight = "Directory" },
      { filetype = "neo-tree", text = "󰉋 File Explorer", text_align = "center", separator = true, highlight = "Directory" },
      { filetype = "undotree", text = "󰣜 Undo Tree", text_align = "center", separator = true },
      { filetype = "Outline", text = "󰙅 Symbols", text_align = "center", separator = true },
    }

    bufferline.setup({
      options = {
        mode = "buffers",
        style_preset = bufferline.style_preset.default,
        themable = true,
        separator_style = "slant",
        indicator = { icon = "▎", style = "icon" },
        buffer_close_icon = "󰅖",
        modified_icon = "●",
        close_icon = "",
        left_trunc_marker = "",
        right_trunc_marker = "",
        max_name_length = 30,
        max_prefix_length = 20,
        truncate_names = true,
        tab_size = 21,
        color_icons = true,
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
        show_duplicate_prefix = true,
        duplicates_across_groups = true,
        persist_buffer_sort = true,
        move_wraps_at_ends = false,
        enforce_regular_tabs = false,
        always_show_bufferline = true,
        auto_toggle_bufferline = true,
        numbers = "none",
        sort_by = "insert_after_current",
        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,
        diagnostics_update_on_event = true,
        diagnostics_indicator = function(_, _, diag)
          local out = ""
          for _, n in pairs(diag) do out = out .. n .. " " end
          return out
        end,
        custom_filter = filter_valid_buffers,
        get_element_icon = function(el)
          return devicons.get_icon_by_filetype(el.filetype, { default = false })
        end,
        hover = {
          enabled = true,
          delay = 200,
          reveal = { "close" },
        },
        groups = groups,
        offsets = offsets,
        highlights = {
          fill = { bg = { attribute = "bg", highlight = "TabLine" } },
          background = { italic = false },
          buffer_visible = { italic = false },
          buffer_selected = { bold = true, italic = false },
          diagnostic_selected = { bold = true, italic = false },
          info_selected = { bold = true, italic = false },
          info_diagnostic_selected = { bold = true, italic = false },
          warning_selected = { bold = true, italic = false },
          warning_diagnostic_selected = { bold = true, italic = false },
          error_selected = { bold = true, italic = false },
          error_diagnostic_selected = { bold = true, italic = false },
          close_button = { fg = { attribute = "fg", highlight = "TabLineSel" } },
          close_button_visible = { fg = { attribute = "fg", highlight = "TabLine" } },
          close_button_selected = { fg = { attribute = "fg", highlight = "TabLineSel" } },
        },
      },
    })

    -- Keymaps
    map("<S-h>", "<cmd>BufferLineCyclePrev<cr>", "Previous buffer")
    map("<S-l>", "<cmd>BufferLineCycleNext<cr>", "Next buffer")
    map("<leader>bp", "<cmd>BufferLineCyclePrev<cr>", "Previous buffer")
    map("<leader>bn", "<cmd>BufferLineCycleNext<cr>", "Next buffer")
    map("<leader>bc", "<cmd>BufferLinePickClose<cr>", "Pick close")
    map("<leader>bC", "<cmd>BufferLineCloseOthers<cr>", "Close others")
    map("<leader>bl", "<cmd>BufferLineCloseLeft<cr>", "Close left")
    map("<leader>br", "<cmd>BufferLineCloseRight<cr>", "Close right")
    map("<leader>bb", "<cmd>BufferLinePick<cr>", "Pick buffer")
    map("]b", "<cmd>BufferLineMoveNext<cr>", "Move buffer next")
    map("[b", "<cmd>BufferLineMovePrev<cr>", "Move buffer prev")
    map("<leader>bg", "<cmd>BufferLineGroupToggle<cr>", "Toggle groups")

    for i = 1, 9 do
      map("<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<cr>", "Go to buffer " .. i)
    end

    -- Custom bufferline sort commands
    local sort_cmds = {
      Directory = "directory",
      Extension = "extension",
      RelativeDirectory = "relative_directory",
      Tabs = "tabs",
    }

    for name, method in pairs(sort_cmds) do
      vim.api.nvim_create_user_command("BufferLineSortBy" .. name, function()
        bufferline.sort_buffers_by(method)
      end, { desc = "Sort buffers by " .. name })
    end

    -- Autocommands
    local group = vim.api.nvim_create_augroup("BufferLineCustom", { clear = true })

    vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
      group = group,
      desc = "Auto-hide bufferline when only one buffer",
      callback = function()
        vim.schedule(function()
          local listed = vim.tbl_filter(function(buf)
            return vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted
          end, vim.api.nvim_list_bufs())
          vim.opt.showtabline = (#listed < 2) and 0 or 2
        end)
      end,
    })

    vim.api.nvim_create_autocmd("ColorScheme", {
      group = group,
      desc = "Refresh bufferline on colorscheme change",
      callback = function()
        vim.schedule(function()
          bufferline.setup(bufferline.get_config())
        end)
      end,
    })
  end,
}
