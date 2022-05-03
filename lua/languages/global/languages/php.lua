-- Install Lsp server
-- :LspInstall intelephense

-- Install debugger
-- :DIInstall php

local global = require("core.global")
local funcs = require("core.funcs")
local languages_setup = require("languages.global.utils")
local nvim_lsp_util = require("lspconfig/util")
local default_debouce_time = 150
local dap_install = require("dap-install")
local dap = require("dap")

local language_configs = {}

language_configs["lsp"] = function()
    local function start_server(server)
        server:setup({
            flags = {
                debounce_text_changes = default_debouce_time,
            },
            autostart = true,
            filetypes = { "php" },
            on_attach = function(client, bufnr)
                table.insert(global["languages"]["php"]["pid"], client.rpc.pid)
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

    languages_setup.setup_lsp("intelephense", start_server)
    languages_setup.setup_lsp("phpactor", start_server)
end

language_configs["dap"] = function()
    if funcs.dir_exists(global.lsp_path .. "dapinstall/php/") ~= true then
        vim.cmd("DIInstall php")
    end
    dap_install.config("php", {})
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
                "-dxdebug.start_with_request=yes",
            },
            env = {
                XDEBUG_MODE = "debug,develop",
                XDEBUG_CONFIG = "client_port=${port}",
            },
        },
    }
end

return language_configs
