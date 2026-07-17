return {
	"yetone/avante.nvim",
	event = "VeryLazy",
	build = "make",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"stevearc/dressing.nvim",
		{ "nvim-lua/plenary.nvim", branch = "master" },
		"MunifTanjim/nui.nvim",
		"folke/snacks.nvim",
	},
	opts = {
		provider = "openai_compatible",
		providers = {
			openai_compatible = {
				__inherited_from = "openai",
				api_key_name = "",
				endpoint = "http://192.168.1.225:8080/v1",
				model = "local",
				timeout = 30000,
				extra_request_body = {
					temperature = 0,
					max_tokens = 4096,
				},
			},
		},
		behaviour = {
			auto_suggestions = false,
			auto_set_highlight_group = true,
			auto_set_keymaps = true,
			auto_apply_diff_after_generation = false,
			support_paste_from_clipboard = true,
		},
		mappings = {
			ask = "<leader>aa",
			edit = "<leader>ae",
			refresh = "<leader>ar",
			diff = {
				ours = "co",
				theirs = "ct",
				all_theirs = "ca",
				both = "cb",
				cursor = "cc",
				next = "]x",
				prev = "[x",
			},
			suggestion = {
				accept = "<M-l>",
				next = "<M-]>",
				prev = "<M-[>",
				dismiss = "<C-]>",
			},
			jump = {
				next = "]]",
				prev = "[[",
			},
			submit = {
				normal = "<CR>",
				insert = "<C-s>",
			},
		},
		hints = {
			enabled = false,
		},
		windows = {
			position = "right",
			wrap = true,
			width = 40,
			sidebar_header = {
				enabled = true,
				align = "center",
				rounded = true,
			},
			input = {
				prefix = "> ",
				height = 8,
			},
			edit = {
				border = "rounded",
				start_insert = true,
			},
			ask = {
				floating = false,
				start_insert = true,
				border = "rounded",
			},
		},
		highlights = {
			diff = {
				current = "DiffText",
				incoming = "DiffAdd",
			},
		},
		diff = {
			autojump = true,
			list_opener = "copen",
			override_timeoutlen = 500,
		},
	},
}
