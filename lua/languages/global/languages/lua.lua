-- Install Lsp server
-- :LspInstall sumneko_lua

-- Install debugger
-- :DIInstall lua

local global = require("core.global")
local funcs = require("core.funcs")
local languages_setup = require("languages.global.utils")
local nvim_lsp = require("lspconfig")
local nvim_lsp_util = require("lspconfig/util")
local lsp_signature = require("lsp_signature")
local default_debouce_time = 150
local sumneko_path = global.lsp_path .. "lsp_servers/sumneko_lua/extension/server/bin/" .. global.os
local lsp_installer = require("nvim-lsp-installer")
local lsp_installer_servers = require("nvim-lsp-installer.servers")
local dap = require("dap")

local language_configs = {}

language_configs["buffer"] = function()
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
end

language_configs["lsp"] = function()
    local function start_sumneko_lua()
        nvim_lsp.sumneko_lua.setup {
            cmd = {sumneko_path .. "/lua-language-server", "-E", sumneko_path .. "/main.lua"},
            flags = {
                debounce_text_changes = default_debouce_time
            },
            autostart = true,
            filetypes = {"lua"},
            on_attach = function(client, bufnr)
                table.insert(global["languages"]["lua"]["pid"], client.rpc.pid)
                vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
                lsp_signature.on_attach(languages_setup.config_lsp_signature)
                languages_setup.document_highlight(client, bufnr)
            end,
            capabilities = languages_setup.get_capabilities(),
            settings = {
                Lua = {
                    completion = {keywordSnippet = "Disable"},
                    diagnostics = {
                        globals = {"vim", "use"},
                        disable = {"lowercase-global"}
                    },
                    runtime = {version = "LuaJIT", path = vim.split(package.path, ";")},
                    workspace = {
                        library = {
                            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                            [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true
                        }
                    }
                }
            },
            root_dir = nvim_lsp_util.root_pattern("."),
            handlers = languages_setup.show_line_diagnostics()
        }
    end
    local ok, sumneko_lua = lsp_installer_servers.get_server("sumneko_lua")
    if ok then
        if not sumneko_lua:is_installed() then
            sumneko_lua:install()
            lsp_installer.on_server_ready(
                function()
                    start_sumneko_lua()
                end
            )
        else
            start_sumneko_lua()
        end
    end
end

language_configs["dap"] = function()
    if funcs.dir_exists(global.lsp_path .. "dapinstall/lua/") ~= true then
        vim.cmd("DIInstall lua")
    end
    dap.adapters.nlua = function(callback, config)
        callback(
            {
                type = "server",
                host = config.host,
                port = config.port
            }
        )
    end
    dap.configurations.lua = {
        {
            type = "nlua",
            request = "attach",
            name = "Attach to running Neovim instance",
            host = function()
                local value = vim.fn.input("Host [127.0.0.1]: ")
                if value ~= "" then
                    return value
                end
                return "127.0.0.1"
            end,
            port = function()
                local val = tonumber(vim.fn.input("Port: "))
                assert(val, "Please provide a port number")
                return val
            end
        }
    }
end

return language_configs
