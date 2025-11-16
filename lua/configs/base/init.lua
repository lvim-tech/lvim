local options = require("configs.base.options")
local keymaps = require("configs.base.keymaps")
local keymaps_ft = require("configs.base.keymaps_ft")
local group = vim.api.nvim_create_augroup("LvimIDE", {
    clear = true,
})
local funcs = require("core.funcs")
local base_file_types = require("languages.base.file_types")
local user_file_types = require("languages.user.file_types")

local configs = {}

configs["base_options"] = function()
    options.global()
end

configs["base_lvim"] = function()
    vim.deprecate = function() end
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
            local function get_hl_fg(name)
                if not name then
                    return nil
                end
                if vim.api.nvim_get_hl then
                    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
                    if ok and hl then
                        local col = hl.fg or hl["foreground"]
                        if col then
                            if type(col) == "number" then
                                return string.format("#%06x", col)
                            elseif type(col) == "string" then
                                return col
                            end
                        end
                    end
                end
                local id = vim.fn.hlID(name)
                if id ~= 0 then
                    local synfg = vim.fn.synIDattr(vim.fn.synIDtrans(id), "fg#")
                    if synfg ~= "" then
                        return synfg
                    end
                end
                return nil
            end
            local git_add = get_hl_fg("MiniDiffSignAdd") or get_hl_fg("GitSignsAdd") or get_hl_fg("DiffAdd")
            local git_change = get_hl_fg("MiniDiffSignChange") or get_hl_fg("GitSignsChange") or get_hl_fg("DiffText")
            local git_delete = get_hl_fg("MiniDiffSignDelete") or get_hl_fg("GitSignsDelete") or get_hl_fg("DiffDelete")
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
                git_add = git_add or green,
                git_change = git_change or orange,
                git_delete = git_delete or red,
            }
            vim.api.nvim_set_hl(0, "WinBar", { bg = _G.LVIM_COLORS.bg_dark, fg = _G.LVIM_COLORS.fg })
            vim.api.nvim_set_hl(0, "WinBarNC", { bg = _G.LVIM_COLORS.bg_dark, fg = _G.LVIM_COLORS.fg })
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

configs["base_events"] = function()
    vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
        pattern = {
            "markdown",
        },
        callback = function()
            vim.opt_local.foldtext = "v:lua.md_fold_text()"
            vim.opt_local.foldmethod = "expr"
            vim.opt_local.conceallevel = 2
            vim.opt_local.wrap = false
            vim.opt_local.number = false
            vim.opt_local.relativenumber = false
            vim.opt_local.colorcolumn = "0"
            vim.opt_local.cursorcolumn = false
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
            "fyler",
            "Fyler",
            "neo-tree",
            "time-machine-list",
        },
        callback = function()
            vim.schedule(function()
                vim.opt_local.number = false
                vim.opt_local.relativenumber = false
                vim.opt_local.cursorcolumn = false
                vim.opt_local.colorcolumn = "0"
            end)
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
    vim.api.nvim_create_user_command("FocusFloatWindow", 'lua require("core.funcs").focus_float_window()', {})
    vim.api.nvim_create_user_command("SetGlobalPath", 'lua require("core.funcs").set_global_path()', {})
    vim.api.nvim_create_user_command("SetWindowPath", 'lua require("core.funcs").set_window_path()', {})
    vim.api.nvim_create_user_command("SudoWrite", 'lua require("core.funcs").sudo_write()', {})
    vim.api.nvim_create_user_command("Quit", 'lua require("core.ext.quite").quit()', {})
    vim.api.nvim_create_user_command("Save", function()
        vim.schedule(function()
            pcall(function()
                vim.cmd("w")
            end)
        end)
    end, {})

    require("core.ext.gxplus").setup()
    vim.keymap.set("n", "gx", "<cmd>GxPlus<CR>", { silent = true, desc = "GxPlus" })
end

configs["base_keymaps"] = function()
    funcs.keymaps("n", { noremap = true, silent = true }, keymaps.normal)
    funcs.keymaps("x", { noremap = true, silent = true }, keymaps.visual)
    funcs.keymaps("i", { noremap = true, silent = true }, keymaps.insert)
    keymaps_ft.set_keymaps_ft()
end

return configs
