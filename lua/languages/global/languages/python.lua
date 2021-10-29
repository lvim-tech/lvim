-- Install Lsp server
-- :LspInstall pyright

-- Install debugger
-- :DIInstall python

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

language_configs["buffer"] = function()
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
end

language_configs["lsp"] = function()
    local function start_pyright()
        nvim_lsp.pyright.setup {
            cmd = {
                global.lsp_path .. "lsp_servers/python/node_modules/.bin/pyright-langserver",
                "--stdio"
            },
            flags = {
                debounce_text_changes = default_debouce_time
            },
            autostart = true,
            filetypes = {"python"},
            on_attach = function(client, bufnr)
                table.insert(global["languages"]["python"]["pid"], client.rpc.pid)
                vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
                lsp_signature.on_attach(languages_setup.config_lsp_signature)
                languages_setup.document_highlight(client, bufnr)
            end,
            capabilities = languages_setup.get_capabilities(),
            root_dir = nvim_lsp_util.root_pattern("."),
            handlers = languages_setup.show_line_diagnostics()
        }
    end
    local ok, pyright = lsp_installer_servers.get_server("pyright")
    if ok then
        if not pyright:is_installed() then
            pyright:install()
            lsp_installer.on_server_ready(
                function()
                    start_pyright()
                end
            )
        else
            start_pyright()
        end
    end
end

language_configs["dap"] = function()
    if funcs.dir_exists(global.lsp_path .. "dapinstall/python/") ~= true then
        vim.cmd("DIInstall python")
    end
    dap.adapters.python = {
        type = "executable",
        command = "python",
        args = {"-m", "debugpy.adapter"}
    }
    dap.configurations.python = {
        {
            type = "python",
            request = "launch",
            name = "Launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            pythonPath = "python3"
        }
    }
end

return language_configs
