local icons = require("configs.base.ui.icons")

return {
    name = "commands",
    label = "Commands",
    icon = icons.common.eval .. " ",
    settings = {
        {
            name = "restart_lsp",
            label = "Restart LSP",
            type = "action",
            run = function()
                vim.cmd("LvimLspRestart")
                vim.notify("LSP restarted!", vim.log.levels.INFO)
            end,
        },
        {
            name = "open_config",
            label = "Open Neovim Config",
            type = "action",
            cmd = "edit $MYVIMRC",
        },
    },
}
