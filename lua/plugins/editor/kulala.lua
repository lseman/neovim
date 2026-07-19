return {
    "mistweaverco/kulala.nvim",
    ft = { "http", "rest" },
    keys = {
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
    opts = {
        global_keymaps = false,
        ui = {
            display_mode = "split",
        },
    },
}
