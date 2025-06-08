local harpoon = require("harpoon")

-- Correct setup
harpoon.setup({
  settings = {
    save_on_toggle = true,
    sync_on_ui_close = true,
    key = function()
      return vim.loop.cwd()
    end
  }
})

local list = harpoon:list()

-- Keybindings
vim.keymap.set("n", "<C-S-A>", function()
  list:add()
end, { desc = "Harpoon: Add current file" })

vim.keymap.set("n", "<C-S-D>", function()
  list:remove()
end, { desc = "Harpoon: Remove current file" })

vim.keymap.set("n", "<C-S-P>", function()
  list:prev()
end, { desc = "Harpoon: Previous file" })

vim.keymap.set("n", "<C-S-N>", function()
  list:next()
end, { desc = "Harpoon: Next file" })

-- Telescope picker
local function toggle_telescope(harpoon_list)
  local ok, pickers = pcall(require, "telescope.pickers")
  if not ok then return end

  local file_paths = {}
  for _, item in ipairs(harpoon_list.items or {}) do
    table.insert(file_paths, item.value)
  end

  pickers.new({}, {
    prompt_title = "Harpoon",
    finder = require("telescope.finders").new_table({ results = file_paths }),
    previewer = require("telescope.config").values.file_previewer({}),
    sorter = require("telescope.config").values.generic_sorter({}),
  }):find()
end

vim.keymap.set("n", "<C-w>", function()
  toggle_telescope(list)
end, { desc = "Harpoon: Open in Telescope" })

-- Optional: No longer needed — save is automatic on toggle/ui close
-- If you really want to ensure sync:
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    pcall(function()
      local l = require("harpoon"):list()
      if l.sync then l:sync() end
    end)
  end
})
