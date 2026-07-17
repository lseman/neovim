return {
	"j-hui/fidget.nvim",
	version = "~1.1", -- pinned by :Lazy update
	event = "LspAttach",
	keys = {
		{
			"<leader>lp",
			function()
				require("fidget.progress").suppress()
			end,
			desc = "Toggle LSP Progress HUD",
		},
		{
			"<leader>lh",
			function()
				require("fidget.notification").show_history()
			end,
			desc = "Fidget History",
		},
		{
			"<leader>lH",
			function()
				require("fidget.notification").clear_history()
			end,
			desc = "Clear Fidget History",
		},
		{
			"<leader>lc",
			function()
				require("fidget.notification").clear()
			end,
			desc = "Clear Active Progress",
		},
	},
	opts = function()
		local progress_display = require("fidget.progress.display")
		local spinner = require("fidget.spinner")

		return {
			progress = {
				poll_rate = 0,
				suppress_on_insert = true,
				ignore_done_already = true,
				ignore_empty_message = true,
				display = {
					render_limit = 6,
					done_ttl = 2,
					done_icon = "",
					progress_icon = {
						pattern = "dots",
						period = 1.6,
					},
					progress_style = "Special",
					done_style = "Constant",
					group_style = "Title",
					icon_style = "SpecialComment",
					priority = 40,
					format_message = function(msg)
						local message = msg.message

						if not message or message == "" then
							message = msg.done and "Completed" or "Working..."
						end

						if type(msg.percentage) == "number" then
							message = string.format("%s %d%%", message, msg.percentage)
						end

						return message
					end,
					format_annote = function(msg)
						if msg.title and msg.title ~= "" then
							return msg.title
						end
						return msg.lsp_client.name
					end,
					overrides = {
						clangd = {
							icon = progress_display.for_icon(spinner.animate("meter", 1.4), ""),
						},
						basedpyright = {
							name = "basedpyright",
							icon = progress_display.for_icon(spinner.animate("dots", 1.6), ""),
						},
						rust_analyzer = {
							name = "rust-analyzer",
							icon = progress_display.for_icon(spinner.animate("dots", 1.6), ""),
						},
					},
				},
			},
			notification = {
				override_vim_notify = false,
				window = {
					normal_hl = "NormalFloat",
					winblend = 8,
					border = "rounded",
					zindex = 45,
					x_padding = 1,
					y_padding = 1,
					align = "bottom",
					relative = "editor",
				},
				view = {
					stack_upwards = true,
					icon_separator = " ",
					group_separator = " ",
				},
			},
		}
	end,
}
