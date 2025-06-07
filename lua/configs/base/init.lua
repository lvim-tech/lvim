local options = require("configs.base.options")
local keymaps = require("configs.base.keymaps")
local keymaps_ft = require("configs.base.keymaps_ft")
local group = vim.api.nvim_create_augroup("LvimIDE", {
    clear = true,
})
local lvim_ui_config = require("modules.base.configs.ui")
local editor_config = require("modules.base.configs.editor")
local ui_config = require("modules.base.configs.ui")
local funcs = require("core.funcs")
local base_file_types = require("languages.base.file_types")
local user_file_types = require("languages.user.file_types")

local configs = {}

configs["base_lvim"] = function()
    vim.deprecate = function() end
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
        elseif _G.LVIM_SETTINGS.theme == "lvim-gruvbox" then
            status = "Lvim Gruvbox"
        elseif _G.LVIM_SETTINGS.theme == "lvim-everforest" then
            status = "Lvim Everforest"
        end
        ui_config = require("lvim-ui-config.config")
        local select = require("lvim-ui-config.select")
        local opts = ui_config.select({
            "Lvim Dark",
            "Lvim Darker",
            "Lvim Light",
            "Lvim Kanagawa",
            "Lvim Gruvbox",
            "Lvim Everforest",
            "Cancel",
        }, { prompt = "Theme (" .. status .. ")" }, {})
        select(opts, function(choice)
            if choice == "Cancel" then
            else
                local user_choice = string.lower(choice)
                user_choice = string.gsub(user_choice, " ", "-")
                _G.LVIM_SETTINGS["theme"] = user_choice
                vim.cmd("colorscheme " .. user_choice)
                funcs.write_file(_G.global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
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
                vim.notify("Float height: " .. choice, vim.log.levels.INFO, {
                    title = "LVIM IDE",
                })
                _G.LVIM_SETTINGS["floatheight"] = tonumber(user_choice) + 0.0
                funcs.write_file(_G.global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
                editor_config.fzf_lua()
            end
        end)
    end
    vim.api.nvim_create_user_command("LvimFloatHeight", lvim_float_height, {})
    vim.api.nvim_create_user_command(
        "EditorConfigCreate",
        "lua require'core.funcs'.copy_file(_G.global.lvim_path .. '/.configs/templates/.editorconfig', vim.fn.getcwd() .. '/.editorconfig')",
        { desc = "Create .editorconfig file from template" }
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
            local blue_bh = funcs.blend(blue, 0.1, bg)
            local blue_bl = funcs.blend(blue, 0.3, bg)
            local green_bh = funcs.blend(green, 0.1, bg)
            local green_bl = funcs.blend(green, 0.3, bg)
            local orange_bh = funcs.blend(orange, 0.1, bg)
            local orange_bl = funcs.blend(orange, 0.3, bg)
            local red_bh = funcs.blend(red, 0.1, bg)
            local red_bl = funcs.blend(red, 0.3, bg)
            local cyan_bh = funcs.blend(cyan, 0.1, bg)
            local cyan_bl = funcs.blend(cyan, 0.3, bg)
            local purple_bh = funcs.blend(purple, 0.1, bg)
            local purple_bl = funcs.blend(purple, 0.3, bg)
            _G.LVIM_COLORS = {
                bg = vim.o.background == "dark" and bg or fg,
                bg_dark = vim.o.background == "dark" and bg_dark or fg_light,
                bg_float = bg_float,
                fg = vim.o.background == "dark" and fg or bg,
                fg_light = vim.o.background == "dark" and fg_light or bg_dark,
                gray = gray,
                blue = blue,
                green = green,
                orange = orange,
                red = red,
                cyan = cyan,
                purple = purple,
                blue_bh = blue_bh,
                blue_bl = blue_bl,
                green_bh = green_bh,
                green_bl = green_bl,
                orange_bh = orange_bh,
                orange_bl = orange_bl,
                red_bh = red_bh,
                red_bl = red_bl,
                cyan_bh = cyan_bh,
                cyan_bl = cyan_bl,
                purple_bh = purple_bh,
                purple_bl = purple_bl,
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
        end,
        group = group,
    })
    vim.api.nvim_create_user_command("SortLuaTable", funcs.sort_lua_table, {})
    vim.api.nvim_create_user_command("CommandOutput", funcs.command_output, {
        desc = "Execute command and show output in window",
    })
    vim.keymap.set(
        "n",
        "<Leader>co",
        funcs.command_output,
        { noremap = true, silent = true, desc = "Execute command with output window" }
    )
end

configs["base_options"] = function()
    options.global()
end

configs["base_events"] = function()
    vim.api.nvim_create_autocmd("FileType", {
        pattern = {
            "markdown",
        },
        callback = function()
            vim.opt_local.foldtext = "v:lua.md_fold_text()"
            vim.opt_local.foldmethod = "expr"
            vim.opt_local.conceallevel = 2
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
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = "*",
        callback = function()
            if funcs.is_helm() then
                vim.bo.filetype = "helm"
            end
        end,
        group = group,
    })
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "helm",
        callback = function()
            vim.bo.commentstring = "{{/* %s */}}"
        end,
        group = group,
    })
end

configs["base_languages"] = function()
    vim.keymap.del("n", "grn")
    vim.keymap.del({ "n", "v" }, "gra")
    vim.keymap.del("n", "grr")
    vim.keymap.del("n", "gri")
    vim.keymap.del("n", "gO")
    vim.keymap.del("i", "<C-s>")
    _G.file_types = funcs.merge(base_file_types, user_file_types)
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
                vim.notify("Keys helper enabled. LVIM IDE needs to be restarted", vim.log.levels.INFO, {
                    title = "LVIM IDE",
                })
            elseif choice == "Disable" then
                _G.LVIM_SETTINGS["keyshelper"] = false
                funcs.write_file(global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
                vim.notify("Keys helper disabled. LVIM IDE needs to be restarted", vim.log.levels.INFO, {
                    title = "LVIM IDE",
                })
            end
        end)
    end
    vim.api.nvim_create_user_command("LvimKeysHelper", lvim_keys_helper, {})
    local function lvim_keys_helper_delay()
        ui_config = require("lvim-ui-config.config")
        local select = require("lvim-ui-config.select")
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
                vim.notify("Keys helper delay: " .. choice .. "ms", vim.log.levels.INFO, {
                    title = "LVIM IDE",
                })
            end
        end)
    end
    vim.api.nvim_create_user_command("LvimKeysHelperDelay", lvim_keys_helper_delay, {})
end

return configs
