-- Install Lsp server
-- :LspInstall rust_analyzer

-- Install debugger
-- :DIInstall codelldb

local global = require("core.global")
local funcs = require("core.funcs")
local languages_setup = require("languages.global.utils")
local nvim_lsp_util = require("lspconfig/util")
local lsp_signature = require("lsp_signature")
local default_debouce_time = 150
local lsp_installer_servers = require("nvim-lsp-installer/servers")
local server_available, requested_server = lsp_installer_servers.get_server("rust_analyzer")
local dap_install = require("dap-install")
local dap = require("dap")

local language_configs = {}

language_configs["lsp"] = function()
	local function start_rust_analyzer()
		if server_available then
			require("rust-tools").setup({
				tools = {
					hover_actions = {
						border = {
							{ "┌", "FloatBorder" },
							{ "─", "FloatBorder" },
							{ "┐", "FloatBorder" },
							{ "│", "FloatBorder" },
							{ "┘", "FloatBorder" },
							{ "─", "FloatBorder" },
							{ "└", "FloatBorder" },
							{ "│", "FloatBorder" },
						},
					},
				},
				server = vim.tbl_deep_extend("force", requested_server:get_default_options(), {
					flags = {
						debounce_text_changes = default_debouce_time,
					},
					autostart = true,
					filetypes = { "rust" },
					on_attach = function(client, bufnr)
						table.insert(global["languages"]["rust"]["pid"], client.rpc.pid)
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
				}),
			})
		end
	end
	start_rust_analyzer()
end

language_configs["dap"] = function()
	if funcs.dir_exists(global.lsp_path .. "dapinstall/ccppr_lldb/") ~= true then
		vim.cmd("DIInstall ccppr_lldb")
	end
	dap_install.config("ccppr_lldb", {})
	dap.configurations.rust = {
		{
			type = "cpp",
			request = "launch",
			name = "Launch",
			program = function()
				return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
			end,
			args = {},
			cwd = "${workspaceFolder}",
			env = function()
				local variables = {}
				for k, v in pairs(vim.fn.environ()) do
					table.insert(variables, string.format("%s=%s", k, v))
				end
				return variables
			end,
			stopOnEntry = false,
		},
	}
end

return language_configs
