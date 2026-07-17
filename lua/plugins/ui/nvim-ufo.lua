return {
	"kevinhwang91/nvim-ufo",
	event = "VeryLazy",
	dependencies = "kevinhwang91/promise-async",
	keys = {
		{
			"zI",
			function()
				local ok, ufo = pcall(require, "ufo")
				if ok then
					return ufo.openAllFolds()
				end
				return "zI"
			end,
			mode = "n",
			noremap = true,
			silent = true,
			desc = "Ufo: Open all folds",
		},
		{
			"zM",
			function()
				local ok, ufo = pcall(require, "ufo")
				if ok then
					return ufo.closeAllFolds()
				end
				return "zM"
			end,
			mode = "n",
			noremap = true,
			silent = true,
			desc = "Ufo: Close all folds",
		},
	},
	config = function(_, opts)
		vim.b.ufo = true
		require("ufo").setup(opts)
	end,
	opts = {
		provider_selector = function(_, filetype, buftype)
			if buftype == "nofile" or buftype == "terminal" or
			   (filetype and vim.tbl_contains({
				   "nofile",
				   "help",
				   "qf",
				   "netrw",
				   "NvimTree",
				   "neo-tree",
				   "yazi",
			   }, filetype)) then
				return nil
			end
			return "treesitter"
		end,

		open_fold_hl_timeout = 200,
		close_fold_kinds_for_ft = { default = { "imports", "comments" } },
		preview = {
			mappings = {
				scrollU = "<C-u>",
				scrollD = "<C-d>",
				jumpUp = "k",
				jumpDown = "j",
			},
		},

		fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
			local newVirtText = {}
			local suffix = (" 󰁂 %d "):format(endLnum - lnum)
			local sufWidth = vim.fn.strdisplaywidth(suffix)
			local targetWidth = width - sufWidth
			local curWidth = 0
			for _, chunk in ipairs(virtText) do
				local chunkWidth = vim.fn.strdisplaywidth(chunk[1])
				if curWidth + chunkWidth > targetWidth then
					table.insert(newVirtText, {
						chunk[1] .. string.rep(".", chunkWidth - (curWidth + chunkWidth - targetWidth)),
						chunk[2],
					})
					break
				end
				table.insert(newVirtText, chunk)
				curWidth = curWidth + chunkWidth
			end
			table.insert(newVirtText, { suffix, "UfoFoldedEllipsis" })
			return newVirtText
		end,
	},
}
