-- Install Lsp server
-- :LspInstall bashls

local global = require("core.global")
local languages_setup = require("languages.global.utils")
local nvim_lsp = require("lspconfig")
local nvim_lsp_util = require("lspconfig/util")
local lsp_signature = require("lsp_signature")
local default_debouce_time = 150
local lsp_installer = require("nvim-lsp-installer")
local lsp_installer_servers = require("nvim-lsp-installer.servers")

local language_configs = {}

language_configs["lsp"] = function()
    local function start_bashls()
        nvim_lsp.bashls.setup {
            cmd = {
                global.lsp_path .. "lsp_servers/bash/node_modules/.bin/bash-language-server",
                "start"
            },
            flags = {
                debounce_text_changes = default_debouce_time
            },
            autostart = true,
            filetypes = {"sh"},
            on_attach = function(client, bufnr)
                table.insert(global["languages"]["shell"]["pid"], client.rpc.pid)
                vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
                lsp_signature.on_attach(languages_setup.config_lsp_signature)
                languages_setup.document_highlight(client, bufnr)
            end,
            capabilities = languages_setup.get_capabilities(),
            root_dir = nvim_lsp_util.root_pattern("."),
            handlers = languages_setup.show_line_diagnostics()
        }
    end
    local ok, bashls = lsp_installer_servers.get_server("bashls")
    if ok then
        if not bashls:is_installed() then
            bashls:install()
            lsp_installer.on_server_ready(
                function()
                    start_bashls()
                end
            )
        else
            start_bashls()
        end
    end
end

return language_configs
