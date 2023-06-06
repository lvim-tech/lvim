local config = {}

config.navigator_nvim = function()
    require("Navigator").setup()
    vim.keymap.set("n", "<C-h>", "<CMD>NavigatorLeft<CR>")
    vim.keymap.set("n", "<C-l>", "<CMD>NavigatorRight<CR>")
    vim.keymap.set("n", "<C-k>", "<CMD>NavigatorUp<CR>")
    vim.keymap.set("n", "<C-j>", "<CMD>NavigatorDown<CR>")
end

config.telescope_nvim = function()
    local telescope_status_ok, telescope = pcall(require, "telescope")
    if not telescope_status_ok then
        return
    end
    telescope.setup({
        defaults = {
            prompt_prefix = "   ",
            selection_caret = "  ",
            entry_prefix = "  ",
            initial_mode = "insert",
            selection_strategy = "reset",
            sorting_strategy = "ascending",
            layout_strategy = "horizontal",
            layout_config = {
                horizontal = {
                    prompt_position = "top",
                    preview_width = 0.5,
                    results_width = 0.5,
                },
                vertical = {
                    mirror = false,
                },
                width = 0.95,
                height = 0.95,
                preview_cutoff = 120,
            },
            vimgrep_arguments = {
                "rg",
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
                "--smart-case",
                "--hidden",
            },
            file_sorter = require("telescope.sorters").get_fuzzy_file,
            file_ignore_patterns = {
                "node_modules",
                ".git",
                "target",
                "vendor",
            },
            generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
            path_display = { shorten = 5 },
            winblend = 0,
            border = {},
            borderchars = { " ", " ", " ", " ", " ", " ", " ", " " },
            color_devicons = true,
            set_env = { ["COLORTERM"] = "truecolor" },
            file_previewer = require("telescope.previewers").vim_buffer_cat.new,
            grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
            qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
            buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
        },
        pickers = {
            file_browser = {
                hidden = true,
            },
            find_files = {
                hidden = true,
            },
            live_grep = {
                hidden = true,
                only_sort_text = true,
            },
        },
        extensions = {
            fzf = {
                fuzzy = true,
                override_generic_sorter = false,
                override_file_sorter = true,
                case_mode = "smart_case",
            },
            file_browser = {},
        },
    })
    telescope.load_extension("macros")
    telescope.load_extension("fzf")
    telescope.load_extension("file_browser")
    telescope.load_extension("tmux")
    vim.keymap.set("n", "tt", function()
        vim.cmd("Telescope tmux sessions")
    end, { noremap = true, silent = true, desc = "Telescope tmux sessions" })
    vim.api.nvim_create_autocmd("User", {
        pattern = "TelescopePreviewerLoaded",
        callback = function()
            vim.opt.number = true
        end,
    })
end

config.fzf_lua = function()
    local fzf_lua_status_ok, fzf_lua = pcall(require, "fzf-lua")
    if not fzf_lua_status_ok then
        return
    end
    local actions = require("fzf-lua.actions")
    fzf_lua.setup({
        winopts = {
            height = 1.00,
            width = 1.00,
            border = { " ", " ", " ", " ", " ", " ", " ", " " },
            preview = {
                vertical = "down:45%",
                horizontal = "right:50%",
                border = "noborder",
            },
        },
        keymap = {
            builtin = {
                ["<F1>"] = "toggle-help",
                ["<F2>"] = "toggle-fullscreen",
                ["<F3>"] = "toggle-preview-wrap",
                ["<F4>"] = "toggle-preview",
                ["<F5>"] = "toggle-preview-ccw",
                ["<C-d>"] = "preview-page-down",
                ["<C-u>"] = "preview-page-up",
                ["<C-r>"] = "preview-page-reset",
            },
        },
        actions = {
            files = {
                ["default"] = actions.file_edit_or_qf,
                ["ctrl-h"] = actions.file_split,
                ["ctrl-v"] = actions.file_vsplit,
                ["ctrl-t"] = actions.file_tabedit,
                ["alt-q"] = actions.file_sel_to_qf,
                ["alt-l"] = actions.file_sel_to_ll,
            },
            buffers = {
                ["default"] = actions.buf_edit,
                ["ctrl-h"] = actions.buf_split,
                ["ctrl-v"] = actions.buf_vsplit,
                ["ctrl-t"] = actions.buf_tabedit,
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

config.rg_nvim = function()
    local rg_status_ok, rg = pcall(require, "rg")
    if not rg_status_ok then
        return
    end
    rg.setup({
        default_keybindings = {
            enable = true,
            modes = { "v" },
            binding = "tr",
        },
    })
end

config.neocomposer_nvim = function()
    local neocomposer_status_ok, neocomposer = pcall(require, "NeoComposer")
    if not neocomposer_status_ok then
        return
    end
    neocomposer.setup({
        notify = false,
        colors = {
            bg = _G.LVIM_SETTINGS.colorschemes.colors[_G.LVIM_SETTINGS.colorschemes.theme].bg,
            fg = _G.LVIM_SETTINGS.colorschemes.colors[_G.LVIM_SETTINGS.colorschemes.theme].teal_01,
            red = _G.LVIM_SETTINGS.colorschemes.colors[_G.LVIM_SETTINGS.colorschemes.theme].red_02,
            blue = _G.LVIM_SETTINGS.colorschemes.colors[_G.LVIM_SETTINGS.colorschemes.theme].blue_02,
            green = _G.LVIM_SETTINGS.colorschemes.colors[_G.LVIM_SETTINGS.colorschemes.theme].green_02,
        },
        keymaps = {
            play_macro = "<Leader>q",
            toggle_record = "Q",
            cycle_next = "<m-n>",
            cycle_prev = "<m-p>",
        },
    })
end

config.nvim_peekup = function()
    vim.api.nvim_create_autocmd("FileType", {
        pattern = {
            "peek",
        },
        callback = function()
            vim.opt_local.clipboard = "unnamed"
        end,
        group = "LvimIDE",
    })
end
config.nvim_hlslens = function()
    local hlslens_status_ok, hlslens = pcall(require, "hlslens")
    if not hlslens_status_ok then
        return
    end
    hlslens.setup({
        nearest_float_when = false,
        override_lens = function(render, posList, nearest, idx, relIdx)
            local sfw = vim.v.searchforward == 1
            local indicator, text, chunks
            local absRelIdx = math.abs(relIdx)
            if absRelIdx > 1 then
                indicator = ("%d%s"):format(absRelIdx, sfw ~= (relIdx > 1) and "" or "")
            elseif absRelIdx == 1 then
                indicator = sfw ~= (relIdx == 1) and "" or ""
            else
                indicator = ""
            end

            local lnum, col = unpack(posList[idx])
            if nearest then
                local cnt = #posList
                if indicator ~= "" then
                    text = ("[%s %d/%d]"):format(indicator, idx, cnt)
                else
                    text = ("[%d/%d]"):format(idx, cnt)
                end
                chunks = { { " ", "Ignore" }, { text, "HlSearchLensNear" } }
            else
                text = ("[%s %d]"):format(indicator, idx)
                chunks = { { " ", "Ignore" }, { text, "HlSearchLens" } }
            end
            render.setVirt(0, lnum - 1, col - 1, chunks, nearest)
        end,
    })
    local opts = { noremap = true, silent = true }
    vim.keymap.set(
        "n",
        "n",
        [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
        opts
    )
    vim.keymap.set(
        "n",
        "N",
        [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
        opts
    )
    vim.keymap.set("n", "*", [[*<Cmd>lua require('hlslens').start()<CR>]], opts)
    vim.keymap.set("n", "#", [[#<Cmd>lua require('hlslens').start()<CR>]], opts)
    vim.keymap.set("n", "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]], opts)
    vim.keymap.set("n", "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]], opts)
end

config.nvim_bqf = function()
    local bqf_status_ok, bqf = pcall(require, "bqf")
    if not bqf_status_ok then
        return
    end
    bqf.setup({
        delay_syntax = 1,
        preview = {
            border_chars = { "│", "│", "─", "─", "┌", "┐", "└", "┘", "█" },
        },
    })
end

config.nvim_pqf = function()
    local pqf_status_ok, pqf = pcall(require, "pqf")
    if not pqf_status_ok then
        return
    end
    pqf.setup({
        signs = {
            error = "  ",
            warning = "  ",
            hint = "  ",
            info = "  ",
        },
    })
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
    vim.keymap.set("n", "]m", function()
        vim.cmd("LvimListQuickFixMenuChoice")
    end, { noremap = true, silent = true, desc = "QfMenuChoice" })
    vim.keymap.set("n", "]d", function()
        vim.cmd("LvimListQuickFixMenuDelete")
    end, { noremap = true, silent = true, desc = "QfMenuDelete" })
    vim.keymap.set("n", "][", function()
        vim.cmd("copen")
    end, { noremap = true, silent = true, desc = "QfOpen" })
    vim.keymap.set("n", "[]", function()
        vim.cmd("cclose")
    end, { noremap = true, silent = true, desc = "QfClose" })
    vim.keymap.set("n", "]]", function()
        vim.cmd("LvimListQuickFixNext")
    end, { noremap = true, silent = true, desc = "QfNext" })
    vim.keymap.set("n", "[[", function()
        vim.cmd("LvimListQuickFixPrev")
    end, { noremap = true, silent = true, desc = "QfPrev" })
    vim.keymap.set("n", "]lm", function()
        vim.cmd("LvimListLocMenuChoice")
    end, { noremap = true, silent = true, desc = "LocMenuChoice" })
    vim.keymap.set("n", "]ld", function()
        vim.cmd("LvimListLocMenuDelete")
    end, { noremap = true, silent = true, desc = "LocMenuDelete" })
    vim.keymap.set("n", "]l[", function()
        vim.cmd("lopen")
    end, { noremap = true, silent = true, desc = "LocOpen" })
    vim.keymap.set("n", "[l]", function()
        vim.cmd("lclose")
    end, { noremap = true, silent = true, desc = "LocClose" })
    vim.keymap.set("n", "]l]", function()
        vim.cmd("LvimListLocNext")
    end, { noremap = true, silent = true, desc = "LocNext" })
    vim.keymap.set("n", "[l[", function()
        vim.cmd("LvimListLocPrev")
    end, { noremap = true, silent = true, desc = "LocPrev" })
end

config.tabby_nvim = function()
    local tabby_status_ok, tabby = pcall(require, "tabby")
    if not tabby_status_ok then
        return
    end
    local tabby_util_status_ok, tabby_util = pcall(require, "tabby.util")
    if not tabby_util_status_ok then
        return
    end
    local tabby_filename_status_ok, tabby_filename = pcall(require, "tabby.filename")
    if not tabby_filename_status_ok then
        return
    end
    local theme = _G.LVIM_SETTINGS.colorschemes.theme
    local hl_tabline = {
        color_01 = _G.LVIM_SETTINGS.colorschemes.colors[theme].bg_01,
        color_02 = _G.LVIM_SETTINGS.colorschemes.colors[theme].bg_03,
        color_03 = _G.LVIM_SETTINGS.colorschemes.colors[theme].green_01,
        color_04 = _G.LVIM_SETTINGS.colorschemes.colors[theme].green_02,
    }
    local get_tab_label = function(tab_number)
        local s, v = pcall(function()
            return vim.api.nvim_eval("ctrlspace#util#Gettabvar(" .. tab_number .. ", 'CtrlSpaceLabel')")
        end)
        if s then
            if v == "" then
                return tab_number
            else
                return tab_number .. ": " .. v
            end
        else
            return tab_number .. ": " .. v
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
                    "    ",
                    hl = {
                        bg = hl_tabline.color_04,
                        fg = hl_tabline.color_01,
                        style = "bold",
                    },
                },
            },
        }
        local tabs = vim.api.nvim_list_tabpages()
        local current_tab = vim.api.nvim_get_current_tabpage()
        local name_of_buf
        local wins = tabby_util.tabpage_list_wins(current_tab)
        local top_win = vim.api.nvim_tabpage_get_win(current_tab)
        local hl
        local win_name
        for _, win_id in ipairs(wins) do
            local ft = vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(win_id), "filetype")
            win_name = tabby_filename.unique(win_id)
            if not vim.tbl_contains(exclude, ft) then
                if win_id == top_win then
                    hl = { bg = hl_tabline.color_03, fg = hl_tabline.color_02, style = "bold" }
                else
                    hl = { bg = hl_tabline.color_02, fg = hl_tabline.color_03, style = "bold" }
                end
                table.insert(comps, {
                    type = "win",
                    winid = win_id,
                    label = {
                        "  " .. win_name .. "  ",
                        hl = hl,
                    },
                    right_sep = { "", hl = { bg = hl_tabline.color_01, fg = hl_tabline.color_01 } },
                })
            end
        end
        table.insert(comps, {
            type = "text",
            text = { "%=" },
            hl = { bg = hl_tabline.color_01, fg = hl_tabline.color_01 },
        })
        for _, tab_id in ipairs(tabs) do
            local tab_number = vim.api.nvim_tabpage_get_number(tab_id)
            name_of_buf = get_tab_label(tab_number)
            if tab_id == current_tab then
                hl = { bg = hl_tabline.color_03, fg = hl_tabline.color_02, style = "bold" }
            else
                hl = { bg = hl_tabline.color_02, fg = hl_tabline.color_03, style = "bold" }
            end
            table.insert(comps, {
                type = "tab",
                tabid = tab_id,
                label = {
                    "  " .. name_of_buf .. "  ",
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

config.nvim_treesitter_textobject = function()
    require("nvim-treesitter.configs").setup({
        require("nvim-treesitter.configs").setup({
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        ["ac"] = "@class.outer",
                        ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
                        ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
                    },
                    selection_modes = {
                        ["@parameter.outer"] = "v",
                        ["@function.outer"] = "V",
                        ["@class.outer"] = "<c-v>",
                    },
                    include_surrounding_whitespace = true,
                },
            },
        }),
    })
end

config.nvim_treesitter_context = function()
    local treesitter_context_status_ok, treesitter_context = pcall(require, "treesitter-context")
    if not treesitter_context_status_ok then
        return
    end
    treesitter_context.setup({
        enable = true,
        max_lines = 0,
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
        exact_patterns = {},
        zindex = 20,
        mode = "cursor",
        separator = nil,
    })
end

config.nvim_treeclimber = function()
    local nvim_treeclimber_status_ok, nvim_treeclimber = pcall(require, "nvim-treeclimber")
    if not nvim_treeclimber_status_ok then
        return
    end
    vim.api.nvim_set_hl(
        0,
        "TreeClimberHighlight",
        { background = _G.LVIM_SETTINGS.colorschemes.colors[_G.LVIM_SETTINGS.colorschemes.theme].bg_05 }
    )
    vim.api.nvim_set_hl(
        0,
        "TreeClimberSiblingBoundary",
        { background = _G.LVIM_SETTINGS.colorschemes.colors[_G.LVIM_SETTINGS.colorschemes.theme].bg }
    )
    vim.api.nvim_set_hl(0, "TreeClimberSibling", {
        background = _G.LVIM_SETTINGS.colorschemes.colors[_G.LVIM_SETTINGS.colorschemes.theme].bg_04,
        bold = true,
    })
    vim.api.nvim_set_hl(
        0,
        "TreeClimberParent",
        { background = _G.LVIM_SETTINGS.colorschemes.colors[_G.LVIM_SETTINGS.colorschemes.theme].orange_01 }
    )
    vim.api.nvim_set_hl(
        0,
        "TreeClimberParentStart",
        { background = _G.LVIM_SETTINGS.colorschemes.colors[_G.LVIM_SETTINGS.colorschemes.theme].teal_01, bold = true }
    )
    vim.keymap.set("n", "<leader>k", nvim_treeclimber.show_control_flow, {})
    vim.keymap.set({ "x", "o" }, "i.", nvim_treeclimber.select_current_node, { desc = "select current node" })
    vim.keymap.set({ "x", "o" }, "a.", nvim_treeclimber.select_expand, { desc = "select parent node" })
    vim.keymap.set(
        { "n", "x", "o" },
        "tle",
        nvim_treeclimber.select_forward_end,
        { desc = "select and move to the end of the node, or the end of the next node" }
    )
    vim.keymap.set(
        { "n", "x", "o" },
        "tlb",
        nvim_treeclimber.select_backward,
        { desc = "select and move to the begining of the node, or the beginning of the next node" }
    )
    vim.keymap.set({ "n", "x", "o" }, "tl[", nvim_treeclimber.select_siblings_backward, {})
    vim.keymap.set({ "n", "x", "o" }, "tl]", nvim_treeclimber.select_siblings_forward, {})
    vim.keymap.set(
        { "n", "x", "o" },
        "tlg",
        nvim_treeclimber.select_top_level,
        { desc = "select the top level node from the current position" }
    )
    vim.keymap.set({ "n", "x", "o" }, "tlh", nvim_treeclimber.select_backward, { desc = "select previous node" })
    vim.keymap.set({ "n", "x", "o" }, "tlj", nvim_treeclimber.select_shrink, { desc = "select child node" })
    vim.keymap.set({ "n", "x", "o" }, "tlk", nvim_treeclimber.select_expand, { desc = "select parent node" })
    vim.keymap.set({ "n", "x", "o" }, "tll", nvim_treeclimber.select_forward, { desc = "select the next node" })
    vim.keymap.set(
        { "n", "x", "o" },
        "tlL",
        nvim_treeclimber.select_grow_forward,
        { desc = "Add the next node to the selection" }
    )
    vim.keymap.set(
        { "n", "x", "o" },
        "tlH",
        nvim_treeclimber.select_grow_backward,
        { desc = "Add the next node to the selection" }
    )
end

config.rest_nvim = function()
    local rest_nvim_status_ok, rest_nvim = pcall(require, "rest-nvim")
    if not rest_nvim_status_ok then
        return
    end
    rest_nvim.setup()
    vim.api.nvim_create_user_command("Rest", "lua require('rest-nvim').run()", {})
    vim.api.nvim_create_user_command("RestPreview", "lua require('rest-nvim').run(true)", {})
    vim.api.nvim_create_user_command("RestLast", "lua require('rest-nvim').last()", {})
    vim.keymap.set("n", "trr", function()
        rest_nvim.run()
    end, { noremap = true, silent = true, desc = "Rest" })
    vim.keymap.set("n", "trp", function()
        rest_nvim.run(true)
    end, { noremap = true, silent = true, desc = "RestPreview" })
    vim.keymap.set("n", "trl", function()
        rest_nvim.last()
    end, { noremap = true, silent = true, desc = "RestLast" })
end

config.sniprun = function()
    local sniprun_status_ok, sniprun = pcall(require, "sniprun")
    if not sniprun_status_ok then
        return
    end
    sniprun.setup()
    vim.keymap.set({ "n", "v" }, "ts", ":SnipRun<CR>", { noremap = true, silent = true, desc = "SnipRun" })
    vim.keymap.set("n", "<Esc>", "<Esc>:noh<CR>:SnipClose<CR>", { noremap = true, silent = true, desc = "Escape" })
end

config.code_runner_nvim = function()
    local global = require("core.global")
    local code_runner_status_ok, code_runner = pcall(require, "code_runner")
    if not code_runner_status_ok then
        return
    end
    code_runner.setup({
        filetype_path = global.lvim_path .. "/.configs/code_runner/files.json",
        project_path = global.lvim_path .. "/.configs/code_runner/projects.json",
    })
end

config.nvim_spectre = function()
    local spectre_status_ok, spectre = pcall(require, "spectre")
    if not spectre_status_ok then
        return
    end
    spectre.setup()
    vim.api.nvim_create_user_command("Spectre", "lua require('spectre').open()", {})
    vim.api.nvim_create_user_command("SpectreToggleLine", "lua require('spectre').toggle_line()", {})
    vim.api.nvim_create_user_command("SpectreSelectEntry", "lua require('spectre.actions').select_entry()", {})
    vim.api.nvim_create_user_command(
        "SpectreRunCurrentReplace",
        "lua require('spectre.actions').run_current_replace()",
        {}
    )
    vim.api.nvim_create_user_command("SpectreRunReplace", "lua require('spectre.actions').run_replace()", {})
    vim.api.nvim_create_user_command("SpectreSendToQF", "lua require('spectre.actions').send_to_qf()", {})
    vim.api.nvim_create_user_command("SpectreReplaceCommand", "lua require('spectre.actions').replace_cmd()", {})
    vim.api.nvim_create_user_command("SpectreToggleLiveUpdate", "lua require('spectre').toggle_live_update()", {})
    vim.api.nvim_create_user_command("SpectreChangeView", "lua require('spectre').change_view()", {})
    vim.api.nvim_create_user_command("SpectreResumeLastSearch", "lua require('spectre').resume_last_search()", {})
    vim.api.nvim_create_user_command("SpectreIgnoreCase", "lua require('spectre').change_options('ignore-case')", {})
    vim.api.nvim_create_user_command("SpectreHidden", "lua require('spectre').change_options('hidden')", {})
    vim.api.nvim_create_user_command("SpectreShowOptions", "lua require('spectre').show_options()", {})
    vim.keymap.set("n", "<A-s>", function()
        vim.cmd("Spectre")
    end, { noremap = true, silent = true, desc = "Spectre" })
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
    })
    vim.keymap.set("n", "<C-c>p", function()
        vim.cmd("CccPick")
    end, { noremap = true, silent = true, desc = "ColorPicker" })
    vim.api.nvim_create_autocmd("Filetype", {
        command = "CccHighlighterEnable",
    })
end

config.suda_vim = function()
    vim.g.suda_smart_edit = 1
end

config.hop_nvim = function()
    local hop_status_ok, hop = pcall(require, "hop")
    if not hop_status_ok then
        return
    end
    hop.setup()
end

config.todo_comments_nvim = function()
    local todo_comments_status_ok, todo_comments = pcall(require, "todo-comments")
    if not todo_comments_status_ok then
        return
    end
    todo_comments.setup({
        keywords = {
            FIX = { icon = " ", color = "error", alt = { "FIX", "FIXME" } },
            TODO = { icon = " ", color = "info", alt = { "TODO" } },
            HACK = { icon = " ", color = "error", alt = { "HACK" } },
            WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
            PERF = { icon = "神", color = "warning", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
            NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
            TEST = { icon = " ", color = "test", alt = { "TEST", "TESTING", "PASSED", "FAILED" } },
        },
        highlight = {
            before = "fg",
            keyword = "fg",
            after = "fg",
        },
        colors = {
            error = { "ToDoError" },
            warning = { "ToDoWarning" },
            info = { "ToDoInfo" },
            hint = { "ToDoHint" },
            test = { "ToDoTest" },
        },
    })
end

config.pretty_fold_nvim = function()
    local pretty_fold_status_ok, pretty_fold = pcall(require, "pretty-fold")
    if not pretty_fold_status_ok then
        return
    end
    pretty_fold.setup({
        fill_char = "─",
        sections = {
            left = {
                "content",
            },
            right = {
                "┤ ",
                "number_of_folded_lines",
                " ├─",
            },
        },
        ft_ignore = { "org" },
    })
    local fold_preview_status_ok, fold_preview = pcall(require, "fold-preview")
    if not fold_preview_status_ok then
        return
    end
    fold_preview.setup({
        default_keybindings = false,
    })
    local map = require("fold-preview").mapping
    function _G.fold_preview()
        map.show_close_preview_open_fold()
        vim.cmd("IndentBlanklineRefresh")
    end
    vim.api.nvim_create_user_command("FoldPreview", "lua _G.fold_preview()", {})
    vim.keymap.set("n", "zp", function()
        _G.fold_preview()
    end, { noremap = true, silent = true, desc = "FoldPreview" })
end

config.calendar_vim = function()
    vim.g.calendar_diary_extension = ".org"
    vim.g.calendar_diary = "~/Org/diary/"
    vim.g.calendar_diary_path_pattern = "{YYYY}-{MM}-{DD}{EXT}"
    vim.g.calendar_monday = 1
    vim.g.calendar_weeknm = 1
    vim.keymap.set("n", "tc", function()
        vim.cmd("CalendarVR")
    end, { noremap = true, silent = true, desc = "Calendar" })
end

return config
