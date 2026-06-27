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
      {
        "<leader>gd",
        "<cmd>DiffviewOpen<CR>",
        desc = "Diffview Open",
      },
      {
        "<leader>gD",
        "<cmd>DiffviewClose<CR>",
        desc = "Diffview Close",
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
