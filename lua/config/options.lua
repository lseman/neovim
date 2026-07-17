-- Native OSC52 clipboard (works over SSH/tmux without extra tools)
vim.g.clipboard = {
	name = "OSC52",
	copy = {
		["+"] = require("vim.ui.clipboard.osc52").copy("+"),
		["*"] = require("vim.ui.clipboard.osc52").copy("*"),
	},
	paste = {
		["+"] = require("vim.ui.clipboard.osc52").paste("+"),
		["*"] = require("vim.ui.clipboard.osc52").paste("*"),
	},
}

-- ============================
-- Editor Option Groups
-- ============================

local ui_options = {
	number = true,
	relativenumber = false,
	showmatch = true,
	termguicolors = true,
	showbreak = "↳ ",
	breakindent = true,
	linebreak = true,
	wrap = true,
	mouse = "a",
	clipboard = "unnamedplus",
	signcolumn = "yes",
	scrolloff = 5,
	sidescrolloff = 8,
	splitkeep = "screen",
	confirm = true,
	smoothscroll = true, -- native smooth scrolling (0.10+)
	splitright = true,
	splitbelow = true,
	virtualedit = "block", -- free cursor in visual-block mode
	jumpoptions = "view", -- restore view on <C-o>/<C-i> (0.10+)
	exrc = true, -- allow project-local .nvim.lua config (0.10+)
	laststatus = 3,
	winborder = "rounded",
}

local search_options = {
	ignorecase = true,
	smartcase = true,
	hlsearch = true,
	incsearch = true,
}

local indent_options = {
	tabstop = 4,
	softtabstop = 4,
	shiftwidth = 4,
	expandtab = true,
	autoindent = true,
	smartindent = true,
	shiftround = true,
}

local completion_options = {
	wildmode = "longest,list,full",
	pumheight = 10,
	completeopt = "menu,menuone,noselect",
	inccommand = "split",
}

local file_options = {
	backup = false,
	swapfile = false,
	undofile = true,
	writebackup = false,
}

local performance_options = {
	hidden = true,
	history = 100,
	synmaxcol = 240,
	updatetime = 200, -- faster completion/CursorHold trigger
	timeoutlen = 300,
}

-- ============================
-- Apply All Options
-- ============================

local function apply_options(opts)
	for key, value in pairs(opts) do
		vim.opt[key] = value
	end
end

for _, opts in ipairs({
	ui_options,
	search_options,
	indent_options,
	completion_options,
	file_options,
	performance_options,
}) do
	apply_options(opts)
end

local undodir = vim.fs.joinpath(vim.fn.stdpath("state"), "undo")
vim.fn.mkdir(undodir, "p")
vim.opt.undodir = undodir

if vim.fn.executable("rg") == 1 then
	vim.opt.grepprg = "rg --vimgrep --smart-case --hidden --glob=!.git"
	vim.opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
end

vim.opt.diffopt:append("linematch:60")
vim.opt.shortmess:append("Ic")
vim.opt.sessionoptions:append("globals")

-- ============================
-- nvim-ufo Folds
-- ============================
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.ufo.getFoldExpr()"
vim.opt.foldtext = ""
vim.opt.foldnestmax = 20
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldcolumn = "1"
