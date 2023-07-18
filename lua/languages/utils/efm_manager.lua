local global = require("core.global")
local lspconfig = require("lspconfig")
local nvim_lsp_util = require("lspconfig/util")
local setup_diagnostics = require("languages.utils.setup_diagnostics")

local M = {}

if global.efm == false then
    global.efm = {
        root_dir = function(fname)
            return nvim_lsp_util.find_git_ancestor(fname) or vim.fn.getcwd()
        end,
        init_options = { documentFormatting = true },
        settings = {
            languages = {},
        },
        filetypes = {},
        on_attach = function(client, bufnr)
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.omni(client, bufnr)
            setup_diagnostics.tag(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.document_formatting(client, bufnr)
        end,
    }
end

M.setup_efm = function()
    local mason_registry = require("mason-registry")
    if not mason_registry.is_installed("efm") then
        local ok, p = pcall(function()
            return mason_registry.get_package("efm")
        end)
        if not ok then
            vim.notify("Package efm not available")
        else
            p:install():once(
                "closed",
                vim.schedule_wrap(function()
                    lspconfig.efm.setup(global.efm)
                    vim.cmd(":LspStart efm")
                    global.install_proccess = false
                end)
            )
        end
    else
        lspconfig.efm.setup(global.efm)
        vim.cmd(":LspStart efm")
    end
end

return M
