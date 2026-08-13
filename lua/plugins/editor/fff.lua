return {
    "dmtrKovalenko/fff.nvim",
    build = function()
        require("fff.download").download_or_build_binary()
    end,
    opts = {
        layout = {
            width = 0.4,
            height = 0.8,
            preview_size = 0.5,
        },
        max_results = 100,
        max_threads = 4,
        lazy_sync = true,
        path_shorten_strategy = "middle_number",
    },
    keys = {
        { "ff", function() require('fff').find_files() end, desc = 'FFFind files' },
        { "fg", function() require('fff').live_grep() end, desc = 'LiFFFe grep' },
    },
}
