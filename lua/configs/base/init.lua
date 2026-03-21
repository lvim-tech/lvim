-- Base configuration bootstrap for LVIM IDE.
-- Exports a table of named setup functions that are called in sequence by the
-- main init to wire together options, keymaps, autocommands, user commands,
-- language file-type merging and the colour-palette extraction pipeline.

---@module "configs.base.init"

local options = require("configs.base.options")
local keymaps = require("configs.base.keymaps")
local keymaps_ft = require("configs.base.keymaps_ft")

---@type integer  Shared autocommand group used by all LvimIDE autocmds.
local group = vim.api.nvim_create_augroup("LvimIDE", {
    clear = true,
})

local funcs = require("core.funcs")

---@type table<string, fun(): nil>  Map of setup-phase name → setup function.
local configs = {}

-- Apply global vim.g / vim.opt settings (delegates to configs.base.options).
configs["base_options"] = function()
    options.global()
end

-- Wire LVIM-specific global behaviour: suppress deprecation noise, register
-- utility user commands (EditorConfigCreate, RemoveComments, SortLuaTable,
-- CommandOutput) and set up the ColorScheme autocmd that rebuilds
-- _G.LVIM.colors from the active theme.
configs["base_lvim"] = function()
    -- Silence Neovim deprecation warnings that originate from third-party plugins.
    vim.deprecate = function() end

    vim.api.nvim_create_user_command(
        "EditorConfigCreate",
        "lua require'core.funcs'.copy_file(_G.LVIM.global.lvim_path .. '/.configs/templates/.editorconfig', vim.fn.getcwd() .. '/.editorconfig')",
        { desc = "Create .editorconfig file from template" }
    )
    vim.api.nvim_create_user_command("RemoveComments", "lua require'core.funcs'.remove_comments()", {})
    vim.keymap.set("n", "gcd", function()
        vim.cmd("RemoveComments")
    end, { noremap = true, silent = true, desc = "Delete all comments" })

    -- Rebuild _G.LVIM.colors (LvimColors) whenever the colorscheme changes so
    -- that all UI components that reference palette entries stay consistent.
    vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
            -- Extract semantic colors from standard highlight groups.
            local color_base = funcs.get_highlight("Folded")
            ---@type string
            local bg = color_base.bg
            ---@type string  bg darkened by 20% toward black
            local bg_dark = funcs.blend(bg, 0.8, "#000000")
            ---@type string
            local bg_float = funcs.get_highlight("NormalFloat").bg
            ---@type string  gray used as the base foreground neutral
            local gray = funcs.get_highlight("NonText").fg
            local fg = gray
            ---@type string  fg lightened 40% toward white for secondary text
            local fg_light = funcs.blend(fg, 0.4, "#FFFFFF")

            -- Semantic accent colors pulled from well-known highlight groups.
            local blue = funcs.get_highlight("Function").fg
            local green = funcs.get_highlight("String").fg
            local orange = funcs.get_highlight("Constant").fg
            local red = funcs.get_highlight("DiagnosticError").fg
            local cyan = funcs.get_highlight("Special").fg
            local purple = funcs.get_highlight("Statement").fg

            -- Diagnostic colors.
            local diag_error = funcs.get_highlight("DiagnosticError").fg
            local diag_warn = funcs.get_highlight("DiagnosticWarn").fg
            local diag_hint = funcs.get_highlight("DiagnosticHint").fg
            local diag_info = funcs.get_highlight("DiagnosticInfo").fg

            -- Pre-blended tints: _bh = 10% opacity over bg, _bl = 30% opacity.
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

            -- Resolve git sign colors with a priority fallback chain:
            -- MiniDiff → GitSigns → core Diff highlight groups.
            ---@param name string  Highlight group name to query
            ---@return string|nil  Hex color string or nil if not defined
            local function get_hl_fg(name)
                if not name then
                    return nil
                end
                -- Prefer the modern nvim_get_hl API (Neovim 0.9+).
                if vim.api.nvim_get_hl then
                    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
                    if ok and hl then
                        local col = hl.fg or hl["foreground"]
                        if col then
                            if type(col) == "number" then
                                -- nvim_get_hl returns integers; convert to #rrggbb.
                                return string.format("#%06x", col)
                            elseif type(col) == "string" then
                                return col
                            end
                        end
                    end
                end
                -- Fallback: legacy synIDattr path for older Neovim versions.
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

            -- Populate the global LvimColors palette, swapping bg/fg for light themes.
            ---@type LvimColors
            _G.LVIM.colors = {
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
                -- Fall back to nearest semantic color if git signs are unset.
                git_add = git_add or green,
                git_change = git_change or orange,
                git_delete = git_delete or red,
            }

            -- Synchronise WinBar highlights with the freshly computed palette.
            vim.api.nvim_set_hl(0, "WinBar", { bg = _G.LVIM.colors.bg_dark, fg = _G.LVIM.colors.fg })
            vim.api.nvim_set_hl(0, "WinBarNC", { bg = _G.LVIM.colors.bg_dark, fg = _G.LVIM.colors.fg })

            -- Re-run heirline and UI setup so they pick up the new palette.
            require("modules.base.configs.ui").heirline_nvim.config()
            require("modules.base.configs.ui").ui_nvim.config()
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

-- Register filetype-specific autocommands:
-- Markdown visual overrides, prose listchars, 2-space indent for selected
-- languages, stripped UI for side-panel filetypes, Helm detection, and
-- Helm comment-string override.
configs["base_events"] = function()
    -- Markdown: custom fold text, no line numbers, no color column.
    vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
        pattern = { "markdown" },
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

    -- Prose filetypes: explicit listchars to surface invisible whitespace.
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "text", "markdown", "org" },
        callback = function()
            vim.opt_local.listchars = "tab:  ,nbsp: ,trail: ,space: ,extends:→,precedes:←"
        end,
        group = group,
    })

    -- Languages that conventionally use 2-space indentation.
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "c", "cpp", "dart", "haskell", "objc", "objcpp", "ruby", "markdown", "org" },
        callback = function()
            vim.opt_local.tabstop = 2
            vim.opt_local.shiftwidth = 2
        end,
        group = group,
    })

    -- Side-panel / tool filetypes: hide numbers and color column.
    -- vim.schedule defers the option changes so the window is fully initialised.
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

    -- Auto-detect Helm chart files and set the filetype so LSP and Tree-sitter
    -- use the correct grammar/server (requires core.funcs.is_helm()).
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = "*",
        callback = function()
            if funcs.is_helm() then
                vim.bo.filetype = "helm"
            end
        end,
        group = group,
    })

    -- Helm: use Go-template block comment syntax for commentstring.
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "helm",
        callback = function()
            vim.bo.commentstring = "{{/* %s */}}"
        end,
        group = group,
    })
end

-- Remove the default LSP keymaps injected by Neovim so LVIM can define its own.
configs["base_languages"] = function()
    -- Remove Neovim's built-in LSP default mappings before LVIM installs its own.
    vim.keymap.del("n", "grn")
    vim.keymap.del({ "n", "v" }, "gra")
    vim.keymap.del("n", "grr")
    vim.keymap.del("n", "gri")
    vim.keymap.del("n", "gO")
    vim.keymap.del("i", "<C-s>")
end

-- Create utility user commands for window/path management and register
-- the GxPlus URL/file opener.
configs["base_commands"] = function()
    vim.api.nvim_create_user_command("CloseFloatWindows", 'lua require("core.funcs").close_float_windows()', {})
    vim.api.nvim_create_user_command("FocusFloatWindow", 'lua require("core.funcs").focus_float_window()', {})
    vim.api.nvim_create_user_command("SetGlobalPath", 'lua require("core.funcs").set_global_path()', {})
    vim.api.nvim_create_user_command("SetWindowPath", 'lua require("core.funcs").set_window_path()', {})
    vim.api.nvim_create_user_command("SudoWrite", 'lua require("core.funcs").sudo_write()', {})
    -- Safe :w wrapped in pcall so write errors are non-fatal in macros/scripts.
    vim.api.nvim_create_user_command("Save", function()
        vim.schedule(function()
            pcall(function()
                vim.cmd("w")
            end)
        end)
    end, {})
end

-- Register all normal, visual and insert-mode keymaps, then apply
-- filetype-specific keymaps via keymaps_ft.
configs["base_keymaps"] = function()
    funcs.keymaps("n", { noremap = true, silent = true }, keymaps.normal)
    funcs.keymaps("x", { noremap = true, silent = true }, keymaps.visual)
    funcs.keymaps("i", { noremap = true, silent = true }, keymaps.insert)
    keymaps_ft.set_keymaps_ft()
end

return configs
