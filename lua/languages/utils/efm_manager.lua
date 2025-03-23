local global = require("core.global")
-- local funcs = require("core.funcs")
local lspconfig = require("lspconfig")
-- local nvim_lsp_util = require("lspconfig/util")
local setup_diagnostics = require("languages.utils.setup_diagnostics")

-- local efm_base = require("languages.base.languages._efm")
-- local efm_user = require("languages.user.languages._efm")

local M = {}

-- local efm = funcs.merge(efm_base, efm_user)
if global.efm == false then
    global.efm = {
        init_options = { documentFormatting = true },
        settings = {
            languages = {},
        },
        filetypes = {},
        on_attach = function(client, bufnr)
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.document_auto_format(client, bufnr)
        end,
        root_dir = function(fname)
            return vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
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
            vim.notify("Please run ':MasonUpdate' to update registers and restart LVIM IDE")
        else
            p:install():once(
                "closed",
                vim.schedule_wrap(function()
                    lspconfig.efm.setup(global.efm)
                    -- vim.cmd(":LspStart efm")
                    global.install_proccess = false
                end)
            )
        end
    else
        lspconfig.efm.setup(global.efm)
        -- vim.cmd(":LspStart efm")
    end
end

return M
