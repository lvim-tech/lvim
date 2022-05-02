local config = {}

function config.lvim_colorscheme()
	vim.cmd("colorscheme lvim")
end

function config.dashboard_nvim()
	vim.g.dashboard_custom_header = {
		"       888     Y88b      / 888      e    e             ",
		"       888      Y88b    /  888     d8b  d8b            ",
		"       888       Y88b  /   888    d888bdY88b           ",
		"       888        Y888/    888   / Y88Y Y888b          ",
		"       888         Y8/     888  /   YY   Y888b         ",
		"       888____      Y      888 /          Y888b        ",
	}
	vim.g.dashboard_preview_file_height = 12
	vim.g.dashboard_preview_file_width = 80
	vim.g.dashboard_custom_section = {
		a = {
			description = { "     Projects                 " },
			command = "CtrlSpace b",
		},
		b = {
			description = { "     File explorer            " },
			command = "TelescopeBrowser",
		},
		c = {
			description = { "     Search file              " },
			command = "Telescope find_files",
		},
		d = {
			description = { "     Search in files          " },
			command = "Telescope live_grep",
		},
		e = {
			description = { "     Browser bookmarks        " },
			command = ":TelescopeBookmarks",
		},
		f = {
			description = { "     Help                     " },
			command = ":LvimHelper",
		},
		g = {
			description = { "     Settings                 " },
			command = ":e ~/.config/nvim/lua/configs/global/lvim.lua",
		},
		h = {
			description = { "     Readme                   " },
			command = ":e ~/.config/nvim/README.md",
		},
	}
end

function config.nvim_tree()
	vim.g.nvim_tree_show_icons = {
		git = 1,
		folders = 1,
		files = 1,
		folder_arrows = 0,
	}
	vim.g.nvim_tree_icons = {
		default = "",
		symlink = "",
		git = {
			unstaged = "",
			staged = "",
			unmerged = "",
			renamed = "➜",
			untracked = "",
			ignored = "◌",
		},
		folder = {
			default = "",
			open = "",
			empty = "",
			empty_open = "",
			symlink = "",
		},
	}
	require("nvim-tree").setup({
		update_cwd = true,
		update_focused_file = {
			enable = true,
		},
	})
end

function config.which_key()
	local options = {
		plugins = {
			marks = true,
			registers = true,
			presets = {
				operators = false,
				motions = false,
				text_objects = false,
				windows = false,
				nav = false,
				z = false,
				g = false,
			},
			spelling = {
				enabled = true,
				suggestions = 20,
			},
		},
		icons = {
			breadcrumb = "»",
			separator = "➜",
			group = "+",
		},
		window = {
			border = "single",
			position = "bottom",
			margin = {
				0,
				0,
				0,
				0,
			},
			padding = {
				2,
				2,
				2,
				2,
			},
		},
		layout = {
			height = {
				min = 4,
				max = 25,
			},
			width = {
				min = 20,
				max = 50,
			},
			spacing = 10,
		},
		hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " },
		show_help = true,
	}
	local nopts = {
		mode = "n",
		prefix = "<leader>",
		buffer = nil,
		silent = true,
		noremap = true,
		nowait = true,
	}
	local vopts = {
		mode = "v",
		prefix = "<leader>",
		buffer = nil,
		silent = true,
		noremap = true,
		nowait = true,
	}
	local nmappings = {
		e = { "<Cmd>NvimTreeToggle<CR>", "NvimTree toggle" },
		b = {
			name = "Buffers",
			n = { "<Cmd>BufSurfForward<CR>", "Next buffer" },
			p = { "<Cmd>BufSurfBack<CR>", "Prev buffer" },
			l = { "<Cmd>Telescope buffers<CR>", "List buffers" },
		},
		d = {
			name = "Database",
			u = { "<Cmd>DBUIToggle<CR>", "DB UI toggle" },
			f = { "<Cmd>DBUIFindBuffer<CR>", "DB find buffer" },
			r = { "<Cmd>DBUIRenameBuffer<CR>", "DB rename buffer" },
			l = { "<Cmd>DBUILastQueryInfo<CR>", "DB last query" },
		},
		p = {
			name = "Packer",
			c = { "<cmd>PackerCompile<CR>", "Compile" },
			i = { "<cmd>PackerInstall<CR>", "Install" },
			s = { "<cmd>PackerSync<CR>", "Sync" },
			S = { "<cmd>PackerStatus<CR>", "Status" },
			u = { "<cmd>PackerUpdate<CR>", "Update" },
		},
		P = {
			name = "Path",
			g = { "<Cmd>SetGlobalPath<CR>", "Set global path" },
			w = { "<Cmd>SetWindowPath<CR>", "Set window path" },
		},
		l = {
			name = "LSP",
			n = { "<Cmd>LspGoToNext<CR>", "Go to next" },
			p = { "<Cmd>LspGoToPrev<CR>", "Go to prev" },
			r = { "<Cmd>LspRename<CR>", "Rename" },
			h = { "<Cmd>LspHover<CR>", "Hover" },
			d = { "<Cmd>LspDefinition<CR>", "Definition" },
			t = { "<Cmd>LspTypeDefinition<CR>", "Type definition" },
			R = { "<Cmd>LspReferences<CR>", "References" },
			a = { "<Cmd>LspCodeAction<CR>", "Code action" },
			f = { "<Cmd>LspFormatting<CR>", "Formatting" },
			s = { "<Cmd>LspFormattingSync<CR>", "Sync formatting" },
			S = {
				name = "Symbol",
				d = { "<Cmd>LspDocumentSymbol<CR>", "Document symbol" },
				w = { "<Cmd>LspWorkspaceSymbol<CR>", "Workspace symbol" },
			},
			w = {
				"<Cmd>LspAddToWorkspaceFolder<CR>",
				"Add to workspace folder",
			},
			v = {
				name = "Virtualtext",
				s = { "<Cmd>LspVirtualTextShow<CR>", "Virtual text show" },
				h = { "<Cmd>LspVirtualTextHide<CR>", "Virtual text hide" },
			},
		},
		g = {
			name = "GIT",
			b = { "<Cmd>GitSignsBlameLine<CR>", "Blame" },
			B = { "<Cmd>GBrowse<CR>", "Browse" },
			d = { "<Cmd>Git diff<CR>", "Diff" },
			n = { "<Cmd>GitSignsNextHunk<CR>", "Next hunk" },
			p = { "<Cmd>GitSignsPrevHunk<CR>", "Prev hunk" },
			l = { "<Cmd>Git log<CR>", "Log" },
			P = { "<Cmd>GitSignsPreviewHunk<CR>", "Preview hunk" },
			r = { "<Cmd>GitSignsResetHunk<CR>", "Reset stage hunk" },
			s = { "<Cmd>GitSignsStageHunk<CR>", "Stage hunk" },
			u = { "<Cmd>GitSignsUndoStageHunk<CR>", "Undo stage hunk" },
			R = { "<Cmd>GitSignsResetBuffer<CR>", "Reset buffer" },
			S = { "<Cmd>Gstatus<CR>", "Status" },
			N = { "<Cmd>Neogit<CR>", "Neogit" },
		},
		m = {
			name = "Bookmark",
			t = { "<Cmd>BookmarkToggle<CR>", "Toggle bookmark" },
			n = { "<Cmd>BookmarkNext<CR>", "Next bookmark" },
			p = { "<Cmd>BookmarkPrev<CR>", "Prev bookmark" },
		},
		f = {
			name = "Find & Fold",
			f = { "<Cmd>HopWord<CR>", "Hop Word" },
			["]"] = { "<Cmd>HopChar1<CR>", "Hop Char1" },
			["["] = { "<Cmd>HopChar2<CR>", "Hop Char2" },
			l = { "<Cmd>HopLine<CR>", "Hop Line" },
			s = { "<Cmd>HopLineStart<CR>", "Hop Line Start" },
			m = { "<Cmd>:set foldmethod=manual<CR>", "Manual (default)" },
			i = { "<Cmd>:set foldmethod=indent<CR>", "Indent" },
			e = { "<Cmd>:set foldmethod=expr<CR>", "Expr" },
			d = { "<Cmd>:set foldmethod=diff<CR>", "Diff" },
			M = { "<Cmd>:set foldmethod=marker<CR>", "Marker" },
		},
		s = {
			name = "Spectre",
			d = {
				'<Cmd>lua require("spectre").delete()<CR>',
				"Toggle current item",
			},
			g = {
				'<Cmd>lua require("spectre.actions").select_entry()<CR>',
				"Goto current file",
			},
			q = {
				'<Cmd>lua require("spectre.actions").send_to_qf()<CR>',
				"Send all item to quickfix",
			},
			m = {
				'<Cmd>lua require("spectre.actions").replace_cmd()<CR>',
				"Input replace vim command",
			},
			o = {
				'<Cmd>lua require("spectre").show_options()<CR>',
				"show option",
			},
			R = {
				'<Cmd>lua require("spectre.actions").run_replace()<CR>',
				"Replace all",
			},
			v = {
				'<Cmd>lua require("spectre").change_view()<CR>',
				"Change result view mode",
			},
			c = {
				'<Cmd>lua require("spectre").change_options("ignore-case")<CR>',
				"Toggle ignore case",
			},
			h = {
				'<Cmd>lua require("spectre").change_options("hidden")<CR>',
				"Toggle search hidden",
			},
		},
		t = {
			name = "Telescope",
			b = { "<Cmd>Telescope file_browser<CR>", "File browser" },
			f = { "<Cmd>Telescope find_files<CR>", "Find files" },
			w = { "<Cmd>Telescope live_grep<CR>", "Live grep" },
			u = { "<Cmd>Telescope buffers<CR>", "Buffers" },
			m = { "<Cmd>Telescope marks<CR>", "Marks" },
			o = { "<Cmd>Telescope commands<CR>", "Commands" },
			y = { "<Cmd>Telescope symbols<CR>", "Symbols" },
			n = { "<Cmd>Telescope quickfix<CR>", "Quickfix" },
			c = { "<Cmd>Telescope git_commits<CR>", "Git commits" },
			B = { "<Cmd>Telescope git_bcommits<CR>", "Git bcommits" },
			r = { "<Cmd>Telescope git_branches<CR>", "Git branches" },
			s = { "<Cmd>Telescope git_status<CR>", "Git status" },
			S = { "<Cmd>Telescope git_stash<CR>", "Git stash" },
			i = { "<Cmd>Telescope git_files<CR>", "Git files" },
			M = { "<Cmd>Telescope media_files<CR>", "Media files" },
		},
	}
	local vmappings = {
		["/"] = { ":CommentToggle<CR>", "Comment" },
		f = { "<Cmd>LspRangeFormatting<CR>", "Range formatting" },
	}
	local which_key = require("which-key")
	which_key.setup(options)
	which_key.register(nmappings, nopts)
	which_key.register(vmappings, vopts)
end

function config.lualine()
	local lualine = require("lualine")
	local colors = {
		bg = "#272F35",
		darkbg = "#272F35",
		fg = "#D9DA9E",
		color_01 = "#E6B673",
		color_02 = "#00839F",
		color_03 = "#A7C080",
		color_04 = "#F2994B",
		color_05 = "#1C9898",
		color_06 = "#25B8A5",
		color_07 = "#90c1a3",
		color_08 = "#F05F4E",
	}
	local conditions = {
		buffer_not_empty = function()
			return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
		end,
		hide_in_width = function()
			return vim.fn.winwidth(0) > 120
		end,
		check_git_workspace = function()
			local filepath = vim.fn.expand("%:p:h")
			local gitdir = vim.fn.finddir(".git", filepath .. ";")
			return gitdir and #gitdir > 0 and #gitdir < #filepath
		end,
	}
	local lualine_config = {
		options = {
			component_separators = "",
			section_separators = "",
			theme = {
				normal = {
					a = { fg = colors.bg, bg = colors.bg },
					b = { fg = colors.bg, bg = colors.bg },
					c = { fg = colors.bg, bg = colors.bg },
					x = { fg = colors.bg, bg = colors.bg },
					y = { fg = colors.bg, bg = colors.bg },
					z = { fg = colors.bg, bg = colors.bg },
				},
			},
			globalstatus = 3,
		},
		sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = {},
			lualine_x = {},
			lualine_y = {},
			lualine_z = {},
		},
		extensions = { "nvim-tree", "symbols-outline", "toggleterm", "quickfix" },
	}
	local function ins_left_a(component)
		table.insert(lualine_config.sections.lualine_a, component)
	end
	local function ins_left_b(component)
		table.insert(lualine_config.sections.lualine_b, component)
	end
	local function ins_left_c(component)
		table.insert(lualine_config.sections.lualine_c, component)
	end
	local function ins_right(component)
		table.insert(lualine_config.sections.lualine_x, component)
	end
	ins_left_a({
		function()
			local alias = {
				n = "NORMAL",
				v = "VISUAL",
				V = "V-LINE",
				[""] = "V-BLOCK",
				s = "SELECT",
				S = "S-LINE",
				[""] = "S-BLOCK",
				i = "INSERT",
				R = "REPLACE",
				c = "COMMAND",
				r = "PROMPT",
				["!"] = "EXTERNAL",
				t = "TERMINAL",
			}
			local mode_color = {
				n = colors.color_03,
				i = colors.color_08,
				v = colors.color_04,
				[""] = colors.color_04,
				V = colors.color_04,
				c = colors.color_06,
				no = colors.color_08,
				s = colors.color_04,
				S = colors.color_04,
				[""] = colors.color_04,
				ic = colors.color_01,
				R = colors.color_05,
				Rv = colors.color_05,
				cv = colors.color_08,
				ce = colors.color_08,
				r = colors.color_02,
				rm = colors.color_02,
				["r?"] = colors.color_02,
				["!"] = colors.color_08,
				t = colors.color_08,
			}
			local vim_mode = vim.fn.mode()
			vim.api.nvim_command("hi! LualineMode guifg=" .. mode_color[vim.fn.mode()] .. " guibg=" .. colors.bg)
			return "   " .. alias[vim_mode]
		end,
		color = "LualineMode",
		padding = { right = 1 },
	})
	ins_left_b({
		"filetype",
		colored = false,
		icon_only = false,
		color = {
			fg = colors.color_07,
			gui = "bold",
		},
	})
	ins_left_c({
		"filename",
		cond = conditions.buffer_not_empty,
		color = {
			fg = colors.color_02,
			gui = "bold",
		},
		path = 2,
		shorting_target = 20,
	})
	ins_left_c({
		"diff",
		symbols = {
			added = "   ",
			modified = "  ",
			removed = "  ",
		},
		diff_color = {
			added = {
				fg = colors.color_03,
			},
			modified = {
				fg = colors.color_04,
			},
			removed = {
				fg = colors.color_08,
			},
		},
	})
	ins_left_c({
		"branch",
		icon = " ",
		color = {
			fg = colors.color_05,
			gui = "bold",
		},
		cond = conditions.hide_in_width,
	})
	ins_left_c({
		function()
			local package = require("package-info")
			return package.get_status()
		end,
		padding = {
			left = 0,
			right = 0,
		},
		color = {
			fg = colors.color_05,
		},
		cond = nil,
	})
	ins_right({
		"diagnostics",
		sources = {
			"nvim_diagnostic",
		},
		symbols = {
			error = " ",
			warn = " ",
			hint = " ",
			info = " ",
		},
		diagnostics_color = {
			error = {
				fg = colors.color_08,
			},
			warn = {
				fg = colors.color_04,
			},
			hint = {
				fg = colors.color_07,
			},
			info = {
				fg = colors.color_07,
			},
		},
	})
	ins_right({
		function(msg)
			msg = msg or ""
			local buf_clients = vim.lsp.buf_get_clients()
			if next(buf_clients) == nil then
				if type(msg) == "boolean" or #msg == 0 then
					return ""
				end
				return msg
			end
			local buf_client_names = {}
			for _, client in pairs(buf_clients) do
				table.insert(buf_client_names, client.name)
			end
			return table.concat(buf_client_names, ", ")
		end,
		icon = " ",
		cond = conditions.hide_in_width,
		color = {
			fg = colors.color_02,
			gui = "bold",
		},
	})
	ins_right({
		"o:encoding",
		fmt = string.upper,
		cond = conditions.hide_in_width,
		color = {
			fg = colors.color_03,
			gui = "bold",
		},
	})
	ins_right({
		"fileformat",
		fmt = string.upper,
		cond = conditions.hide_in_width,
		icons_enabled = true,
		padding = {
			left = 0,
			right = 2,
		},
		color = {
			fg = colors.color_03,
			gui = "bold",
		},
	})
	ins_right({
		function()
			local current_line = vim.fn.line(".")
			local total_lines = vim.fn.line("$")
			local chars = { "█", "▇", "▆", "▅", "▄", "▃", "▂", "▁" }
			local line_ratio = current_line / total_lines
			local index = math.ceil(line_ratio * #chars)
			return chars[index]
		end,
		padding = {
			left = 0,
			right = 0,
		},
		color = {
			fg = colors.color_08,
			bg = colors.darkbg,
		},
		cond = nil,
	})
	lualine.setup(lualine_config)
end

function config.fm()
	require("fm-nvim").setup({
		ui = {
			float = {
				border = "single",
				float_hl = "NormalFloat",
				border_hl = "FloatBorder",
				height = 0.95,
				width = 0.99,
			},
		},
		cmds = {
			vifm_cmd = "vifmrun",
		},
	})
end

function config.toggleterm()
	local terminal_float = require("toggleterm.terminal").Terminal:new({
		count = 4,
		direction = "float",
		float_opts = {
			border = "single",
			winblend = 0,
			width = vim.o.columns - 20,
			height = vim.o.lines - 9,
			highlights = {
				border = "FloatBorder",
				background = "NormalFloat",
			},
		},
		on_open = function(term)
			vim.api.nvim_buf_set_keymap(term.bufnr, "n", "<Esc>", "<cmd>close<cr>", { noremap = true, silent = true })
			vim.api.nvim_buf_set_keymap(
				term.bufnr,
				"t",
				"<Esc>",
				"<c-\\><c-n><cmd>close<cr><c-w><c-p>",
				{ noremap = true }
			)
			vim.wo.cursorcolumn = false
			vim.wo.cursorline = false
			vim.cmd("startinsert!")
		end,
		on_close = function()
			vim.cmd("quit!")
		end,
	})
	local terminal_one = require("toggleterm.terminal").Terminal:new({
		count = 1,
		direction = "horizontal",
		on_open = function(term)
			vim.api.nvim_buf_set_keymap(term.bufnr, "n", "<Esc>", "<cmd>close<cr>", { noremap = true, silent = true })
			vim.api.nvim_buf_set_keymap(
				term.bufnr,
				"t",
				"<Esc>",
				"<c-\\><c-n><cmd>close<cr><c-w><c-p>",
				{ noremap = true, silent = true }
			)
			vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-x>", "<c-\\><c-n>", { noremap = true, silent = true })
			vim.wo.cursorcolumn = false
			vim.wo.cursorline = false
			vim.cmd("startinsert!")
			vim.api.nvim_exec([[exe "normal \<C-W>\="]], true)
		end,
		on_close = function()
			vim.cmd("quit!")
		end,
	})
	local terminal_two = require("toggleterm.terminal").Terminal:new({
		count = 2,
		direction = "horizontal",
		on_open = function(term)
			vim.api.nvim_buf_set_keymap(term.bufnr, "n", "<Esc>", "<cmd>close<cr>", { noremap = true, silent = true })
			vim.api.nvim_buf_set_keymap(
				term.bufnr,
				"t",
				"<Esc>",
				"<c-\\><c-n><cmd>close<cr><c-w><c-p>",
				{ noremap = true, silent = true }
			)
			vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-x>", "<c-\\><c-n>", { noremap = true, silent = true })
			vim.wo.cursorcolumn = false
			vim.wo.cursorline = false
			vim.cmd("startinsert!")
			vim.api.nvim_exec([[exe "normal \<C-W>\="]], true)
		end,
		on_close = function()
			vim.cmd("quit!")
		end,
	})
	local terminal_three = require("toggleterm.terminal").Terminal:new({
		count = 3,
		direction = "horizontal",
		on_open = function(term)
			vim.api.nvim_buf_set_keymap(term.bufnr, "n", "<Esc>", "<cmd>close<cr>", { noremap = true, silent = true })
			vim.api.nvim_buf_set_keymap(
				term.bufnr,
				"t",
				"<Esc>",
				"<c-\\><c-n><cmd>close<cr><c-w><c-p>",
				{ noremap = true, silent = true }
			)
			vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-x>", "<c-\\><c-n>", { noremap = true, silent = true })
			vim.wo.cursorcolumn = false
			vim.wo.cursorline = false
			vim.cmd("startinsert!")
			vim.api.nvim_exec([[exe "normal \<C-W>\="]], true)
		end,
		on_close = function()
			vim.cmd("quit!")
		end,
	})
	function _G.toggleterm_float_toggle()
		terminal_float:toggle()
	end
	function _G.toggleterm_one_toggle()
		terminal_one:toggle()
	end
	function _G.toggleterm_two_toggle()
		terminal_two:toggle()
	end
	function _G.toggleterm_three_toggle()
		terminal_three:toggle()
	end
	vim.cmd("command! TTFloat lua _G.toggleterm_float_toggle()")
	vim.cmd("command! TTOne lua _G.toggleterm_one_toggle()")
	vim.cmd("command! TTTwo lua _G.toggleterm_two_toggle()")
	vim.cmd("command! TTThree lua _G.toggleterm_three_toggle()")
end

function config.zen_mode()
	require("zen-mode").setup({
		window = {
			options = {
				number = false,
				relativenumber = false,
			},
		},
		plugins = {
			gitsigns = {
				enabled = true,
			},
		},
	})
end

function config.twilight()
	require("twilight").setup({
		dimming = {
			alpha = 0.5,
		},
	})
end

function config.indent_blankline()
	require("indent_blankline").setup({
		char = "▏",
		show_first_indent_level = true,
		show_trailing_blankline_indent = true,
		show_current_context = true,
		context_patterns = {
			"class",
			"function",
			"method",
			"block",
			"list_literal",
			"selector",
			"^if",
			"^table",
			"if_statement",
			"while",
			"for",
		},
		filetype_exclude = {
			"startify",
			"dashboard",
			"dotooagenda",
			"log",
			"fugitive",
			"gitcommit",
			"packer",
			"vimwiki",
			"markdown",
			"json",
			"txt",
			"vista",
			"help",
			"todoist",
			"NvimTree",
			"peekaboo",
			"git",
			"TelescopePrompt",
			"undotree",
			"flutterToolsOutline",
		},
		buftype_exclude = {
			"terminal",
			"nofile",
		},
	})
end

function config.lvim_focus()
	require("lvim-focus").setup()
end

function config.lvim_helper()
	local global = require("core.global")
	require("lvim-helper").setup({
		files = {
			global.home .. "/.config/nvim/help/lvim_bindings_normal_mode.md",
			global.home .. "/.config/nvim/help/lvim_bindings_visual_mode.md",
			global.home .. "/.config/nvim/help/lvim_bindings_debug_dap.md",
			global.home .. "/.config/nvim/help/vim_cheat_sheet_global.md",
			global.home .. "/.config/nvim/help/vim_cheat_sheet_cursor_movement.md",
			global.home .. "/.config/nvim/help/vim_cheat_sheet_visual_mode.md",
			global.home .. "/.config/nvim/help/vim_cheat_sheet_visual_commands.md",
			global.home .. "/.config/nvim/help/vim_cheat_sheet_insert_mode.md",
			global.home .. "/.config/nvim/help/vim_cheat_sheet_editing.md",
			global.home .. "/.config/nvim/help/vim_cheat_sheet_registers.md",
			global.home .. "/.config/nvim/help/vim_cheat_sheet_marks_and_positions.md",
			global.home .. "/.config/nvim/help/vim_cheat_sheet_macros.md",
			global.home .. "/.config/nvim/help/vim_cheat_sheet_cut_and_paste.md",
			global.home .. "/.config/nvim/help/vim_cheat_sheet_indent_text.md",
			global.home .. "/.config/nvim/help/vim_cheat_sheet_exiting.md",
			global.home .. "/.config/nvim/help/vim_cheat_sheet_search_and_replace.md",
			global.home .. "/.config/nvim/help/vim_cheat_sheet_search_in_multiple_files.md",
			global.home .. "/.config/nvim/help/vim_cheat_sheet_tabs.md",
			global.home .. "/.config/nvim/help/vim_cheat_sheet_working_with_multiple_files.md",
			global.home .. "/.config/nvim/help/vim_cheat_sheet_diff.md",
		},
	})
end

return config
