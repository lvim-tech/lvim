-- Install Lsp server
-- :LspInstall solargraph

-- Install debugger
-- :DIInstall ruby_vsc
-- Do not forget to add `ruby-debug-ide` gem to your bundle or system!
-- gem install ruby-debug-ide

local global = require("core.global")
local funcs = require("core.funcs")
local languages_setup = require("languages.global.utils")
local nvim_lsp = require("lspconfig")
local nvim_lsp_util = require("lspconfig/util")
local lsp_signature = require("lsp_signature")
local default_debouce_time = 150
local lsp_installer = require("nvim-lsp-installer")
local lsp_installer_servers = require("nvim-lsp-installer.servers")
local dap = require("dap")

local language_configs = {}

language_configs["lsp"] = function()
    local function start_solargraph()
        nvim_lsp.solargraph.setup {
            cmd = {
                global.lsp_path .. "lsp_servers/solargraph/bin/solargraph",
                "stdio"
            },
            flags = {
                debounce_text_changes = default_debouce_time
            },
            autostart = true,
            filetypes = {"ruby"},
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
                languages_setup.document_highlight(client, bufnr)
            end,
            capabilities = languages_setup.get_capabilities(),
            root_dir = nvim_lsp_util.root_pattern("."),
            handlers = languages_setup.show_line_diagnostics()
        }
    end
    local ok, solargraph = lsp_installer_servers.get_server("solargraph")
    if ok then
        if not solargraph:is_installed() then
            solargraph:install()
            lsp_installer.on_server_ready(
                function()
                    start_solargraph()
                end
            )
        else
            start_solargraph()
        end
    end
end

language_configs["dap"] = function()
    if funcs.dir_exists(global.lsp_path .. "dapinstall/ruby_vsc/") ~= true then
        vim.cmd("DIInstall ruby_vsc")
    end
    local path_debuggers = vim.fn.stdpath("data") .. "/dapinstall/"
    dap.adapters.ruby = {
        type = "executable",
        command = "node",
        args = {path_debuggers .. "ruby_vsc/extension/dist/debugger/main.js"}
    }
    dap.configurations.ruby = {
        {
            type = "ruby",
            name = "Launch",
            request = "launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end
        }
    }
end

return language_configs
