local data = require("lvim-control-center.persistence.data")
local icons = require("configs.base.ui.icons")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local fidget = require("fidget")
local code_lens = require("languages.utils.code_lens")

return {
    name = "lsp",
    label = "LSP",
    icon = icons.common.project,
    settings = {
        {
            name = "autoformat",
            label = "Auto format",
            type = "bool",
            default = true,
            get = function()
                if _G.LVIM_SETTINGS and _G.LVIM_SETTINGS["autoformat"] ~= nil then
                    return _G.LVIM_SETTINGS["autoformat"]
                else
                    return true
                end
            end,
            set = function(val, on_init)
                _G.LVIM_SETTINGS["autoformat"] = val
                if not on_init then
                    data.save("autoformat", val)
                end
            end,
        },
        {
            name = "inlayhint",
            label = "Inlay hint",
            type = "bool",
            default = true,
            get = function()
                if _G.LVIM_SETTINGS and _G.LVIM_SETTINGS["inlayhint"] ~= nil then
                    return _G.LVIM_SETTINGS["inlayhint"]
                else
                    return true
                end
            end,
            set = function(val, on_init)
                _G.LVIM_SETTINGS["inlayhint"] = val
                if not on_init then
                    local buffers = vim.api.nvim_list_bufs()
                    for _, bufnr in ipairs(buffers) do
                        if vim.lsp.inlay_hint ~= nil then
                            vim.lsp.inlay_hint.enable(val, { bufnr })
                        end
                    end
                    data.save("inlayhint", val)
                end
            end,
        },
        {
            name = "virtualdiagnostic",
            label = "Virtual diagnostic",
            type = "select",
            options = { "text-and-lines", "text", "lines", "none" },
            default = "none",
            get = function()
                if _G.LVIM_SETTINGS and _G.LVIM_SETTINGS["virtualdiagnostic"] ~= nil then
                    return _G.LVIM_SETTINGS["virtualdiagnostic"]
                else
                    return "none"
                end
            end,
            set = function(val, on_init)
                _G.LVIM_SETTINGS["virtualdiagnostic"] = val
                if not on_init then
                    local config = vim.diagnostic.config
                    local virtualdiagnostic
                    if val == "text-and-lines" then
                        virtualdiagnostic = { text = true, lines = true }
                    elseif val == "text" then
                        virtualdiagnostic = { text = true, lines = false }
                    elseif val == "lines" then
                        virtualdiagnostic = { text = false, lines = true }
                    else
                        virtualdiagnostic = { text = false, lines = false }
                    end
                    local is_empty = not virtualdiagnostic or next(virtualdiagnostic) == nil
                    config({
                        virtual_text = (not is_empty and virtualdiagnostic.text) and { prefix = icons.common.dot }
                            or false,
                        virtual_lines = not is_empty and virtualdiagnostic.lines or false,
                    })
                    data.save("virtualdiagnostic", val)
                end
            end,
        },
        {
            name = "lspprogress",
            label = "LSP progress",
            type = "select",
            options = { "fidget", "notify", "none" },
            default = "fidget",
            get = function()
                if _G.LVIM_SETTINGS and _G.LVIM_SETTINGS["lspprogress"] ~= nil then
                    return _G.LVIM_SETTINGS["lspprogress"]
                else
                    return "fidget"
                end
            end,
            set = function(val, on_init)
                _G.LVIM_SETTINGS["lspprogress"] = val
                if not on_init then
                    if val == "notify" then
                        fidget.progress.suppress(true)
                        fidget.notification.suppress(true)
                        setup_diagnostics.enable_lsp_progress()
                    elseif val == "fidget" then
                        fidget.progress.suppress(false)
                        fidget.notification.suppress(false)
                        setup_diagnostics.disable_lsp_progress()
                    else
                        fidget.progress.suppress(true)
                        fidget.notification.suppress(true)
                        setup_diagnostics.disable_lsp_progress()
                    end
                    data.save("lspprogress", val)
                end
            end,
        },
        {
            name = "codelens",
            label = "Code lens",
            type = "bool",
            default = true,
            get = function()
                if _G.LVIM_SETTINGS and _G.LVIM_SETTINGS["codelens"] ~= nil then
                    return _G.LVIM_SETTINGS["codelens"]
                else
                    return true
                end
            end,
            set = function(val, on_init)
                _G.LVIM_SETTINGS["codelens"] = val
                if not on_init then
                    code_lens.set_codelens_enabled(val)
                    data.save("codelens", val)
                end
            end,
        },
        {
            name = "lspinfo",
            label = "Info LSP",
            type = "action",
            run = function()
                vim.cmd("LvimLspInfo")
            end,
        },
        {
            name = "lsprestart",
            label = "Restart LSP",
            type = "action",
            run = function()
                vim.cmd("LvimLspRestart")
            end,
        },
        {
            name = "lsptoggleservers",
            label = "Toggle LSP servers for workspace",
            type = "action",
            run = function()
                vim.cmd("LvimLspToggleServers")
            end,
        },
        {
            name = "lsptoggleserversforbuffer",
            label = "Toggle LSP servers for buffer",
            type = "action",
            run = function(origin_bufnr)
                vim.cmd("LvimLspToggleServersForBuffer " .. origin_bufnr)
            end,
        },
    },
}
