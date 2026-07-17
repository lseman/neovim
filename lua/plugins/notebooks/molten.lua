local function current_cell_bounds()
	local start = vim.fn.search("^# %%", "bcnW")
	local stop = vim.fn.search("^# %%", "nW")

	if start == 0 then
		start = 1
	end

	if stop == 0 then
		stop = vim.api.nvim_buf_line_count(0)
	else
		stop = stop - 1
	end

	return start, stop
end

local function evaluate_line()
	require("config.molten_kernel").with_kernel(function(kernel)
		vim.api.nvim_cmd({ cmd = "MoltenEvaluateLine", args = { kernel } }, {})
	end)
end

local function evaluate_current_cell()
	require("config.molten_kernel").with_kernel(function(kernel)
		local start, stop = current_cell_bounds()
		local ok, err = pcall(vim.fn.MoltenEvaluateRange, kernel, start, stop)
		if not ok then
			vim.notify("Molten range evaluation failed: " .. tostring(err), vim.log.levels.ERROR)
		end
	end)
end

local function evaluate_all_cells()
	require("config.molten_kernel").with_kernel(function(kernel)
		local line_count = vim.api.nvim_buf_line_count(0)
		local markers = {}

		for line = 1, line_count do
			if vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]:match("^# %%") then
				markers[#markers + 1] = line
			end
		end

		if #markers == 0 then
			local ok, err = pcall(vim.fn.MoltenEvaluateRange, kernel, 1, line_count)
			if not ok then
				vim.notify("Molten range evaluation failed: " .. tostring(err), vim.log.levels.ERROR)
			end
			return
		end

		if markers[1] > 1 then
			table.insert(markers, 1, 1)
		end

		for index, start in ipairs(markers) do
			local stop = markers[index + 1] and markers[index + 1] - 1 or line_count
			local ok, err = pcall(vim.fn.MoltenEvaluateRange, kernel, start, stop)
			if not ok then
				vim.notify("Molten range evaluation failed: " .. tostring(err), vim.log.levels.ERROR)
				return
			end
		end
	end)
end

local function evaluate_visual()
	require("config.molten_kernel").with_kernel(function(kernel)
		vim.api.nvim_cmd({ cmd = "MoltenEvaluateVisual", args = { kernel } }, {})
	end)
end

local function is_quarto_buffer()
	return vim.bo.filetype == "quarto" or vim.bo.filetype == "qmd"
end

local function run_current_notebook_cell()
	if is_quarto_buffer() then
		require("config.molten_kernel").with_kernel(function()
			require("quarto.runner").run_cell()
		end)
		return
	end

	evaluate_current_cell()
end

local function run_all_notebook_cells()
	if is_quarto_buffer() then
		require("config.molten_kernel").with_kernel(function()
			require("quarto.runner").run_all()
		end)
		return
	end

	evaluate_all_cells()
end

return { -- 1) Molten
	{
		"benlubas/molten-nvim",
		dependencies = { "folke/snacks.nvim" },
		-- Remote plugins auto-register in Neovim 0.10+ (no UpdateRemotePlugins needed).
		-- Do NOT use `cmd` here — it creates lazy stubs that shadow the real
		-- remote-plugin commands.  Load eagerly on notebook/python filetypes.
		lazy = false,
		init = function()
			-- Output window behaviour
			vim.g.molten_auto_open_output = true
			vim.g.molten_auto_close_output = false
			vim.g.molten_enter_output_behavior = "open_then_enter"
			vim.g.molten_auto_init_behavior = "raise"

			-- Output window appearance
			vim.g.molten_output_win_max_height = 20
			vim.g.molten_output_win_max_width = 100
			vim.g.molten_output_win_border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
			vim.g.molten_output_win_style = "minimal" -- cleaner float (no statusline, etc.)
			vim.g.molten_output_win_cover_gutter = false
			vim.g.molten_use_border_highlights = true -- use highlight groups for border colours

			-- Virtual-text inline summary
			vim.g.molten_virt_text_output = true
			vim.g.molten_virt_lines_off_screen = true -- keep virt lines even when cell is off-screen
			vim.g.molten_virt_text_max_lines = 20 -- more lines visible in the inline summary
			vim.g.molten_output_virt_lines = true
			vim.g.molten_output_show_more = true -- show "N more lines" indicator when truncated
			vim.g.molten_wrap_output = true

			-- Images
			vim.g.molten_image_provider = "snacks.nvim"
			vim.g.molten_auto_image_popup = true
			vim.g.molten_image_location = "both" -- show inline AND in popup
			vim.g.molten_save_path = vim.fn.stdpath("data") .. "/molten"

			-- Performance
			vim.g.molten_tick_rate = 150
			vim.g.molten_copy_output = false
		end,
		config = function()
			local kernel = require("config.molten_kernel")
			local prompt = require("prompt")
			prompt.prompt_init = kernel.prompt_init
			prompt.prompt_init_and_run = kernel.prompt_init_and_run

			vim.g._prompt_init = prompt.prompt_init
			vim.g._prompt_init_and_run = prompt.prompt_init_and_run

			local function state_path()
				local file = vim.api.nvim_buf_get_name(0)
				local name = file ~= "" and vim.fn.fnamemodify(file, ":t:r") or "scratch"
				local safe = name:gsub("[^%w_.-]", "_")
				vim.fn.mkdir(vim.g.molten_save_path, "p")
				return vim.g.molten_save_path .. "/" .. safe .. ".json"
			end

			vim.api.nvim_create_user_command("NotebookMode", function()
				vim.opt_local.spell = false
				vim.opt_local.conceallevel = 0
				pcall(vim.cmd, "RenderMarkdown buf_disable")
				pcall(function()
					require("quarto").activate()
				end)
				vim.notify("Notebook mode ready. Use :MoltenInit to pick a kernel.", vim.log.levels.INFO)
			end, {
				desc = "Prepare current buffer for notebook work",
			})

			vim.api.nvim_create_user_command("MoltenStateSave", function()
				vim.cmd("MoltenSave " .. vim.fn.fnameescape(state_path()))
			end, {
				desc = "Save Molten state for this buffer",
			})

			vim.api.nvim_create_user_command("MoltenStateLoad", function()
				vim.cmd("MoltenLoad " .. vim.fn.fnameescape(state_path()))
			end, {
				desc = "Load Molten state for this buffer",
			})
		end,
		keys = {
			{
				"<leader>mi",
				"<cmd>MoltenInit<CR>",
				desc = "Molten Init (select kernel)",
			},
			{
				"<leader>ml",
				evaluate_line,
				desc = "Evaluate current line",
			},
			{
				"<leader>mo",
				"<cmd>MoltenShowOutput<CR>",
				desc = "Show/enter output window",
			},
			{
				"<leader>mh",
				"<cmd>MoltenHideOutput<CR>",
				desc = "Hide output window",
			},
			{
				"<leader>md",
				"<cmd>MoltenDelete<CR>",
				desc = "Delete current cell output",
			},
			{
				"<leader>mr",
				"<cmd>MoltenReevaluateCell<CR>",
				desc = "Re-evaluate cell",
			},
			{
				"<leader>mc",
				evaluate_visual,
				mode = "v",
				desc = "Evaluate visual selection",
			},
			{
				"<leader>ms",
				"<cmd>MoltenStateSave<CR>",
				desc = "Save Molten state",
			},
			{
				"<leader>mL",
				"<cmd>MoltenStateLoad<CR>",
				desc = "Load Molten state",
			},
			{
				"<leader>mn",
				"<cmd>NotebookMode<CR>",
				desc = "Notebook mode",
			},
			{
				"<leader>mR",
				"<cmd>MoltenRestart!<CR>",
				desc = "Restart kernel (clear outputs)",
			},
			{
				"<leader>mI",
				"<cmd>MoltenInterrupt<CR>",
				desc = "Interrupt kernel",
			},
			{
				"<leader>mm",
				evaluate_current_cell,
				desc = "Run current %% cell",
			},
			{
				"<F5>",
				run_current_notebook_cell,
				desc = "Run current notebook cell (F5)",
			},
			{
				"<F10>",
				run_all_notebook_cells,
				desc = "Run all notebook cells (F10)",
			},
		},
	},
}
