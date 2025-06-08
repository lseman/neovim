return {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        enabled = true,
        scope = {
            enabled = true,
            highlight = {
                'ScopeRed',
                'ScopeYellow',
                'ScopeBlue',
                'ScopeOrange',
                'ScopeGreen',
                'ScopeViolet',
                'ScopeCyan'
            },
            show_start = true,
            show_end = true,
        },
        indent = {
            char = '▏',
        },
        exclude = {
            filetypes = {
                'help',
                'alpha',
                'dashboard',
                'neo-tree',
                'Trouble',
                'lazy',
                'mason',
                'notify',
                'toggleterm',
                'lazyterm',
            },
        },
    },
    config = function()
        local hooks = require('ibl.hooks')
        
        -- Define highlights with corrected colors
        local highlights = {
            ScopeRed = '#E06C75',     -- Actual red color
            ScopeYellow = '#E5C07B',   -- Warm yellow
            ScopeBlue = '#61AFEF',     -- Bright blue
            ScopeOrange = '#D19A66',   -- Warm orange
            ScopeGreen = '#98C379',    -- Soft green
            ScopeViolet = '#C678DD',   -- Bright violet
            ScopeCyan = '#56B6C2',     -- Cool cyan
        }

        -- Register highlight setup hook
        hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
            -- Set scope highlights
            for name, color in pairs(highlights) do
                vim.api.nvim_set_hl(0, name, { fg = color })
            end
        end)
    end
}