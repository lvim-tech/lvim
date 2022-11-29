local config = {}

config.editorconfig_nvim = function()
    vim.api.nvim_create_user_command(
        "EditorConfigCreate",
        "lua require'core.funcs'.copy_file(require'core.global'.lvim_path .. '/.configs/templates/.editorconfig', vim.fn.getcwd() .. '/.editorconfig')",
        {}
    )
end

config.vim_ctrlspace = function()
    vim.keymap.set("n", "<space><space>", function()
        vim.cmd("CtrlSpace")
    end, { noremap = true, silent = true, desc = "CtrlSpace" })
end

config.telescope_nvim = function()
    local telescope_status_ok, telescope = pcall(require, "telescope")
    if not telescope_status_ok then
        return
    end
    if not packer_plugins["telescope-fzf-native.nvim"].loaded then
        local loader = require("packer").loader
        loader("telescope-fzf-native.nvim" .. " telescope-file-browser.nvim" .. " telescope-tmux.nvim")
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
                    preview_width = 0.55,
                    results_width = 0.8,
                },
                vertical = {
                    mirror = false,
                },
                width = 0.95,
                height = 0.90,
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
    telescope.load_extension("fzf")
    telescope.load_extension("file_browser")
    telescope.load_extension("tmux")
    vim.keymap.set("n", "<A-,>", function()
        vim.cmd("Telescope find_files")
    end, { noremap = true, silent = true, desc = "Telescope find_files" })
    vim.keymap.set("n", "<A-.>", function()
        vim.cmd("Telescope live_grep")
    end, { noremap = true, silent = true, desc = "Telescope live_grep" })
    vim.keymap.set("n", "<A-/>", function()
        vim.cmd("Telescope file_browser")
    end, { noremap = true, silent = true, desc = "Telescope file_browser" })
    vim.keymap.set("n", "<A-b>", function()
        vim.cmd("Telescope buffers")
    end, { noremap = true, silent = true, desc = "Telescope buffers" })
    vim.keymap.set("n", "tt", function()
        vim.cmd("Telescope tmux sessions")
    end, { noremap = true, silent = true, desc = "Telescope tmux sessions" })
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

config.nvim_hlslens = function()
    local hlslens_status_ok, hlslens = pcall(require, "hlslens")
    if not hlslens_status_ok then
        return
    end
    hlslens.setup({
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
    pqf.setup()
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
            "calendar",
            "octo",
            "neo-tree",
            "neo-tree-popup",
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

config.nvim_gomove = function()
    local gomove_status_ok, gomove = pcall(require, "gomove")
    if not gomove_status_ok then
        return
    end
    gomove.setup()
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
    vim.api.nvim_create_user_command("Spectre", "lua require('spectre').open()", {})
    spectre.setup({
        color_devicons = true,
        line_sep_start = "-----------------------------------------",
        result_padding = "|  ",
        line_sep = "-----------------------------------------",
        highlight = {
            ui = "String",
            search = "DiffAdd",
            replace = "DiffChange",
        },
        mapping = {
            ["delete_line"] = nil,
            ["enter_file"] = nil,
            ["send_to_qf"] = nil,
            ["replace_cmd"] = nil,
            ["show_option_menu"] = nil,
            ["run_replace"] = nil,
            ["change_view_mode"] = nil,
            ["toggle_ignore_case"] = nil,
            ["toggle_ignore_hidden"] = nil,
        },
        find_engine = {
            ["rg"] = {
                cmd = "rg",
                args = {
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                },
                options = {
                    ["ignore-case"] = {
                        value = "--ignore-case",
                        icon = "[I]",
                        desc = "ignore case",
                    },
                    ["hidden"] = {
                        value = "--hidden",
                        desc = "hidden file",
                        icon = "[H]",
                    },
                },
            },
            ["ag"] = {
                cmd = "ag",
                args = { "--vimgrep", "-s" },
                options = {
                    ["ignore-case"] = {
                        value = "-i",
                        icon = "[I]",
                        desc = "ignore case",
                    },
                    ["hidden"] = {
                        value = "--hidden",
                        desc = "hidden file",
                        icon = "[H]",
                    },
                },
            },
        },
        replace_engine = {
            ["sed"] = {
                cmd = "sed",
                args = nil,
            },
            options = {
                ["ignore-case"] = {
                    value = "--ignore-case",
                    icon = "[I]",
                    desc = "ignore case",
                },
            },
        },
        default = {
            find = {
                cmd = "rg",
                options = { "ignore-case" },
            },
            replace = {
                cmd = "sed",
            },
        },
        replace_vim_cmd = "cfdo",
        is_open_target_win = true,
        is_insert_mode = false,
    })
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

config.nvim_colorize_lua = function()
    local colorizer_status_ok, colorizer = pcall(require, "colorizer")
    if not colorizer_status_ok then
        return
    end
    colorizer.setup()
    vim.api.nvim_create_autocmd("BufWritePost", {
        callback = function()
            vim.api.nvim_command("ColorizerAttachToBuffer")
        end,
        group = "LvimIDE",
    })
end

config.color_picker_nvim = function()
    local color_picker_status_ok, color_picker = pcall(require, "color-picker")
    if not color_picker_status_ok then
        return
    end
    color_picker.setup({})
    vim.keymap.set("n", "<C-c>p", function()
        vim.cmd("PickColor")
    end, { noremap = true, silent = true, desc = "ColorPicker" })
    vim.keymap.set("n", "<C-c>P", function()
        vim.cmd("PickColorInsert")
    end, { noremap = true, silent = true, desc = "PickColorInsert" })
end

config.lvim_colorcolumn = function()
    local lvim_colorcolumn_status_ok, lvim_colorcolumn = pcall(require, "lvim-colorcolumn")
    if not lvim_colorcolumn_status_ok then
        return
    end
    lvim_colorcolumn.setup()
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
