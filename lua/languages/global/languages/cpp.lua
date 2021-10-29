-- Install Lsp server
-- :LspInstall clangd

-- Install debugger
-- :DIInstall ccppr_lldb

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
    local function start_clangd()
        nvim_lsp.clangd.setup {
            cmd = {
                global.lsp_path .. "lsp_servers/clangd/clangd"
            },
            flags = {
                debounce_text_changes = default_debouce_time
            },
            autostart = true,
            filetypes = {"c", "cpp", "objc", "objcpp"},
            on_attach = function(client, bufnr)
                table.insert(global["languages"]["cpp"]["pid"], client.rpc.pid)
                vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
                lsp_signature.on_attach(languages_setup.config_lsp_signature)
                languages_setup.document_highlight(client, bufnr)
            end,
            capabilities = languages_setup.get_capabilities(),
            root_dir = nvim_lsp_util.root_pattern("."),
            handlers = languages_setup.show_line_diagnostics()
        }
    end
    local ok, clangd = lsp_installer_servers.get_server("clangd")
    if ok then
        if not clangd:is_installed() then
            clangd:install()
            lsp_installer.on_server_ready(
                function()
                    start_clangd()
                end
            )
        else
            start_clangd()
        end
    end
end

language_configs["dap"] = function()
    if funcs.dir_exists(global.lsp_path .. "dapinstall/ccppr_lldb/") ~= true then
        vim.cmd("DIInstall ccppr_lldb")
    end
    dap.adapters.cpp = {
        type = "executable",
        attach = {pidProperty = "pid", pidSelect = "ask"},
        command = "lldb-vscode",
        name = "lldb"
    }
    dap.configurations.cpp = {
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
            stopOnEntry = false
        }
    }
end

return language_configs
