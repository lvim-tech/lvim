-- Install Lsp server
-- :LspInstall intelephense

-- Install debugger
-- :DIInstall php

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
    local function start_intelephense()
        nvim_lsp.intelephense.setup {
            cmd = {
                global.lsp_path .. "lsp_servers/php/node_modules/.bin/intelephense",
                "--stdio"
            },
            flags = {
                debounce_text_changes = default_debouce_time
            },
            autostart = true,
            filetypes = {"php"},
            on_attach = function(client, bufnr)
                table.insert(global["languages"]["php"]["pid"], client.rpc.pid)
                vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
                lsp_signature.on_attach(languages_setup.config_lsp_signature)
                languages_setup.document_highlight(client, bufnr)
            end,
            capabilities = languages_setup.get_capabilities(),
            root_dir = nvim_lsp_util.root_pattern("."),
            handlers = languages_setup.show_line_diagnostics()
        }
    end
    local ok, intelephense = lsp_installer_servers.get_server("intelephense")
    if ok then
        if not intelephense:is_installed() then
            intelephense:install()
            lsp_installer.on_server_ready(
                function()
                    start_intelephense()
                end
            )
        else
            start_intelephense()
        end
    end
end

language_configs["dap"] = function()
    if funcs.dir_exists(global.lsp_path .. "dapinstall/php/") ~= true then
        vim.cmd("DIInstall php")
    end
    local path_debuggers = vim.fn.stdpath("data") .. "/dapinstall/"
    dap.adapters.php = {
        type = "executable",
        command = "node",
        args = {path_debuggers .. "php/vscode-php-debug/out/phpDebug.js"}
    }
    dap.configurations.php = {
        {
            type = "php",
            name = "Launch",
            request = "launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${fileDirname}",
            port = 0,
            runtimeArgs = {
                "-dxdebug.start_with_request=yes"
            },
            env = {
                XDEBUG_MODE = "debug,develop",
                XDEBUG_CONFIG = "client_port=${port}"
            }
        }
    }
end

return language_configs
