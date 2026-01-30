return {
  "nvim-telescope/telescope-fzf-native.nvim",
  lazy = true,
  dependencies = { "nvim-telescope/telescope.nvim" },

  -- Official recommended build command (works on Linux/macOS/WSL)
  build = "make",

  -- If you really need cmake + ninja/make fallback, keep your logic but simplify
  -- build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && make -C build",

  config = function()
    local telescope = require("telescope")

    -- Safe extension loading
    local ok, _ = pcall(telescope.load_extension, "fzf")
    if not ok then
      vim.notify("Failed to load telescope-fzf-native extension", vim.log.levels.WARN)
      return
    end

    telescope.setup({
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    })
  end,
}