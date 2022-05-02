local funcs = require("core.funcs")
local lvim = require("configs.global.lvim")
local keymaps = require("configs.global.keymaps")
local group = vim.api.nvim_create_augroup("LvimIDE", {
	clear = true,
})

local configs = {}

configs["group"] = group

configs["vim_global"] = function()
	lvim.global()
	lvim.set()
end

configs["events_global"] = function()
	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "dart", "ruby", "yaml", "c", "cpp", "objc", "objcpp" },
		command = "setlocal ts=2 sw=2",
		group = group,
	})
	vim.api.nvim_create_autocmd("FileType", {
		pattern = {
			"help",
			"Trouble",
			"Outline",
			"git",
			"dapui_scopes",
			"dapui_breakpoints",
			"dapui_stacks",
			"dapui_watches",
			"NeogitStatus",
		},
		command = "setlocal colorcolumn=0 nocursorcolumn",
		group = group,
	})
	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "dashboard" },
		command = "setlocal nowrap",
		group = group,
	})
	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "org" },
		command = "setlocal foldmethod=expr",
		group = group,
	})
	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "org" },
		command = "setlocal foldexpr=nvim_treesitter#foldexpr()",
		group = group,
	})
end

configs["languages_global"] = function()
	vim.api.nvim_create_autocmd("BufWinEnter", {
		pattern = "*",
		command = 'lua require("languages.global").setup()',
		group = group,
	})
end

configs["commands_global"] = function()
	vim.cmd('command! SetGlobalPath lua require("core.funcs").set_global_path()')
	vim.cmd('command! SetWindowPath lua require("core.funcs").set_window_path()')
end

configs["keymaps_global"] = function()
	funcs.keymaps("n", { noremap = false, silent = true }, keymaps.normal)
	funcs.keymaps("x", { noremap = false, silent = true }, keymaps.visual)
end

configs["common_global"] = function()
	vim.g.indent_blankline_char = "▏"
	vim.g.indentLine_char = "▏"
	vim.g.gitblame_enabled = 0
	vim.g.gitblame_highlight_group = "CursorLine"
end

configs["ctrlspace_pre_config_global"] = function()
	vim.g.ctrlspace_use_tablineend = 1
	vim.g.CtrlSpaceLoadLastWorkspaceOnStart = 1
	vim.g.CtrlSpaceSaveWorkspaceOnSwitch = 1
	vim.g.CtrlSpaceSaveWorkspaceOnExit = 1
	vim.g.CtrlSpaceUseTabline = 0
	vim.g.CtrlSpaceUseArrowsInTerm = 1
	vim.g.CtrlSpaceUseMouseAndArrowsInTerm = 1
	vim.g.CtrlSpaceGlobCommand = "rg --files --follow --hidden -g '!{.git/*,node_modules/*,target/*,vendor/*}'"
	vim.g.CtrlSpaceIgnoredFiles = "\v(tmp|temp)[\\/]"
	vim.g.CtrlSpaceSymbols = {
		CS = " ",
		Sin = "",
		All = "",
		Vis = "★",
		File = "",
		Tabs = "ﱡ",
		CTab = "ﱢ",
		NTM = "⁺",
		WLoad = "ﰬ",
		WSave = "ﰵ",
		Zoom = "",
		SLeft = "",
		SRight = "",
		BM = "",
		Help = "",
		IV = "",
		IA = "",
		IM = " ",
		Dots = "ﳁ",
	}
end

return configs
