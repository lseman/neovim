local ts_utils = require("nvim-treesitter.ts_utils")

local M = {}

-- ─── State ────────────────────────────────────────────────────────────────
local state = {
  node_stack = {},
  current_index = 0,
  initial_cursor = nil,
}

-- ─── Visual Selection ─────────────────────────────────────────────────────
local function set_visual_selection(node)
  if not node then return false end
  local start_row, start_col, end_row, end_col = node:range()

  -- Store initial cursor position only once
  if not state.initial_cursor then
    state.initial_cursor = vim.api.nvim_win_get_cursor(0)
  end

  vim.fn.setpos(".", { 0, start_row + 1, start_col + 1, 0 })
  vim.cmd("normal! v")
  vim.fn.setpos(".", { 0, end_row + 1, end_col, 0 })
  return true
end

-- ─── Parent Traversal ─────────────────────────────────────────────────────
local function find_expandable_parent(node)
  local parent = node and node:parent()
  if not parent then return nil end

  local sr1, sc1, er1, ec1 = node:range()
  local sr2, sc2, er2, ec2 = parent:range()

  if sr1 == sr2 and sc1 == sc2 and er1 == er2 and ec1 == ec2 then
    return find_expandable_parent(parent) -- Skip redundant nodes
  end
  return parent
end

-- ─── Selection API ────────────────────────────────────────────────────────
function M.start_selection()
  local node = ts_utils.get_node_at_cursor()
  if not node then
    vim.notify_once("No Treesitter node at cursor", vim.log.levels.WARN)
    return false
  end

  state.node_stack = { node }
  state.current_index = 1
  state.initial_cursor = nil

  if not set_visual_selection(node) then
    vim.notify("Failed to set initial selection", vim.log.levels.ERROR)
    return false
  end

  return true
end

function M.expand_selection()
  if state.current_index == 0 then
    vim.notify_once("No active selection. Use `start_selection()` first.", vim.log.levels.WARN)
    return false
  end

  local current_node = state.node_stack[state.current_index]
      or ts_utils.get_node_at_cursor()

  if not current_node then
    vim.notify("No node found to expand", vim.log.levels.WARN)
    return false
  end

  local parent = find_expandable_parent(current_node)
  if not parent then
    vim.notify_once("No parent node to expand to", vim.log.levels.INFO)
    vim.cmd("normal! gv")
    return false
  end

  table.insert(state.node_stack, parent)
  state.current_index = state.current_index + 1

  if not set_visual_selection(parent) then
    table.remove(state.node_stack)
    state.current_index = state.current_index - 1
    vim.notify("Failed to expand selection", vim.log.levels.ERROR)
    return false
  end

  return true
end

function M.contract_selection()
  if state.current_index <= 1 then
    vim.notify_once("Already at the innermost selection", vim.log.levels.INFO)
    return false
  end

  state.current_index = state.current_index - 1
  local node = state.node_stack[state.current_index]

  if not node or not set_visual_selection(node) then
    vim.notify("Failed to contract selection", vim.log.levels.ERROR)
    return false
  end

  return true
end

function M.reset_selection()
  state.node_stack = {}
  state.current_index = 0

  if state.initial_cursor then
    vim.api.nvim_win_set_cursor(0, state.initial_cursor)
    state.initial_cursor = nil
  end
end

function M.get_selection_info()
  local node = state.node_stack[state.current_index]
  return {
    active = state.current_index > 0,
    depth = state.current_index,
    total = #state.node_stack,
    node_type = node and node:type() or nil,
  }
end

function M.smart_select()
  if state.current_index == 0 then
    return M.start_selection()
  else
    return M.expand_selection()
  end
end

return M
