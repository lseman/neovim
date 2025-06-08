return {
    "nvim-lualine/lualine.nvim",
    dependencies = {"nvim-tree/nvim-web-devicons"},

    config = function()

        -- Format file size nicely
        local function format_filesize(size_str)
            local size = tonumber(size_str)
            if not size or size <= 0 then
                return ""
            end
            if size < 1024 then
                return string.format('%d B', size)
            elseif size < 1024 * 1024 then
                return string.format('%.1f KB', size / 1024)
            else
                return string.format('%.2f MB', size / (1024 * 1024))
            end
        end

        -- LSP diagnostic icons
        local diagnostic_symbols = {
            error = ' ',
            warn = ' ',
            info = ' ',
            hint = ' '
        }

        -- Define venv lualine component
        local function venv_statusline()
            local ok, venv = pcall(require, "config.env")
            if not ok or not venv.status then
                return ""
            end
            local status = venv.status()
            return (status and status ~= "") and status or ""
        end

        require("lualine").setup({
            options = {
                icons_enabled = true,
                theme = "auto",
                component_separators = {
                    left = "",
                    right = ""
                },
                section_separators = {
                    left = "",
                    right = ""
                },
                disabled_filetypes = {
                    statusline = {"NvimTree", "alpha", "dashboard", "toggleterm", "packer"},
                    winbar = {}
                },
                always_divide_middle = true,
                globalstatus = true,
                refresh = {
                    statusline = 100,
                    tabline = 200,
                    winbar = 300
                }
            },

            sections = {
                lualine_a = {"mode"},
                lualine_b = {"branch", "diff", {
                    "diagnostics",
                    sources = {"nvim_diagnostic"},
                    symbols = diagnostic_symbols,
                    colored = true,
                    update_in_insert = false
                }},
                lualine_c = {{
                    "filename",
                    path = 1,
                    symbols = {
                        modified = "●",
                        readonly = "",
                        unnamed = "[No Name]"
                    }
                }},
                lualine_x = {{
                    venv_statusline,
                    color = {
                        fg = "#a6e3a1",
                        gui = "bold"
                    }
                }, "encoding", "fileformat", "filetype", {
                    "filesize",
                    fmt = format_filesize
                }},
                lualine_y = {"progress", "location"},
                lualine_z = {{
                    "datetime",
                    style = "%H:%M"
                }}
            },

            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {{
                    "filename",
                    path = 1
                }, {
                    venv_statusline,
                    icon = "",
                    color = {
                        fg = "#a6e3a1",
                        gui = "bold"
                    }
                }},
                lualine_x = {"location"},
                lualine_y = {},
                lualine_z = {}
            },

            tabline = {
                lualine_a = {"buffers"},
                lualine_z = {"tabs"}
            },

            extensions = {"nvim-tree", "toggleterm", "fugitive", "quickfix"}
        })
    end
}
