local global = require("core.global")
local funcs = require("core.funcs")
local options = require("configs.base.options")
local keymaps = require("configs.base.keymaps")
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
        end
        local ui_config = require("lvim-ui-config.config")
        local select = require("lvim-ui-config.select")
        local opts = ui_config.select({
            "Lvim Dark",
            "Lvim Dark Soft",
            "Lvim Light",
            "Lvim Everforest Dark",
            "Lvim Everforest Dark Soft",
            "Lvim Gruvbox Dark",
            "Lvim Gruvbox Dark Soft",
            "Lvim Solarized Dark",
            "Cancel",
        }, { prompt = "Theme (" .. status .. ")" }, {})
        select(opts, function(choice)
            if choice == "Cancel" then
            else
                local user_choice = string.lower(choice)
                user_choice = string.gsub(user_choice, " ", "-")
                vim.notify(user_choice)
                _G.LVIM_SETTINGS.theme = user_choice
                vim.cmd("colorscheme " .. user_choice)
                funcs.write_file(global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
                local lvim_ui_config = require("modules.base.configs.ui")
                lvim_ui_config.heirline_nvim()
                lvim_ui_config.nvim_notify()
                lvim_ui_config.nvim_window_picker()
                lvim_ui_config.neo_tree_nvim()
                local editor_config = require("modules.base.configs.editor")
                editor_config.tabby_nvim()
                editor_config.neocomposer_nvim()
            end
        end)
    end
    vim.api.nvim_create_user_command("LvimTheme", lvim_theme, {})
    local function lvim_auto_format()
        local status
        if _G.LVIM_SETTINGS.autoformat == true then
            status = "Enabled"
        else
            status = "Disabled"
        end
        local ui_config = require("lvim-ui-config.config")
        local select = require("lvim-ui-config.select")
        local opts = ui_config.select({
            "Enable",
            "Disable",
            "Cancel",
        }, { prompt = "AutoFormat (" .. status .. ")" }, {})
        select(opts, function(choice)
            if choice == "Enable" then
                _G.LVIM_SETTINGS.autoformat = true
                funcs.write_file(global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
            elseif choice == "Disable" then
                _G.LVIM_SETTINGS.autoformat = false
                funcs.write_file(global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
            end
        end)
    end
    vim.api.nvim_create_user_command("LvimAutoFormat", lvim_auto_format, {})
    local function lvim_inlay_hint()
        local status
        if _G.LVIM_SETTINGS.inlayhint == true then
            status = "Enabled"
        else
            status = "Disabled"
        end
        local ui_config = require("lvim-ui-config.config")
        local select = require("lvim-ui-config.select")
        local opts = ui_config.select({
            "Enable",
            "Disable",
            "Cancel",
        }, { prompt = "InlayHint (" .. status .. ")" }, {})
        select(opts, function(choice)
            if choice == "Enable" then
                local buffers = vim.api.nvim_list_bufs()
                for _, bufnr in ipairs(buffers) do
                    local clients = vim.lsp.buf_get_clients(bufnr)
                    if #clients > 0 then
                        for _, client in ipairs(clients) do
                            if client.server_capabilities.inlayHintProvider then
                                vim.lsp.inlay_hint(bufnr, true)
                            end
                        end
                    else
                        print("No LSP client associated with the buffer")
                    end
                end
                _G.LVIM_SETTINGS.inlayhint = true
                funcs.write_file(global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
            elseif choice == "Disable" then
                local buffers = vim.api.nvim_list_bufs()
                for _, bufnr in ipairs(buffers) do
                    local clients = vim.lsp.buf_get_clients(bufnr)
                    if #clients > 0 then
                        for _, client in ipairs(clients) do
                            if client.server_capabilities.inlayHintProvider then
                                vim.lsp.inlay_hint(bufnr, false)
                            end
                        end
                    else
                        print("No LSP client associated with the buffer")
                    end
                end
                _G.LVIM_SETTINGS.inlayhint = false
                funcs.write_file(global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
            end
        end)
    end
    vim.api.nvim_create_user_command("LvimInlayHint", lvim_inlay_hint, {})
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
    vim.api.nvim_create_autocmd("FileType", {
        pattern = {
            "netrw",
        },
        callback = function()
            vim.opt_local.statuscolumn = ""
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
    vim.cmd([[inoremap <silent><expr><A-BS>
    \ (&indentexpr isnot '' ? &indentkeys : &cinkeys) =~? '!\^F' &&
    \ &backspace =~? '.*eol\&.*start\&.*indent\&' &&
    \ !search('\S','nbW',line('.')) ? (col('.') != 1 ? "\<C-U>" : "") .
    \ "\<bs>" . (getline(line('.')-1) =~ '\S' ? "" : "\<C-F>") : "\<bs>"]])
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
