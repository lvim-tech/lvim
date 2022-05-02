local config = {}

function config.telescope()
    local loader = require("packer").loader
    if not packer_plugins["telescope-fzf-native.nvim"].loaded then
        loader(
            "telescope-fzf-native.nvim"
            .. " telescope-media-files.nvim"
            .. " telescope-file-browser.nvim"
            .. " telescope-tmux.nvim"
        )
    end
    local telescope = require("telescope")
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
            borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
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
            media_files = {
                filetypes = { "png", "webp", "jpg", "jpeg" },
                find_cmd = "rg",
            },
            file_browser = {},
        },
    })
    telescope.load_extension("fzf")
    telescope.load_extension("media_files")
    telescope.load_extension("file_browser")
    telescope.load_extension("tmux")
end

function config.tabby()
    local util = require("tabby.util")

    local hl_tabline = {
        color_01 = "#272F35",
        color_02 = "#A7C080",
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
        local coms = {
            {
                type = "text",
                text = {
                    "    ",
                    hl = {
                        fg = hl_tabline.color_01,
                        bg = hl_tabline.color_02,
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
                        hl = { fg = hl_tabline.color_02, bg = hl_tabline.color_01 },
                    },
                })
                local wins = util.tabpage_list_wins(current_tab)
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
                        hl = { fg = hl_tabline.color_01, bg = hl_tabline.color_02 },
                    },
                })
            end
        end
        table.insert(coms, { type = "text", text = { " ", hl = { bg = hl_tabline.color_01 } } })

        return coms
    end

    require("tabby").setup({
        components = components,
    })
end

function config.lvim_move()
    require("lvim-move").setup()
end

function config.vim_slime()
    vim.g.slime_target = "tmux"
end

function config.nvim_spectre()
    vim.cmd("command! Spectre lua require('spectre').open()")
    require("spectre").setup({
        color_devicons = true,
        line_sep_start = "-----------------------------------------",
        result_padding = "|  ",
        line_sep = "-----------------------------------------",
        highlight = {
            ui = "String",
            search = "DiffChange",
            replace = "DiffDelete",
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
end

function config.nvim_comment()
    require("Comment").setup()
end

function config.vim_bookmarks()
    vim.g.bookmark_no_default_key_mappings = 1
    vim.g.bookmark_sign = ""
end

function config.vim_doge()
    vim.g.doge_mapping = "<Leader>*"
end

function config.nvim_autopairs()
    local autopairs = require("nvim-autopairs")
    local Rule = require("nvim-autopairs.rule")
    local cond = require("nvim-autopairs.conds")
    autopairs.setup({
        check_ts = true,
        ts_config = {
            lua = {
                "string",
            },
            javascript = {
                "template_string",
            },
            java = false,
        },
    })
    autopairs.add_rule(Rule("$$", "$$", "tex"))
    autopairs.add_rules({
        Rule("$", "$", { "tex", "latex" })
            :with_pair(cond.not_after_regex_check("%%"))
            :with_pair(cond.not_before_regex_check("xxx", 3))
            :with_move(cond.none())
            :with_del(cond.not_after_regex_check("xx"))
            :with_cr(cond.none()),
    })
    autopairs.add_rules({
        Rule("$$", "$$", "tex"):with_pair(function(opts)
            print(vim.inspect(opts))
            if opts.line == "aa $$" then
                return false
            end
        end),
    })
    local ts_conds = require("nvim-autopairs.ts-conds")
    autopairs.add_rules({
        Rule("%", "%", "lua"):with_pair(ts_conds.is_ts_node({ "string", "comment" })),
        Rule("$", "$", "lua"):with_pair(ts_conds.is_not_ts_node({ "function" })),
    })
end

function config.nvim_colorize()
    require("colorizer").setup({
        "*",
    }, {
        RGB = true,
        RRGGBB = true,
        RRGGBBAA = true,
        rgb_fn = true,
        hsl_fn = true,
        css = true,
        css_fn = true,
    })
end

function config.cinnamon()
    require("cinnamon").setup({
        extra_keymaps = true,
        extended_keymaps = true,
    })
end

function config.suda()
    vim.g.suda_smart_edit = 1
end

function config.hop()
    require("hop").setup()
end

function config.todo_comments()
    require("todo-comments").setup({
        colors = {
            error = { "#F05F4E", "#F05F4E" },
            warning = { "#F2994B", "#F2994B" },
            info = { "#A7C080", "#A7C080" },
            hint = { "#FF7A66", "#FF7A66" },
            default = { "#90c1a3", "#90c1a3" },
        },
    })
end

function config.pretty_fold()
    require("pretty-fold").setup({
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
    })
    require("pretty-fold.preview").setup()
    local keymap_amend = require("keymap-amend")
    local mapping = require("pretty-fold.preview").mapping
    keymap_amend("n", "zp", function()
        if vim.fn.foldclosed(".") > -1 then
            mapping.show_close_preview_open_fold()
            vim.cmd("IndentBlanklineRefresh")
        end
    end)
end

return config
