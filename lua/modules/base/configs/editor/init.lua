local icons = require("configs.base.ui.icons")

local config = {}

config.lvim_space = function()
    local lvim_space_status_ok, lvim_space = pcall(require, "lvim-space")
    if not lvim_space_status_ok then
        return
    end
    lvim_space.setup({
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
            local row = math.ceil((vim.api.nvim_get_option_value("lines", {}) - win_height) * 1 - 3)
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
                    border = "noborder",
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
    -- Marks set
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
    -- Jumps
    vim.keymap.set("n", "mjj", function()
        vessel.view_jumps()
    end, { desc = "Jumps all" })
    vim.keymap.set("n", "mjl", function()
        vessel.view_local_jumps()
    end, { desc = "Jumps local" })
    vim.keymap.set("n", "mje", function()
        vessel.view_external_jumps()
    end, { desc = "Jumps External" })
end

config.neocomposer_nvim = function()
    local neocomposer_status_ok, neocomposer = pcall(require, "NeoComposer")
    if not neocomposer_status_ok then
        return
    end
    neocomposer.setup({
        window = {
            width = 120,
            height = 26,
        },
        colors = {
            bg = _G.LVIM_COLORS.bg_dark,
            fg = _G.LVIM_COLORS.cyan,
            red = _G.LVIM_COLORS.red,
            blue = _G.LVIM_COLORS.blue,
            green = _G.LVIM_COLORS.green,
        },
        keymaps = {
            play_macro = "<Leader>q",
            yank_macro = "<Leader>ky",
            stop_macro = "<Leader>ks",
            toggle_record = "q",
            cycle_next = "<Leader>kn",
            cycle_prev = "<Leader>kp",
            toggle_macro_menu = "<Leader>km",
        },
    })
    vim.api.nvim_set_hl(0, "ComposerBorder", {
        bg = _G.LVIM_COLORS.bg_dark,
        fg = _G.LVIM_COLORS.bg_dark,
    })
    vim.api.nvim_set_hl(0, "ComposerTitle", {
        bg = _G.LVIM_COLORS.bg_dark,
        fg = _G.LVIM_COLORS.red,
    })
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
    vim.keymap.set("n", "<C-c><C-h>", function()
        vim.cmd("LvimDiagnostics")
    end, { noremap = true, silent = true, desc = "LspDiagnostic QF" })

    vim.keymap.set("n", "]]", function()
        vim.cmd("LvimListQuickFixNext")
    end, { noremap = true, silent = true, desc = "QfNext" })
    vim.keymap.set("n", "][", function()
        vim.cmd("LvimListQuickFixPrev")
    end, { noremap = true, silent = true, desc = "QfPrev" })
    vim.keymap.set("n", "]o", function()
        vim.cmd("copen")
    end, { noremap = true, silent = true, desc = "QfOpen" })
    vim.keymap.set("n", "]q", function()
        vim.cmd("cclose")
    end, { noremap = true, silent = true, desc = "QfClose" })
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

    vim.keymap.set("n", "[]", function()
        vim.cmd("LvimListLocNext")
    end, { noremap = true, silent = true, desc = "LocNext" })
    vim.keymap.set("n", "[[", function()
        vim.cmd("LvimListLocPrev")
    end, { noremap = true, silent = true, desc = "LocPrev" })
    vim.keymap.set("n", "[o", function()
        vim.cmd("lopen")
    end, { noremap = true, silent = true, desc = "LocOpen" })
    vim.keymap.set("n", "[q", function()
        vim.cmd("lclose")
    end, { noremap = true, silent = true, desc = "LocClose" })
    vim.keymap.set("n", "[c", function()
        vim.cmd("LvimListLocMenuChoice")
    end, { noremap = true, silent = true, desc = "LocMenuChoice" })
    vim.keymap.set("n", "[d", function()
        vim.cmd("LvimListLocMenuDelete")
    end, { noremap = true, silent = true, desc = "LocMenuDelete" })
    vim.keymap.set("n", "[l", function()
        vim.cmd("LvimListLocMenuLoad")
    end, { noremap = true, silent = true, desc = "LocMenuLoad" })
    vim.keymap.set("n", "[s", function()
        vim.cmd("LvimListLocMenuSave")
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

    -- Функция за получаване на табове от lvim-space
    local get_lvim_space_tabs = function()
        local pub_status_ok, pub = pcall(require, "lvim-space.pub")
        if pub_status_ok then
            return pub.get_tab_info()
        else
            return {}
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

        -- Заменяме vim табовете с lvim-space табове
        local lvim_tabs = get_lvim_space_tabs()
        for _, tab in ipairs(lvim_tabs) do
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
