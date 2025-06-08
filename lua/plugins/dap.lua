return {
  {
    "mfussenegger/nvim-dap",
    lazy = false,
    dependencies = {
      "nvim-neotest/nvim-nio",
      { "rcarriga/nvim-dap-ui", name = "dapui" },
      "theHamsta/nvim-dap-virtual-text",
      {
        "nvim-telescope/telescope-dap.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
      },
    },
    keys = {
      -- DAP core
      { "<F5>",     function() require("dap").continue() end,            desc = "Debug: Continue" },
      { "<F10>",    function() require("dap").step_over() end,          desc = "Debug: Step Over" },
      { "<F11>",    function() require("dap").step_into() end,          desc = "Debug: Step Into" },
      { "<F12>",    function() require("dap").step_out() end,           desc = "Debug: Step Out" },
      { "<leader>b", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>B", function()
        require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, desc = "Conditional Breakpoint" },
      { "<leader>dr", function() require("dap").repl.open() end,        desc = "Open REPL" },
      { "<leader>dl", function() require("dap").run_last() end,         desc = "Run Last Debug" },

      -- DAP UI
      { "<leader>du", function() require("dapui").toggle() end,         desc = "Toggle DAP UI" },
      { "<leader>de", function() require("dapui").eval() end, mode = { "n", "v" }, desc = "Evaluate" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- 🧩 DAP UI Setup
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "➡" },
        mappings = {
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o", remove = "d", edit = "e", repl = "r", toggle = "t",
        },
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              { id = "breakpoints", size = 0.25 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.25 },
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size = 10,
            position = "bottom",
          },
        },
        floating = {
          border = "single",
          mappings = { close = { "q", "<Esc>" } },
        },
      })

      -- 🧠 Virtual Text Setup
      require("nvim-dap-virtual-text").setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        virt_text_pos = "eol",
        commented = false,
        all_frames = false,
        virt_lines = false,
      })

      -- 🔄 Event Hooks
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
        vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#993939", bg = "#31353f" })
        vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#61afef", bg = "#31353f" })
        vim.api.nvim_set_hl(0, "DapStopped", { fg = "#98c379", bg = "#31353f" })
      end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      -- 🔖 Signs
      local signs = {
        DapBreakpoint = "",
        DapStopped = "",
        DapBreakpointCondition = "",
        DapLogPoint = "",
        DapBreakpointRejected = "",
      }
      for name, icon in pairs(signs) do
        vim.fn.sign_define(name, { text = icon, texthl = name, linehl = "", numhl = "" })
      end
    end,
  },

  {
    "nvim-telescope/telescope-dap.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "mfussenegger/nvim-dap",
    },
    keys = {
      { "<leader>dc", function() require("telescope").extensions.dap.commands() end,       desc = "DAP: Commands" },
      { "<leader>dC", function() require("telescope").extensions.dap.configurations() end, desc = "DAP: Configs" },
      { "<leader>db", function() require("telescope").extensions.dap.list_breakpoints() end, desc = "DAP: Breakpoints" },
      { "<leader>dv", function() require("telescope").extensions.dap.variables() end,      desc = "DAP: Variables" },
      { "<leader>df", function() require("telescope").extensions.dap.frames() end,         desc = "DAP: Frames" },
    },
    config = function()
      local ok, telescope = pcall(require, "telescope")
      if ok then telescope.load_extension("dap") end
    end,
  },
}
