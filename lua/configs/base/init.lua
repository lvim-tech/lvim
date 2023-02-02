local global = require("core.global")
local funcs = require("core.funcs")
local options = require("configs.base.options")
local keymaps = require("configs.base.keymaps")
local group = vim.api.nvim_create_augroup("LvimIDE", {
    clear = true,
})

local configs = {}

configs["base_lvim"] = function()
    local function lvim_theme()
        local select = require("lvim-ui-config.select")
        local status
        if _G.LVIM_SETTINGS.colorschemes.theme == "dark" then
            status = "Dark"
        elseif _G.LVIM_SETTINGS.colorschemes.theme == "darksoft" then
            status = "DarkSoft"
        elseif _G.LVIM_SETTINGS.colorschemes.theme == "light" then
            status = "Light"
        end
        select({
            "Dark",
            "DarkSoft",
            "Light",
            "Cancel",
        }, { prompt = "Theme (" .. status .. ")" }, function(choice)
            if choice == "Cancel" then
            else
                local user_choice = string.lower(choice)
                _G.LVIM_SETTINGS.colorschemes.theme = user_choice
                funcs.write_file(global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
                local ui_config = require("modules.base.configs.ui")
                ui_config.heirline_nvim()
                ui_config.nvim_notify()
                ui_config.nvim_window_picker()
                ui_config.neo_tree_nvim()
                local editor_config = require("modules.base.configs.editor")
                editor_config.tabby_nvim()
                vim.cmd("colorscheme lvim-" .. user_choice)
            end
        end, "editor")
    end
    vim.api.nvim_create_user_command("LvimTheme", lvim_theme, {})
    local function lvim_auto_format()
        local select = require("lvim-ui-config.select")
        local status
        if _G.LVIM_SETTINGS.autoformat == true then
            status = "Enabled"
        else
            status = "Disabled"
        end
        select({
            "Enable",
            "Disable",
            "Cancel",
        }, { prompt = "AutoFormat (" .. status .. ")" }, function(choice)
            if choice == "Enable" then
                _G.LVIM_SETTINGS.autoformat = true
            elseif choice == "Disable" then
                _G.LVIM_SETTINGS.autoformat = false
            end
        end, "editor")
    end
    vim.api.nvim_create_user_command("LvimAutoFormat", lvim_auto_format, {})
end

configs["base_options"] = function()
    options.global()
    vim.g.indent_blankline_char = "▏"
    vim.g.gitblame_enabled = 0
    vim.g.gitblame_highlight_group = "CursorLine"
    pcall(function()
        vim.opt.splitkeep = "screen"
    end)
    vim.g.netrw_banner = 0
    vim.g.netrw_hide = 1
    vim.g.netrw_browse_split = 0
    vim.g.netrw_altv = 1
    vim.g.netrw_liststyle = 4
    vim.g.netrw_winsize = 20
    vim.g.netrw_keepdir = 1
    vim.g.netrw_list_hide = "(^|ss)\zs.S+"
    vim.g.netrw_localcopydircmd = "cp -r"
    vim.api.nvim_create_autocmd("FileType", {
        pattern = {
            "netrw",
        },
        callback = function()
            vim.api.nvim_set_keymap("n", "<Esc>", "<Cmd>:bd<CR>", {})
            vim.api.nvim_set_keymap("n", ".", "gh", {})
            vim.api.nvim_set_keymap("n", "P", "<C-w>z", {})
            vim.api.nvim_set_keymap("n", ".", "gh", {})
            vim.api.nvim_set_keymap("n", "<TAB>", "mf", {})
            vim.api.nvim_set_keymap("n", "<S-TAB>", "mF", {})
            vim.api.nvim_set_keymap("n", "<Leader><TAB>", "mu", {})
            vim.api.nvim_set_keymap("n", "fc", "mc", {})
            vim.api.nvim_set_keymap("n", "fC", "mtmc", {})
            vim.api.nvim_set_keymap("n", "fx", "mm", {})
            vim.api.nvim_set_keymap("n", "fX", "mtmm", {})
            vim.api.nvim_set_keymap("n", "f;", "mx", {})
            vim.api.nvim_set_keymap("n", "bb", "mb", {})
            vim.api.nvim_set_keymap("n", "bd", "mB", {})
            vim.api.nvim_set_keymap("n", "bl", "gb", {})
            vim.api.nvim_set_keymap("n", "H", "u", {})
            vim.api.nvim_set_keymap("n", "fa", "d", {})
            vim.api.nvim_set_keymap("n", "ff", [[%:w<CR>]], {})
            vim.api.nvim_set_keymap("n", "fr", "R", {})
            vim.api.nvim_set_keymap("n", "fd", "D", {})
        end,
        group = group,
    })
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
    vim.api.nvim_create_autocmd({
        "BufWinEnter",
    }, {
        pattern = "*.dart",
        callback = function()
            vim.cmd("set filetype=dart")
        end,
        group = group,
    })
    vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWinLeave" }, {
        callback = function()
            local buftype = vim.tbl_contains({ "prompt", "nofile", "help", "quickfix" }, vim.bo.buftype)
            local filetype = vim.tbl_contains({
                "NeogitStatus",
                "Outline",
                "calendar",
                "dapui_breakpoints",
                "dapui_scopes",
                "dapui_stacks",
                "dapui_watches",
                "git",
                "netrw",
                "octo",
                "org",
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
    vim.api.nvim_create_user_command("CloseFloatWindows", 'lua require("core.funcs").close_float_windows()', {})
    vim.api.nvim_create_user_command("SetGlobalPath", 'lua require("core.funcs").set_global_path()', {})
    vim.api.nvim_create_user_command("SetWindowPath", 'lua require("core.funcs").set_window_path()', {})
    vim.api.nvim_create_user_command("SudoWrite", 'lua require("core.funcs").sudo_write()', {})
    vim.api.nvim_create_user_command("Quit", 'lua require("core.funcs").quit()', {})
    vim.api.nvim_create_user_command("Save", function()
        vim.schedule(function()
            pcall(function()
                vim.cmd("w")
            end)
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
    vim.g.CtrlSpaceSearchTiming = 10
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
