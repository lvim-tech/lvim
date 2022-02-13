-- Install Lsp server
-- :LspInstall r_language_server

local global = require("core.global")
local languages_setup = require("languages.global.utils")
local nvim_lsp_util = require("lspconfig/util")
local lsp_signature = require("lsp_signature")
local default_debouce_time = 150

local language_configs = {}

language_configs["lsp"] = function()
    local function start_r_language_server(server)
        server:setup {
            flags = {
                debounce_text_changes = default_debouce_time
            },
            autostart = true,
            filetypes = {"r", "rmd"},
            on_attach = function(client, bufnr)
                table.insert(global["languages"]["r"]["pid"], client.rpc.pid)
                vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
                lsp_signature.on_attach(languages_setup.config_lsp_signature)
                languages_setup.document_highlight(client)
            end,
            capabilities = languages_setup.get_capabilities(),
            root_dir = function(fname)
                return nvim_lsp_util.find_git_ancestor(fname) or vim.fn.getcwd()
            end
        }
    end
    languages_setup.setup_lsp("r_language_server", start_r_language_server)
end

return language_configs
