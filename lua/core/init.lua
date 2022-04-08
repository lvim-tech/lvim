local global = require("core.global")

if global == "unsuported" then
	print("Your OS is not supported!")
else
	local funcs = require("core.funcs")
	local vim = vim
	local createdir = function()
		local data_path = {
			global.cache_path .. "backup",
			global.cache_path .. "session",
			global.cache_path .. "swap",
			global.cache_path .. "tags",
			global.cache_path .. "undo",
		}
		if vim.fn.isdirectory(global.cache_dir) == 0 then
			os.execute("mkdir -p " .. global.cache_path)
		end
		for _, v in pairs(data_path) do
			if vim.fn.isdirectory(v) == 0 then
				os.execute("mkdir -p " .. v)
			end
		end
	end
	local leader_map = function()
		vim.g.mapleader = " "
		vim.api.nvim_set_keymap("n", " ", "", { noremap = true })
		vim.api.nvim_set_keymap("x", " ", "", { noremap = true })
	end
	global["diagnostics"] = {}
	global["diagnostics"]["path"] = vim.fn.getcwd()
	global["diagnostics"]["method"] = "global"
	local packer = require("core.pack")
	local load_ide = function()
		createdir()
		leader_map()
		packer.load_pack()
		funcs.configs()
	end
	load_ide()
end
