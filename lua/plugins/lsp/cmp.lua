-- LuaSnip: snippet engine (kept independent of blink.cmp)
local luasnip_spec = {
    "L3MON4D3/LuaSnip",
    event = "InsertEnter",
    build = "make install_jsregexp",
    dependencies = {"rafamadriz/friendly-snippets", "honza/vim-snippets"},
    opts = {
        history = true,
        updateevents = "TextChanged,TextChangedI",
        delete_check_events = "TextChanged,InsertLeave",
        enable_autosnippets = true,
        region_check_events = "CursorMoved"
    },
    config = function(_, opts)
        local ls = require("luasnip")
        ls.setup(opts)
        require("luasnip.loaders.from_vscode").lazy_load()
        pcall(require, "config.luasnip")

        vim.keymap.set({"i", "s"}, "<C-k>", function()
            if ls.expand_or_jumpable() then
                ls.expand_or_jump()
            end
        end, {
            silent = true,
            desc = "Expand or jump snippet"
        })

        vim.keymap.set({"i", "s"}, "<C-j>", function()
            if ls.jumpable(-1) then
                ls.jump(-1)
            end
        end, {
            silent = true,
            desc = "Jump back in snippet"
        })

        vim.api.nvim_create_autocmd("InsertLeave", {
            group = vim.api.nvim_create_augroup("LuaSnipCleanup", {
                clear = true
            }),
            desc = "Clean up snippet session on insert leave",
            callback = function()
                local buf = vim.api.nvim_get_current_buf()
                if ls.session.current_nodes[buf] and not ls.session.jump_active then
                    ls.unlink_current()
                end
            end
        })
    end
}

-- nvim-autopairs: bracket pairing (works independently of blink)
local autopairs_spec = {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
        fast_wrap = {
            map = "<M-e>",
            chars = {"{", "[", "(", '"', "'"},
            pattern = [=[[%'%"%)%>%]%)%}%,] ]=],
            end_key = "$",
            keys = "qwertyuiopzxcvbnmasdfghjkl",
            check_comma = true,
            highlight = "PmenuSel",
            highlight_grey = "LineNr"
        },
        disable_filetype = {"TelescopePrompt", "vim", "spectre_panel", "dap-repl"},
        enable_moveright = true,
        enable_afterquote = true,
        enable_check_bracket_line = true,
        enable_bracket_in_quote = true,
        break_undo = true,
        map_cr = true,
        map_bs = true,
        disable_in_macro = true
    },
    config = function(_, opts)
        local npairs = require("nvim-autopairs")
        local Rule = require("nvim-autopairs.rule")
        local cond = require("nvim-autopairs.conds")
        npairs.setup(opts)
        npairs.add_rules({Rule("f'", "'", "python"):with_pair(cond.before_regex("%a+")),
                          Rule('f"', '"', "python"):with_pair(cond.before_regex("%a+")),
                          Rule("```", "```", "markdown"):with_cr(cond.none()),
                          Rule("$", "$", "tex"):with_pair(cond.not_after_regex("%%"))})
    end
}

-- blink.cmp: modern completion engine
-- opts are defined in config/cmp.lua
local blink_spec = {
    "saghen/blink.cmp",
    event = {"InsertEnter", "CmdlineEnter"},
    version = "1.*",
    dependencies = {"L3MON4D3/LuaSnip"},
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = function()
        local config = require("config.cmp")
        return config()
    end,
    opts_extend = {"sources.default"}
}

return {luasnip_spec, autopairs_spec, blink_spec}
