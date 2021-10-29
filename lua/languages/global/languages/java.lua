-- Install Lsp server
-- :LspInstall jdtls

local global = require("core.global")
local languages_utils = require("languages.global.utils")
local nvim_lsp = require("lspconfig")
local nvim_lsp_util = require("lspconfig/util")
local lsp_signature = require("lsp_signature")
local default_debouce_time = 150
local lsp_installer = require("nvim-lsp-installer")
local lsp_installer_servers = require("nvim-lsp-installer.servers")

local language_configs = {}

language_configs["lsp"] = function()
    local function start_jdtls()
        nvim_lsp.jdtls.setup {
            cmd = {global.vim_path .. "/bin/jdtls.sh"},
            flags = {
                debounce_text_changes = default_debouce_time
            },
            autostart = true,
            filetypes = {"java"},
            on_attach = function(client, bufnr)
                table.insert(global["languages"]["java"]["pid"], client.rpc.pid)
                vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
                lsp_signature.on_attach(languages_utils.config_lsp_signature)
                languages_utils.document_highlight(client, bufnr)
            end,
            capabilities = languages_utils.get_capabilities(),
            root_dir = nvim_lsp_util.root_pattern("."),
            handlers = languages_utils.show_line_diagnostics()
        }
    end
    local ok, jdtls = lsp_installer_servers.get_server("jdtls")
    if ok then
        if not jdtls:is_installed() then
            jdtls:install()
            lsp_installer.on_server_ready(
                function()
                    start_jdtls()
                end
            )
        else
            start_jdtls()
        end
    end
end

return language_configs
