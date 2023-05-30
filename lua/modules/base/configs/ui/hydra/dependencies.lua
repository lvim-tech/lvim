local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

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

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
    group = "LvimIDE",
    callback = function()
        local current_buf = vim.api.nvim_get_current_buf()
        local file_path = vim.api.nvim_buf_get_name(current_buf)
        local file_name = vim.fn.fnamemodify(file_path, ":t")
        if file_name == "package.json" then
            Hydra({
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
                body = "<leader>]",
                heads = {
                    {
                        "t",
                        keymap.cmd("PackageInfoToggle"),
                        { silent = true, desc = "Toggle" },
                    },
                    {
                        "I",
                        keymap.cmd("PackageInfoInstall"),
                        { silent = true, desc = "Install" },
                    },
                    {
                        "v",
                        keymap.cmd("PackageInfoChangeVersion"),
                        { silent = true, desc = "Change version" },
                    },
                    {
                        "d",
                        keymap.cmd("PackageInfoDelete"),
                        { silent = true, desc = "Delete" },
                    },
                    { "<Esc>", nil, { exit = true, desc = false } },
                },
            })
        elseif file_name == "Cargo.toml" then
            Hydra({
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
                body = "<leader>]",
                heads = {
                    {
                        "t",
                        keymap.cmd("CratesToggle"),
                        { silent = true, desc = "Toggle" },
                    },
                    {
                        "r",
                        keymap.cmd("CratesReload"),
                        { silent = true, desc = "Reload" },
                    },
                    {
                        "v",
                        keymap.cmd("CratesShowVersionsPopup"),
                        { silent = true, desc = "Show versions popup" },
                    },
                    {
                        "f",
                        keymap.cmd("CratesShowFeaturesPopup"),
                        { silent = true, desc = "Show features popup" },
                    },
                    {
                        "p",
                        keymap.cmd("CratesUpdateCrate"),
                        { silent = true, desc = "Update crate" },
                    },
                    {
                        "P",
                        keymap.cmd("CratesUpdateCrates"),
                        { silent = true, desc = "Update crates" },
                    },
                    {
                        "ep",
                        keymap.cmd("CratesUpdateAllCrates"),
                        { silent = true, desc = "Update all crates" },
                    },
                    {
                        "g",
                        keymap.cmd("CratesUpgradeCrate"),
                        { silent = true, desc = "Upgrade crate" },
                    },
                    {
                        "G",
                        keymap.cmd("CratesUpgradeCrates"),
                        { silent = true, desc = "Upgrade crates" },
                    },
                    {
                        "eg",
                        keymap.cmd("CratesUpgradeAllCrates"),
                        { silent = true, desc = "Upgrade all crates" },
                    },
                    { "<Esc>", nil, { exit = true, desc = false } },
                },
            })
        elseif file_name == "pubspec.yaml" then
            Hydra({
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
                body = "<leader>]",
                heads = {
                    {
                        "p",
                        keymap.cmd("PubspecAssistAddPackage"),
                        { silent = true, desc = "Add package" },
                    },
                    {
                        "d",
                        keymap.cmd("PubspecAssistAddDevPackage"),
                        { silent = true, desc = "Add dev package" },
                    },
                    {
                        "v",
                        keymap.cmd("PubspecAssistPickVersion"),
                        { silent = true, desc = "Pick version" },
                    },
                    { "<Esc>", nil, { exit = true, desc = false } },
                },
            })
        end
    end,
})