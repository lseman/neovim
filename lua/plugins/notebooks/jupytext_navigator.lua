return {
    "GCBallesteros/NotebookNavigator.nvim",
    dependencies = {"GCBallesteros/jupytext.nvim", "benlubas/molten-nvim", "nvim-treesitter/nvim-treesitter"},
    ft = {"python", "julia", "r", "markdown", "quarto"},
    opts = {
        -- Cell marker used by the percent format
        cell_markers = {
            python = "# %%",
            lua = "-- %%",
            julia = "# %%",
            r = "# %%"
        },
        -- Use molten as the kernel runner
        kernel_provider = "molten",
        -- How to detect start of file as a cell
        activate_hydra_keys = nil -- set e.g. "<leader>jh" to enable hydra mode
    },
    keys = {{
        "]c",
        function()
            require("notebook-navigator").move_cell("d")
        end,
        desc = "Next cell"
    }, {
        "[c",
        function()
            require("notebook-navigator").move_cell("u")
        end,
        desc = "Prev cell"
    }, {
        "<leader>jj",
        function()
            require("notebook-navigator").run_cell()
        end,
        desc = "Run cell"
    }, {
        "<leader>jJ",
        function()
            require("notebook-navigator").run_and_move()
        end,
        desc = "Run cell + move next"
    }, {
        "<leader>ja",
        function()
            require("notebook-navigator").run_all_cells()
        end,
        desc = "Run all cells"
    }, {
        "<leader>jc",
        function()
            require("notebook-navigator").comment_cell()
        end,
        desc = "Comment cell"
    }, {
        "<leader>jn",
        function()
            require("notebook-navigator").add_cell_below()
        end,
        desc = "Add cell below"
    }, {
        "<leader>jN",
        function()
            require("notebook-navigator").add_cell_above()
        end,
        desc = "Add cell above"
    }, -- Visual: run selection as a cell
    {
        "<leader>jv",
        function()
            require("notebook-navigator").run_cell()
        end,
        mode = "v",
        desc = "Run visual as cell"
    }}
}
