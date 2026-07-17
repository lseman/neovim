local M = {}

local prompt_active = false

local function notify_kernel_missing()
  vim.notify("No Jupyter kernels found. Install one, then run :MoltenInit.", vim.log.levels.WARN)
end

local function setup_highlights()
  vim.api.nvim_set_hl(0, "MoltenKernelPickerTitle", { link = "Title", default = true })
  vim.api.nvim_set_hl(0, "MoltenKernelPickerNumber", { link = "Number", default = true })
  vim.api.nvim_set_hl(0, "MoltenKernelPickerNew", { link = "DiagnosticOk", default = true })
  vim.api.nvim_set_hl(0, "MoltenKernelPickerShared", { link = "DiagnosticInfo", default = true })
  vim.api.nvim_set_hl(0, "MoltenKernelPickerMuted", { link = "Comment", default = true })
  vim.api.nvim_set_hl(0, "MoltenKernelPickerName", { link = "Identifier", default = true })
  vim.api.nvim_set_hl(0, "MoltenKernelPickerBorder", { link = "FloatBorder", default = true })
end

function M.buffer_kernels()
  local ok, kernels = pcall(vim.fn.MoltenRunningKernels, true)
  return ok and kernels or {}
end

local function available_kernel_choices()
  local choices = {}

  local available_ok, available = pcall(vim.fn.MoltenAvailableKernels)
  if available_ok then
    for _, kernel in ipairs(available) do
      choices[#choices + 1] = { name = kernel, shared = false }
    end
  end

  local running_ok, running = pcall(vim.fn.MoltenRunningKernels)
  if running_ok then
    for _, kernel in ipairs(running) do
      choices[#choices + 1] = { name = kernel, shared = true }
    end
  end

  return choices
end

local function choice_kind(choice)
  return choice.shared and "RUNNING" or "NEW"
end

local function close_picker(win, callback, choice)
  if vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end

  prompt_active = false

  if callback then
    callback(choice)
  end
end

local function pick_kernel(choices, callback, title)
  if prompt_active then
    return
  end

  prompt_active = true
  setup_highlights()

  local title_line = title or "Choose a kernel to start"
  local lines = { "  " .. title_line, "  Select the kernel for this buffer.", "" }
  for index, choice in ipairs(choices) do
    lines[#lines + 1] = string.format("  %d  %-7s  %s", index, choice_kind(choice), choice.name)
  end
  lines[#lines + 1] = ""
  lines[#lines + 1] = "  Enter select   1-9 choose   Esc/q cancel"

  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, vim.api.nvim_strwidth(line))
  end
  width = math.min(math.max(width + 4, 44), math.max(vim.o.columns - 4, 20))

  local height = #lines
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "molten_kernel_picker"
  vim.bo[buf].modifiable = false

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = {
      { "╭", "MoltenKernelPickerBorder" },
      { "─", "MoltenKernelPickerBorder" },
      { "╮", "MoltenKernelPickerBorder" },
      { "│", "MoltenKernelPickerBorder" },
      { "╯", "MoltenKernelPickerBorder" },
      { "─", "MoltenKernelPickerBorder" },
      { "╰", "MoltenKernelPickerBorder" },
      { "│", "MoltenKernelPickerBorder" },
    },
    title = " Molten Kernel ",
    title_pos = "center",
    footer = " " .. #choices .. " available ",
    footer_pos = "right",
  })

  vim.wo[win].cursorline = true
  vim.wo[win].wrap = false
  vim.wo[win].winhighlight = "Normal:NormalFloat,FloatBorder:MoltenKernelPickerBorder,CursorLine:Visual"
  vim.api.nvim_win_set_cursor(win, { 4, 0 })

  vim.api.nvim_buf_add_highlight(buf, -1, "MoltenKernelPickerTitle", 0, 2, -1)
  vim.api.nvim_buf_add_highlight(buf, -1, "MoltenKernelPickerMuted", 1, 2, -1)
  vim.api.nvim_buf_add_highlight(buf, -1, "MoltenKernelPickerMuted", #lines - 1, 2, -1)
  for index, choice in ipairs(choices) do
    local line = index + 2
    vim.api.nvim_buf_add_highlight(buf, -1, "MoltenKernelPickerNumber", line, 2, 3)
    vim.api.nvim_buf_add_highlight(
      buf,
      -1,
      choice.shared and "MoltenKernelPickerShared" or "MoltenKernelPickerNew",
      line,
      5,
      12
    )
    vim.api.nvim_buf_add_highlight(buf, -1, "MoltenKernelPickerName", line, 14, -1)
  end

  local function selected_choice()
    local line = vim.api.nvim_win_get_cursor(win)[1]
    local index = line - 3
    return choices[index]
  end

  local function move(delta)
    local line = vim.api.nvim_win_get_cursor(win)[1]
    line = math.min(math.max(line + delta, 4), #choices + 3)
    vim.api.nvim_win_set_cursor(win, { line, 0 })
  end

  local map_opts = { buffer = buf, nowait = true, silent = true }
  vim.keymap.set("n", "<CR>", function()
    close_picker(win, callback, selected_choice())
  end, map_opts)
  for _, key in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", key, function()
      close_picker(win, callback)
    end, map_opts)
  end
  for _, key in ipairs({ "j", "<Down>" }) do
    vim.keymap.set("n", key, function()
      move(1)
    end, map_opts)
  end
  for _, key in ipairs({ "k", "<Up>" }) do
    vim.keymap.set("n", key, function()
      move(-1)
    end, map_opts)
  end
  for index = 1, math.min(#choices, 9) do
    vim.keymap.set("n", tostring(index), function()
      close_picker(win, callback, choices[index])
    end, map_opts)
  end

  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(win),
    once = true,
    callback = function()
      prompt_active = false
    end,
  })
end

function M.init(choice)
  if choice.shared then
    vim.api.nvim_cmd({ cmd = "MoltenInit", args = { "shared", choice.name } }, {})
  else
    vim.api.nvim_cmd({ cmd = "MoltenInit", args = { choice.name } }, {})
  end
end

function M.with_kernel(run)
  local kernels = M.buffer_kernels()
  if #kernels > 0 then
    run(kernels[1])
    return
  end

  local choices = available_kernel_choices()
  if #choices == 0 then
    notify_kernel_missing()
    return
  end

  local function launch(choice)
    if not choice then
      return
    end

    if choice.shared then
      M.init(choice)
      vim.schedule(function()
        run(choice.name)
      end)
      return
    end

    vim.api.nvim_create_autocmd("User", {
      pattern = "MoltenKernelReady",
      once = true,
      callback = function(event)
        run(event.data.kernel_id)
      end,
    })
    M.init(choice)
  end

  if #choices == 1 then
    vim.notify("Starting kernel: " .. choices[1].name, vim.log.levels.INFO)
    launch(choices[1])
    return
  end

  pick_kernel(choices, launch)
end

function M.prompt_init(kernels, title)
  local choices = vim.tbl_map(function(kernel)
    return { name = kernel[1], shared = kernel[2] }
  end, kernels)

  pick_kernel(choices, function(choice)
    if choice then
      M.init(choice)
    end
  end, title or "Choose a kernel to start")
end

function M.prompt_init_and_run(kernels, title, command)
  if title == "You Need to Initialize a Kernel First:" then
    title = "Choose a kernel to start"
  end

  local choices = vim.tbl_map(function(kernel)
    return { name = kernel[1], shared = kernel[2] }
  end, kernels)

  pick_kernel(choices, function(choice)
    if not choice then
      return
    end

    if choice.shared then
      M.init(choice)
      vim.schedule(function()
        vim.cmd(command:gsub("%%k", choice.name))
      end)
      return
    end

    vim.api.nvim_create_autocmd("User", {
      pattern = "MoltenKernelReady",
      once = true,
      callback = function(event)
        vim.cmd(command:gsub("%%k", event.data.kernel_id))
      end,
    })
    M.init(choice)
  end, title)
end

return M
