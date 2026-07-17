vim.g.snacks_animate = false

local function toggle_explorer()
  local open = Snacks.picker.get({
    source = "explorer",
  })
  if #open > 0 then
    for _, picker in ipairs(open) do
      picker:close()
    end
    return
  end
  Snacks.explorer()
end

return {
  "folke/snacks.nvim",
  event = "VeryLazy",

  ---@type snacks.Config
  opts = {
    bigfile = {
      enabled = true,
    },
    dashboard = {
      enabled = true, -- snacks loads on VeryLazy, shows dashboard when no file opened
      width = 64,
      pane_gap = 5,
      preset = {

        keys = {
          {
            icon = " ",
            key = "f",
            desc = "Smart find",
            action = function()
              Snacks.picker.smart()
            end,
          },
          {
            icon = " ",
            key = "g",
            desc = "Grep text",
            action = function()
              Snacks.picker.grep()
            end,
          },
          {
            icon = " ",
            key = "r",
            desc = "Recent files",
            action = function()
              Snacks.picker.recent()
            end,
          },
          {
            icon = " ",
            key = "c",
            desc = "Edit config",
            action = function()
              Snacks.picker.files({
                cwd = vim.fn.stdpath "config",
              })
            end,
          },
          {
            icon = " ",
            key = "p",
            desc = "Projects",
            action = function()
              Snacks.picker.projects()
            end,
          },
          {
            icon = "󰌌 ",
            key = "k",
            desc = "Keymaps",
            action = function()
              Snacks.picker.keymaps()
            end,
          },
          {
            icon = "󰒲 ",
            key = "l",
            desc = "Lazy",
            action = ":Lazy",
          },
          {
            icon = "󰓙 ",
            key = "h",
            desc = "Health check",
            action = ":checkhealth",
          },
          {
            icon = " ",
            key = "q",
            desc = "Quit",
            action = ":qa",
          },
        },
      },
      sections = {
        {
          section = "header",
          padding = 1,
        },
        {
          icon = " ",
          section = "keys",
          gap = 1,
          indent = 2,
          padding = 1,
        },
        {
          pane = 2,
          section = "terminal",
          cmd = "colorscript -e square",
          height = 5,
          padding = 1,
          enabled = function()
            return vim.fn.executable "colorscript" == 1
          end,
        },
        {
          pane = 2,
          icon = " ",
          title = "Recent",
          section = "recent_files",
          indent = 2,
          padding = 1,
        },
        {
          pane = 2,
          icon = " ",
          title = "Projects",
          section = "projects",
          indent = 2,
          padding = 1,
        },
        {
          pane = 2,
          icon = " ",
          title = "Git Status",
          section = "terminal",
          enabled = function()
            return Snacks.git.get_root() ~= nil
          end,
          cmd = "git status --short --branch --renames",
          height = 6,
          indent = 3,
          padding = 1,
          ttl = 300,
        },
        {
          section = "startup",
          padding = 1,
        },
      },
    },
    explorer = {
      enabled = true,
      replace_netrw = false,
      trash = true,
    },
    indent = {
      enabled = true,
    },
    image = {
      enabled = true,
      doc = {
        enabled = true,
        inline = true,
        float = true,
        max_width = 80,
        max_height = 40,
      },
      img_dirs = { "img", "images", "assets", "static", "public", "media", "attachments" },
      formats = {
        "png",
        "jpg",
        "jpeg",
        "gif",
        "bmp",
        "webp",
        "tiff",
        "heic",
        "avif",
        "mp4",
        "mov",
        "avi",
        "mkv",
        "webm",
        "pdf",
        "icns",
        "svg",
      },
    },
    input = {
      enabled = true,
    },
    lazygit = {
      enabled = true,
    },
    picker = {
      enabled = true,
      ui_select = true,
      sources = {
        files = {
          hidden = true,
          ignored = false,
        },
        grep = {
          hidden = true,
          ignored = false,
          exclude = { ".git" },
        },
        grep_buffers = {
          hidden = true,
          ignored = false,
        },
        diagnostics = {
          layout = {
            preset = "ivy",
          },
        },
        diagnostics_buffer = {
          layout = {
            preset = "ivy",
          },
        },
        explorer = {
          hidden = true,
          ignored = false,
          follow_file = true,
          watch = true,
          diagnostics = true,
          git_status = true,
          auto_close = false,
          layout = {
            preset = "sidebar",
            preview = false,
          },
          win = {
            list = {
              keys = {
                ["<CR>"] = "confirm",
                ["<2-LeftMouse>"] = "confirm",
                ["<C-s>"] = "edit_split",
                ["<C-v>"] = "edit_vsplit",
                ["<C-t>"] = "tab",
                ["Y"] = {
                  function(picker)
                    local item = picker:selected({
                      fallback = true,
                    })[1]
                    if not item or not item.file then
                      return
                    end
                    local path = vim.fn.fnamemodify(item.file, ":p")
                    vim.fn.setreg("+", path)
                    vim.notify("Copied: " .. path, vim.log.levels.INFO)
                  end,
                  mode = { "n", "x" },
                },
              },
            },
          },
        },
      },
      layout = {
        preset = "default",
      },
    },
    quickfile = {
      enabled = true,
    },
    profiler = {
      enabled = false, -- rarely used, saves startup time
    },
    scratch = {
      enabled = true,
    },
    scroll = {
      enabled = false,
    },
    scope = {
      enabled = false, -- rarely used, saves startup time
    },
    statuscolumn = {
      enabled = true,
    },
    words = {
      enabled = true,
    },
    notifier = {
      enabled = true,
      timeout = 3000,
      style = "compact",
    },
    terminal = {
      win = {
        position = "bottom",
        height = 0.32,
      },
    },
    toggle = {
      enabled = true,
    },
    zen = {
      enabled = true,
    },
  },

  keys = {
    {
      "<leader>.",
      function()
        Snacks.scratch()
      end,
      desc = "Toggle Scratch Buffer",
    },
    {
      "<leader>S",
      function()
        Snacks.scratch.select()
      end,
      desc = "Select Scratch Buffer",
    },
    {
      "<leader><space>",
      function()
        Snacks.picker.smart()
      end,
      desc = "Smart Find Files",
    },
    {
      "<leader>sf",
      function()
        Snacks.picker.smart({
          filter = {
            cwd = true,
          },
        })
      end,
      desc = "Frecency (cwd)",
    },
    {
      "<leader>sF",
      function()
        Snacks.picker.smart()
      end,
      desc = "Frecency (global)",
    },
    {
      "<leader>e",
      function()
        Snacks.explorer()
      end,
      desc = "File Explorer",
    },
    {
      "<leader>n",
      function()
        Snacks.notifier.show_history()
      end,
      desc = "Notification History",
    },
    {
      "<leader>un",
      function()
        Snacks.notifier.hide()
      end,
      desc = "Dismiss all notifications",
    },
    {
      "<leader>:",
      function()
        Snacks.picker.command_history()
      end,
      desc = "Command History",
    },
    {
      "<leader>ff",
      function()
        Snacks.picker.files()
      end,
      desc = "Find Files",
    },
    {
      "<leader>fg",
      function()
        Snacks.picker.grep()
      end,
      desc = "Grep (project)",
    },
    {
      "<leader>fb",
      function()
        Snacks.picker.buffers()
      end,
      desc = "Buffers",
    },
    {
      "<leader>fc",
      function()
        Snacks.picker.files({
          cwd = vim.fn.stdpath "config",
        })
      end,
      desc = "Config Files",
    },
    {
      "<leader>fG",
      function()
        Snacks.picker.git_files()
      end,
      desc = "Git Files",
    },
    {
      "<leader>fp",
      function()
        Snacks.picker.projects()
      end,
      desc = "Projects",
    },
    {
      "<leader>fr",
      function()
        Snacks.picker.recent()
      end,
      desc = "Recent Files",
    },
    {
      "<leader>fs",
      function()
        Snacks.picker.lsp_symbols()
      end,
      desc = "Document Symbols",
    },
    {
      "<leader>fS",
      function()
        Snacks.picker.lsp_workspace_symbols()
      end,
      desc = "Workspace Symbols",
    },
    {
      "<leader>sB",
      function()
        Snacks.picker.grep_buffers()
      end,
      desc = "Grep Open Buffers",
    },
    {
      "<leader>sw",
      function()
        Snacks.picker.grep_word()
      end,
      mode = { "n", "x" },
      desc = "Word / Selection",
    },
    {
      '<leader>s"',
      function()
        Snacks.picker.registers()
      end,
      desc = "Registers",
    },
    {
      "<leader>s/",
      function()
        Snacks.picker.search_history()
      end,
      desc = "Search History",
    },
    {
      "<leader>sC",
      function()
        Snacks.picker.commands()
      end,
      desc = "Commands",
    },
    {
      "<leader>sD",
      function()
        Snacks.picker.diagnostics_buffer()
      end,
      desc = "Buffer Diagnostics",
    },
    {
      "<leader>sj",
      function()
        Snacks.picker.jumps()
      end,
      desc = "Jumps",
    },
    {
      "<leader>sl",
      function()
        Snacks.picker.loclist()
      end,
      desc = "Location List",
    },
    {
      "<leader>sm",
      function()
        Snacks.picker.marks()
      end,
      desc = "Marks",
    },
    {
      "<leader>sp",
      function()
        Snacks.picker.lazy()
      end,
      desc = "Plugin Spec Search",
    },
    {
      "<leader>sq",
      function()
        Snacks.picker.qflist()
      end,
      desc = "Quickfix List",
    },
    {
      "<leader>sR",
      function()
        Snacks.picker.resume()
      end,
      desc = "Resume Picker",
    },
    {
      "<leader>su",
      function()
        Snacks.picker.undo()
      end,
      desc = "Undo History",
    },
    {
      "<leader>uC",
      function()
        Snacks.picker.colorschemes()
      end,
      desc = "Colorschemes",
    },
    {
      "<leader>fd",
      function()
        Snacks.picker.diagnostics()
      end,
      desc = "Diagnostics",
    },
    {
      "<leader>fh",
      function()
        Snacks.picker.help()
      end,
      desc = "Help Pages",
    },
    {
      "<leader>fk",
      function()
        Snacks.picker.keymaps()
      end,
      desc = "Keymaps",
    },
    {
      "<leader>fn",
      function()
        Snacks.picker.notifications()
      end,
      desc = "Notifications",
    },
    {
      "<leader>z",
      function()
        Snacks.zen()
      end,
      desc = "Zen Mode",
    },
    {
      "<leader>gk",
      function()
        Snacks.picker.git_branches()
      end,
      desc = "Git Branches",
    },
    {
      "<leader>gl",
      function()
        Snacks.picker.git_log()
      end,
      desc = "Git Log",
    },
    {
      "<leader>gL",
      function()
        Snacks.picker.git_log_line()
      end,
      desc = "Git Log Line",
    },
    {
      "<leader>gf",
      function()
        Snacks.picker.git_log_file()
      end,
      desc = "Git Log File",
    },
    {
      "<leader>gd",
      function()
        Snacks.picker.git_diff()
      end,
      desc = "Git Diff (Hunks)",
    },
    {
      "<leader>gs",
      function()
        Snacks.picker.git_status()
      end,
      desc = "Git Status",
    },
    {
      "<leader>cR",
      function()
        Snacks.rename.rename_file()
      end,
      desc = "Rename File",
    },
    {
      "<leader>gb",
      function()
        Snacks.gitbrowse()
      end,
      desc = "Git Browse (line/repo)",
    },
    {
      "<leader>lg",
      function()
        Snacks.lazygit()
      end,
      desc = "Lazygit",
    },
    {
      "<leader>nf",
      function()
        Snacks.explorer.reveal()
      end,
      desc = "Reveal File",
    },
    {
      "<leader>kr",
      function()
        require("kulala").run()
      end,
      desc = "HTTP request",
    },
    {
      "<leader>ka",
      function()
        require("kulala").run_all()
      end,
      desc = "HTTP run all",
    },
    {
      "<leader>kR",
      function()
        require("kulala").scratchpad()
      end,
      desc = "HTTP scratchpad",
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        Snacks.toggle
          .option("spell", {
            name = "Spelling",
          })
          :map "<leader>us"
        Snacks.toggle
          .option("wrap", {
            name = "Wrap",
          })
          :map "<leader>uw"
        Snacks.toggle
          .option("relativenumber", {
            name = "Relative Number",
          })
          :map "<leader>uL"
        Snacks.toggle.diagnostics():map "<leader>ud"
        Snacks.toggle.line_number():map "<leader>ul"
        Snacks.toggle
          .option("conceallevel", {
            off = 0,
            on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2,
            name = "Conceal",
          })
          :map "<leader>uc"
        Snacks.toggle.treesitter():map "<leader>uT"
        Snacks.toggle.inlay_hints():map "<leader>uh"
        Snacks.toggle.indent():map "<leader>ug"
        Snacks.toggle.words():map "<leader>uW"
        Snacks.toggle.profiler():map "<leader>uP"
      end,
    })
  end,
  opts_extend = { "sources.default" },
}
