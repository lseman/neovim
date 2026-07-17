return {
	"folke/trouble.nvim",
	cmd = "Trouble",
	opts = {
		modes = {
			diagnostics = {
				auto_close = false,
				auto_open = false,
				focus = false,
			},
		},
		icons = {
			indent = { fold_open = "", fold_closed = "" },
		},
		sort_by = "severity",
	},
	keys = {
		{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
		{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
		{ "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols" },
		{ "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP Info" },
	},
}
