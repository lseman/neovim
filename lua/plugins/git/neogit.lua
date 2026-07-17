return {
  {
    "NeogitOrg/neogit",
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
    cmd = { "Neogit" },
    keys = {
      {
        "<leader>gg",
        "<cmd>Neogit<CR>",
        desc = "Neogit Status",
      },
    },
    opts = {
      integrations = {
        diffview = true,
      },
      graph_style = "unicode",
    },
  },
}
