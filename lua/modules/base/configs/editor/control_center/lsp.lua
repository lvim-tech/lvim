-- LSP settings group for the LVIM Control Center.
-- Provides toggles and action buttons for LSP-related features: auto-format on
-- save, inlay hints, virtual diagnostic display mode, LSP progress display
-- backend, code-lens rendering, and one-click LSP management actions.
-- Settings are persisted via the lvim-control-center data store.

---@module "modules.base.configs.editor.control_center.lsp"

local data = require("lvim-control-center.persistence.data")
local icons = require("configs.base.ui.icons")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local fidget = require("fidget")
local code_lens = require("languages.utils.code_lens")

---@type table  Control Center settings group descriptor for LSP options
return {
    name = "lsp",
    label = "LSP",
    icon = icons.common.light_bulb,
    settings = {
        -- -----------------------------------------------------------------
        -- Auto-format on save
        -- -----------------------------------------------------------------
        {
            name = "autoformat",
            label = "Auto format",
            type = "bool",
            default = true,
            ---@return boolean  Whether auto-format on save is active (falls back to true when unset)
            get = function()
                if _G.LVIM.settings and _G.LVIM.settings["autoformat"] ~= nil then
                    return _G.LVIM.settings["autoformat"]
                else
                    return true
                end
            end,
            ---@param val     boolean  New auto-format state
            ---@param on_init boolean  True during startup; skip persistence
            set = function(val, on_init)
                _G.LVIM.settings["autoformat"] = val
                if not on_init then
                    data.save("autoformat", val)
                end
            end,
        },
        -- -----------------------------------------------------------------
        -- Inlay hints
        -- -----------------------------------------------------------------
        {
            name = "inlayhint",
            label = "Inlay hint",
            type = "bool",
            default = true,
            ---@return boolean  Whether inlay hints are enabled (falls back to true when unset)
            get = function()
                if _G.LVIM.settings and _G.LVIM.settings["inlayhint"] ~= nil then
                    return _G.LVIM.settings["inlayhint"]
                else
                    return true
                end
            end,
            ---@param val     boolean  New inlay-hint state
            ---@param on_init boolean  True during startup; skip per-buffer toggle
            set = function(val, on_init)
                _G.LVIM.settings["inlayhint"] = val
                if not on_init then
                    -- Apply the new state to every currently loaded buffer that supports inlay hints.
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
        -- -----------------------------------------------------------------
        -- Virtual diagnostic display mode
        -- -----------------------------------------------------------------
        {
            name = "virtualdiagnostic",
            label = "Virtual diagnostic",
            type = "select",
            -- Possible modes:
            --   "text-and-lines" – show both inline text and virtual lines
            --   "text"           – inline text only (end-of-line virtual text)
            --   "lines"          – virtual lines below the offending line only
            --   "none"           – all virtual diagnostics disabled
            options = { "text-and-lines", "text", "lines", "none" },
            default = "none",
            ---@return string  Current virtual diagnostic mode (falls back to "none" when unset)
            get = function()
                if _G.LVIM.settings and _G.LVIM.settings["virtualdiagnostic"] ~= nil then
                    return _G.LVIM.settings["virtualdiagnostic"]
                else
                    return "none"
                end
            end,
            ---@param val     string   One of "text-and-lines"|"text"|"lines"|"none"
            ---@param on_init boolean  True during startup
            set = function(val, on_init)
                _G.LVIM.settings["virtualdiagnostic"] = val
                local config = vim.diagnostic.config
                ---@type { text: boolean, lines: boolean }
                local virtualdiagnostic
                -- Translate the human-readable option into the boolean flags
                -- expected by vim.diagnostic.config().
                if val == "text-and-lines" then
                    virtualdiagnostic = { text = true, lines = true }
                elseif val == "text" then
                    virtualdiagnostic = { text = true, lines = false }
                elseif val == "lines" then
                    virtualdiagnostic = { text = false, lines = true }
                else
                    virtualdiagnostic = { text = false, lines = false }
                end
                -- Guard against an unexpectedly empty table (defensive check).
                local is_empty = not virtualdiagnostic or next(virtualdiagnostic) == nil
                -- Use vim.schedule to avoid calling diagnostic.config() from inside a
                -- fast-event callback, which is not allowed by the Neovim API.
                vim.schedule(function()
                    config({
                        virtual_text = (not is_empty and virtualdiagnostic.text) and { prefix = icons.common.dot }
                            or false,
                        virtual_lines = not is_empty and virtualdiagnostic.lines or false,
                    })
                end)
                if not on_init then
                    data.save("virtualdiagnostic", val)
                end
            end,
        },
        -- -----------------------------------------------------------------
        -- LSP progress display backend
        -- -----------------------------------------------------------------
        {
            name = "lspprogress",
            label = "LSP progress",
            type = "select",
            -- Backends:
            --   "fidget"  – use the fidget.nvim floating spinner
            --   "notify"  – use vim.notify-based notifications
            --   "none"    – suppress all LSP progress output
            options = { "fidget", "notify", "none" },
            default = "fidget",
            ---@return string  Currently active LSP progress backend (falls back to "fidget" when unset)
            get = function()
                if _G.LVIM.settings and _G.LVIM.settings["lspprogress"] ~= nil then
                    return _G.LVIM.settings["lspprogress"]
                else
                    return "fidget"
                end
            end,
            ---@param val     string   One of "fidget"|"notify"|"none"
            ---@param on_init boolean  True during startup; skip live backend switch
            set = function(val, on_init)
                _G.LVIM.settings["lspprogress"] = val
                if not on_init then
                    if val == "notify" then
                        -- Suppress fidget and hand off progress events to vim.notify.
                        fidget.progress.suppress(true)
                        fidget.notification.suppress(true)
                        setup_diagnostics.enable_lsp_progress()
                    elseif val == "fidget" then
                        -- Re-enable fidget and disable the notify-based handler.
                        fidget.progress.suppress(false)
                        fidget.notification.suppress(false)
                        setup_diagnostics.disable_lsp_progress()
                    else
                        -- "none": suppress fidget and disable the notify handler.
                        fidget.progress.suppress(true)
                        fidget.notification.suppress(true)
                        setup_diagnostics.disable_lsp_progress()
                    end
                    data.save("lspprogress", val)
                end
            end,
        },
        -- -----------------------------------------------------------------
        -- Code lens
        -- -----------------------------------------------------------------
        {
            name = "codelens",
            label = "Code lens",
            type = "bool",
            default = true,
            ---@return boolean  Whether code-lens rendering is enabled (falls back to true when unset)
            get = function()
                if _G.LVIM.settings and _G.LVIM.settings["codelens"] ~= nil then
                    return _G.LVIM.settings["codelens"]
                else
                    return true
                end
            end,
            ---@param val     boolean  New code-lens state
            ---@param on_init boolean  True during startup; skip live update
            set = function(val, on_init)
                _G.LVIM.settings["codelens"] = val
                if not on_init then
                    code_lens.set_codelens_enabled(val)
                    data.save("codelens", val)
                end
            end,
        },
        -- -----------------------------------------------------------------
        -- LSP action: show info
        -- -----------------------------------------------------------------
        {
            name = "lspinfo",
            label = "Info LSP",
            type = "action",
            ---Opens the LVIM LSP info panel for the current buffer.
            run = function()
                vim.cmd("LvimLspInfo")
            end,
        },
        -- -----------------------------------------------------------------
        -- LSP action: restart
        -- -----------------------------------------------------------------
        {
            name = "lsprestart",
            label = "Restart LSP",
            type = "action",
            ---Restarts all LSP clients attached to the current buffer.
            run = function()
                vim.cmd("LvimLspRestart")
            end,
        },
        -- -----------------------------------------------------------------
        -- LSP action: toggle servers for workspace
        -- -----------------------------------------------------------------
        {
            name = "lsptoggleservers",
            label = "Toggle LSP servers for workspace",
            type = "action",
            ---Opens a picker to enable/disable LSP servers for the current workspace.
            run = function()
                vim.cmd("LvimLspToggleServers")
            end,
        },
        -- -----------------------------------------------------------------
        -- LSP action: toggle servers for buffer
        -- -----------------------------------------------------------------
        {
            name = "lsptoggleserversforbuffer",
            label = "Toggle LSP servers for buffer",
            type = "action",
            ---Opens a picker to enable/disable LSP servers for a specific buffer.
            ---@param origin_bufnr integer  Buffer handle passed by the control center
            run = function(origin_bufnr)
                vim.cmd("LvimLspToggleServersForBuffer " .. origin_bufnr)
            end,
        },
    },
}
