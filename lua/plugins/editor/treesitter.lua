local ensure_installed = {
    "c",
    "cpp",
    "lua",
    "vimdoc",
    "query",
    "markdown",
    "markdown_inline",
    "latex",
    "javascript",
    "typescript",
    "tsx",
    "html",
    "css",
    "bash",
    "regex",
    "json",
    "yaml",
    "toml",
    "cmake",
    "make",
    "dockerfile",
    "git_config",
    "git_rebase",
    "gitcommit",
    "gitignore",
    "python",
}

local excluded_filetypes = {
    TelescopePrompt = true,
    snacks_picker_list = true,
    lazy = true,
    mason = true,
    alpha = true,
    dashboard = true,
}

return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    dependencies = {
        {
            "JoosepAlviste/nvim-ts-context-commentstring",
            opts = {
                enable_autocmd = false,
                languages = {
                    javascript = {
                        __default = "// %s",
                        jsx_element = "{/* %s */}",
                        jsx_fragment = "{/* %s */}",
                        jsx_attribute = "// %s",
                        comment = "// %s",
                    },
                    typescript = { __default = "// %s" },
                    tsx = {
                        __default = "// %s",
                        jsx_element = "{/* %s */}",
                        jsx_fragment = "{/* %s */}",
                        jsx_attribute = "// %s",
                    },
                },
            },
        },
        {
            "windwp/nvim-ts-autotag",
            opts = {},
        },
    },

    config = function()
        local treesitter = require "nvim-treesitter"

        -- `main` is a full rewrite: setup now only configures the install path.
        -- Parsers and queries live together under stdpath("data")/site.
        treesitter.setup()
        treesitter.install(ensure_installed)

        local group = vim.api.nvim_create_augroup("TreesitterFeatures", { clear = true })
        vim.api.nvim_create_autocmd("FileType", {
            group = group,
            callback = function(args)
                if excluded_filetypes[vim.bo[args.buf].filetype] then
                    return
                end

                local name = vim.api.nvim_buf_get_name(args.buf)
                local stat = name ~= "" and vim.uv.fs_stat(name) or nil
                if stat and stat.size > 200 * 1024 then
                    return
                end

                -- Not every filetype has a parser. Missing parsers should fall back
                -- to normal syntax highlighting without producing an error.
                if pcall(vim.treesitter.start, args.buf) then
                    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end,
            desc = "Enable Tree-sitter highlighting and indentation",
        })
    end,
}
