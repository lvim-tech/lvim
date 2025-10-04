local icons = require("configs.base.ui.icons")

return {
    name = "commands",
    label = "Commands",
    icon = icons.common.eval .. " ",
    settings = {
        {
            name = "snapshotfileshow",
            label = "Show current snapshot file",
            type = "action",
            run = function()
                vim.cmd("SnapshotFileShow")
            end,
        },
        {
            name = "snapshotfilechoice",
            label = "Choice snapshot file",
            type = "action",
            run = function()
                vim.cmd("SnapshotFileChoice")
            end,
        },
        {
            name = "lazy",
            label = "Lazy",
            type = "action",
            run = function()
                vim.cmd("Lazy")
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
