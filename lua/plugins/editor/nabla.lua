return {
    {
        "jbyuki/nabla.nvim",
        -- nabla.lua exposes no setup() function, so passing `opts` here would
        -- error on load. It's lazy-loaded on demand via require() from the
        -- <C-b> keymap in config/keymaps.lua (popup-only, no continuous render).
    },
}
