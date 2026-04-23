-- quarto.nvim: first-class support for .qmd files
-- Quarto is the modern successor to RMarkdown and works with Python, R, Julia, etc.
-- It layers on top of otter.nvim for embedded LSP and molten-nvim for execution.
return {
    "quarto-dev/quarto-nvim",
    ft = {"quarto", "qmd"},
    dependencies = {"jmbuhr/otter.nvim", "nvim-treesitter/nvim-treesitter"},
    opts = {
        debug = false,
        closePreviewOnExit = true,
        lspFeatures = {
            enabled = true,
            chunks = "curly", -- "curly" = {python} blocks, "all" = any fenced block
            languages = {"python", "r", "julia", "bash", "lua"},
            diagnostics = {
                enabled = true,
                triggers = {"BufWritePost"}
            },
            completion = {
                enabled = true -- requires blink.cmp or nvim-cmp
            }
        },
        codeRunner = {
            enabled = true,
            default_method = "molten", -- use molten for interactive execution
            ft_runners = {}, -- per-filetype overrides if needed
            never_run = {"yaml"}
        }
    },
    keys = {{
        "<localleader>qp",
        function()
            require("quarto").quartoPreview()
        end,
        desc = "Quarto: Preview"
    }, {
        "<localleader>qq",
        function()
            require("quarto").quartoClosePreview()
        end,
        desc = "Quarto: Close preview"
    }, {
        "<localleader>qa",
        function()
            require("quarto").activate()
        end,
        desc = "Quarto: Activate LSP"
    }, -- Run cells via quarto's code runner (delegates to molten)
    {
        "<localleader>qr",
        function()
            require("quarto.runner").run_cell()
        end,
        desc = "Quarto: Run cell"
    }, {
        "<localleader>qR",
        function()
            require("quarto.runner").run_above()
        end,
        desc = "Quarto: Run above"
    }, {
        "<localleader>qal",
        function()
            require("quarto.runner").run_all()
        end,
        desc = "Quarto: Run all"
    }, {
        "<localleader>ql",
        function()
            require("quarto.runner").run_line()
        end,
        desc = "Quarto: Run line"
    }, {
        "<localleader>qv",
        function()
            require("quarto.runner").run_range()
        end,
        mode = "v",
        desc = "Quarto: Run selection"
    }}
}
