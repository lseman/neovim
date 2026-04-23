return {
    "jmbuhr/otter.nvim",
    dependencies = {"nvim-treesitter/nvim-treesitter", {
        "saghen/blink.cmp",
        optional = true
    }, -- completions inside embedded code blocks
    {
        "neovim/nvim-lspconfig",
        optional = true
    }},

    ft = {"markdown", "quarto", "rmd", "qmd"},

    opts = {
        languages = {"python", "lua", "rust", "cpp", "c", "go", "javascript", "typescript", "bash", "r", "julia"},
        handle_leading_whitespace = true,
        strip_wrapping_quote_characters = {"'", '"', "`"},
        remove_extra_blank_lines = true,
        debug = false
    },

    config = function(_, opts)
        local otter = require("otter")
        local map = vim.keymap.set
        local silent = {
            noremap = true,
            silent = true
        }

        -- Activate on every matching filetype (including the buffer that triggered the load)
        vim.api.nvim_create_autocmd("FileType", {
            pattern = {"markdown", "quarto", "rmd", "qmd"},
            group = vim.api.nvim_create_augroup("OtterAutoActivate", {
                clear = true
            }),
            callback = function()
                vim.defer_fn(function()
                    if vim.api.nvim_buf_is_valid(0) then
                        otter.activate(opts.languages, true, true)
                    end
                end, 80) -- small delay so treesitter injections settle first
            end
        })

        -- Manual controls
        map("n", "<leader>oo", function()
            otter.activate(opts.languages, true, true)
            vim.notify("Otter activated", vim.log.levels.INFO)
        end, vim.tbl_extend("force", silent, {
            desc = "Otter: Activate"
        }))

        map("n", "<leader>od", function()
            otter.deactivate()
            vim.notify("Otter deactivated", vim.log.levels.INFO)
        end, vim.tbl_extend("force", silent, {
            desc = "Otter: Deactivate"
        }))

        map("n", "<leader>or", function()
            otter.activate(opts.languages, true, true)
            vim.notify("Otter refreshed", vim.log.levels.INFO)
        end, vim.tbl_extend("force", silent, {
            desc = "Otter: Refresh"
        }))
    end
}

