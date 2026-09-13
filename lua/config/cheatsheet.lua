-- lua/config/cheatsheet.lua
-- Terminal card-grid cheatsheet — groups mappings by first word of desc,
-- displays them in columns.
-- Inspired by NvChad's grid.lua but self-contained and config-agnostic.

local M = {}
local api = vim.api

-- ── Highlight groups ──────────────────────────────────────────────────────

local function setup_hl()
  local function hex(name)
    local h = api.nvim_get_hl(0, { name = name, link = false })
    return h and h.fg or 0xffffff
  end

  api.nvim_set_hl(0, "CheatsheetTitle", {
    fg = hex("Identifier"),
    bold = true,
  })
  api.nvim_set_hl(0, "CheatsheetCard", {
    link = "Comment",
  })
  api.nvim_set_hl(0, "CheatsheetKey", {
    fg = hex("String"),
    bold = true,
  })
  api.nvim_set_hl(0, "CheatsheetAction", {
    link = "Normal",
  })
end

-- ── Mapping collection & grouping ────────────────────────────────────────

local mode_names = { n = "Normal", i = "Insert", v = "Visual", x = "Select", o = "Operator", t = "Terminal", c = "Command" }
local mode_order = { "n", "i", "v", "x", "o", "t", "c" }

-- Excluded first-words (noise mappings we don't want in the cheatsheet)
local excluded_words = {
  "<Plug>",
  "nvim",
  "lua",
  "vim",      -- includes "Vim.snippet.jump" etc.
  "plugin",
  "toggle",
  "default",  -- default Neovim help entries
}

local function capitalize(str)
  return (str:gsub("^%l", string.upper))
end

local function is_excluded(word)
  local w = word:lower()
  for _, ex in ipairs(excluded_words) do
    if w == ex:lower() or w:find(ex:lower() .. "%.") then
      return true
    end
  end
  return false
end

--- Collect and group all keymaps.
--- Returns { category = { { desc, key }, ... } }
M.collect_mappings = function(bufnr)
  local groups = {}
  local seen = {}

  local function add_maps(maps)
    for _, map in ipairs(maps) do
      local lhs = map.lhs or ""
      local desc = map.desc or ""
      local mode = map.mode or "n"

      -- Skip empty, multi-line, or single-char descriptions
      if desc == "" then goto continue end
      if desc:find "\n" then goto continue end
      local word_count = select(2, desc:gsub("%S+", ""))
      if word_count < 1 then goto continue end

      -- Skip default Neovim help mappings (desc contains "-default")
      if desc:match "%-default$" then goto continue end

      -- Extract first word as category
      local category = desc:match "%S+"
      if is_excluded(category) then goto continue end
      category = capitalize(category)

      -- Skip mode-only entries for non-normal modes (avoids noise from which-key etc.)
      if mode ~= "n" and map.rhs == nil and not map.callback then
        goto continue
      end

      -- Build a unique key to deduplicate
      local display_key = lhs:gsub("^ ", "<leader> +")
      local uniq = category .. "\0" .. display_key .. "\0" .. desc
      if seen[uniq] then goto continue end
      seen[uniq] = true

      -- Remove first word from description for the card body
      local action = desc:match "%s(.+)" or desc
      action = capitalize(action)

      if not groups[category] then
        groups[category] = {}
      end
      table.insert(groups[category], { action, display_key })

      ::continue::
    end
  end

  for _, mode in ipairs(mode_order) do
    add_maps(api.nvim_get_keymap(mode))
    if api.nvim_buf_is_valid(bufnr or 0) then
      add_maps(api.nvim_buf_get_keymap(bufnr or 0, mode))
    end
  end

  -- Remove groups with only one entry (usually noise)
  for cat, mappings in pairs(groups) do
    if #mappings <= 1 then
      groups[cat] = nil
    end
  end

  return groups
end

-- ── Rendering ────────────────────────────────────────────────────────────

M.open = function()
  local source_buf = api.nvim_get_current_buf()
  setup_hl()

  local buf = api.nvim_create_buf(false, true)
  local win = api.nvim_open_win(buf, true, {
    relative = "editor",
    width = math.max(1, vim.o.columns - 4),
    height = math.max(1, vim.o.lines - 6),
    row = 2,
    col = 2,
    style = "minimal",
    border = "rounded",
  })

  api.nvim_win_set_option(win, "wrap", false)
  api.nvim_win_set_option(win, "cursorline", false)
  api.nvim_win_set_option(win, "number", false)
  api.nvim_win_set_option(win, "relativenumber", false)
  api.nvim_win_set_option(win, "signcolumn", "no")
  api.nvim_win_set_option(win, "foldenable", false)

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = "cheatsheet"

  -- Close keymaps
  vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, silent = true, noremap = true })
  vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = buf, silent = true, noremap = true })

  M.render(buf, win, source_buf)

  -- Redraw on resize
  local group = api.nvim_create_augroup("CheatsheetResize" .. buf, { clear = true })
  api.nvim_create_autocmd({ "WinResized", "VimResized" }, {
    group = group,
    callback = function()
      if not api.nvim_win_is_valid(win) or not api.nvim_buf_is_valid(buf) then return end
      api.nvim_win_set_config(win, {
        width = math.max(1, vim.o.columns - 4),
        height = math.max(1, vim.o.lines - 6),
      })
      M.render(buf, win, source_buf)
    end,
  })
  api.nvim_create_autocmd("BufWipeout", {
    group = group,
    buffer = buf,
    once = true,
    callback = function()
      api.nvim_del_augroup_by_id(group)
    end,
  })
end

local function set_lines(buf, lines)
  vim.bo[buf].modifiable = true
  local ok, err = pcall(api.nvim_buf_set_lines, buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  if not ok then error(err) end
end

M.render = function(buf, win, source_buf)
  if not api.nvim_buf_is_valid(buf) or not api.nvim_win_is_valid(win) then return end
  local ns = api.nvim_create_namespace "cheatsheet"
  api.nvim_buf_clear_namespace(buf, ns, 0, -1)

  local groups = M.collect_mappings(source_buf)

  -- Sort category names
  local categories = vim.tbl_keys(groups)
  table.sort(categories)

  if #categories == 0 then
    set_lines(buf, { "No mappings found." })
    return
  end

  -- Use editor dimensions as fallback when window is too small
  local win_w = api.nvim_win_get_width(win or 0)
  if win_w < 40 then win_w = vim.o.columns - 8 end

  -- Calculate card width from the longest key+action pair
  local max_card_w = 0
  for _, cat in ipairs(categories) do
    max_card_w = math.max(max_card_w, api.nvim_strwidth(cat) + 2)
    for _, mapping in ipairs(groups[cat]) do
      local w = api.nvim_strwidth(mapping[1]) + api.nvim_strwidth(mapping[2]) + 8
      max_card_w = math.max(max_card_w, w)
    end
  end

  -- Determine columns: each card gets max_card_w + padding
  local padding = 4
  local usable_w = win_w - 8  -- border padding
  local cols_qty = math.floor(usable_w / (max_card_w + padding))
  if cols_qty < 1 then cols_qty = 1 end

  local card_slot_w = max_card_w

  -- Distribute cards into columns
  local card_rows_per_col = {}
  for c = 1, cols_qty do
    card_rows_per_col[c] = {}
  end

  local card_idx = 0
  for _, cat in ipairs(categories) do
    card_idx = card_idx + 1
    local col = ((card_idx - 1) % cols_qty) + 1

    -- Category header
    local header_str = " " .. cat .. " "
    local header_w = api.nvim_strwidth(header_str)
    local pad_l = math.floor((max_card_w - header_w) / 2)
    table.insert(card_rows_per_col[col], {
      { string.rep(" ", pad_l), "CheatsheetCard" },
      { header_str, "CheatsheetTitle" },
      { string.rep(" ", max_card_w - pad_l - header_w), "CheatsheetCard" },
    })

    -- Mapping rows
    for _, mapping in ipairs(groups[cat]) do
      local key = mapping[2]
      local action = mapping[1]
      local content = "  " .. key .. string.rep(" ", max_card_w - api.nvim_strwidth(key) - api.nvim_strwidth(action) - 4) .. action .. "   "
      table.insert(card_rows_per_col[col], {
        { content, "CheatsheetCard" },
      })
    end

    -- Separator line
    table.insert(card_rows_per_col[col], {
      { string.rep("─", max_card_w), "CheatsheetCard" },
    })
  end

  -- Find max rows across all columns
  local max_rows = 0
  for c = 1, cols_qty do
    max_rows = math.max(max_rows, #card_rows_per_col[c])
  end

  -- Allocate one buffer line per card row
  local total_rows = max_rows
  local empty_lines = {}
  for _ = 1, total_rows do
    table.insert(empty_lines, "")
  end
  set_lines(buf, empty_lines)

  -- Draw extmarks for each column
  for c = 1, cols_qty do
    local col_start_col = (c - 1) * (card_slot_w + padding) + 2  -- +2 for border
    if col_start_col >= win_w then break end

    for r = 1, #card_rows_per_col[c] do
      local row = r - 1
      api.nvim_buf_set_extmark(buf, ns, row, 0, {
        virt_text_win_col = col_start_col,
        virt_text = card_rows_per_col[c][r],
        virt_text_pos = "overlay",
      })
    end
  end

  -- Fill remaining space with empty lines for columns that have fewer rows
  for c = 1, cols_qty do
    local col_start_col = (c - 1) * (card_slot_w + padding) + 2
    if col_start_col >= win_w then break end
    for r = #card_rows_per_col[c] + 1, max_rows do
      api.nvim_buf_set_extmark(buf, ns, r - 1, 0, {
        virt_text_win_col = col_start_col,
        virt_text = { { string.rep(" ", card_slot_w), "CheatsheetCard" } },
        virt_text_pos = "overlay",
      })
    end
  end

  -- Fill empty lines below all columns
  for r = max_rows + 1, total_rows do
    api.nvim_buf_set_extmark(buf, ns, r - 1, 0, {
      virt_text = { { string.rep(" ", win_w), "CheatsheetCard" } },
      virt_text_pos = "overlay",
    })
  end

end

-- ── User command ────────────────────────────────────────────────────────

vim.api.nvim_create_user_command("Cheatsheet", function()
  M.open()
end, {
  desc = "Open keymap cheatsheet",
})

return M
