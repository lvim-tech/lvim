local icons = require("configs.base.ui.icons")

return {
    lvim_space = {
        opts = {
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
        },
    },
    lvim_control_center = {
        opts = function()
            vim.keymap.set("n", "<Leader><Leader>v", "<CMD>LvimControlCenter lvim<CR>")
            vim.keymap.set("n", "<Leader><Leader>g", "<CMD>LvimControlCenter general<CR>")
            vim.keymap.set("n", "<Leader><Leader>a", "<CMD>LvimControlCenter appearance<CR>")
            vim.keymap.set("n", "<Leader><Leader>l", "<CMD>LvimControlCenter lsp<CR>")
            vim.keymap.set("n", "<Leader><Leader>c", "<CMD>LvimControlCenter commands<CR>")
            vim.keymap.set("n", "<Leader><Leader>p", "<CMD>LvimControlCenter projects<CR>")
            local lvim = require("modules.base.configs.editor.control_center.lvim")
            local general = require("modules.base.configs.editor.control_center.general")
            local appearance = require("modules.base.configs.editor.control_center.appearance")
            local lsp = require("modules.base.configs.editor.control_center.lsp")
            local commands = require("modules.base.configs.editor.control_center.commands")
            local projects = require("modules.base.configs.editor.control_center.projects")
            return {
                groups = {
                    lvim,
                    general,
                    appearance,
                    lsp,
                    commands,
                    projects,
                },
            }
        end,
    },
    smart_splits = {
        keys = {
            {
                "<C-h>",
                function()
                    require("smart-splits").move_cursor_left()
                end,
                desc = "Navigator left",
            },
            {
                "<C-l>",
                function()
                    require("smart-splits").move_cursor_right()
                end,
                desc = "Navigator right",
            },
            {
                "<C-k>",
                function()
                    require("smart-splits").move_cursor_up()
                end,
                desc = "Navigator up",
            },
            {
                "<C-j>",
                function()
                    require("smart-splits").move_cursor_down()
                end,
                desc = "Navigator down",
            },
            {
                "<C-Left>",
                function()
                    require("smart-splits").resize_left()
                end,
                desc = "Navigator down",
            },
            {
                "<C-Right>",
                function()
                    require("smart-splits").resize_right()
                end,
                desc = "Navigator down",
            },
            {
                "<C-Up>",
                function()
                    require("smart-splits").resize_up()
                end,
                desc = "Navigator up",
            },
            {
                "<C-Down>",
                function()
                    require("smart-splits").resize_down()
                end,
                desc = "Navigator down",
            },
        },
        opts = {},
    },
    fzf_lua = {
        cmd = { "FzfLua" },
        keys = {
            {
                "<Leader>f",
                function()
                    vim.cmd("FzfLua files")
                end,
                desc = "FzfLua files",
            },
            {
                "<Leader>O",
                function()
                    vim.cmd("FzfLua oldfiles")
                end,
                desc = "FzfLua oldfiles",
            },
            {
                "<Leader>w",
                function()
                    vim.cmd("FzfLua live_grep")
                end,
                desc = "FzfLua search",
            },
            {
                "<Leader>M",
                function()
                    vim.cmd("FzfLua marks")
                end,
                desc = "FzfLua marks",
            },
            {
                "<Leader>b",
                function()
                    vim.cmd("FzfLua buffers")
                end,
                desc = "FzfLua buffers",
            },
            {
                "gzd",
                function()
                    vim.cmd("FzfLua lsp_definitions")
                end,
                desc = "FzfLua lsp definitions",
            },
            {
                "gzD",
                function()
                    vim.cmd("FzfLua lsp_declarations")
                end,
                desc = "FzfLua lsp declarations",
            },
            {
                "gzt",
                function()
                    vim.cmd("FzfLua lsp_typedefs")
                end,
                desc = "FzfLua lsp type definition",
            },
            {
                "gzr",
                function()
                    vim.cmd("FzfLua lsp_references")
                end,
                desc = "FzfLua lsp references",
            },
            {
                "gzi",
                function()
                    vim.cmd("FzfLua lsp_implementations")
                end,
                desc = "FzfLua lsp implementations",
            },
            {
                "gzf",
                function()
                    vim.cmd("FzfLua lsp_finder")
                end,
                desc = "FzfLua lsp finder",
            },
            {
                "gzw",
                function()
                    vim.cmd("FzfLua lsp_document_diagnostics")
                end,
                desc = "FzfLua lsp document diagnostics",
            },
            {
                "gzW",
                function()
                    vim.cmd("FzfLua lsp_workspace_diagnostics")
                end,
                desc = "FzfLua lsp workspace diagnostics",
            },
            {
                "gzs",
                function()
                    vim.cmd("FzfLua lsp_document_symbols")
                end,
                desc = "FzfLua lsp document symbols",
            },
            {
                "gzS",
                function()
                    vim.cmd("FzfLua lsp_workspace_symbols")
                end,
                desc = "FzfLua lsp workspace symbols",
            },
        },
        opts = function()
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
            return {
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
                    local win_height =
                        math.ceil(vim.api.nvim_get_option_value("lines", {}) * _G.LVIM_SETTINGS.floatheight)
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
            }
        end,
    },
    lvim_linguistics = {
        opts = function()
            vim.keymap.set("n", "<C-c>l", function()
                vim.cmd("LvimLinguisticsTOGGLEInsertModeLanguage")
            end, { noremap = true, silent = true, desc = "LvimLinguisticsTOGGLEInsertModeLanguage" })
            vim.keymap.set("n", "<C-c>k", function()
                vim.cmd("LvimLinguisticsTOGGLESpelling")
            end, { noremap = true, silent = true, desc = "LvimLinguisticsTOGGLESpelling" })
            return {
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
            }
        end,
    },
    rgflow_nvim = {
        keys = {
            {
                "<Leader>rG",
                function()
                    require("rgflow").open()
                end,
                desc = "Rgflow open blank",
            },
            {
                "<Leader>rg",
                function()
                    require("rgflow").open_cword()
                end,
                desc = "Rgflow open cword",
            },
            {
                "<Leader>rp",
                function()
                    require("rgflow").open_cword()
                end,
                desc = "Rgflow open and paste",
            },
            {
                "<Leader>ra",
                function()
                    require("rgflow").open_again()
                end,
                desc = "Rgflow open again",
            },
            {
                "<Leader>rx",
                function()
                    require("rgflow").abort()
                end,
                desc = "Rgflow abort",
            },
            {
                "<Leader>rc",
                function()
                    require("rgflow").print_cmd()
                end,
                desc = "Rgflow print cmd",
            },
            {
                "<Leader>r?",
                function()
                    require("rgflow").print_status()
                end,
                desc = "Rgflow print status",
            },
            {
                "<Leader>rg",
                function()
                    require("rgflow").open_visual()
                end,
                mode = "x",
                desc = "Rgflow open visual",
            },
        },
        opts = {
            cmd_flags = "--smart-case --fixed-strings --ignore --max-columns 200",
            default_trigger_mappings = false,
            default_ui_mappings = true,
            default_quickfix_mappings = true,
            ui_top_line_char = "",
        },
    },
    vessel_nvim = {
        opts = function()
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
                        vim.api.nvim_win_set_cursor(
                            0,
                            { valid_marks[#valid_marks].line, valid_marks[#valid_marks].col }
                        )
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
            return {
                create_commands = true,
                commands = {
                    view_marks = "Marks",
                    view_jumps = "Jumps",
                },
            }
        end,
    },
    macrobank_nvim = {
        cmd = { "MacroBank", "MacroBankLive", "MacroBankSelect", "MacroBankPlay" },
        keys = {
            {
                "mco",
                function()
                    vim.cmd("MacroBank")
                end,
                desc = "Edit saved macros",
            },
            {
                "mce",
                function()
                    vim.cmd("MacroBankLive")
                end,
                desc = "Edit macros",
            },
            {
                "mcs",
                function()
                    vim.cmd("MacroBankSelect")
                end,
                desc = "Select macro",
            },
            {
                "mcp",
                function()
                    vim.cmd("MacroBankPlay")
                end,
                desc = "Play macro",
            },
        },
        opts = {
            store_path_global = vim.fn.stdpath("config") .. "/macrobank_store.json",
            project_store_paths = ".nvim/macrobank.json",
        },
    },
    nvim_hlslens = {
        opts = function()
            local hlslens_status_ok, hlslens = pcall(require, "hlslens")
            if not hlslens_status_ok then
                return
            end
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
            return {
                nearest_float_when = true,
                override_lens = function(render, posList, nearest, idx, relIdx)
                    local sfw = vim.v.searchforward == 1
                    local indicator, text, chunks
                    local absRelIdx = math.abs(relIdx)
                    if absRelIdx > 1 then
                        indicator = ("%d%s"):format(
                            absRelIdx,
                            sfw ~= (relIdx > 1) and icons.common.up2 or icons.common.down2
                        )
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
            }
        end,
    },
    nvim_bqf = {
        opts = {
            delay_syntax = 1,
            preview = {
                border = "single",
                winblend = 0,
            },
        },
    },
    quicker_nvim = {
        opts = {},
    },
    lvim_qf_loc = {
        cmd = {
            "LvimDiagnostics",
            "LvimListQuickFixOpen",
            "LvimListQuickFixClose",
            "LvimListQuickFixNext",
            "LvimListQuickFixPrev",
            "LvimListQuickFixMenuChoice",
            "LvimListQuickFixMenuDelete",
            "LvimListQuickFixMenuLoad",
            "LvimListQuickFixMenuSave",
            "LvimLocListOpen",
            "LvimLocListClose",
            "LvimLocListNext",
            "LvimLocListPrev",
            "LvimLocListMenuChoice",
            "LvimLocListMenuDelete",
            "LvimLocListMenuLoad",
            "LvimLocListMenuSave",
        },
        keys = {
            -- QF Diagnostic
            {
                "<C-c><C-h>",
                function()
                    vim.cmd("LvimDiagnostics")
                end,
                desc = "LspDiagnostic QF",
            },
            -- Quick fix
            {
                "]o",
                function()
                    vim.cmd("LvimListQuickFixOpen")
                end,
                desc = "QfOpen",
            },
            {
                "]q",
                function()
                    vim.cmd("LvimListQuickFixClose")
                end,
                desc = "QfClose",
            },
            {
                "]]",
                function()
                    vim.cmd("LvimListQuickFixNext")
                end,
                desc = "QfNext",
            },
            {
                "][",
                function()
                    vim.cmd("LvimListQuickFixPrev")
                end,
                desc = "QfPrev",
            },
            {
                "]c",
                function()
                    vim.cmd("LvimListQuickFixMenuChoice")
                end,
                desc = "QfMenuChoice",
            },
            {
                "]d",
                function()
                    vim.cmd("LvimListQuickFixMenuDelete")
                end,
                desc = "QfMenuDelete",
            },
            {
                "]l",
                function()
                    vim.cmd("LvimListQuickFixMenuLoad")
                end,
                desc = "QfMenuLoad",
            },
            {
                "]s",
                function()
                    vim.cmd("LvimListQuickFixMenuSave")
                end,
                desc = "QfMenuSave",
            },
            -- Loc list
            {
                "[o",
                function()
                    vim.cmd("LvimLocListOpen")
                end,
                desc = "LocOpen",
            },
            {
                "[q",
                function()
                    vim.cmd("LvimLocListClose")
                end,
                desc = "LocClose",
            },
            {
                "[]",
                function()
                    vim.cmd("LvimLocListNext")
                end,
                desc = "LocNext",
            },
            {
                "[[",
                function()
                    vim.cmd("LvimLocListPrev")
                end,
                desc = "LocPrev",
            },
            {
                "[c",
                function()
                    vim.cmd("LvimLocListMenuChoice")
                end,
                desc = "LocMenuChoice",
            },
            {
                "[d",
                function()
                    vim.cmd("LvimLocListMenuDelete")
                end,
                desc = "LocMenuDelete",
            },
            {
                "[l",
                function()
                    vim.cmd("LvimLocListMenuLoad")
                end,
                desc = "LocMenuLoad",
            },
            {
                "[s",
                function()
                    vim.cmd("LvimLocListMenuSave")
                end,
                desc = "LocMenuSave",
            },
        },
        opts = {},
    },
    tabby_nvim = {
        opts = function()
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
                if
                    lvim_data.workspace_name
                    and lvim_data.workspace_name ~= "Unknown"
                    and lvim_data.workspace_name ~= ""
                then
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
            return {
                components = components,
            }
        end,
    },
    dial_nvim = {
        keys = {
            {
                "<C-a>",
                "<Plug>(dial-increment)",
                desc = "Dial Increment",
                mode = { "n", "v" },
            },
            {
                "<C-x>",
                "<Plug>(dial-decrement)",
                desc = "Dial Decrement",
                mode = { "n", "v" },
            },
        },
        config = function()
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
        end,
    },
    lvim_move = {
        opts = {},
    },
    kulala_nvim = {
        config = function()
            require("kulala").setup({
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
        end,
    },
    flow_nvim = {
        cmd = { "FlowRunSelected", "FlowRunFile", "FlowLauncher" },
        keys = {
            {
                "<Leader>lls",
                ":FlowRunSelected<CR>",
                mode = "x",
                desc = "Flow run selected",
            },
            {
                "<Leader>llf",
                ":FlowRunFile<CR>",
                desc = "Flow run file",
            },
            {
                "<Leader>lll",
                ":FlowLauncher<CR>",
                desc = "Flow launcher",
            },
        },
        opts = {
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
        },
    },
    transfer_nvim = {
        cmd = {
            "TransferInit",
            "DiffRemote",
            "TransferUpload",
            "TransferDownload",
            "TransferDirDiff",
            "TransferRepeat",
        },
        keys = {
            {
                "<Leader>ti",
                "<cmd>TransferInit<cr>",
                desc = "Transfer Init",
            },
            {
                "<Leader>tf",
                "<cmd>DiffRemote<cr>",
                desc = "Diff Remote",
            },
            {
                "<Leader>tF",
                "<cmd>TransferDirDiff<cr>",
                desc = "Transfer Dir Diff",
            },
            {
                "<Leader>tu",
                "<cmd>TransferUpload<cr>",
                desc = "Transfer Upload",
            },
            {
                "<Leader>td",
                "<cmd>TransferDownload<cr>",
                desc = "Transfer Download",
            },
            {
                "<Leader>tr",
                "<cmd>TransferDownload<cr>",
                desc = "Transfer Download",
            },
        },
        opts = {},
    },
    compiler_nvim = {
        cmd = {
            "CompilerOpen",
            "CompilerToggleResults",
            "CompilerRedo",
        },
        keys = {
            {
                "<Leader>oo",
                "<cmd>CompilerOpen<cr>",
                desc = "Compiler Open",
            },
            {
                "<Leader>og",
                "<cmd>CompilerToggleResults<cr>",
                desc = "Compiler Toggle Results",
            },
            {
                "<Leader>od",
                "<cmd>CompilerRedo<cr>",
                desc = "Compiler Redo",
            },
        },
        opts = {},
    },
    overseer_nvim = {
        cmd = { "OverseerRun", "OverseerToggle", "OverseerShell", "OverseerTaskAction" },
        keys = {
            {
                "<Leader>or",
                ":OverseerRun<CR>",
                desc = "Overseer Run",
            },
            {
                "<Leader>ot",
                ":OverseerToggle<CR>",
                desc = "Overseer Toggle",
            },
            {
                "<Leader>os",
                ":OverseerShell<CR>",
                desc = "Overseer Shell",
            },
            {
                "<Leader>oa",
                ":OverseerTaskAction<CR>",
                desc = "Overseer Task Action",
            },
        },
        opts = function()
            local overseer_status_ok, overseer = pcall(require, "overseer")
            if not overseer_status_ok then
                return
            end
            local path = vim.fn.stdpath("config") .. "/.configs/overseer"
            local registered_names = {}
            for _, file in ipairs(vim.fn.globpath(path, "*.lua", false, true)) do
                local ok, tmpl = pcall(dofile, file)
                if ok and type(tmpl) == "table" and tmpl.name then
                    if not registered_names[tmpl.name] then
                        overseer.register_template(tmpl)
                        registered_names[tmpl.name] = true
                    end
                end
            end
            vim.api.nvim_create_user_command("OverseerRun", function()
                overseer.run_template({}, function(task)
                    if task then
                        vim.defer_fn(function()
                            overseer.open({ enter = false })
                        end, 100)
                    else
                        vim.notify("No task created", vim.log.levels.WARN)
                    end
                end)
            end, {})
            return {
                dap = true,
                output = {
                    use_terminal = true,
                    preserve_output = false,
                },
            }
        end,
    },
    grug_far_nvim = {
        cmd = { "GrugFar" },
        keys = {
            {
                "<A-s>",
                ":GrugFar<CR>",
                desc = "GrugFar",
            },
        },
        opts = {
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
        },
    },
    replacer_nvim = {
        cmd = { "ReplacerRun", "ReplacerSave" },
        keys = {
            {
                "dr",
                "<cmd>ReplacerRun<cr>",
                mode = "n",
                desc = "Replacer run",
            },
            {
                "dR",
                "<cmd>ReplacerSave<cr>",
                mode = "n",
                desc = "Replacer save",
            },
        },
        opts = function()
            local replacer_status_ok, replacer = pcall(require, "replacer")
            if not replacer_status_ok then
                return
            end
            local opts = { rename_files = true, save_on_write = true }
            vim.api.nvim_create_user_command("ReplacerRun", function()
                replacer.run(opts)
            end, { desc = "Run the replacer" })
            vim.api.nvim_create_user_command("ReplacerSave", function()
                replacer.save(opts)
            end, { desc = "Save the replacer state" })
            return {}
        end,
    },
    comment_nvim = {
        opts = {},
    },
    vim_bufsurf = {
        config = function()
            vim.keymap.set("n", "<C-n>", function()
                vim.cmd("BufSurfForward")
            end, { noremap = true, silent = true, desc = "BufSurfForward" })
            vim.keymap.set("n", "<C-p>", function()
                vim.cmd("BufSurfBack")
            end, { noremap = true, silent = true, desc = "BufSurfBack" })
        end,
    },
    neogen = {
        cmd = { "NeogenFile", "NeogenClass", "NeogenFunction", "NeogenType" },
        opts = function()
            vim.api.nvim_create_user_command("NeogenFile", "lua require('neogen').generate({ type = 'file' })", {})
            vim.api.nvim_create_user_command("NeogenClass", "lua require('neogen').generate({ type = 'class' })", {})
            vim.api.nvim_create_user_command("NeogenFunction", "lua require('neogen').generate({ type = 'func' })", {})
            vim.api.nvim_create_user_command("NeogenType", "lua require('neogen').generate({ type = 'type' })", {})
            return {
                snippet_engine = "luasnip",
            }
        end,
    },
    ccc_nvim = {
        cmd = { "CccPick" },
        keys = {
            {
                "<C-c>r",
                "<cmd>CccPick<cr>",
                mode = "n",
                desc = "ColorPicker",
            },
        },
        opts = {
            alpha_show = "show",
            highlight_mode = "virtual",
            virtual_symbol = " ● ",
        },
    },
    nvim_highlight_colors = {
        opts = {
            render = "virtual",
            virtual_symbol = "●",
            enable_tailwind = true,
            exclude_buftypes = { "nofile" },
        },
    },
    flash_nvim = {
        keys = function()
            local motion_keys = {}
            for _, motion in ipairs({ "f", "t", "F", "T" }) do
                table.insert(motion_keys, {
                    motion,
                    function()
                        require("flash").jump({
                            mode = "char",
                            search = {
                                mode = require("flash.plugins.char").mode(motion),
                                max_length = 1,
                            },
                        }, require("flash.plugins.char").motions[motion])
                    end,
                    mode = { "n", "x", "o" },
                    desc = "Flash " .. motion,
                })
            end
            local other_keys = {
                {
                    "<C-c>.",
                    function()
                        require("flash").jump()
                    end,
                    mode = { "n", "x", "o" },
                    desc = "Flash Jump",
                },
                {
                    "<C-c>,",
                    function()
                        require("flash").treesitter()
                    end,
                    mode = { "n", "x", "o" },
                    desc = "Flash Treesitter",
                },
                {
                    "<C-c>;",
                    function()
                        require("flash").jump({
                            search = { mode = "search" },
                            label = { after = false, before = { 0, 0 }, uppercase = false },
                            pattern = [[\<\|\>]],
                            action = function(match, state)
                                state:hide()
                                require("flash").jump({
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
                    end,
                    mode = { "n", "x", "o" },
                    desc = "Flash Search",
                },
                {
                    "r",
                    function()
                        require("flash").remote()
                    end,
                    mode = "o",
                    desc = "Flash Remote",
                },
            }
            return vim.list_extend(motion_keys, other_keys)
        end,
        opts = {
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
        },
    },
    todo_comments_nvim = {
        opts = function()
            return {
                keywords = {
                    FIX = {
                        icon = icons.common.fix,
                        color = _G.LVIM_COLORS.diag_error,
                        alt = { "FIX", "FIXME", "BUG" },
                    },
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
            }
        end,
    },
    calendar_vim = {
        cmd = { "Calendar", "CalendarH", "CalendarVR", "CalendarT", "CalendarSearch" },
        keys = {
            {
                "<Leader>ch",
                "<cmd>CalendarH<cr>",
                mode = "n",
                desc = "Calendar horizontal",
            },
            {
                "<Leader>cv",
                "<cmd>CalendarVR<cr>",
                mode = "n",
                desc = "Calendar vertical",
            },
        },
        config = function()
            vim.g.calendar_diary_extension = ".org"
            vim.g.calendar_diary = "~/Org/diary/"
            vim.g.calendar_diary_path_pattern = "{YYYY}-{MM}-{DD}{EXT}"
            vim.g.calendar_monday = 1
            vim.g.calendar_weeknm = 1
            vim.keymap.del("n", "<Leader>cal")
            vim.keymap.del("n", "<Leader>caL")
        end,
    },
}

-- vim: foldmethod=indent foldlevel=1
