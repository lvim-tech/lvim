-- Install Lsp server
-- :LspInstall tsserver

-- Install debugger
-- :DIInstall jsnode

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
local path_debugger = vim.fn.stdpath("data") .. "/dapinstall/jsnode/vscode-node-debug2/out/src/nodeDebug.js"

local language_configs = {}

language_configs["lsp"] = function()
    local function start_tsserver()
        nvim_lsp.tsserver.setup {
            cmd = {
                global.lsp_path .. "lsp_servers/tsserver/node_modules/.bin/typescript-language-server",
                "--stdio"
            },
            flags = {
                debounce_text_changes = default_debouce_time
            },
            autostart = true,
            filetypes = {"javascript", "javascriptreact", "typescript", "typescriptreact"},
            on_attach = function(client, bufnr)
                table.insert(global["languages"]["jsts"]["pid"], client.rpc.pid)
                vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
                lsp_signature.on_attach(languages_setup.config_lsp_signature)
                languages_setup.document_highlight(client, bufnr)
            end,
            capabilities = languages_setup.get_capabilities(),
            root_dir = nvim_lsp_util.root_pattern("."),
            handlers = languages_setup.show_line_diagnostics()
        }
    end
    local ok, tsserver = lsp_installer_servers.get_server("tsserver")
    if ok then
        if not tsserver:is_installed() then
            tsserver:install()
            lsp_installer.on_server_ready(
                function()
                    start_tsserver()
                end
            )
        else
            start_tsserver()
        end
    end
end

language_configs["dap"] = function()
    if funcs.dir_exists(global.lsp_path .. "dapinstall/jsnode/") ~= true then
        vim.cmd("DIInstall jsnode")
    end
    dap.adapters.node2 = {
        type = "executable",
        command = "node",
        args = {path_debugger}
    }
    dap.configurations.javascript = {
        {
            type = "node2",
            request = "launch",
            name = "Launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            outFiles = {"${workspaceRoot}/dist/js/*"},
            sourceMaps = true,
            protocol = "inspector",
            console = "integratedTerminal"
        }
    }
    dap.configurations.typescript = {
        {
            type = "node2",
            request = "launch",
            name = "Launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            outFiles = {"${workspaceRoot}/dist/js/*"},
            sourceMaps = true,
            protocol = "inspector",
            console = "integratedTerminal"
        }
    }
end

return language_configs
