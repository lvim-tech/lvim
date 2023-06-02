local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local M = {}

local package_info_hint = [[
                        PACKAGE INFO

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Toggle                      _t_ │ _I_                    Install
Change version              _v_ │ _d_                     Delete

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                         exit _<Esc>_
]]

local crates_hint = [[
                           CRATES

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Toggle                      _t_ │ _r_                     Reload

Show versions popup         _v_ │ _f_        Show features popup

Update crate                _p_ │ _P_              Update crates
Update all crates          _ep_ │

Upgrade crate               _g_ │ _G_             Upgrade crates
Upgrade all crates         _eg_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                         exit _<Esc>_
]]

local pubspec_assist_hint = [[
                       PUBSPEC ASSIST

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Add package                 _p_ │ _d_            Add dev package
Pick version                _v_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                         exit _<Esc>_
]]

M.package_info = function()
    M.package_info_hydra = Hydra({
        name = "PACKAGE INFO",
        hint = package_info_hint,
        config = {
            color = "pink",
            invoke_on_body = true,
            hint = {
                position = "bottom-center",
                border = "single",
            },
            buffer = true,
        },
        mode = { "n", "x", "v" },
        body = ";w",
        heads = {
            {
                "t",
                keymap.cmd("PackageInfoToggle"),
                { nowait = true, silent = true, desc = "Toggle" },
            },
            {
                "I",
                keymap.cmd("PackageInfoInstall"),
                { nowait = true, silent = true, desc = "Install" },
            },
            {
                "v",
                keymap.cmd("PackageInfoChangeVersion"),
                { nowait = true, silent = true, desc = "Change version" },
            },
            {
                "d",
                keymap.cmd("PackageInfoDelete"),
                { nowait = true, silent = true, desc = "Delete" },
            },
            { "<Esc>", nil, { exit = true, desc = false } },
        },
    })
end

M.crates = function()
    M.crates_hydra = Hydra({
        name = "CRATES",
        hint = crates_hint,
        config = {
            color = "pink",
            invoke_on_body = true,
            hint = {
                position = "bottom-center",
                border = "single",
            },
            buffer = true,
        },
        mode = { "n", "x", "v" },
        body = ";w",
        heads = {
            {
                "t",
                keymap.cmd("CratesToggle"),
                { nowait = true, silent = true, desc = "Toggle" },
            },
            {
                "r",
                keymap.cmd("CratesReload"),
                { nowait = true, silent = true, desc = "Reload" },
            },
            {
                "v",
                keymap.cmd("CratesShowVersionsPopup"),
                { nowait = true, silent = true, desc = "Show versions popup" },
            },
            {
                "f",
                keymap.cmd("CratesShowFeaturesPopup"),
                { nowait = true, silent = true, desc = "Show features popup" },
            },
            {
                "p",
                keymap.cmd("CratesUpdateCrate"),
                { nowait = true, silent = true, desc = "Update crate" },
            },
            {
                "P",
                keymap.cmd("CratesUpdateCrates"),
                { nowait = true, silent = true, desc = "Update crates" },
            },
            {
                "ep",
                keymap.cmd("CratesUpdateAllCrates"),
                { nowait = true, silent = true, desc = "Update all crates" },
            },
            {
                "g",
                keymap.cmd("CratesUpgradeCrate"),
                { nowait = true, silent = true, desc = "Upgrade crate" },
            },
            {
                "G",
                keymap.cmd("CratesUpgradeCrates"),
                { nowait = true, silent = true, desc = "Upgrade crates" },
            },
            {
                "eg",
                keymap.cmd("CratesUpgradeAllCrates"),
                { nowait = true, silent = true, desc = "Upgrade all crates" },
            },
            { "<Esc>", nil, { exit = true, desc = false } },
        },
    })
end

M.pubspec_assist = function()
    M.pubspec_assist_hydra = Hydra({
        name = "PUBSPEC ASSIST",
        hint = pubspec_assist_hint,
        config = {
            color = "pink",
            invoke_on_body = true,
            hint = {
                position = "bottom-center",
                border = "single",
            },
            buffer = true,
        },
        mode = { "n", "x", "v" },
        body = ";w",
        heads = {
            {
                "p",
                keymap.cmd("PubspecAssistAddPackage"),
                { nowait = true, silent = true, desc = "Add package" },
            },
            {
                "d",
                keymap.cmd("PubspecAssistAddDevPackage"),
                { nowait = true, silent = true, desc = "Add dev package" },
            },
            {
                "v",
                keymap.cmd("PubspecAssistPickVersion"),
                { nowait = true, silent = true, desc = "Pick version" },
            },
            { "<Esc>", nil, { exit = true, desc = false } },
        },
    })
end

return M
