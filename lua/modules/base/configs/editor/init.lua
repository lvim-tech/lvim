local funcs = require("core.funcs")
local icons = require("configs.base.ui.icons")

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
            prompt_prefix = " " .. icons.common.search .. " ",
            selection_caret = "  ",
            entry_prefix = "  ",
            initial_mode = "insert",
            selection_strategy = "reset",
            sorting_strategy = "ascending",
            layout_strategy = "bottom_pane",
            layout_config = {
                height = function()
                    return math.ceil((vim.api.nvim_get_option("lines") + 5) * _G.LVIM_SETTINGS.floatheight)
                end,
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
    fzf_lua.setup({
        fzf_colors = {
            ["fg"] = { "fg", "FzfLuaLine" },
            ["bg"] = { "bg", "FzfLuaNormal" },
            ["hl"] = { "fg", "FzfLuaItemKindVariable" },
            ["fg+"] = { "fg", "FzfLuaLinePlus" },
            ["bg+"] = { "bg", "FzfLuaNormal" },
            ["hl+"] = { "fg", "FzfLuaItemKindVariable" },
            ["info"] = { "fg", "FzfLuaPrompt" },
            ["prompt"] = { "fg", "FzfLuaPrompt" },
            ["pointer"] = { "fg", "DiagnosticError" },
            ["marker"] = { "fg", "DiagnosticError" },
            ["spinner"] = { "fg", "FzfLuaPrompt" },
            ["header"] = { "fg", "FzfLuaPrompt" },
            ["gutter"] = { "bg", "FzfLuaNormal" },
        },
        winopts_fn = function()
            local win_height = math.ceil(vim.api.nvim_get_option("lines") * _G.LVIM_SETTINGS.floatheight)
            local win_width = math.ceil(vim.api.nvim_get_option("columns") * 1)
            local col = math.ceil((vim.api.nvim_get_option("columns") - win_width) * 1)
            local row = math.ceil((vim.api.nvim_get_option("lines") - win_height) * 1 - 3)
            return {
                title = "FZF LUA",
                title_pos = "center",
                width = win_width,
                height = win_height,
                row = row,
                col = col,
                border = { " ", " ", " ", " ", " ", " ", " ", " " },
                preview = {
                    vertical = "down:45%",
                    horizontal = "right:50%",
                    border = "noborder",
                },
            }
        end,
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
                indicator = ("%d%s"):format(absRelIdx, sfw ~= (relIdx > 1) and icons.common.up or icons.common.down)
            elseif absRelIdx == 1 then
                indicator = sfw ~= (relIdx == 1) and icons.common.up or icons.common.down
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
            border = "single",
            winblend = 0,
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
            error = " " .. icons.diagnostics.error,
            warning = " " .. icons.diagnostics.warn,
            info = " " .. icons.diagnostics.info,
            hint = " " .. icons.diagnostics.hint,
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
    local tabby_util_status_ok, tabby_util = pcall(require, "tabby.util")
    if not tabby_util_status_ok then
        return
    end
    local tabby_filename_status_ok, tabby_filename = pcall(require, "tabby.filename")
    if not tabby_filename_status_ok then
        return
    end
    local theme = _G.LVIM_SETTINGS.theme
    local hl_tabline = {
        color_01 = _G.LVIM_COLORS["colors"][theme].bg_01,
        color_02 = _G.LVIM_COLORS["colors"][theme].bg_03,
        color_03 = _G.LVIM_COLORS["colors"][theme].green_01,
        color_04 = _G.LVIM_COLORS["colors"][theme].green_02,
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
                    " " .. icons.common.vim .. " ",
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

config.nvim_various_textobjs = function()
    local nvim_various_textobjs_status_ok, nvim_various_textobjs = pcall(require, "various-textobjs")
    if not nvim_various_textobjs_status_ok then
        return
    end
    nvim_various_textobjs.setup({
        useDefaultKeymaps = true,
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

config.rest_nvim = function()
    local rest_nvim_status_ok, rest_nvim = pcall(require, "rest-nvim")
    if not rest_nvim_status_ok then
        return
    end
    rest_nvim.setup()
    vim.api.nvim_create_user_command("Rest", "lua require('rest-nvim').run()", {})
    vim.api.nvim_create_user_command("RestPreview", "lua require('rest-nvim').run(true)", {})
    vim.api.nvim_create_user_command("RestLast", "lua require('rest-nvim').last()", {})
    vim.keymap.set("n", "rr", function()
        rest_nvim.run()
    end, { noremap = true, silent = true, desc = "Rest" })
    vim.keymap.set("n", "rp", function()
        rest_nvim.run(true)
    end, { noremap = true, silent = true, desc = "RestPreview" })
    vim.keymap.set("n", "rl", function()
        rest_nvim.last()
    end, { noremap = true, silent = true, desc = "RestLast" })
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

config.code_runner_nvim = function()
    local global = require("core.global")
    local code_runner_status_ok, code_runner = pcall(require, "code_runner")
    if not code_runner_status_ok then
        return
    end
    code_runner.setup({
        filetype_path = global.lvim_path .. "/.configs/code_runner/files.json",
        project_path = global.lvim_path .. "/.configs/code_runner/projects.json",
        mode = "float",
        -- Focus on runner window(only works on toggle, term and tab mode)
        focus = true,
        -- startinsert (see ':h inserting-ex')
        startinsert = true,
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
    local ft_exclude = require("modules.base.configs.ui.heirline.file_types")
    local bt_exclude = require("modules.base.configs.ui.heirline.buf_types")
    ccc.setup({
        alpha_show = "show",
    })
    vim.keymap.set("n", "<C-c>r", function()
        vim.cmd("CccPick")
    end, { noremap = true, silent = true, desc = "ColorPicker" })
    vim.api.nvim_create_autocmd("Filetype", {
        callback = function()
            if
                not funcs.buffer_matches({
                    buftype = bt_exclude,
                    filetype = ft_exclude,
                })
            then
                vim.cmd("CccHighlighterEnable")
            end
        end,
        -- command = "CccHighlighterEnable",
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
            FIX = { icon = icons.common.fix, color = "error", alt = { "FIX", "FIXME" } },
            TODO = { icon = icons.common.todo, color = "info", alt = { "TODO" } },
            HACK = { icon = icons.common.hack, color = "error", alt = { "HACK" } },
            WARN = { icon = icons.common.warning, color = "warning", alt = { "WARNING", "XXX" } },
            PERF = { icon = icons.common.performance, color = "warning", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
            NOTE = { icon = icons.common.note, color = "hint", alt = { "INFO" } },
            TEST = { icon = icons.common.test, color = "test", alt = { "TEST", "TESTING", "PASSED", "FAILED" } },
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
