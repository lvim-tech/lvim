local icons = require("configs.base.ui.icons")

local config = {}

config.lvim_control_center = function()
    local lvim_control_center_status_ok, lvim_control_center = pcall(require, "lvim-control-center")
    if not lvim_control_center_status_ok then
        return
    end
    local lvim = require("modules.base.configs.editor.control_center.lvim")
    local general = require("modules.base.configs.editor.control_center.general")
    local appearance = require("modules.base.configs.editor.control_center.appearance")
    local lsp = require("modules.base.configs.editor.control_center.lsp")
    local commands = require("modules.base.configs.editor.control_center.commands")
    lvim_control_center.setup({
        groups = {
            lvim,
            general,
            appearance,
            lsp,
            commands,
        },
    })
    vim.keymap.set("n", "<Leader><Leader><Leader>", "<CMD>LvimControlCenter<CR>")
    vim.keymap.set("n", "<Leader><Leader>g", "<CMD>LvimControlCenter global<CR>")
    vim.keymap.set("n", "<Leader><Leader>a", "<CMD>LvimControlCenter appearance<CR>")
    vim.keymap.set("n", "<Leader><Leader>l", "<CMD>LvimControlCenter lsp<CR>")
    vim.keymap.set("n", "<Leader><Leader>c", "<CMD>LvimControlCenter commands<CR>")
end

config.lvim_space = function()
    local lvim_space_status_ok, lvim_space = pcall(require, "lvim-space")
    if not lvim_space_status_ok then
        return
    end
    lvim_space.setup({
        log = true,
        ui = {
            icons = {
                error = " ",
                warn = " ",
                info = " ",
                project = " ",
                project_active = " ",
                workspace = " ",
                workspace_active = " ",
                tab = " ",
                tab_active = " ",
                file = " ",
                file_active = " ",
                empty = "󰇘 ",
                pre = "➤ ",
            },
        },
    })
end

config.navigator_nvim = function()
    local navigator_status_ok, navigator = pcall(require, "Navigator")
    if not navigator_status_ok then
        return
    end
    navigator.setup({})
    vim.keymap.set("n", "<C-h>", "<CMD>NavigatorLeft<CR>")
    vim.keymap.set("n", "<C-l>", "<CMD>NavigatorRight<CR>")
    vim.keymap.set("n", "<C-k>", "<CMD>NavigatorUp<CR>")
    vim.keymap.set("n", "<C-j>", "<CMD>NavigatorDown<CR>")
end

config.fzf_lua = function()
    local fzf_lua_status_ok, fzf_lua = pcall(require, "fzf-lua")
    if not fzf_lua_status_ok then
        return
    end
    local img_previewer
    for _, v in ipairs({
        { cmd = "ueberzug", args = {} },
        { cmd = "chafa", args = { "{file}", "--format=symbols" } },
        { cmd = "viu", args = { "-b" } },
    }) do
        if vim.fn.executable(v.cmd) == 1 then
            img_previewer = vim.list_extend({ v.cmd }, v.args)
            break
        end
    end
    fzf_lua.setup({
        fzf_colors = true,
        defaults = {
            multiline = 1,
        },
        previewers = {
            builtin = {
                extensions = {
                    ["png"] = img_previewer,
                    ["jpg"] = img_previewer,
                    ["jpeg"] = img_previewer,
                    ["gif"] = img_previewer,
                    ["webp"] = img_previewer,
                },
                ueberzug_scaler = "fit_contain",
            },
        },
        fzf_opts = {
            ["--highlight-line"] = true,
            ["--border"] = "none",
            ["--layout"] = "reverse",
            ["--height"] = "100%",
            ["--info"] = "inline-right",
            ["--ansi"] = true,
        },
        winopts = function()
            local win_height = math.ceil(vim.api.nvim_get_option_value("lines", {}) * _G.LVIM_SETTINGS.floatheight)
            local win_width = math.ceil(vim.api.nvim_get_option_value("columns", {}) * 1)
            local col = math.ceil((vim.api.nvim_get_option_value("columns", {}) - win_width) * 1)
            local row = math.ceil((vim.api.nvim_get_option_value("lines", {}) - win_height) * 1)
            return {
                previewer = "builtin",
                title = "FZF LUA",
                title_pos = "center",
                width = win_width,
                height = win_height,
                row = row,
                col = col,
                border = { " ", " ", " ", " ", " ", " ", " ", " " },
                preview = {
                    layout = "horizontal",
                    vertical = "down:45%",
                    horizontal = "right:60%",
                    border = { " ", " ", " ", " ", " ", " ", " ", " " },
                },
            }
        end,
        keymap = {
            builtin = {
                ["<M-Esc>"] = "hide",
                ["<F1>"] = "toggle-help",
                ["<F2>"] = "toggle-fullscreen",
                ["<F3>"] = "toggle-preview-wrap",
                ["<F4>"] = "toggle-preview",
                ["<F5>"] = "toggle-preview-ccw",
                ["<F6>"] = "toggle-preview-cw",
                ["<F7>"] = "toggle-preview-ts-ctx",
                ["<F8>"] = "preview-ts-ctx-dec",
                ["<F9>"] = "preview-ts-ctx-inc",
                ["<S-Left>"] = "preview-reset",
                ["<C-d>"] = "preview-page-down",
                ["<C-u>"] = "preview-page-up",
                ["<M-S-down>"] = "preview-down",
                ["<M-S-up>"] = "preview-up",
            },
        },
    })
end

config.lvim_linguistics = function()
    local lvim_linguistics_status_ok, lvim_linguistics = pcall(require, "lvim-linguistics")
    if not lvim_linguistics_status_ok then
        return
    end
    lvim_linguistics.setup({
        base_config = {
            mode_language = {
                active = false,
                normal_mode_language = "us",
                insert_mode_language = "bg",
                insert_mode_languages = { "en", "fr", "de", "bg" },
            },
            spell = {
                active = false,
                language = "en",
                languages = {
                    en = {
                        spelllang = "en",
                        spellfile = "en.add",
                    },
                    fr = {
                        spelllang = "fr",
                        spellfile = "fr.add",
                    },
                    de = {
                        spelllang = "de",
                        spellfile = "de.add",
                    },
                    bg = {
                        spelllang = "bg",
                        spellfile = "bg.add",
                    },
                },
            },
        },
    })
    vim.keymap.set("n", "<C-c>l", function()
        vim.cmd("LvimLinguisticsTOGGLEInsertModeLanguage")
    end, { noremap = true, silent = true, desc = "LvimLinguisticsTOGGLEInsertModeLanguage" })
    vim.keymap.set("n", "<C-c>k", function()
        vim.cmd("LvimLinguisticsTOGGLESpelling")
    end, { noremap = true, silent = true, desc = "LvimLinguisticsTOGGLESpelling" })
end

config.rgflow_nvim = function()
    local rgflow_status_ok, rgflow = pcall(require, "rgflow")
    if not rgflow_status_ok then
        return
    end
    rgflow.setup({
        cmd_flags = "--smart-case --fixed-strings --ignore --max-columns 200",
        default_trigger_mappings = false,
        default_ui_mappings = true,
        default_quickfix_mappings = true,
        ui_top_line_char = "",
    })
end

config.vessel_nvim = function()
    local vessel_status_ok, vessel = pcall(require, "vessel")
    if not vessel_status_ok then
        return
    end
    vessel.opt.marks.highlights.path = "Title"
    vessel.opt.marks.highlights.not_loaded = "Folded"
    vessel.opt.marks.highlights.decorations = "Folded"
    vessel.opt.marks.highlights.mark = "Title"
    vessel.opt.marks.highlights.lnum = "Error"
    vessel.opt.marks.highlights.col = "CursorLineNr"
    vessel.opt.marks.highlights.line = "Folded"
    vessel.setup({
        create_commands = true,
        commands = {
            view_marks = "Marks",
            view_jumps = "Jumps",
        },
    })
    vim.keymap.set("n", "ml", "<Plug>(VesselViewLocalMarks)", { desc = "Marks view local" })
    vim.keymap.set("n", "mg", "<Plug>(VesselViewGlobalMarks)", { desc = "Marks view global" })
    vim.keymap.set("n", "mb", "<Plug>(VesselViewBufferMarks)", { desc = "Marks view buffer" })
    vim.keymap.set("n", "me", "<Plug>(VesselViewExternalMarks)", { desc = "Marks view external" })
    vim.keymap.set("n", "mjj", function()
        vessel.view_jumps()
    end, { desc = "Jumps all" })
    vim.keymap.set("n", "mjl", function()
        vessel.view_local_jumps()
    end, { desc = "Jumps local" })
    vim.keymap.set("n", "mje", function()
        vessel.view_external_jumps()
    end, { desc = "Jumps External" })

    -- Navigation
    local function jump_mark(mark_type, direction)
        mark_type = (mark_type or "local"):lower()
        direction = (direction or "next"):lower()
        local cur_buf = vim.api.nvim_get_current_buf()
        local cur_pos = vim.api.nvim_win_get_cursor(0)
        local cur_line = cur_pos[1]
        local marks_list
        if mark_type == "local" then
            marks_list = vim.fn.getmarklist(cur_buf)
        else
            marks_list = vim.fn.getmarklist()
        end
        local valid_marks = {}
        for _, m in ipairs(marks_list) do
            if m.mark and m.pos and type(m.pos) == "table" and m.pos[2] then
                local mark_name = m.mark
                local buf = m.pos[1] or cur_buf
                local line = m.pos[2]
                local col = m.pos[3] or 0
                if not vim.api.nvim_buf_is_valid(buf) then
                    goto continue
                end
                local ok, last = pcall(vim.api.nvim_buf_line_count, buf)
                if not ok or type(last) ~= "number" then
                    goto continue
                end
                if line < 1 or line > last then
                    goto continue
                end
                if mark_type == "local" then
                    if buf == cur_buf and mark_name:match("^'?%l$") then
                        table.insert(valid_marks, { buf = buf, line = line, col = col })
                    end
                else
                    if mark_name:match("^'?%u$") then
                        table.insert(valid_marks, { buf = buf, line = line, col = col })
                    end
                end
            end
            ::continue::
        end
        if #valid_marks == 0 then
            return
        end
        if mark_type == "local" then
            table.sort(valid_marks, function(a, b)
                return a.line < b.line
            end)
            if direction == "next" then
                for _, m in ipairs(valid_marks) do
                    if m.line > cur_line then
                        vim.api.nvim_win_set_cursor(0, { m.line, m.col })
                        return
                    end
                end
                vim.api.nvim_win_set_cursor(0, { valid_marks[1].line, valid_marks[1].col })
                return
            else
                for i = #valid_marks, 1, -1 do
                    if valid_marks[i].line < cur_line then
                        vim.api.nvim_win_set_cursor(0, { valid_marks[i].line, valid_marks[i].col })
                        return
                    end
                end
                vim.api.nvim_win_set_cursor(0, { valid_marks[#valid_marks].line, valid_marks[#valid_marks].col })
                return
            end
        else
            table.sort(valid_marks, function(a, b)
                if a.buf == b.buf then
                    return a.line < b.line
                end
                return a.buf < b.buf
            end)
            local function after(a, b)
                if a.buf == b.buf then
                    return a.line > b.line
                end
                return a.buf > b.buf
            end
            local function before(a, b)
                if a.buf == b.buf then
                    return a.line < b.line
                end
                return a.buf < b.buf
            end
            local cur_key = { buf = cur_buf, line = cur_line }
            if direction == "next" then
                for _, m in ipairs(valid_marks) do
                    if after(m, cur_key) then
                        if m.buf ~= cur_buf then
                            pcall(vim.api.nvim_set_current_buf, m.buf)
                        end
                        vim.api.nvim_win_set_cursor(0, { m.line, m.col })
                        return
                    end
                end
                local m = valid_marks[1]
                if m.buf ~= cur_buf then
                    pcall(vim.api.nvim_set_current_buf, m.buf)
                end
                vim.api.nvim_win_set_cursor(0, { m.line, m.col })
                return
            else
                for i = #valid_marks, 1, -1 do
                    local m = valid_marks[i]
                    if before(m, cur_key) then
                        if m.buf ~= cur_buf then
                            pcall(vim.api.nvim_set_current_buf, m.buf)
                        end
                        vim.api.nvim_win_set_cursor(0, { m.line, m.col })
                        return
                    end
                end
                local m = valid_marks[#valid_marks]
                if m.buf ~= cur_buf then
                    pcall(vim.api.nvim_set_current_buf, m.buf)
                end
                vim.api.nvim_win_set_cursor(0, { m.line, m.col })
                return
            end
        end
    end
    vim.keymap.set("n", "m]", function()
        jump_mark("local", "next")
    end, { desc = "Local mark Next" })
    vim.keymap.set("n", "m[", function()
        jump_mark("local", "prev")
    end, { desc = "Local mark Prev" })
    vim.keymap.set("n", "M]", function()
        jump_mark("global", "next")
    end, { desc = "Global mark Next" })
    vim.keymap.set("n", "M[", function()
        jump_mark("global", "prev")
    end, { desc = "Global mark Prev" })

    -- Set
    local function set_mark(lhs)
        vim.keymap.set("n", lhs, function()
            vim.api.nvim_feedkeys(
                vim.api.nvim_replace_termcodes(
                    lhs == "mm" and "<Plug>(VesselSetLocalMark)" or "<Plug>(VesselSetGlobalMark)",
                    true,
                    false,
                    true
                ),
                "n",
                false
            )
            vim.schedule(function()
                vim.cmd("redrawstatus")
            end)
        end, { desc = "Marks set " .. (lhs == "mm" and "local" or "global"), silent = true })
    end
    set_mark("mm")
    set_mark("mM")

    -- Delete
    local function uniq(list)
        local seen = {}
        local out = {}
        for _, v in ipairs(list) do
            if not seen[v] then
                seen[v] = true
                table.insert(out, v)
            end
        end
        return out
    end
    local function delete_marks(kind)
        kind = (kind or "local"):lower()
        local cur_buf = vim.api.nvim_get_current_buf()
        local marks_global = vim.fn.getmarklist()
        local marks_local = vim.fn.getmarklist(cur_buf)
        local letters = {}
        local function process_mark_entry(m, allow_local, allow_global)
            if not (m and m.mark and m.pos and type(m.pos) == "table" and m.pos[2]) then
                return
            end
            local name = tostring(m.mark):gsub("^'", "")
            local buf = m.pos[1] or cur_buf
            if allow_local and name:match("^%l$") and buf == cur_buf then
                table.insert(letters, name)
            end
            if allow_global and name:match("^%u$") then
                table.insert(letters, name)
            end
        end
        if kind == "local" then
            for _, m in ipairs(marks_local) do
                process_mark_entry(m, true, false)
            end
        elseif kind == "global" then
            for _, m in ipairs(marks_global) do
                process_mark_entry(m, false, true)
            end
        else
            for _, m in ipairs(marks_local) do
                process_mark_entry(m, true, false)
            end
            for _, m in ipairs(marks_global) do
                process_mark_entry(m, false, true)
            end
        end
        letters = uniq(letters)
        if #letters == 0 then
            if kind == "local" then
                vim.notify("No local marks (a-z) to delete in this buffer", vim.log.levels.INFO)
            elseif kind == "global" then
                vim.notify("No global marks (A-Z) to delete", vim.log.levels.INFO)
            else
                vim.notify("No marks to delete", vim.log.levels.INFO)
            end
            return
        end
        local cmd = "delmarks " .. table.concat(letters, " ")
        pcall(vim.cmd, cmd)
        local human_kind = (kind == "local" and "local marks (a-z)")
            or (kind == "global" and "global marks (A-Z)")
            or "marks (local + global)"
        vim.notify("Deleted " .. human_kind .. ": " .. table.concat(letters, ", "), vim.log.levels.INFO)
    end
    vim.keymap.set("n", "mdl", function()
        delete_marks("local")
    end, { desc = "Delete all local marks (a-z) in current buffer" })
    vim.keymap.set("n", "mdg", function()
        delete_marks("global")
    end, { desc = "Delete all global marks (A-Z)" })
    vim.keymap.set("n", "mda", function()
        delete_marks("all")
    end, { desc = "Delete all local and global marks" })
end

config.macrobank_nvim = function()
    local macrobank_status_ok, macrobank = pcall(require, "macrobank")
    if not macrobank_status_ok then
        return
    end
    macrobank.setup({
        store_path_global = vim.fn.stdpath("config") .. "/macrobank_store.json",
        project_store_paths = ".nvim/macrobank.json",
    })
    vim.keymap.set("n", "mce", ":MacroBankLive<CR>", { desc = "Edit macros" })
    vim.keymap.set("n", "mco", ":MacroBank<CR>", { desc = "Edit saved macros" })
    vim.keymap.set("n", "mcs", ":MacroBankSelect<CR>", { desc = "Select macro" })
    vim.keymap.set("n", "mcp", ":MacroBankPlay<CR>", { desc = "Play macro" })
end

config.nvim_hlslens = function()
    local hlslens_status_ok, hlslens = pcall(require, "hlslens")
    if not hlslens_status_ok then
        return
    end
    hlslens.setup({
        nearest_float_when = true,
        override_lens = function(render, posList, nearest, idx, relIdx)
            local sfw = vim.v.searchforward == 1
            local indicator, text, chunks
            local absRelIdx = math.abs(relIdx)
            if absRelIdx > 1 then
                indicator = ("%d%s"):format(absRelIdx, sfw ~= (relIdx > 1) and icons.common.up2 or icons.common.down2)
            elseif absRelIdx == 1 then
                indicator = sfw ~= (relIdx == 1) and icons.common.up2 or icons.common.down2
            else
                indicator = icons.common.dot
            end
            local lnum, col = unpack(posList[idx])
            if nearest then
                local cnt = #posList
                if indicator ~= "" then
                    text = ("[%s %d/%d]"):format(indicator, idx, cnt)
                else
                    text = ("[%d/%d]"):format(idx, cnt)
                end
                chunks = { { " " }, { text, "HlSearchLensNear" } }
            else
                text = ("[%s %d]"):format(indicator, idx)
                chunks = { { " " }, { text, "HlSearchLens" } }
            end
            render.setVirt(0, lnum - 1, col - 1, chunks, nearest)
        end,
    })
    local function normal_feedkeys(keys)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", true)
    end
    vim.keymap.set("n", "n", function()
        normal_feedkeys(vim.v.count1 .. "n")
        hlslens.start()
    end, { silent = true })
    vim.keymap.set("n", "N", function()
        normal_feedkeys(vim.v.count1 .. "N")
        hlslens.start()
    end, { silent = true })
    vim.keymap.set("n", "*", function()
        normal_feedkeys("*")
        hlslens.start()
    end, { silent = true })
    vim.keymap.set("n", "#", function()
        normal_feedkeys("#")
        hlslens.start()
    end, { silent = true })
    vim.keymap.set("n", "g*", function()
        normal_feedkeys("g*")
        hlslens.start()
    end, { silent = true })
    vim.keymap.set("n", "g#", function()
        normal_feedkeys("g#")
        hlslens.start()
    end, { silent = true })
    vim.keymap.set("n", "<Esc>", function()
        vim.cmd("noh")
        hlslens.stop()
    end, { silent = true })
end

config.nvim_bqf = function()
    local bqf_status_ok, bqf = pcall(require, "bqf")
    if not bqf_status_ok then
        return
    end
    bqf.setup({
        delay_syntax = 1,
        preview = {
            border = "single",
            winblend = 0,
        },
    })
end

config.quicker_nvim = function()
    local quicker_status_ok, quicker = pcall(require, "quicker")
    if not quicker_status_ok then
        return
    end
    quicker.setup()
end

config.lvim_qf_loc = function()
    local lvim_qf_loc_status_ok, lvim_qf_loc = pcall(require, "lvim-qf-loc")
    if not lvim_qf_loc_status_ok then
        return
    end
    lvim_qf_loc.setup()
    -- QF Diagnostic
    vim.keymap.set("n", "<C-c><C-h>", function()
        vim.cmd("LvimDiagnostics")
    end, { noremap = true, silent = true, desc = "LspDiagnostic QF" })
    -- Quick fix
    vim.keymap.set("n", "]o", function()
        vim.cmd("LvimListQuickFixOpen")
    end, { noremap = true, silent = true, desc = "QfOpen" })
    vim.keymap.set("n", "]q", function()
        vim.cmd("LvimListQuickFixClose")
    end, { noremap = true, silent = true, desc = "QfClose" })
    vim.keymap.set("n", "]]", function()
        vim.cmd("LvimListQuickFixNext")
    end, { noremap = true, silent = true, desc = "QfNext" })
    vim.keymap.set("n", "][", function()
        vim.cmd("LvimListQuickFixPrev")
    end, { noremap = true, silent = true, desc = "QfPrev" })
    vim.keymap.set("n", "]c", function()
        vim.cmd("LvimListQuickFixMenuChoice")
    end, { noremap = true, silent = true, desc = "QfMenuChoice" })
    vim.keymap.set("n", "]d", function()
        vim.cmd("LvimListQuickFixMenuDelete")
    end, { noremap = true, silent = true, desc = "QfMenuDelete" })
    vim.keymap.set("n", "]l", function()
        vim.cmd("LvimListQuickFixMenuLoad")
    end, { noremap = true, silent = true, desc = "QfMenuLoad" })
    vim.keymap.set("n", "]s", function()
        vim.cmd("LvimListQuickFixMenuSave")
    end, { noremap = true, silent = true, desc = "QfMenuSave" })
    -- Loc list
    vim.keymap.set("n", "[o", function()
        vim.cmd("LvimLocListOpen")
    end, { noremap = true, silent = true, desc = "LocOpen" })
    vim.keymap.set("n", "[q", function()
        vim.cmd("LvimLocListClose")
    end, { noremap = true, silent = true, desc = "LocClose" })
    vim.keymap.set("n", "[]", function()
        vim.cmd("LvimLocListNext")
    end, { noremap = true, silent = true, desc = "LocNext" })
    vim.keymap.set("n", "[[", function()
        vim.cmd("LvimLocListPrev")
    end, { noremap = true, silent = true, desc = "LocPrev" })
    vim.keymap.set("n", "[c", function()
        vim.cmd("LvimLocListMenuChoice")
    end, { noremap = true, silent = true, desc = "LocMenuChoice" })
    vim.keymap.set("n", "[d", function()
        vim.cmd("LvimLocListMenuDelete")
    end, { noremap = true, silent = true, desc = "LocMenuDelete" })
    vim.keymap.set("n", "[l", function()
        vim.cmd("LvimLocListMenuLoad")
    end, { noremap = true, silent = true, desc = "LocMenuLoad" })
    vim.keymap.set("n", "[s", function()
        vim.cmd("LvimLocListMenuSave")
    end, { noremap = true, silent = true, desc = "LocMenuSave" })
end

config.tabby_nvim = function()
    local tabby_status_ok, tabby = pcall(require, "tabby")
    if not tabby_status_ok then
        return
    end
    local tabby_module_api_status_ok, tabby_module_api = pcall(require, "tabby.module.api")
    if not tabby_module_api_status_ok then
        return
    end
    local tabby_future_win_name_status_ok, tabby_future_win_name = pcall(require, "tabby.feature.win_name")
    if not tabby_future_win_name_status_ok then
        return
    end

    local get_lvim_space_tabs = function()
        local pub_status_ok, pub = pcall(require, "lvim-space.pub")
        if pub_status_ok then
            return pub.get_tab_info()
        else
            return { project_name = nil, workspace_name = nil, tabs = {} }
        end
    end

    local components = function()
        local exclude = {
            "ctrlspace",
            "ctrlspace_help",
            "packer",
            "undotree",
            "diff",
            "Outline",
            "LvimHelper",
            "floaterm",
            "toggleterm",
            "dashboard",
            "vista",
            "spectre_panel",
            "DiffviewFiles",
            "flutterToolsOutline",
            "log",
            "qf",
            "dapui_scopes",
            "dapui_breakpoints",
            "dapui_stacks",
            "dapui_watches",
            "dapui_console",
            "dap-repl",
            "calendar",
            "octo",
            "neo-tree",
            "neo-tree-popup",
            "netrw",
        }
        local comps = {
            {
                type = "text",
                text = {
                    " " .. icons.common.vim .. " ",
                    hl = {
                        bg = _G.LVIM_COLORS.green,
                        fg = _G.LVIM_COLORS.bg_dark,
                        style = "bold",
                    },
                },
            },
        }
        local current_tab = vim.api.nvim_get_current_tabpage()
        local wins = tabby_module_api.get_tab_wins(current_tab)
        local top_win = vim.api.nvim_tabpage_get_win(current_tab)
        local hl
        local win_name

        for _, win_id in ipairs(wins) do
            local ft = vim.api.nvim_get_option_value("filetype", { buf = vim.api.nvim_win_get_buf(win_id) })
            win_name = tabby_future_win_name.get(win_id, { mode = "unique" })
            if not vim.tbl_contains(exclude, ft) then
                if win_id == top_win then
                    hl = { bg = _G.LVIM_COLORS.green, fg = _G.LVIM_COLORS.bg_dark, style = "bold" }
                else
                    hl = { bg = _G.LVIM_COLORS.bg_dark, fg = _G.LVIM_COLORS.green, style = "bold" }
                end
                table.insert(comps, {
                    type = "win",
                    winid = win_id,
                    label = {
                        "  " .. win_name .. "  ",
                        hl = hl,
                    },
                    right_sep = { "", hl = { bg = _G.LVIM_COLORS.bg_dark, fg = _G.LVIM_COLORS.bg_dark } },
                })
            end
        end

        table.insert(comps, {
            type = "text",
            text = { "%=" },
            hl = { bg = _G.LVIM_COLORS.bg_dark, fg = _G.LVIM_COLORS.bg_dark },
        })

        local lvim_data = get_lvim_space_tabs()

        if lvim_data.tabs and #lvim_data.tabs > 0 then
            for _, tab in ipairs(lvim_data.tabs) do
                if tab.active then
                    hl = { bg = _G.LVIM_COLORS.green, fg = _G.LVIM_COLORS.bg_dark, style = "bold" }
                else
                    hl = { bg = _G.LVIM_COLORS.bg_dark, fg = _G.LVIM_COLORS.green, style = "bold" }
                end
                table.insert(comps, {
                    type = "text",
                    text = {
                        "  " .. tab.name .. "  ",
                        hl = hl,
                    },
                })
            end
        end

        if lvim_data.workspace_name and lvim_data.workspace_name ~= "Unknown" and lvim_data.workspace_name ~= "" then
            table.insert(comps, {
                type = "text",
                text = {
                    "  " .. lvim_data.workspace_name .. "  ",
                    hl = {
                        bg = _G.LVIM_COLORS.orange,
                        fg = _G.LVIM_COLORS.bg_dark,
                        style = "bold",
                    },
                },
            })
        end

        if lvim_data.project_name and lvim_data.project_name ~= "Unknown" and lvim_data.project_name ~= "" then
            table.insert(comps, {
                type = "text",
                text = {
                    "  " .. lvim_data.project_name .. "  ",
                    hl = {
                        bg = _G.LVIM_COLORS.red,
                        fg = _G.LVIM_COLORS.bg_dark,
                        style = "bold",
                    },
                },
            })
        end

        return comps
    end

    tabby.setup({
        components = components,
    })
end

config.nvim_lastplace = function()
    local nvim_lastplace_status_ok, nvim_lastplace = pcall(require, "nvim-lastplace")
    if not nvim_lastplace_status_ok then
        return
    end
    nvim_lastplace.setup({
        lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
        lastplace_ignore_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit" },
        lastplace_open_folds = true,
    })
end

config.dial_nvim = function()
    local dial_config_status_ok, dial_config = pcall(require, "dial.config")
    if not dial_config_status_ok then
        return
    end
    local dial_augend_status_ok, dial_augend = pcall(require, "dial.augend")
    if not dial_augend_status_ok then
        return
    end
    dial_config.augends:register_group({
        default = {
            dial_augend.integer.alias.decimal,
            dial_augend.integer.alias.hex,
            dial_augend.date.alias["%Y/%m/%d"],
            dial_augend.constant.new({
                elements = { "true", "false" },
                word = true,
                cyclic = true,
            }),
            dial_augend.constant.new({
                elements = { "True", "False" },
                word = true,
                cyclic = true,
            }),
            dial_augend.constant.new({
                elements = { "and", "or" },
                word = true,
                cyclic = true,
            }),
            dial_augend.constant.new({
                elements = { "&&", "||" },
                word = false,
                cyclic = true,
            }),
        },
    })
    vim.keymap.set("n", "<C-a>", "<Plug>(dial-increment)", { noremap = true, silent = true, desc = "Dial Increment" })
    vim.keymap.set("n", "<C-x>", "<Plug>(dial-decrement)", { noremap = true, silent = true, desc = "Dial Decrement" })
    vim.keymap.set("v", "<C-a>", "<Plug>(dial-increment)", { noremap = true, silent = true, desc = "Dial Increment" })
    vim.keymap.set("v", "<C-x>", "<Plug>(dial-decrement)", { noremap = true, silent = true, desc = "Dial Decrement" })
    vim.keymap.set("v", "g<C-a>", "<Plug>(dial-increment)", { noremap = true, silent = true, desc = "Dial Increment" })
    vim.keymap.set("v", "g<C-x>", "<Plug>(dial-decrement)", { noremap = true, silent = true, desc = "Dial Decrement" })
end

config.lvim_move = function()
    local lvim_move_status_ok, lvim_move = pcall(require, "lvim-move")
    if not lvim_move_status_ok then
        return
    end
    lvim_move.setup()
end

config.nvim_treesitter_context = function()
    local treesitter_context_status_ok, treesitter_context = pcall(require, "treesitter-context")
    if not treesitter_context_status_ok then
        return
    end
    treesitter_context.setup({
        enable = true,
        max_lines = 3,
        trim_scope = "outer",
        min_window_height = 0,
        patterns = {
            default = {
                "class",
                "function",
                "method",
                "for",
                "while",
                "if",
                "switch",
                "case",
            },
            tex = {
                "chapter",
                "section",
                "subsection",
                "subsubsection",
            },
            rust = {
                "impl_item",
                "struct",
                "enum",
            },
            scala = {
                "object_definition",
            },
            vhdl = {
                "process_statement",
                "architecture_body",
                "entity_declaration",
            },
            markdown = {
                "section",
            },
            elixir = {
                "anonymous_function",
                "arguments",
                "block",
                "do_block",
                "list",
                "map",
                "tuple",
                "quoted_content",
            },
            json = {
                "pair",
            },
            yaml = {
                "block_mapping_pair",
            },
        },
        on_attach = function(bufnr)
            if vim.bo[bufnr].filetype == "markdown" or vim.bo[bufnr].filetype == "org" then
                return false
            end
            return true
        end,
        exact_patterns = {},
        zindex = 20,
        mode = "cursor",
        separator = nil,
    })
end

config.nvim_various_textobjs = function()
    local nvim_various_textobjs_status_ok, nvim_various_textobjs = pcall(require, "various-textobjs")
    if not nvim_various_textobjs_status_ok then
        return
    end
    nvim_various_textobjs.setup({
        keymaps = {
            useDefaults = true,
            disabledKeymaps = {
                "i/",
                "a/",
                "in",
                "an",
                "ii",
                "ai",
                "iI",
                "aI",
                "gc",
            },
        },
    })
    vim.keymap.set(
        { "o", "x" },
        "ii",
        "<cmd>lua require('various-textobjs').indentation(true, true)<CR>",
        { noremap = true, silent = true, desc = "inner indentation" }
    )
    vim.keymap.set(
        { "o", "x" },
        "ai",
        "<cmd>lua require('various-textobjs').indentation(false, false)<CR>",
        { noremap = true, silent = true, desc = "outer indentation" }
    )
end

config.kulala_nvim = function()
    local kulala_nvim_status_ok, kulala_nvim = pcall(require, "kulala")
    if not kulala_nvim_status_ok then
        return
    end
    vim.notify("kulala_nvim loaded")
    kulala_nvim.setup({
        global_keymaps = true,
        icons = {
            inlay = {
                loading = icons.common.hourglass,
                done = icons.common.todo,
                error = icons.common.warning,
            },
            lualine = icons.common.separator,
            textHighlight = "WarningMsg",
        },
    })
end

config.flow_nvim = function()
    local flow_status_ok, flow = pcall(require, "flow")
    if not flow_status_ok then
        return
    end
    flow.setup({
        output = {
            buffer = true,
            split_cmd = "80vsplit",
        },
        filetype_cmd_map = {
            lua = "lua <<-EOF\n%s\nEOF",
            python = "python <<-EOF\n%s\nEOF",
            ruby = "ruby <<-EOF\n%s\nEOF",
            bash = "bash <<-EOF\n%s\nEOF",
            sh = "sh <<-EOF\n%s\nEOF",
            scheme = "scheme <<-EOF\n%s\nEOF",
            javascript = "node <<-EOF\n%s\nEOF",
            typescript = "node <<-EOF\n%s\nEOF",
            go = "go run .",
        },
    })
end

config.transfer_nvim = function()
    local transfer_status_ok, transfer = pcall(require, "transfer")
    if not transfer_status_ok then
        return
    end
    transfer.setup()
end

config.code_runner_nvim = function()
    local code_runner_status_ok, code_runner = pcall(require, "code_runner")
    if not code_runner_status_ok then
        return
    end
    code_runner.setup({
        filetype_path = _G.global.lvim_path .. "/.configs/code_runner/files.json",
        project_path = _G.global.lvim_path .. "/.configs/code_runner/projects.json",
        mode = "float",
        focus = true,
        startinsert = true,
    })
end

config.grug_far = function()
    local grug_far_status_ok, grug_far = pcall(require, "grug-far")
    if not grug_far_status_ok then
        return
    end
    grug_far.setup({
        keymaps = {
            replace = { n = "<localleader>er" },
            qflist = { n = "<localleader>eq" },
            syncLocations = { n = "<localleader>es" },
            syncLine = { n = "<localleader>el" },
            close = { n = "<localleader>ec" },
            historyOpen = { n = "<localleader>et" },
            historyAdd = { n = "<localleader>ea" },
            refresh = { n = "<localleader>ef" },
            gotoLocation = { n = "<enter>" },
            pickHistoryEntry = { n = "<enter>" },
        },
    })
end

config.replacer_nvim = function()
    local replacer_status_ok, replacer = pcall(require, "replacer")
    if not replacer_status_ok then
        return
    end
    local opts = { rename_files = true, save_on_write = true }
    vim.keymap.set("n", "dr", function()
        replacer.run(opts)
    end, { noremap = true, silent = true, desc = "Replacer run" })
    vim.keymap.set("n", "dR", function()
        replacer.save(opts)
    end, { noremap = true, silent = true, desc = "Replacer save" })
end

config.comment_nvim = function()
    local comment_status_ok, comment = pcall(require, "Comment")
    if not comment_status_ok then
        return
    end
    comment.setup()
end

config.vim_bufsurf = function()
    vim.keymap.set("n", "<C-n>", function()
        vim.cmd("BufSurfForward")
    end, { noremap = true, silent = true, desc = "BufSurfForward" })
    vim.keymap.set("n", "<C-p>", function()
        vim.cmd("BufSurfBack")
    end, { noremap = true, silent = true, desc = "BufSurfBack" })
end

config.neogen = function()
    local neogen_status_ok, neogen = pcall(require, "neogen")
    if not neogen_status_ok then
        return
    end
    neogen.setup({
        snippet_engine = "luasnip",
    })
    vim.api.nvim_create_user_command("NeogenFile", "lua require('neogen').generate({ type = 'file' })", {})
    vim.api.nvim_create_user_command("NeogenClass", "lua require('neogen').generate({ type = 'class' })", {})
    vim.api.nvim_create_user_command("NeogenFunction", "lua require('neogen').generate({ type = 'func' })", {})
    vim.api.nvim_create_user_command("NeogenType", "lua require('neogen').generate({ type = 'type' })", {})
end

config.ccc_nvim = function()
    local ccc_status_ok, ccc = pcall(require, "ccc")
    if not ccc_status_ok then
        return
    end
    ccc.setup({
        alpha_show = "show",
        highlight_mode = "virtual",
        virtual_symbol = " ● ",
    })
    vim.keymap.set("n", "<C-c>r", function()
        vim.cmd("CccPick")
    end, { noremap = true, silent = true, desc = "ColorPicker" })
end

config.nvim_highlight_colors = function()
    local highlight_colors_status_ok, highlight_colors = pcall(require, "nvim-highlight-colors")
    if not highlight_colors_status_ok then
        return
    end
    highlight_colors.setup({
        render = "virtual",
        virtual_symbol = "●",
        enable_tailwind = true,
        exclude_buftypes = { "nofile" },
    })
end

config.suda_vim = function()
    vim.g.suda_smart_edit = 1
end

config.flash_nvim = function()
    local flash_status_ok, flash = pcall(require, "flash")
    if not flash_status_ok then
        return
    end
    flash.setup({
        search = {
            exclude = {
                "notify",
                "noice",
                "cmp_menu",
                function(win)
                    return not vim.api.nvim_win_get_config(win).focusable
                end,
            },
        },
        modes = {
            char = {
                enabled = true,
            },
        },
    })
    local Config = require("flash.config")
    local Char = require("flash.plugins.char")
    for _, motion in ipairs({ "f", "t", "F", "T" }) do
        vim.keymap.set({ "n", "x", "o" }, motion, function()
            flash.jump(Config.get({
                mode = "char",
                search = {
                    mode = Char.mode(motion),
                    max_length = 1,
                },
            }, Char.motions[motion]))
        end)
    end
    vim.keymap.set({ "n", "x", "o" }, "<C-c>.", function()
        flash.jump()
    end, { desc = "Flash jump" })
    vim.keymap.set({ "n", "x", "o" }, "<C-c>,", function()
        flash.treesitter()
    end, { desc = "Flash treesitter" })
    vim.keymap.set({ "o" }, "r", function()
        require("flash").remote()
    end)
    vim.keymap.set({ "n", "x", "o" }, "<C-c>;", function()
        flash.jump({
            search = { mode = "search" },
            label = { after = false, before = { 0, 0 }, uppercase = false },
            pattern = [[\<\|\>]],
            action = function(match, state)
                state:hide()
                flash.jump({
                    search = { max_length = 0 },
                    label = { distance = false },
                    highlight = { matches = false },
                    matcher = function(win)
                        return vim.tbl_filter(function(m)
                            return m.label == match.label and m.win == win
                        end, state.results)
                    end,
                })
            end,
            labeler = function(matches, state)
                local labels = state:labels()
                for m, match in ipairs(matches) do
                    match.label = labels[math.floor((m - 1) / #labels) + 1]
                end
            end,
        })
    end, { desc = "Flash search" })
end

config.todo_comments_nvim = function()
    local todo_comments_status_ok, todo_comments = pcall(require, "todo-comments")
    if not todo_comments_status_ok then
        return
    end
    todo_comments.setup({
        keywords = {
            FIX = { icon = icons.common.fix, color = _G.LVIM_COLORS.diag_error, alt = { "FIX", "FIXME", "BUG" } },
            TODO = { icon = icons.common.todo, color = _G.LVIM_COLORS.diag_info, alt = { "TODO" } },
            HACK = { icon = icons.common.hack, color = _G.LVIM_COLORS.diag_error, alt = { "HACK" } },
            WARN = { icon = icons.common.warning, color = _G.LVIM_COLORS.diag_warn, alt = { "WARNING" } },
            PERF = {
                icon = icons.common.performance,
                color = _G.LVIM_COLORS.diag_warn,
                alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" },
            },
            NOTE = { icon = icons.common.note, color = _G.LVIM_COLORS.diag_info, alt = { "INFO" } },
            TEST = {
                icon = icons.common.test,
                color = _G.LVIM_COLORS.diag_hint,
                alt = { "TEST", "TESTING", "PASSED", "FAILED" },
            },
        },
        highlight = {
            before = "fg",
            keyword = "fg",
            after = "fg",
        },
    })
end

config.calendar_vim = function()
    vim.g.calendar_diary_extension = ".org"
    vim.g.calendar_diary = "~/Org/diary/"
    vim.g.calendar_diary_path_pattern = "{YYYY}-{MM}-{DD}{EXT}"
    vim.g.calendar_monday = 1
    vim.g.calendar_weeknm = 1
    vim.keymap.del("n", "<Leader>cal")
    vim.keymap.del("n", "<Leader>caL")
    vim.keymap.set("n", "<Leader>ch", function()
        vim.cmd("CalendarH")
    end, { noremap = true, silent = true, desc = "Calendar horizontal" })
    vim.keymap.set("n", "<Leader>cv", function()
        vim.cmd("CalendarVR")
    end, { noremap = true, silent = true, desc = "Calendar vertical" })
end

return config
