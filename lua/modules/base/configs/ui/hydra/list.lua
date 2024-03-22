local Hydra = require("hydra")
local lvim = require("modules.base.configs.ui.hydra.lvim")
local common = require("modules.base.configs.ui.hydra.common")
local navigation = require("modules.base.configs.ui.hydra.navigation")
local replace = require("modules.base.configs.ui.hydra.replace")
local explorer = require("modules.base.configs.ui.hydra.explorer")
local annotation_fold = require("modules.base.configs.ui.hydra.annotation_fold")
local linguistics = require("modules.base.configs.ui.hydra.linguistics")
local telescope = require("modules.base.configs.ui.hydra.telescope")
local fzf = require("modules.base.configs.ui.hydra.fzf")
local git = require("modules.base.configs.ui.hydra.git")
local quickfix = require("modules.base.configs.ui.hydra.quickfix")
local location = require("modules.base.configs.ui.hydra.location")
local diagnostics = require("modules.base.configs.ui.hydra.diagnostics")
local glance = require("modules.base.configs.ui.hydra.glance")
local dap = require("modules.base.configs.ui.hydra.dap")
local neotest = require("modules.base.configs.ui.hydra.neotest")
local terminal = require("modules.base.configs.ui.hydra.terminal")
local dependencies_ft = require("modules.base.configs.ui.hydra.dependencies_ft")
-- local vimtex = require("modules.base.configs.ui.hydra.vimtex")
-- local flutter = require("modules.base.configs.ui.hydra.flutter")
local plugins = require("modules.base.configs.ui.hydra.plugins")

local list_hint = [[
                                        HYDRA KEYS

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
LVIM IDE                                  _;i_ │ _;a_                                  Common
Navigation                                _;n_ │ _;e_                                Explorer
Annotation, fold                          _;c_ │ _;m_                                Terminal
Linguistics                               _;u_ │ _;r_                                 Replace
Quick fix                                 _;q_ │ _;o_                                Location
FZF                                       _;f_ │ _;t_                               Telescope
GIT                                       _;g_ │ _;s_                                  Glance
LSP                                       _;l_ │ _;d_                                     DAP
Neotest                                   _;'_ │ _;w_                            Dependencies
Plugins                                   _;p_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
]]

Hydra({
    name = "HYDRA KEYS",
    hint = list_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            float_opts = {
                border = "single",
            },
        },
    },
    mode = { "n", "x", "v" },
    body = ";;",
    heads = {
        {
            ";i",
            function()
                lvim.lvim:activate()
            end,
            { nowait = true, silent = true, desc = "LVIM IDE" },
        },
        {
            ";a",
            function()
                common.common:activate()
            end,
            { nowait = true, silent = true, desc = "Common" },
        },
        {
            ";n",
            function()
                navigation.navigation:activate()
            end,
            { nowait = true, silent = true, desc = "Navigation" },
        },
        {
            ";e",
            function()
                explorer.explorer:activate()
            end,
            { nowait = true, silent = true, desc = "Explorer" },
        },
        {
            ";c",
            function()
                annotation_fold.annotation:activate()
            end,
            { nowait = true, silent = true, desc = "Annotation, fold" },
        },
        {
            ";m",
            function()
                terminal.terminal:activate()
            end,
            { nowait = true, silent = true, desc = "Terminal" },
        },
        {
            ";u",
            function()
                linguistics.linguistics:activate()
            end,
            { nowait = true, silent = true, desc = "Linguistics" },
        },
        {
            ";r",
            function()
                replace.replace:activate()
            end,
            { nowait = true, silent = true, desc = "Replace" },
        },
        {
            ";q",
            function()
                quickfix.quickfix:activate()
            end,
            { nowait = true, silent = true, desc = "Quickfix" },
        },
        {
            ";o",
            function()
                location.location:activate()
            end,
            { nowait = true, silent = true, desc = "Location" },
        },
        {
            ";f",
            function()
                fzf.fzf_menu:activate()
            end,
            { nowait = true, silent = true, desc = "FZF" },
        },
        {
            ";t",
            function()
                telescope.telescope_menu:activate()
            end,
            { nowait = true, silent = true, desc = "Telescope" },
        },
        {
            ";g",
            function()
                git.git_menu:activate()
            end,
            { nowait = true, silent = true, desc = "GIT" },
        },
        {
            ";s",
            function()
                glance.glance:activate()
            end,
            { nowait = true, silent = true, desc = "Glance" },
        },
        {
            ";l",
            function()
                diagnostics.diagnostics:activate()
            end,
            { nowait = true, silent = true, desc = "LSP" },
        },
        {
            ";d",
            function()
                dap.dap:activate()
            end,
            { nowait = true, silent = true, desc = "DAP" },
        },
        {
            ";'",
            function()
                neotest.neotest:activate()
            end,
            { nowait = true, silent = true, desc = "Neotest" },
        },
        {
            ";w",
            function()
                local current_buf = vim.api.nvim_get_current_buf()
                local file_path = vim.api.nvim_buf_get_name(current_buf)
                local file_name = vim.fn.fnamemodify(file_path, ":t")
                if file_name == "package.json" then
                    dependencies_ft.package_info_hydra:activate()
                elseif file_name == "Cargo.toml" then
                    dependencies_ft.crates_hydra:activate()
                elseif file_name == "pubspec.yaml" then
                    dependencies_ft.pubspec_assist_hydra:activate()
                end
            end,
            { nowait = true, silent = true, desc = "Dependencies" },
        },
        {
            ";p",
            function()
                plugins.plugins:activate()
            end,
            { nowait = true, silent = true, desc = "PlugIns" },
        },
        { "<C-q>", nil, { exit = true, desc = false } },
    },
})
