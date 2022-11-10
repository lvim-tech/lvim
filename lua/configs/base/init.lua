local global = require("core.global")
local funcs = require("core.funcs")
local options = require("configs.base.options")
local keymaps = require("configs.base.keymaps")
local group = vim.api.nvim_create_augroup("LvimIDE", {
    clear = true,
})

local configs = {}

configs["base_vim"] = function()
    local theme = funcs.get_line(global.lvim_path .. "/.configs/lvim/theme", 1)
    _G.LVIM_THEME = {
        theme_plugin = "lvim-tech/lvim-colorscheme",
        theme_name = "lvim-colorscheme",
        theme = theme,
        colors = {
            dark = {
                bg = "#20262A",
                bg_01 = "#242B30",
                bg_02 = "#272F35",
                bg_03 = "#2A3339",
                bg_04 = "#364249",
                bg_05 = "#415058",
                bg_06 = "#4C5D67",
                fg_01 = "#97b9ac",
                fg_02 = "#83A598",
                fg_03 = "#6f9184",
                fg_04 = "#70A9A8",
                fg_05 = "#90C1A3",
                fg_06 = "#7CB692",
                blue_01 = "#148fc3",
                blue_02 = "#007baf",
                blue_03 = "#00679b",
                teal_01 = "#2ab198",
                teal_02 = "#169d84",
                teal_03 = "#028970",
                cyan_01 = "#00acc1",
                cyan_02 = "#0098ad",
                cyan_03 = "#008499",
                green_01 = "#A7C080",
                green_02 = "#93ac6c",
                green_03 = "#7f9858",
                red_01 = "#F16A5B",
                red_02 = "#dd5647",
                red_03 = "#c94233",
                orange_01 = "#ffae50",
                orange_02 = "#ff9a3c",
                orange_03 = "#F08628",
            },
            light = {
                bg = "#EAEAEA",
                bg_01 = "#FFFFFF",
                bg_02 = "#f5f5f5",
                bg_03 = "#ebebeb",
                bg_04 = "#e1e1e1",
                bg_05 = "#d7d7d7",
                bg_06 = "#cdcdcd",
                fg_01 = "#6f9184",
                fg_02 = "#5b7d70",
                fg_03 = "#9bbdb0",
                fg_04 = "#488180",
                fg_05 = "#5e8f71",
                fg_06 = "#4a8460",
                blue_01 = "#28a3d7",
                blue_02 = "#148fc3",
                blue_03 = "#007baf",
                teal_01 = "#2ab198",
                teal_02 = "#169d84",
                teal_03 = "#028970",
                cyan_01 = "#00acc1",
                cyan_02 = "#0098ad",
                cyan_03 = "#008499",
                green_01 = "#7f9858",
                green_02 = "#6b8444",
                green_03 = "#577030",
                red_01 = "#c94233",
                red_02 = "#b52e1f",
                red_03 = "#a11a0b",
                orange_01 = "#f08628",
                orange_02 = "#dc7214",
                orange_03 = "#c85e00",
            },
        },
    }
    local function lvim_theme()
        local select = require("lvim-ui-config.select")
        select({
            "Dark",
            "Light",
            "Cancel",
        }, { prompt = "Change theme" }, function(choice)
            if choice == "Cancel" then
            else
                local user_choice = string.lower(choice)
                funcs.write_file(global.lvim_path .. "/.configs/lvim/theme", user_choice)
                _G.LVIM_THEME.theme = user_choice
                local ui_config = require("modules.base.configs.ui")
                ui_config.heirline_nvim()
                ui_config.nvim_notify()
                ui_config.nvim_window_picker()
                ui_config.neo_tree_nvim()
                local editor_config = require("modules.base.configs.editor")
                editor_config.tabby_nvim()
                local languages_config = require("modules.base.configs.languages")
                languages_config.package_info_nvim()
                vim.cmd("colorscheme lvim-" .. user_choice)
            end
        end, "editor")
    end
    vim.api.nvim_create_user_command("LvimTheme", lvim_theme, {})
    options.global()
end

configs["base_options"] = function()
    vim.g.indent_blankline_char = "▏"
    vim.g.gitblame_enabled = 0
    vim.g.gitblame_highlight_group = "CursorLine"
    pcall(function()
        vim.opt.splitkeep = "screen"
    end)
end

configs["base_events"] = function()
    vim.api.nvim_create_autocmd("FileType", {
        pattern = {
            "c",
            "cpp",
            "dart",
            "haskell",
            "objc",
            "objcpp",
            "ruby",
        },
        command = "setlocal ts=2 sw=2",
        group = group,
    })
    vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWinLeave" }, {
        callback = function()
            local buftype = vim.tbl_contains({ "prompt", "nofile", "help", "quickfix" }, vim.bo.buftype)
            local filetype = vim.tbl_contains({
                "calendar",
                "Outline",
                "git",
                "dapui_scopes",
                "dapui_breakpoints",
                "dapui_stacks",
                "dapui_watches",
                "NeogitStatus",
                "org",
                "octo",
                "toggleterm",
            }, vim.bo.filetype)
            if buftype or filetype then
                vim.opt_local.number = false
                vim.opt_local.relativenumber = false
                vim.opt_local.cursorcolumn = false
                vim.opt_local.colorcolumn = "0"
            end
        end,
        group = group,
    })
    vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWinLeave" }, {
        callback = function()
            local filetype = vim.tbl_contains({
                "tex",
            }, vim.bo.filetype)
            if filetype then
                vim.opt_local.cursorcolumn = false
                vim.opt_local.colorcolumn = "0"
            end
        end,
        group = group,
    })
end

configs["base_languages"] = function()
    vim.api.nvim_create_autocmd("BufWinEnter", {
        callback = function()
            require("languages.base").setup()
        end,
        group = group,
    })
end

configs["base_commands"] = function()
    vim.api.nvim_create_user_command("SetGlobalPath", 'lua require("core.funcs").set_global_path()', {})
    vim.api.nvim_create_user_command("SetWindowPath", 'lua require("core.funcs").set_window_path()', {})
    vim.api.nvim_create_user_command("SudoWrite", 'lua require("core.funcs").sudo_write()', {})
    vim.api.nvim_create_user_command("Quit", 'lua require("core.funcs").quit()', {})
    vim.api.nvim_create_user_command("Save", function()
        vim.schedule(function()
            if not vim.bo.readonly then
                vim.cmd("w")
            end
        end)
    end, {})
end

configs["base_keymaps"] = function()
    funcs.keymaps("n", { noremap = true, silent = true }, keymaps.normal)
    funcs.keymaps("x", { noremap = true, silent = true }, keymaps.visual)
end

configs["base_ctrlspace_pre_config"] = function()
    vim.g.ctrlspace_use_tablineend = 1
    vim.g.CtrlSpaceLoadLastWorkspaceOnStart = 0
    vim.g.CtrlSpaceSaveWorkspaceOnSwitch = 1
    vim.g.CtrlSpaceSaveWorkspaceOnExit = 1
    vim.g.CtrlSpaceUseTabline = 0
    vim.g.CtrlSpaceUseArrowsInTerm = 1
    vim.g.CtrlSpaceUseMouseAndArrowsInTerm = 1
    vim.g.CtrlSpaceGlobCommand = "rg --files --follow --hidden -g '!{.git/*,node_modules/*,target/*,vendor/*}'"
    vim.g.CtrlSpaceIgnoredFiles = "\v(tmp|temp)[\\/]"
    vim.g.CtrlSpaceSymbols = {
        CS = "",
        Sin = "",
        All = "",
        Vis = "★",
        File = "",
        Tabs = "ﱡ",
        CTab = "ﱢ",
        NTM = "⁺",
        WLoad = "ﰬ",
        WSave = "ﰵ",
        Zoom = "",
        SLeft = "",
        SRight = "",
        BM = "",
        Help = "",
        IV = "",
        IA = "",
        IM = " ",
        Dots = "ﳁ",
    }
end

configs["base_ask_packages"] = function()
    local lvim_packages_file = global.cache_path .. "/.lvim_packages"
    if funcs.file_exists(lvim_packages_file) then
        global.lvim_packages = true
    end
    vim.api.nvim_create_user_command("AskForPackagesFile", "lua require('core.funcs').delete_packages_file()", {})
end

return configs
