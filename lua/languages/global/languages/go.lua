-- Install Lsp server
-- :LspInstall gopls

-- Install debugger
-- :DIInstall go_delve

local global = require("core.global")
local funcs = require("core.funcs")
local languages_setup = require("languages.global.utils")
local nvim_lsp_util = require("lspconfig/util")
local default_debouce_time = 150
local dap_install = require("dap-install")
local dap = require("dap")

local language_configs = {}

language_configs["lsp"] = function()
	local function start_gopls(server)
		server:setup({
			flags = {
				debounce_text_changes = default_debouce_time,
			},
			autostart = true,
			filetypes = { "go", "gomod" },
			on_attach = function(client, bufnr)
				table.insert(global["languages"]["go"]["pid"], client.rpc.pid)
				vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
				languages_setup.document_highlight(client)
				languages_setup.document_formatting(client)
			end,
			capabilities = languages_setup.get_capabilities(),
			root_dir = function(fname)
				return nvim_lsp_util.find_git_ancestor(fname) or vim.fn.getcwd()
			end,
		})
	end
	languages_setup.setup_lsp("gopls", start_gopls)
end

language_configs["dap"] = function()
	if funcs.dir_exists(global.lsp_path .. "dapinstall/go_delve/") ~= true then
		vim.cmd("DIInstall go_delve")
	end
	dap_install.config("go_delve", {})
	dap.adapters.go = function(callback)
		local handle
		local port = 38697
		handle = vim.loop.spawn("dlv", {
			args = { "dap", "-l", "127.0.0.1:" .. port },
			detached = true,
		}, function(code)
			handle:close()
			print("Delve exited with exit code: " .. code)
		end)
		vim.defer_fn(function()
			callback({ type = "server", host = "127.0.0.1", port = port })
		end, 100)
	end
	dap.configurations.go = {
		{
			type = "go",
			name = "Launch",
			request = "launch",
			program = function()
				return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
			end,
		},
		{
			type = "go",
			name = "Launch test",
			request = "launch",
			mode = "test",
			program = function()
				return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
			end,
		},
	}
end

return language_configs
