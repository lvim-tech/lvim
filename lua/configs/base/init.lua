local global = require("core.global")
local funcs = require("core.funcs")
local options = require("configs.base.options")
local keymaps = require("configs.base.keymaps")
local keymaps_ft = require("configs.base.keymaps_ft")
local icons = require("configs.base.ui.icons")
local group = vim.api.nvim_create_augroup("LvimIDE", {
    clear = true,
})

local configs = {}

configs["base_lvim"] = function()
    vim.api.nvim_create_autocmd("OptionSet", {
        callback = function()
            vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"
        end,
        group = group,
    })
    local function lvim_theme()
        local status
        if _G.LVIM_SETTINGS.theme == "lvim-dark" then
            status = "Lvim Dark"
        elseif _G.LVIM_SETTINGS.theme == "lvim-dark-soft" then
            status = "Lvim Dark Soft"
        elseif _G.LVIM_SETTINGS.theme == "lvim-light" then
            status = "Lvim Light"
        elseif _G.LVIM_SETTINGS.theme == "lvim-gruvbox-dark" then
            status = "Lvim Gruvbox Dark"
        elseif _G.LVIM_SETTINGS.theme == "lvim-gruvbox-dark-soft" then
            status = "Lvim Gruvbox Dark Soft"
        elseif _G.LVIM_SETTINGS.theme == "lvim-everforest-dark" then
            status = "Lvim Everforest Dark"
        elseif _G.LVIM_SETTINGS.theme == "lvim-everforest-dark-soft" then
            status = "Lvim Everforest Dark Soft"
        elseif _G.LVIM_SETTINGS.theme == "lvim-solarized-dark" then
            status = "Lvim Solarized Dark"
        elseif _G.LVIM_SETTINGS.theme == "lvim-catppuccin-dark" then
            status = "Lvim Catppuccin Dark"
        elseif _G.LVIM_SETTINGS.theme == "lvim-catppuccin-dark-soft" then
            status = "Lvim Catppuccin Dark Soft"
        end
        local ui_config = require("lvim-ui-config.config")
        local select = require("lvim-ui-config.select")
        local notify = require("lvim-ui-config.notify")
        local opts = ui_config.select({
            "Lvim Dark",
            "Lvim Dark Soft",
            "Lvim Light",
            "Lvim Everforest Dark",
            "Lvim Everforest Dark Soft",
            "Lvim Gruvbox Dark",
            "Lvim Gruvbox Dark Soft",
            "Lvim Catppuccin Dark",
            "Lvim Catppuccin Dark Soft",
            "Lvim Solarized Dark",
            "Cancel",
        }, { prompt = "Theme (" .. status .. ")" }, {})
        select(opts, function(choice)
            if choice == "Cancel" then
            else
                local user_choice = string.lower(choice)
                user_choice = string.gsub(user_choice, " ", "-")
                _G.LVIM_SETTINGS.theme = user_choice
                vim.cmd("colorscheme " .. user_choice)
                funcs.write_file(global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
                local lvim_ui_config = require("modules.base.configs.ui")
                lvim_ui_config.heirline_nvim()
                lvim_ui_config.nvim_notify()
                lvim_ui_config.nvim_window_picker()
                lvim_ui_config.neo_tree_nvim()
                lvim_ui_config.lvim_fm()
                local editor_config = require("modules.base.configs.editor")
                editor_config.tabby_nvim()
                editor_config.neocomposer_nvim()
                local version_control_config = require("modules.base.configs.version_control")
                version_control_config.lvim_forgit()
                notify.info("Theme: " .. choice, { title = "LVIM IDE" })
            end
        end)
    end
    vim.api.nvim_create_user_command("LvimTheme", lvim_theme, {})
    local function lvim_float_height()
        local status = tostring(_G.LVIM_SETTINGS.floatheight)
        if status == "1" then
            status = "1.0"
        end
        local ui_config = require("lvim-ui-config.config")
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
                _G.LVIM_SETTINGS.floatheight = tonumber(user_choice) + 0.0
                funcs.write_file(global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
                local editor_config = require("modules.base.configs.editor")
                editor_config.fzf_lua()
                editor_config.telescope_nvim()
                local lvim_ui_config = require("modules.base.configs.ui")
                lvim_ui_config.lvim_fm()
                local version_control_config = require("modules.base.configs.version_control")
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
        callback = function()
            vim.schedule(function()
                vim.opt_local.tabstop = 2
                vim.opt_local.shiftwidth = 2
            end)
        end,
        group = group,
    })
    vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWinLeave" }, {
        callback = function()
            local buftype = vim.tbl_contains({
                "prompt",
                "nofile",
                "help",
                "quickfix",
            }, vim.bo.buftype)
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
                vim.schedule(function()
                    vim.opt_local.number = false
                    vim.opt_local.relativenumber = false
                    vim.opt_local.cursorcolumn = false
                    vim.opt_local.colorcolumn = "0"
                end)
            end
        end,
        group = group,
    })
    vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWinLeave" }, {
        callback = function()
            local filetype = vim.tbl_contains({ "tex" }, vim.bo.filetype)
            if filetype then
                vim.schedule(function()
                    vim.opt_local.cursorcolumn = false
                    vim.opt_local.colorcolumn = "0"
                end)
            end
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
    keymaps_ft.set_keymaps_ft()
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
end

configs["base_ask_packages"] = function()
    local lvim_packages_file = global.cache_path .. "/.lvim_packages"
    if funcs.file_exists(lvim_packages_file) then
        global.lvim_packages = true
    end
    vim.api.nvim_create_user_command("AskForPackagesFile", "lua require('core.funcs').delete_packages_file()", {})
end

return configs
