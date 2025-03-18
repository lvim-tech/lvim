local global = require("core.global")
local funcs = require("core.funcs")
local options = require("configs.base.options")
local keymaps = require("configs.base.keymaps")
local keymaps_ft = require("configs.base.keymaps_ft")
local icons = require("configs.base.ui.icons")
local group = vim.api.nvim_create_augroup("LvimIDE", {
    clear = true,
})
local lvim_ui_config = require("modules.base.configs.ui")
local editor_config = require("modules.base.configs.editor")
local ui_config = require("modules.base.configs.ui")
local version_control_config = require("modules.base.configs.version_control")

local configs = {}

configs["base_lvim"] = function()
    local function lvim_theme()
        local status
        if _G.LVIM_SETTINGS.theme == "lvim-dark" then
            status = "Lvim Dark"
        elseif _G.LVIM_SETTINGS.theme == "lvim-darker" then
            status = "Lvim Darker"
        elseif _G.LVIM_SETTINGS.theme == "lvim-light" then
            status = "Lvim Light"
        elseif _G.LVIM_SETTINGS.theme == "lvim-kanagawa" then
            status = "Lvim Kanagawa"
        end
        ui_config = require("lvim-ui-config.config")
        local select = require("lvim-ui-config.select")
        local opts = ui_config.select({
            "Lvim Dark",
            "Lvim Darker",
            "Lvim Light",
            "Lvim Kanagawa",
            "Cancel",
        }, { prompt = "Theme (" .. status .. ")" }, {})
        select(opts, function(choice)
            if choice == "Cancel" then
            else
                local user_choice = string.lower(choice)
                user_choice = string.gsub(user_choice, " ", "-")
                _G.LVIM_SETTINGS["theme"] = user_choice
                vim.cmd("colorscheme " .. user_choice)
                funcs.write_file(global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
            end
        end)
    end
    vim.api.nvim_create_user_command("LvimTheme", lvim_theme, {})
    local function lvim_float_height()
        local status = tostring(_G.LVIM_SETTINGS.floatheight)
        if status == "1" then
            status = "1.0"
        end
        local select = require("lvim-ui-config.select")
        local notify = require("lvim-ui-config.notify")
        local opts = ui_config.select({
            "0.1",
            "0.2",
            "0.3",
            "0.4",
            "0.5",
            "0.6",
            "0.7",
            "0.8",
            "0.9",
            "1.0",
            "Cancel",
        }, { prompt = "Float height (current: " .. status .. ")" }, {})
        select(opts, function(choice)
            if choice == "Cancel" then
            else
                local user_choice = choice
                notify.info("Float height: " .. choice, { title = "LVIM IDE" })
                _G.LVIM_SETTINGS["floatheight"] = tonumber(user_choice) + 0.0
                funcs.write_file(global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
                editor_config.fzf_lua()
                version_control_config.lvim_forgit()
            end
        end)
    end
    vim.api.nvim_create_user_command("LvimFloatHeight", lvim_float_height, {})
    vim.api.nvim_create_user_command(
        "EditorConfigCreate",
        "lua require'core.funcs'.copy_file(require'core.global'.lvim_path .. '/.configs/templates/.editorconfig', vim.fn.getcwd() .. '/.editorconfig')",
        {}
    )
    vim.api.nvim_create_user_command("RemoveComments", "lua require'core.funcs'.remove_comments()", {})
    vim.keymap.set("n", "gcd", function()
        vim.cmd("RemoveComments")
    end, { noremap = true, silent = true, desc = "Delete all comments" })
    vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
            local color_base = funcs.get_highlight("Folded")
            local bg = color_base.bg
            local bg_dark = funcs.blend(bg, 0.8, "#000000")
            local bg_float = funcs.get_highlight("NormalFloat").bg
            local gray = funcs.get_highlight("NonText").fg
            local fg = gray
            local fg_light = funcs.blend(fg, 0.4, "#FFFFFF")
            local blue = funcs.get_highlight("Function").fg
            local green = funcs.get_highlight("String").fg
            local orange = funcs.get_highlight("Constant").fg
            local red = funcs.get_highlight("DiagnosticError").fg
            local cyan = funcs.get_highlight("Special").fg
            local purple = funcs.get_highlight("Statement").fg
            local diag_error = funcs.get_highlight("DiagnosticError").fg
            local diag_warn = funcs.get_highlight("DiagnosticWarn").fg
            local diag_hint = funcs.get_highlight("DiagnosticHint").fg
            local diag_info = funcs.get_highlight("DiagnosticInfo").fg
            _G.LVIM_COLORS = {
                bg = vim.o.background == "dark" and bg or fg,
                bg_dark = vim.o.background == "dark" and bg_dark or fg_light,
                bg_float = bg_float,
                fg = vim.o.background == "dark" and fg or bg,
                fg_light = vim.o.background == "dark" and fg_light or bg_dark,
                gray = gray,
                blue = blue,
                green = green,
                red = red,
                orange = orange,
                cyan = cyan,
                purple = purple,
                diag_error = diag_error,
                diag_warn = diag_warn,
                diag_hint = diag_hint,
                diag_info = diag_info,
            }
            vim.api.nvim_set_hl(0, "WinBar", { bg = _G.LVIM_COLORS.bg_dark, fg = _G.LVIM_COLORS.fg })
            vim.api.nvim_set_hl(0, "WinBarNC", { bg = _G.LVIM_COLORS.bg_dark, fg = _G.LVIM_COLORS.fg })
            lvim_ui_config.heirline_nvim()
            lvim_ui_config.nvim_window_picker()
            editor_config.tabby_nvim()
            editor_config.neocomposer_nvim()
            version_control_config.lvim_forgit()
        end,
    })
end

configs["base_options"] = function()
    options.global()
    vim.g.gitblame_enabled = 0
    vim.g.gitblame_highlight_group = "CursorLine"
    pcall(function()
        vim.opt.splitkeep = "screen"
    end)
    vim.g.netrw_banner = 0
    vim.g.netrw_hide = 1
    vim.g.netrw_browse_split = 0
    vim.g.netrw_altv = 1
    vim.g.netrw_liststyle = 1
    vim.g.netrw_winsize = 20
    vim.g.netrw_keepdir = 1
    vim.g.netrw_list_hide = "(^|ss)\zs.S+"
    vim.g.netrw_localcopydircmd = "cp -r"
end

configs["base_events"] = function()
    vim.api.nvim_create_autocmd("FileType", {
        pattern = {
            "markdown",
        },
        callback = function()
            vim.opt_local.wrap = false
        end,
        group = group,
    })
    vim.api.nvim_create_autocmd("FileType", {
        pattern = {
            "text",
            "markdown",
            "org",
        },
        callback = function()
            vim.opt_local.listchars = "tab:  ,nbsp: ,trail: ,space: ,extends:→,precedes:←"
        end,
        group = group,
    })
    vim.api.nvim_create_autocmd("FileType", {
        pattern = {
            "c",
            "cpp",
            "dart",
            "haskell",
            "objc",
            "objcpp",
            "ruby",
            "markdown",
            "org",
        },
        callback = function()
            vim.bo.syntax = ""
            vim.opt_local.tabstop = 2
            vim.opt_local.shiftwidth = 2
        end,
        group = group,
    })
    vim.api.nvim_create_autocmd("FileType", {
        pattern = {
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
        },
        callback = function()
            vim.opt_local.number = false
            vim.opt_local.relativenumber = false
            vim.opt_local.cursorcolumn = false
            vim.opt_local.colorcolumn = "0"
        end,
        group = group,
    })
end

configs["base_languages"] = function()
    vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
        callback = function()
            require("languages").setup()
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
    funcs.keymaps("i", { noremap = true, silent = true }, keymaps.insert)
    keymaps_ft.set_keymaps_ft()
end

configs["base_which_key"] = function()
    local function lvim_keys_helper()
        ui_config = require("lvim-ui-config.config")
        local select = require("lvim-ui-config.select")
        local notify = require("lvim-ui-config.notify")
        local status
        if _G.LVIM_SETTINGS.keyshelper == true then
            status = "Enabled"
        else
            status = "Disabled"
        end
        local opts = ui_config.select({
            "Enable",
            "Disable",
            "Cancel",
        }, { prompt = "Keys helper (" .. status .. ")" }, {})
        select(opts, function(choice)
            if choice == "Enable" then
                _G.LVIM_SETTINGS["keyshelper"] = true
                funcs.write_file(global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
                notify.info("Keys helper enabled. LVIM IDE needs to be restarted", { title = "LVIM IDE" })
            elseif choice == "Disable" then
                _G.LVIM_SETTINGS["keyshelper"] = false
                funcs.write_file(global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
                notify.info("Keys helper disabled. LVIM IDE needs to be restarted", { title = "LVIM IDE" })
            end
        end)
    end
    vim.api.nvim_create_user_command("LvimKeysHelper", lvim_keys_helper, {})
    local function lvim_keys_helper_delay()
        ui_config = require("lvim-ui-config.config")
        local select = require("lvim-ui-config.select")
        local notify = require("lvim-ui-config.notify")
        local status = _G.LVIM_SETTINGS.keyshelperdelay
        local opts = ui_config.select({
            0,
            50,
            100,
            200,
            300,
            400,
            500,
            600,
            700,
            800,
            900,
            1000,
            "Cancel",
        }, { prompt = "KeysHelperDelay (" .. status .. " ms)" }, {})
        select(opts, function(choice)
            if choice == "Cancel" then
            else
                _G.LVIM_SETTINGS["keyshelperdelay"] = tonumber(choice)
                funcs.write_file(global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
                vim.cmd("Lazy reload which-key.nvim")
                notify.info("Keys helper delay: " .. choice .. "ms", { title = "LVIM IDE" })
            end
        end)
    end
    vim.api.nvim_create_user_command("LvimKeysHelperDelay", lvim_keys_helper_delay, {})
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
    vim.g.CtrlSpaceEnableFilesCache = 1
    vim.g.CtrlSpaceSymbols = icons.ctrlspace
    vim.g.CtrlSpaceWorkspaceFile = global.lvim_path .. "/.cache/nvim/ctrlspace_workspaces"
end

configs["base_ask_packages"] = function()
    local lvim_packages_file = global.cache_path .. "/.lvim_packages"
    if funcs.file_exists(lvim_packages_file) then
        global.lvim_packages = true
    end
    vim.api.nvim_create_user_command("AskForPackagesFile", "lua require('core.funcs').delete_packages_file()", {})
end

return configs
