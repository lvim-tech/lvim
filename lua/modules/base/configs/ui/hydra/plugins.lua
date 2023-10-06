local Hydra = require("hydra")
local vimtex = require("modules.base.configs.ui.hydra.vimtex")
local flutter = require("modules.base.configs.ui.hydra.flutter")

local M = {}

local plugins_hint = [[
                                        PLUGINS

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Flutter                                   _f_ │ _v_                                    Vimtex

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
]]

M.plugins = Hydra({
    name = "PLUGINS",
    hint = plugins_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    mode = { "n", "x", "v" },
    body = ";p",
    heads = {
        {
            "v",
            function()
                vimtex.vimtex:activate()
            end,
            { nowait = true, silent = true, desc = "Vimtex" },
        },
        {
            "f",
            function()
                flutter.flutter:activate()
            end,
            { nowait = true, silent = true, desc = "Flutter" },
        },
        { "<C-q>", nil, { exit = true, desc = false } },
    },
})

return M
