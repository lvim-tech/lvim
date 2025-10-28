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
