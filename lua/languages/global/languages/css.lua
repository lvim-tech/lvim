-- Install Lsp server
-- :LspInstall cssls

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
    local function start_cssls()
        nvim_lsp.cssls.setup {
            cmd = {
                "node",
                global.lsp_path ..
                    "lsp_servers/vscode-langservers-extracted/node_modules/.bin/vscode-css-language-server",
                "--stdio"
            },
            flags = {
                debounce_text_changes = default_debouce_time
            },
            autostart = true,
            filetypes = {"css", "scss", "less", "sass"},
            on_attach = function(client, bufnr)
                table.insert(global["languages"]["css"]["pid"], client.rpc.pid)
                vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
                lsp_signature.on_attach(languages_setup.config_lsp_signature)
                languages_setup.document_highlight(client, bufnr)
            end,
            capabilities = languages_setup.get_capabilities(),
            root_dir = nvim_lsp_util.root_pattern("."),
            handlers = languages_setup.show_line_diagnostics()
        }
    end
    local ok, cssls = lsp_installer_servers.get_server("cssls")
    if ok then
        if not cssls:is_installed() then
            cssls:install()
            lsp_installer.on_server_ready(
                function()
                    start_cssls()
                end
            )
        else
            start_cssls()
        end
    end
end

return language_configs
