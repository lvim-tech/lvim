local Hydra = require("hydra")
local lvim = require("modules.base.configs.ui.hydra.lvim")
local common = require("modules.base.configs.ui.hydra.common")
local navigation = require("modules.base.configs.ui.hydra.navigation")
local replace = require("modules.base.configs.ui.hydra.replace")
local explorer = require("modules.base.configs.ui.hydra.explorer")
local comment_annotation_fold = require("modules.base.configs.ui.hydra.comment_annotation_fold")
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
local vimtex = require("modules.base.configs.ui.hydra.vimtex")

local list_hint = [[
                         HYDRA KEYS

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
LVIM IDE                   _;l_ │ _;a_                    Common
Navigation                 _;n_ │ _;r_                   Replace
Vimtex                     _;v_ │ _;e_                  Explorer
Comment, annotation, fold  _;c_ │ _;u_               Linguistics
Telescope                  _;t_ │ _;z_                       FZF
GIT                        _;g_ │ _;q_                  Quickfix
Location                   _;o_ │ _;d_               Diagnostics
Glance                     _;s_ │ _;p_                       DAP
Neotest                    _;'_ │ _;m_                 Termminal
Dependencies               _;w_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                         exit _<Esc>_
]]

Hydra({
    name = "HYDRA KEYS",
    hint = list_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    mode = { "n", "x", "v" },
    body = ";;",
    heads = {
        {
            ";l",
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
            ";r",
            function()
                replace.replace:activate()
            end,
            { nowait = true, silent = true, desc = "Replace" },
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
                comment_annotation_fold.comment_annotation_hint:activate()
            end,
            { nowait = true, silent = true, desc = "Comment, annotation, fold" },
        },
        {
            ";u",
            function()
                linguistics.linguistics:activate()
            end,
            { nowait = true, silent = true, desc = "Linguistics" },
        },
        {
            ";t",
            function()
                telescope.telescope_menu:activate()
            end,
            { nowait = true, silent = true, desc = "Telescope" },
        },
        {
            ";z",
            function()
                fzf.fzf_menu:activate()
            end,
            { nowait = true, silent = true, desc = "FZF" },
        },
        {
            ";g",
            function()
                git.git_menu:activate()
            end,
            { nowait = true, silent = true, desc = "GIT" },
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
            ";d",
            function()
                diagnostics.diagnostics:activate()
            end,
            { nowait = true, silent = true, desc = "Diagnostics" },
        },
        {
            ";s",
            function()
                glance.glance:activate()
            end,
            { nowait = true, silent = true, desc = "Glance" },
        },
        {
            ";p",
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
            ";m",
            function()
                terminal.terminal:activate()
            end,
            { nowait = true, silent = true, desc = "Terminal" },
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
            ";v",
            function()
                vimtex.vimtex:activate()
            end,
            { nowait = true, silent = true, desc = "Vimtex" },
        },
        { "<Esc>", nil, { exit = true, desc = false } },
    },
})
