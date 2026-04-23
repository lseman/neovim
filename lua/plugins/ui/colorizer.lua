return {
    "catgoose/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = {
        filetypes = {"*"},
        user_commands = true,
        options = {
            parsers = {
                css = true, -- preset: enables names, hex, rgb, hsl, oklch
                tailwind = {
                    enable = false,
                    lsp = false
                },
                sass = {
                    enable = false
                },
                xterm = {
                    enable = false
                }
            },
            display = {
                mode = "background", -- "background" | "foreground" | "virtualtext"
                virtualtext = {
                    char = "■",
                    position = "eol"
                }
            }
        }
    }
}
