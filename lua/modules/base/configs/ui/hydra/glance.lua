local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local M = {}

local glance_hint = [[
                                         GLANCE

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Definitions                             _gpd_ │ _gpt_                        Type definitions
References                              _gpr_ │ _gpi_                         Implementations

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
]]

M.glance = Hydra({
    name = "GLANCE",
    hint = glance_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
        },
    },
    mode = { "n", "x", "v" },
    body = ";s",
    heads = {
        {
            "gpd",
            keymap.cmd("Glance definitions"),
            { nowait = true, silent = true, desc = "Definitions" },
        },
        {
            "gpt",
            keymap.cmd("Glance type_definitions"),
            { nowait = true, silent = true, desc = "Type definitions" },
        },
        {
            "gpr",
            keymap.cmd("Glance references"),
            { nowait = true, silent = true, desc = "References" },
        },
        {
            "gpi",
            keymap.cmd("Glance implementations"),
            { nowait = true, silent = true, desc = "Implementations" },
        },
        { "<C-q>", nil, { exit = true, desc = false } },
    },
})

return M
