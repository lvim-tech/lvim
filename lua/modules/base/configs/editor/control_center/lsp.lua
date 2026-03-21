-- LSP settings group for the LVIM Control Center.
-- Provides toggles and action buttons for LSP-related features: auto-format on
-- save, inlay hints, virtual diagnostic display mode, LSP progress display
-- backend, code-lens rendering, and one-click LSP management actions.
-- Settings are persisted via the lvim-control-center data store.

---@module "modules.base.configs.editor.control_center.lsp"

local icons = require("configs.base.ui.icons")

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
            ---@return boolean
            get = function()
                local v = require("lvim-lsp.state").config.features.auto_format
                if type(v) == "function" then return v() end
                return v == true
            end,
            ---@param val     boolean
            ---@param on_init boolean  True during startup; globals already loaded, skip
            set = function(val, on_init)
                if not on_init then
                    require("lvim-lsp.state").config.features.auto_format = val
                    require("lvim-lsp.core.globals").save({ auto_format = val })
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
            ---@return boolean
            get = function()
                local v = require("lvim-lsp.state").config.features.inlay_hints
                if type(v) == "function" then return v() end
                return v == true
            end,
            ---@param val     boolean
            ---@param on_init boolean  True during startup; globals already loaded, skip
            set = function(val, on_init)
                if not on_init then
                    require("lvim-lsp.state").config.features.inlay_hints = val
                    -- Apply immediately to already-attached buffers (LspAttach won't re-fire).
                    if vim.lsp.inlay_hint then
                        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
                            pcall(vim.lsp.inlay_hint.enable, val, { bufnr = bufnr })
                        end
                    end
                    require("lvim-lsp.core.globals").save({ inlay_hints = val })
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
            ---@return string
            get = function()
                local diag = require("lvim-lsp.state").config.diagnostics
                local vt = diag.virtual_text
                local vl = diag.virtual_lines
                local has_text = vt and vt ~= false
                local has_lines = vl and vl ~= false
                if has_text and has_lines then return "text-and-lines" end
                if has_text then return "text" end
                if has_lines then return "lines" end
                return "none"
            end,
            ---@param val     string   One of "text-and-lines"|"text"|"lines"|"none"
            ---@param on_init boolean  True during startup; globals already loaded, skip
            set = function(val, on_init)
                if not on_init then
                    local vt_cfg = (val == "text-and-lines" or val == "text")
                        and { prefix = icons.common.dot } or false
                    local vl_cfg = (val == "text-and-lines" or val == "lines") and true or false
                    local lsp_state = require("lvim-lsp.state")
                    lsp_state.config.diagnostics.virtual_text = vt_cfg
                    lsp_state.config.diagnostics.virtual_lines = vl_cfg
                    vim.schedule(function()
                        vim.diagnostic.config({ virtual_text = vt_cfg, virtual_lines = vl_cfg })
                    end)
                    require("lvim-lsp.core.globals").save({
                        virtual_text = vt_cfg and true or false,
                        virtual_lines = vl_cfg and true or false,
                    })
                end
            end,
        },
        -- -----------------------------------------------------------------
        -- LSP progress display backend
        -- -----------------------------------------------------------------
        {
            name = "lspprogress",
            label = "LSP progress",
            type = "bool",
            default = true,
            ---@return boolean
            get = function()
                return require("lvim-lsp.state").config.progress.enabled ~= false
            end,
            ---@param val     boolean
            ---@param on_init boolean  True during startup; globals already loaded, skip
            set = function(val, on_init)
                if not on_init then
                    require("lvim-lsp.state").config.progress.enabled = val
                    require("lvim-lsp").suppress_progress(not val)
                    require("lvim-lsp.core.globals").save({ progress = val })
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
            ---@return boolean
            get = function()
                return require("lvim-lsp.state").config.code_lens.enabled == true
            end,
            ---@param val     boolean
            ---@param on_init boolean  True during startup; globals already loaded, skip
            set = function(val, on_init)
                if not on_init then
                    require("lvim-lsp.state").config.code_lens.enabled = val
                    require("lvim-lsp.core.features").setup_code_lens()
                    require("lvim-lsp.core.globals").save({ code_lens = val })
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
                vim.cmd("LvimLsp info")
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
                vim.cmd("LvimLsp restart")
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
                vim.cmd("LvimLsp toggle_servers")
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
                vim.cmd("LvimLsp toggle_servers_buffer " .. origin_bufnr)
            end,
        },
    },
}
