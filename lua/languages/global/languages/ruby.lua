-- Install Lsp server
-- :LspInstall solargraph

-- Install debugger
-- :DIInstall ruby_vsc
-- Do not forget to add `ruby-debug-ide` gem to your bundle or system!
-- gem install ruby-debug-ide

local global = require("core.global")
local funcs = require("core.funcs")
local languages_setup = require("languages.global.utils")
local nvim_lsp_util = require("lspconfig/util")
local lsp_signature = require("lsp_signature")
local default_debouce_time = 150
local dap_install = require("dap-install")
local dap = require("dap")

local language_configs = {}

language_configs["lsp"] = function()
	local function start_solargraph(server)
		server:setup({
			flags = {
				debounce_text_changes = default_debouce_time,
			},
			autostart = true,
			filetypes = { "ruby" },
			on_attach = function(client, bufnr)
				table.insert(global["languages"]["ruby"]["pid"], client.rpc.pid)
				if client.resolved_capabilities.document_formatting then
					vim.api.nvim_exec(
						[[
                        augroup LspAutocommands
                            autocmd! * <buffer>
                            autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync()
                        augroup END
                        ]],
						true
					)
				end
				vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
				lsp_signature.on_attach(languages_setup.config_lsp_signature)
				languages_setup.document_highlight(client)
			end,
			capabilities = languages_setup.get_capabilities(),
			root_dir = function(fname)
				return nvim_lsp_util.find_git_ancestor(fname) or vim.fn.getcwd()
			end,
		})
	end
	languages_setup.setup_lsp("solargraph", start_solargraph)
end

language_configs["dap"] = function()
	if funcs.dir_exists(global.lsp_path .. "dapinstall/ruby_vsc/") ~= true then
		vim.cmd("DIInstall ruby_vsc")
	end
	dap_install.config("ruby_vsc", {})
	dap.configurations.ruby = {
		{
			type = "ruby",
			name = "Launch",
			request = "launch",
			program = function()
				return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
			end,
		},
	}
end

return language_configs
