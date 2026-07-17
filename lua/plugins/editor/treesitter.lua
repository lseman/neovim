local treesitter_package = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy", "nvim-treesitter")

-- Neovim 0.13 ships some bundled parsers that can lag behind nvim-treesitter's
-- queries. Prepending the plugin directory makes parser/*.so and queries come
-- from the same source, which avoids runtime mismatches like Python's except*.
if vim.uv.fs_stat(treesitter_package) then
	vim.opt.runtimepath:prepend(treesitter_package)
end

local function apply_query_capture_compat()
	-- Neovim 0.12+ passes captures as TSNode lists; older nvim-treesitter expects single TSNode.
	-- These predicates/directives bridge the gap. Always apply — no harm on older Neovim.
	local ok, query = pcall(require, "vim.treesitter.query")
	if not ok then
		return
	end

	local ok, query = pcall(require, "vim.treesitter.query")
	if not ok then
		return
	end

	-- Neovim 0.12 passes captures to predicates/directives as TSNode lists.
	-- Older nvim-treesitter releases still expect a single TSNode.
	pcall(require, "nvim-treesitter.query_predicates")

	local function first_capture_node(match, capture_id)
		local capture = match[capture_id]
		if type(capture) ~= "table" then
			return capture
		end
		return capture[1]
	end

	local function valid_args(name, pred, count, strict_count)
		local arg_count = #pred - 1
		if strict_count then
			if arg_count ~= count then
				vim.api.nvim_err_writeln(string.format("%s must have exactly %d arguments", name, count))
				return false
			end
		elseif arg_count < count then
			vim.api.nvim_err_writeln(string.format("%s must have at least %d arguments", name, count))
			return false
		end
		return true
	end

	local html_script_type_languages = {
		["importmap"] = "json",
		["module"] = "javascript",
		["application/ecmascript"] = "javascript",
		["text/ecmascript"] = "javascript",
	}

	local non_filetype_match_injection_language_aliases = {
		ex = "elixir",
		pl = "perl",
		sh = "bash",
		uxn = "uxntal",
		ts = "typescript",
	}

	local function get_parser_from_markdown_info_string(injection_alias)
		local match = vim.filetype.match({
			filename = "a." .. injection_alias,
		})
		return match or non_filetype_match_injection_language_aliases[injection_alias] or injection_alias
	end

	query.add_predicate("nth?", function(match, _pattern, _bufnr, pred)
		if not valid_args("nth?", pred, 2, true) then
			return
		end

		local node = first_capture_node(match, pred[2])
		local n = tonumber(pred[3])
		if node and node:parent() and node:parent():named_child_count() > n then
			return node:parent():named_child(n) == node
		end

		return false
	end, {
		force = true,
	})

	query.add_predicate("is?", function(match, _pattern, bufnr, pred)
		if not valid_args("is?", pred, 2) then
			return
		end

		local locals = require("nvim-treesitter.locals")
		local node = first_capture_node(match, pred[2])
		local types = { unpack(pred, 3) }

		if not node then
			return true
		end

		local _, _, kind = locals.find_definition(node, bufnr)
		return vim.tbl_contains(types, kind)
	end, {
		force = true,
	})

	query.add_predicate("kind-eq?", function(match, _pattern, _bufnr, pred)
		if not valid_args(pred[1], pred, 2) then
			return
		end

		local node = first_capture_node(match, pred[2])
		local types = { unpack(pred, 3) }

		if not node then
			return true
		end

		return vim.tbl_contains(types, node:type())
	end, {
		force = true,
	})

	query.add_directive("set-lang-from-mimetype!", function(match, _, bufnr, pred, metadata)
		local capture_id = pred[2]
		local node = first_capture_node(match, capture_id)
		if not node then
			return
		end

		local type_attr_value = vim.treesitter.get_node_text(node, bufnr)
		local configured = html_script_type_languages[type_attr_value]
		if configured then
			metadata["injection.language"] = configured
		else
			local parts = vim.split(type_attr_value, "/", {})
			metadata["injection.language"] = parts[#parts]
		end
	end, {
		force = true,
	})

	query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
		local capture_id = pred[2]
		local node = first_capture_node(match, capture_id)
		if not node then
			return
		end

		local injection_alias = vim.treesitter.get_node_text(node, bufnr):lower()
		metadata["injection.language"] = get_parser_from_markdown_info_string(injection_alias)
	end, {
		force = true,
	})

	query.add_directive("downcase!", function(match, _, bufnr, pred, metadata)
		local capture_id = pred[2]
		local node = first_capture_node(match, capture_id)
		if not node then
			return
		end

		local capture_metadata = metadata[capture_id]
		local text = vim.treesitter.get_node_text(node, bufnr, {
			metadata = capture_metadata,
		}) or ""
		metadata[capture_id] = capture_metadata or {}
		metadata[capture_id].text = string.lower(text)
	end, {
		force = true,
	})
end

return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = {
		{
			"JoosepAlviste/nvim-ts-context-commentstring",
			opts = {
				enable_autocmd = false,
				languages = {
					javascript = {
						__default = "// %s",
						jsx_element = "{/* %s */}",
						jsx_fragment = "{/* %s */}",
						jsx_attribute = "// %s",
						comment = "// %s",
					},
					typescript = {
						__default = "// %s",
					},
					tsx = {
						__default = "// %s",
						jsx_element = "{/* %s */}",
						jsx_fragment = "{/* %s */}",
						jsx_attribute = "// %s",
					},
				},
			},
		}, -- Recommended replacement for built-in autotag
		{
			"windwp/nvim-ts-autotag",
			opts = {},
		},
	},

	opts = {
		parser_install_dir = treesitter_package,
		ensure_installed = { -- Core / always needed
			-- "vim" intentionally omitted: Neovim 0.12+ ships its own vim parser that matches
			-- its bundled queries. nvim-treesitter's vim.so is older and causes query errors.
			"c",
			"cpp",
			"lua",
			"vimdoc",
			"query", -- Docs & markup
			"markdown",
			"markdown_inline",
			"latex", -- Web / frontend
			"javascript",
			"typescript",
			"tsx",
			"html",
			"css", -- Scripting & data
			"bash",
			"regex",
			"json",
			"yaml",
			"toml", -- Build / config
			"cmake",
			"make",
			"dockerfile",
			"git_config",
			"git_rebase",
			"gitcommit",
			"gitignore",
			-- Optional popular additions (uncomment as needed)
			-- "rust", "go", "java", "php", "ruby", "sql",
			"python",
		},

		sync_install = false,
		-- Disable auto-install to avoid build failures when the local tree-sitter CLI
		-- is incompatible with the parser generator ABI.
		auto_install = false,
		ignore_install = {},

		highlight = {
			enable = true,
			disable = function(lang, buf)
				-- Large file protection (good!)
				local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
				if ok and stats and stats.size > 200 * 1024 then -- raised a bit
					return true
				end

				-- UI / special buffers
				local ft = vim.bo[buf].filetype
				local excluded = { "TelescopePrompt", "snacks_picker_list", "lazy", "mason", "alpha", "dashboard" }
				if vim.tbl_contains(excluded, ft) then
					return true
				end

				return false
			end,
			additional_vim_regex_highlighting = false,
		},

		indent = {
			enable = true,
		},

		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "<C-space>",
				node_incremental = "<C-space>",
				scope_incremental = "<C-s>",
				node_decremental = "<BS>",
			},
		},

		textobjects = {
			move = {
				enable = true,
				set_jumps = true,
				goto_next_start = {
					["]f"] = "@function.outer",
					["]F"] = "@function.outer",
					["]c"] = "@class.outer",
					["]C"] = "@class.outer",
					["]a"] = "@parameter.inner",
					["]A"] = "@parameter.outer",
					["]l"] = "@loop.outer",
					["]L"] = "@loop.outer",
					["]o"] = "@conditional.outer",
					["]O"] = "@conditional.outer",
					["]s"] = "@statement.outer",
					["]S"] = "@statement.outer",
					["]z"] = "@fold",
				},
				goto_next_end = {
					["]f"] = "@function.outer",
					["]c"] = "@class.outer",
				},
				goto_previous_start = {
					["[f"] = "@function.outer",
					["[F"] = "@function.outer",
					["[c"] = "@class.outer",
					["[C"] = "@class.outer",
					["[a"] = "@parameter.inner",
					["[A"] = "@parameter.outer",
					["[l"] = "@loop.outer",
					["[L"] = "@loop.outer",
					["[o"] = "@conditional.outer",
					["[O"] = "@conditional.outer",
					["[s"] = "@statement.outer",
					["[S"] = "@statement.outer",
				},
				goto_previous_end = {
					["[f"] = "@function.outer",
					["[c"] = "@class.outer",
				},
			},

			select = {
				enable = true,
				lookahead = true,
				include_surrounding_whitespace = false,
				keymaps = {
					-- Functions & calls
					["af"] = "@function.outer",
					["if"] = "@function.inner",
					["aF"] = "@call.outer",
					["iF"] = "@call.inner",
					-- Classes
					["ac"] = "@class.outer",
					["ic"] = "@class.inner",
					-- Parameters
					["aa"] = "@parameter.outer",
					["ia"] = "@parameter.inner",
					-- Loops & conditionals
					["al"] = "@loop.outer",
					["il"] = "@loop.inner",
					["ao"] = "@conditional.outer",
					["io"] = "@conditional.inner",
					-- Blocks
					["ab"] = "@block.outer",
					["ib"] = "@block.inner",
					-- Comments
					["am"] = "@comment.outer",
					["a/"] = "@comment.outer",
					-- Scope
					["as"] = {
						query = "@scope",
						query_group = "locals",
						desc = "Select scope",
					},
				},
				selection_modes = {
					["@parameter.outer"] = "v",
					["@function.outer"] = "V",
					["@class.outer"] = "<C-v>",
				},
			},

			swap = {
				enable = true,
				swap_next = {
					["<leader>a]"] = "@parameter.inner",
					["<leader>f]"] = "@function.outer",
				},
				swap_previous = {
					["<leader>a["] = "@parameter.inner",
					["<leader>f["] = "@function.outer",
				},
			},

			lsp_interop = {
				enable = true,
				border = "rounded",
				floating_preview_opts = {},
				peek_definition_code = {
					["<leader>df"] = "@function.outer",
					["<leader>dF"] = "@class.outer",
				},
			},
		},
	},

	config = function(_, opts)
		apply_query_capture_compat()
		require("nvim-treesitter.configs").setup(opts)
	end,
}
