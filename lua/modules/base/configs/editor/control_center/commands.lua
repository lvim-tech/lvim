-- Commands group for the LVIM Control Center.
-- One-shot actions grouped into sections with `spacer` headers (like General / Utils):
--   Packages    — plugin + tool (LSP/DAP/linters) install and plugin update
--   System      — dashboard, captured messages / notifications
--   Diagnostics — the lvim-tech dependency tree and :checkhealth
-- Each entry is an "action" that runs a vim command when activated.

---@module "modules.base.configs.editor.control_center.commands"

local icons = require("configs.base.ui.icons")

return {
    name = "commands",
    label = "Commands",
    icon = icons.common.eval,
    settings = {
        -- ── package management ────────────────────────────────────────────────
        { name = "sep_packages", type = "spacer", label = "Packages" },
        {
            name = "plugins",
            label = "Plugins",
            type = "action",
            run = function()
                vim.cmd("LvimInstaller plugins")
            end,
        },
        {
            name = "packages",
            label = "Packages (LSP / DAP / Tools)",
            type = "action",
            run = function()
                vim.cmd("LvimInstaller")
            end,
        },
        {
            name = "packupdate",
            label = "Update plugins",
            type = "action",
            run = function()
                vim.pack.update()
            end,
        },

        -- ── system ────────────────────────────────────────────────────────────
        { name = "sep_system", type = "spacer", label = "System" },
        {
            name = "dashboard",
            label = "Dashboard",
            type = "action",
            run = function()
                vim.cmd("LvimDashboard")
            end,
        },
        {
            name = "messages",
            label = "Messages",
            type = "action",
            run = function()
                vim.cmd("Messages")
            end,
        },

        -- ── diagnostics ───────────────────────────────────────────────────────
        { name = "sep_diagnostics", type = "spacer", label = "Diagnostics" },
        {
            name = "deps",
            label = "Dependencies",
            type = "action",
            run = function()
                vim.cmd("LvimDeps")
            end,
        },
        {
            name = "health",
            label = "Health check",
            type = "action",
            run = function()
                vim.cmd("checkhealth")
            end,
        },
    },
}
