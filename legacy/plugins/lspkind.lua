-- Disabled: blink.cmp renders completion icons natively; lspkind targets nvim-cmp.
return {
    "onsails/lspkind-nvim",
    enabled = false,
    lazy = true,
    event = "InsertEnter",
    -- dependencies = {"hrsh7th/nvim-cmp"},

    opts = function()
        local lspkind = require("lspkind")

        -- You can override / extend the codicons preset
        local symbol_map = lspkind.presets.codicons -- start from official preset
        vim.tbl_deep_extend("force", symbol_map, {
            -- Add / override your favorites
            Copilot = "",
            Supermaven = "", -- or "󰠠 " etc. — popular in 2025
            TabNine = "󰏚"
            -- Snippet       = "",   -- sometimes people prefer this over 󰘍
            -- Codeium       = "󰘦",   -- if you use it
        })

        local source_names = {
            nvim_lsp = "󰒋 LSP",
            buffer = "󰦨 Buf",
            path = "󰉋 Path",
            luasnip = "󰩫 Snip", -- nicer icon in some fonts
            emoji = "󰞅",
            calc = "󰃬",
            spell = "󰓆",
            copilot = " Copilot",
            cmp_tabnine = "󰏚 TabNine",
            treesitter = " TS",
            npm = "󰡘 NPM",
            latex_symbols = "󰊄 LaTeX"
            -- supermaven   = " SM",   -- add if using
        }

        return {
            mode = "symbol", -- "symbol" (icon only) is often preferred nowadays
            preset = "codicons",
            symbol_map = symbol_map,
            maxwidth = 50,
            ellipsis_char = "…", -- slightly nicer than "..."

            -- Very clean custom formatter
            before = function(entry, vim_item)
                local kind_icon = symbol_map[vim_item.kind] or ""
                local source = source_names[entry.source.name] or entry.source.name

                vim_item.kind = kind_icon
                vim_item.menu = source and (" %s"):format(source) or ""

                -- Smarter truncation that respects icon + menu width
                local max_content_width = 50
                local content_width = vim.fn.strdisplaywidth(vim_item.abbr or "") +
                                          vim.fn.strdisplaywidth(vim_item.menu) + vim.fn.strdisplaywidth(kind_icon)

                if content_width > max_content_width then
                    local avail = max_content_width - vim.fn.strdisplaywidth(vim_item.menu) -
                                      vim.fn.strdisplaywidth(kind_icon) - 2
                    vim_item.abbr = vim.fn.strcharpart(vim_item.abbr, 0, avail) .. "…"
                end

                -- Special kind highlights for AI sources
                local source_hl_map = {
                    copilot = "CmpItemKindCopilot",
                    cmp_tabnine = "CmpItemKindTabNine"
                    -- supermaven  = "CmpItemKindSupermaven",   -- example
                }
                if source_hl_map[entry.source.name] then
                    vim_item.kind_hl_group = source_hl_map[entry.source.name]
                end

                return vim_item
            end
        }
    end,

    config = function(_, opts)
        local lspkind = require("lspkind")
        lspkind.init(opts)

        -- Basic popupmenu tuning
        vim.opt.completeopt = {"menu", "menuone", "noselect", "preview"}
        vim.opt.pumheight = 15
        vim.opt.pumwidth = 60 -- a bit wider → better readability
        vim.opt.pumblend = 10

        vim.api.nvim_set_hl(0, "CmpItemMenu", {
            italic = false,
            default = true
        })

        -- Integrate cleanly with cmp
        local cmp_ok, cmp = pcall(require, "cmp")
        if cmp_ok then
            local cmp_format = lspkind.cmp_format(opts)
            cmp.setup {
                formatting = {
                    format = cmp_format -- ← uses your .before function
                }
            }
        end
    end
}
