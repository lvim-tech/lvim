-- Commands group for the LVIM Control Center.
-- A list of one-shot actions exposed in the Control Center UI: open Lazy, run
-- Lazy sync, open Mason, and dump highlight groups (:hi). Each entry is an
-- "action" that runs a vim command. Returned as a Control Center group descriptor.

---@module "modules.base.configs.editor.control_center.commands"

local icons = require("configs.base.ui.icons")

return {
    name = "commands",
    label = "Commands",
    icon = icons.common.eval,
    settings = {
        {
            name = "lazy",
            label = "Lazy",
            type = "action",
            run = function()
                vim.cmd("Lazy")
            end,
        },
        {
            name = "lazysync",
            label = "Lazy sync",
            type = "action",
            run = function()
                vim.cmd("Lazy sync")
            end,
        },
        {
            name = "mason",
            label = "Mason",
            type = "action",
            run = function()
                vim.cmd("Mason")
            end,
        },
        {
            name = "colors",
            label = "Colors",
            type = "action",
            run = function()
                vim.cmd("hi")
            end,
        },
    },
}
