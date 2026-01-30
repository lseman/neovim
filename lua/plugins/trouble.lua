return {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {
        position = "bottom",
        height = 10,
        width = 50,
        -- icons = true,
        mode = "workspace_diagnostics",
        severity = nil,
        fold_open = "",
        fold_closed = "",
        group = true,
        padding = true,
        cycle_results = true,
        action_keys = {
            close = "q",
            cancel = "<esc>",
            refresh = "r",
            jump = "<cr>",
            toggle_fold = {"zA", "za"},
            previous = "k",
            next = "j"
        },
        auto_jump = {},
        signs = {
            error = "",
            warning = "",
            hint = "",
            information = "",
            other = ""
        },
        use_diagnostic_signs = false
    },
    keys = {
        { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
        { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
        { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols" },
        { "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP Info" },
        { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List" },
        { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List" }
    }
}