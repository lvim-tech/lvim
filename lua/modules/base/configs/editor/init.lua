local config = {}

function config.vim_ctrlspace()
    vim.keymap.set("n", "<space><space>", function()
        vim.cmd("CtrlSpace")
    end, { noremap = true, silent = true })
end

function config.telescope_nvim()
    local telescope_status_ok, telescope = pcall(require, "telescope")
    if not telescope_status_ok then
        return
    end
    if not packer_plugins["telescope-fzf-native.nvim"].loaded then
        local loader = require("packer").loader
        loader(
            "telescope-fzf-native.nvim" .. " telescope-file-browser.nvim" .. " telescope-tmux.nvim" .. " howdoi.nvim"
        )
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
            winblend = 8,
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
    telescope.load_extension("howdoi")
    vim.keymap.set("n", "<A-,>", function()
        vim.cmd("Telescope find_files")
    end, { noremap = true, silent = true })
    vim.keymap.set("n", "<A-.>", function()
        vim.cmd("Telescope live_grep")
    end, { noremap = true, silent = true })
    vim.keymap.set("n", "<A-/>", function()
        vim.cmd("Telescope file_browser")
    end, { noremap = true, silent = true })
    vim.keymap.set("n", "<A-b>", function()
        vim.cmd("Telescope buffers")
    end, { noremap = true, silent = true })
    vim.keymap.set("n", "th", function()
        vim.cmd("Telescope howdoi")
    end, { noremap = true, silent = true })
    vim.keymap.set("n", "tt", function()
        vim.cmd("Telescope tmux sessions")
    end, { noremap = true, silent = true })
end

function config.rg_nvim()
    local rg_status_ok, rg = pcall(require, "rg")
    if not rg_status_ok then
        return
    end
    rg.setup({
        default_keybindings = {
            enable = true,
            modes = { "n", "v" },
            binding = "te",
        },
    })
end

function config.nvim_hlslens()
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
    local kopts = { noremap = true, silent = true }
    vim.api.nvim_set_keymap(
        "n",
        "n",
        [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
        kopts
    )
    vim.api.nvim_set_keymap(
        "n",
        "N",
        [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
        kopts
    )
    vim.api.nvim_set_keymap("n", "*", [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
    vim.api.nvim_set_keymap("n", "#", [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
    vim.api.nvim_set_keymap("n", "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
    vim.api.nvim_set_keymap("n", "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)
end

function config.nvim_bqf()
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

function config.nvim_pqf()
    local pqf_status_ok, pqf = pcall(require, "pqf")
    if not pqf_status_ok then
        return
    end
    pqf.setup()
end

function config.tabby_nvim()
    local tabby_util_status_ok, tabby_util = pcall(require, "tabby.util")
    if not tabby_util_status_ok then
        return
    end
    local hl_tabline = {
        color_01 = _G.LVIM_COLORS.bg,
        color_02 = _G.LVIM_COLORS.color_01,
    }
    local get_tab_label = function(tab_number)
        local s, v = pcall(function()
            if not packer_plugins["vim-ctrlspace"].loaded then
                vim.cmd("packadd vim-ctrlspace")
            end
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
        local coms = {
            {
                type = "text",
                text = {
                    "    ",
                    hl = {
                        fg = hl_tabline.color_01,
                        bg = hl_tabline.color_02,
                        style = "bold",
                    },
                },
            },
        }
        local tabs = vim.api.nvim_list_tabpages()
        local current_tab = vim.api.nvim_get_current_tabpage()
        local name_of_buf
        for _, tabid in ipairs(tabs) do
            local tab_number = vim.api.nvim_tabpage_get_number(tabid)
            name_of_buf = get_tab_label(tab_number)
            if tabid == current_tab then
                table.insert(coms, {
                    type = "tab",
                    tabid = tabid,
                    label = {
                        "  " .. name_of_buf .. "  ",
                        hl = { fg = hl_tabline.color_02, bg = hl_tabline.color_01, style = "bold" },
                    },
                })
                local wins = tabby_util.tabpage_list_wins(current_tab)
                local top_win = vim.api.nvim_tabpage_get_win(current_tab)
                for _, winid in ipairs(wins) do
                    local icon = " "
                    if winid == top_win then
                        icon = " "
                    end
                    local bufid = vim.api.nvim_win_get_buf(winid)
                    local buf_name = vim.api.nvim_buf_get_name(bufid)
                    table.insert(coms, {
                        type = "win",
                        winid = winid,
                        label = icon .. vim.fn.fnamemodify(buf_name, ":~:.") .. "  ",
                    })
                end
            else
                table.insert(coms, {
                    type = "tab",
                    tabid = tabid,
                    label = {
                        "  " .. name_of_buf .. "  ",
                        hl = { fg = hl_tabline.color_01, bg = hl_tabline.color_02, style = "bold" },
                    },
                })
            end
        end
        table.insert(coms, { type = "text", text = { " ", hl = { bg = hl_tabline.color_01, style = "bold" } } })
        return coms
    end
    local tabby_status_ok, tabby = pcall(require, "tabby")
    if not tabby_status_ok then
        return
    end
    tabby.setup({
        components = components,
    })
end

function config.nvim_lastplace()
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

function config.dial_nvim()
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
    local opts = { noremap = true, silent = true }
    vim.api.nvim_set_keymap("n", "<C-a>", "<Plug>(dial-increment)", opts)
    vim.api.nvim_set_keymap("n", "<C-x>", "<Plug>(dial-decrement)", opts)
    vim.api.nvim_set_keymap("v", "<C-a>", "<Plug>(dial-increment)", opts)
    vim.api.nvim_set_keymap("v", "<C-x>", "<Plug>(dial-decrement)", opts)
    vim.api.nvim_set_keymap("v", "g<C-a>", "<Plug>(dial-increment)", opts)
    vim.api.nvim_set_keymap("v", "g<C-x>", "<Plug>(dial-decrement)", opts)
end

function config.nvim_gomove()
    local gomove_status_ok, gomove = pcall(require, "gomove")
    if not gomove_status_ok then
        return
    end
    gomove.setup()
end

function config.nvim_treesitter_textsubjects()
    local nvim_treesitter_configs_status_ok, nvim_treesitter_configs = pcall(require, "nvim-treesitter.configs")
    if not nvim_treesitter_configs_status_ok then
        return
    end
    nvim_treesitter_configs.setup({
        textsubjects = {
            enable = true,
            prev_selection = ",",
            keymaps = {
                ["ms"] = "textsubjects-smart",
                ["mo"] = "textsubjects-container-outer",
                ["mi"] = "textsubjects-container-inner",
            },
        },
    })
end

function config.rest_nvim()
    local rest_nvim_status_ok, rest_nvim = pcall(require, "rest-nvim")
    if not rest_nvim_status_ok then
        return
    end
    rest_nvim.setup()
    vim.api.nvim_create_user_command("RestNvim", "lua require('rest-nvim').run()", {})
    vim.api.nvim_create_user_command("RestNvimPreview", "lua require('rest-nvim').run(true)", {})
    vim.api.nvim_create_user_command("RestNvimLast", "lua require('rest-nvim').last()", {})
    vim.keymap.set("n", "trr", function()
        rest_nvim.run()
    end, { noremap = true, silent = true })
    vim.keymap.set("n", "trp", function()
        rest_nvim.run(true)
    end, { noremap = true, silent = true })
    vim.keymap.set("n", "trl", function()
        rest_nvim.last()
    end, { noremap = true, silent = true })
end

function config.sniprun()
    local sniprun_status_ok, sniprun = pcall(require, "sniprun")
    if not sniprun_status_ok then
        return
    end
    sniprun.setup()
    vim.keymap.set("n", "ts", function()
        vim.cmd("SnipRun")
    end, { noremap = true, silent = true })
    vim.keymap.set("n", "<Esc>", "<Esc>:noh<CR>:SnipClose<CR>", { noremap = true, silent = true })
end

function config.code_runner_nvim()
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

function config.nvim_spectre()
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
    end, { noremap = true, silent = true })
end

function config.comment_nvim()
    local comment_status_ok, comment = pcall(require, "Comment")
    if not comment_status_ok then
        return
    end
    comment.setup()
end

function config.vim_bufsurf()
    vim.keymap.set("n", "<C-n>", function()
        vim.cmd("BufSurfForward")
    end, { noremap = true, silent = true })
    vim.keymap.set("n", "<C-p>", function()
        vim.cmd("BufSurfBack")
    end, { noremap = true, silent = true })
end

function config.neogen()
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
    local opts = { noremap = true, silent = true }
    vim.api.nvim_set_keymap("i", "<C-l>", ":lua require('neogen').jump_next<CR>", opts)
    vim.api.nvim_set_keymap("i", "<C-h>", ":lua require('neogen').jump_prev<CR>", opts)
end

function config.nvim_colorize_lua()
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

function config.color_picker_nvim()
    local color_picker_status_ok, color_picker = pcall(require, "color-picker")
    if not color_picker_status_ok then
        return
    end
    color_picker.setup({})
    vim.keymap.set("n", "<C-c>p", function()
        vim.cmd("PickColor")
    end, { noremap = true, silent = true })
    vim.keymap.set("n", "<C-c>P", function()
        vim.cmd("PickColorInsert")
    end, { noremap = true, silent = true })
end

function config.lvim_colorcolumn()
    local lvim_colorcolumn_status_ok, lvim_colorcolumn = pcall(require, "lvim-colorcolumn")
    if not lvim_colorcolumn_status_ok then
        return
    end
    lvim_colorcolumn.setup()
end

function config.suda_vim()
    vim.g.suda_smart_edit = 1
end

function config.hop_nvim()
    local hop_status_ok, hop = pcall(require, "hop")
    if not hop_status_ok then
        return
    end
    hop.setup()
end

function config.todo_comments_nvim()
    local todo_comments_status_ok, todo_comments = pcall(require, "todo-comments")
    if not todo_comments_status_ok then
        return
    end
    todo_comments.setup({
        colors = {
            error = { _G.LVIM_COLORS.color_02 },
            warning = { _G.LVIM_COLORS.color_03 },
            info = { _G.LVIM_COLORS.color_05 },
            hint = { _G.LVIM_COLORS.color_04 },
            default = { _G.LVIM_COLORS.color_05 },
        },
    })
end

function config.pretty_fold_nvim()
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
    end, { noremap = true, silent = true })
end

function config.calendar_vim()
    vim.g.calendar_diary_extension = ".org"
    vim.g.calendar_diary = "~/Org/diary/"
    vim.g.calendar_diary_path_pattern = "{YYYY}-{MM}-{DD}{EXT}"
    vim.g.calendar_monday = 1
    vim.g.calendar_weeknm = 1
    vim.keymap.set("n", "tc", function()
        vim.cmd("CalendarVR")
    end, { noremap = true, silent = true })
end

return config
