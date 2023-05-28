local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local glance_hint = [[
                           GLANCE

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Definitions                 _d_ │ _t_           Type definitions
References                  _r_ │ _I_            Implementations

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                         exit _<Esc>_
]]
Hydra({
    name = "GLANCE",
    hint = glance_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    mode = { "n", "x", "v" },
    body = "<leader>s",
    heads = {
        {
            "d",
            keymap.cmd("Glance definitions"),
            { silent = true, desc = "Definitions" },
        },
        {
            "t",
            keymap.cmd("Glance type_definitions"),
            { silent = true, desc = "Type definitions" },
        },
        {
            "r",
            keymap.cmd("Glance references"),
            { silent = true, desc = "References" },
        },
        {
            "I",
            keymap.cmd("Glance implementations"),
            { silent = true, desc = "Implementations" },
        },
        { "<Esc>", nil, { exit = true, desc = false } },
    },
})
