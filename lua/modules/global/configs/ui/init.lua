local config = {}

function config.dashboard()
    vim.g.dashboard_custom_header = {

        '888     Y88b      / 888      e    e',
        '888      Y88b    /  888     d8b  d8b',
        '888       Y88b  /   888    d888bdY88b',
        '888        Y888/    888   / Y88Y Y888b',
        '888         Y8/     888  /   YY   Y888b',
        '888____      Y      888 /          Y888b'

    }
    vim.g.dashboard_preview_file_height = 12
    vim.g.dashboard_preview_file_width = 80
    vim.g.dashboard_default_executive = 'telescope'
    vim.g.dashboard_custom_section = {
        a = {
            description = {'  File Browser       '},
            command = 'RnvimrToggle'
        },
        b = {
            description = {'  Find File          '},
            command = 'Telescope find_files'
        },
        c = {
            description = {'  Recently Used Files'},
            command = 'Telescope oldfiles'
        },
        d = {
            description = {'  Find Word          '},
            command = 'Telescope live_grep'
        },
        e = {
            description = {'  Keywmaps           '},
            command = ':e ~/.config/nvim/lua/configs/global/keymaps.lua'
        },
        f = {
            description = {'  Settings           '},
            command = ':e ~/.config/nvim/lua/configs/global/lvim.lua'
        },
        g = {
            description = {'  Readme             '},
            command = ':e ~/.config/nvim/README.md'
        }
    }
    vim.g.dashboard_custom_footer = {'I Love You, LUA'}
end

function config.galaxyline()
    local gl = require('galaxyline')
    gl.short_line_list = {'NvimTree', 'vista', 'dbui', 'packer'}
    local colors = {
        bg = "#222222",
        fg = "#bdae93",
        line_bg = "#222222",
        lbg = "#222222",
        fg_green = "#458588",
        yellow = "#E6B673",
        cyan = "#83a598",
        darkblue = "#458588",
        green = "#689d6a",
        orange = "#E6B673",
        purple = "#008080",
        magenta = "#ea6962",
        gray = "#bdae93",
        blue = "#83a598",
        red = "#F2594B",
        error_red = '#F2594B'
    }
    local condition = require('galaxyline.condition')
    local gls = gl.section
    gl.short_line_list = {'NvimTree', 'vista', 'dbui', 'packer'}
    gls.left[1] = {
        ViMode = {
            provider = function()
                -- auto change color according the vim mode
                local mode_color = {
                    n = colors.blue,
                    i = colors.green,
                    v = colors.purple,
                    [''] = colors.purple,
                    V = colors.purple,
                    c = colors.magenta,
                    no = colors.blue,
                    s = colors.orange,
                    S = colors.orange,
                    [''] = colors.orange,
                    ic = colors.yellow,
                    R = colors.red,
                    Rv = colors.red,
                    cv = colors.blue,
                    ce = colors.blue,
                    r = colors.cyan,
                    rm = colors.cyan,
                    ['r?'] = colors.cyan,
                    ['!'] = colors.blue,
                    t = colors.blue
                }
                vim.api.nvim_command('hi GalaxyViMode guifg=' ..
                                         mode_color[vim.fn.mode()])
                return '  LVIM   '
            end,
            highlight = {colors.red, colors.bg}
        }
    }
    print(vim.fn.getbufvar(0, 'ts'))
    vim.fn.getbufvar(0, 'ts')
    gls.left[2] = {
        GitIcon = {
            provider = function() return '  ' end,
            condition = condition.check_git_workspace,
            separator = ' ',
            separator_highlight = {'NONE', colors.bg},
            highlight = {colors.orange, colors.bg}
        }
    }
    gls.left[3] = {
        GitBranch = {
            provider = 'GitBranch',
            condition = condition.check_git_workspace,
            separator = ' ',
            separator_highlight = {'NONE', colors.bg},
            highlight = {colors.grey, colors.bg}
        }
    }
    gls.left[4] = {
        DiffAdd = {
            provider = 'DiffAdd',
            condition = condition.hide_in_width,
            icon = '   ',
            highlight = {colors.green, colors.bg}
        }
    }
    gls.left[5] = {
        DiffModified = {
            provider = 'DiffModified',
            condition = condition.hide_in_width,
            icon = '   ',
            highlight = {colors.blue, colors.bg}
        }
    }
    gls.left[6] = {
        DiffRemove = {
            provider = 'DiffRemove',
            condition = condition.hide_in_width,
            icon = '   ',
            highlight = {colors.red, colors.bg}
        }
    }
    gls.right[1] = {
        DiagnosticError = {
            provider = 'DiagnosticError',
            icon = '  ',
            highlight = {colors.error_red, colors.bg}
        }
    }
    gls.right[2] = {
        DiagnosticWarn = {
            provider = 'DiagnosticWarn',
            icon = '  ',
            highlight = {colors.orange, colors.bg}
        }
    }
    gls.right[3] = {
        DiagnosticHint = {
            provider = 'DiagnosticHint',
            icon = '  ',
            highlight = {colors.blue, colors.bg}
        }
    }
    gls.right[4] = {
        DiagnosticInfo = {
            provider = 'DiagnosticInfo',
            icon = '  ',
            highlight = {colors.blue, colors.bg}
        }
    }
    gls.right[5] = {
        ShowLspClient = {
            provider = 'GetLspClient',
            condition = function()
                local tbl = {['dashboard'] = true, [' '] = true}
                if tbl[vim.bo.filetype] then return false end
                return true
            end,
            icon = '   ',
            highlight = {colors.grey, colors.bg}
        }
    }
    gls.right[6] = {
        LineInfo = {
            provider = 'LineColumn',
            separator = '  ',
            separator_highlight = {'NONE', colors.bg},
            highlight = {colors.grey, colors.bg}
        }
    }
    gls.right[7] = {
        PerCent = {
            provider = 'LinePercent',
            separator = ' ',
            separator_highlight = {'NONE', colors.bg},
            highlight = {colors.grey, colors.bg}
        }
    }
    gls.right[8] = {
        Tabstop = {
            provider = function()
                return
                    "Spaces: " .. vim.api.nvim_buf_get_option(0, "tabstop") ..
                        " "
            end,
            condition = condition.hide_in_width,
            separator = ' ',
            separator_highlight = {'NONE', colors.bg},
            highlight = {colors.grey, colors.bg}
        }
    }
    gls.right[9] = {
        BufferType = {
            provider = 'FileTypeName',
            condition = condition.hide_in_width,
            separator = ' ',
            separator_highlight = {'NONE', colors.bg},
            highlight = {colors.grey, colors.bg}
        }
    }
    gls.right[10] = {
        FileEncode = {
            provider = 'FileEncode',
            condition = condition.hide_in_width,
            separator = ' ',
            separator_highlight = {'NONE', colors.bg},
            highlight = {colors.grey, colors.bg}
        }
    }
    gls.right[11] = {
        Space = {
            provider = function() return ' ' end,
            separator = ' ',
            separator_highlight = {'NONE', colors.bg},
            highlight = {colors.orange, colors.bg}
        }
    }
    gls.short_line_left[1] = {
        BufferType = {
            provider = 'FileTypeName',
            separator = ' ',
            separator_highlight = {'NONE', colors.bg},
            highlight = {colors.grey, colors.bg}
        }
    }
    gls.short_line_left[2] = {
        SFileName = {
            provider = 'SFileName',
            condition = condition.buffer_not_empty,
            highlight = {colors.grey, colors.bg}
        }
    }
    gls.short_line_right[1] = {
        BufferIcon = {
            provider = 'BufferIcon',
            highlight = {colors.grey, colors.bg}
        }
    }
end

function config.indent_blankline()
    vim.g.indent_blankline_char = '▏'
    vim.g.indent_blankline_show_first_indent_level = true
    vim.g.indent_blankline_filetype_exclude =
        {
            "startify", "dashboard", "dotooagenda", "log", "fugitive",
            "gitcommit", "packer", "vimwiki", "markdown", "json", "txt",
            "vista", "help", "todoist", "NvimTree", "peekaboo", "git",
            "TelescopePrompt", "undotree", "flutterToolsOutline", ""
        }
    vim.g.indent_blankline_buftype_exclude = {"terminal", "nofile"}
    vim.g.indent_blankline_show_trailing_blankline_indent = false
    vim.g.indent_blankline_show_current_context = true
    vim.g.indent_blankline_context_patterns =
        {
            "class", "function", "method", "block", "list_literal", "selector",
            "^if", "^table", "if_statement", "while", "for"
        }
    vim.cmd('autocmd CursorMoved * IndentBlanklineRefresh')
end

function config.tree()
    vim.g.nvim_tree_disable_netrw = 0
    vim.g.nvim_tree_hide_dotfiles = 1
    vim.g.nvim_tree_indent_markers = 1
    vim.g.nvim_tree_follow = 1
    vim.g.nvim_tree_lsp_diagnostics = 1
    vim.g.nvim_tree_auto_close = true
    vim.g.nvim_tree_auto_ignore_ft = 'startify'
    local tree_cb = require'nvim-tree.config'.nvim_tree_callback
    vim.g.nvim_tree_bindings = {
        ["<CR>"] = tree_cb("edit"),
        ["l"] = tree_cb("edit"),
        ["o"] = tree_cb("edit"),
        ["<2-LeftMouse>"] = tree_cb("edit"),
        ["<2-RightMouse>"] = tree_cb("cd"),
        ["<C-]>"] = tree_cb("cd"),
        ["v"] = tree_cb("vsplit"),
        ["s"] = tree_cb("split"),
        ["<C-t>"] = tree_cb("tabnew"),
        ["h"] = tree_cb("close_node"),
        ["<BS>"] = tree_cb("close_node"),
        ["<S-CR>"] = tree_cb("close_node"),
        ["<Tab>"] = tree_cb("preview"),
        ["I"] = tree_cb("toggle_ignored"),
        ["H"] = tree_cb("toggle_dotfiles"),
        ["R"] = tree_cb("refresh"),
        ["a"] = tree_cb("create"),
        ["d"] = tree_cb("remove"),
        ["r"] = tree_cb("rename"),
        ["<C-r>"] = tree_cb("full_rename"),
        ["x"] = tree_cb("cut"),
        ["c"] = tree_cb("copy"),
        ["p"] = tree_cb("paste"),
        ["[c"] = tree_cb("prev_git_item"),
        ["]c"] = tree_cb("next_git_item"),
        ["-"] = tree_cb("dir_up"),
        ["q"] = tree_cb("close")
    }
    vim.g.nvim_tree_icons = {
        default = '',
        symlink = '',
        git = {
            unstaged = "",
            staged = "",
            unmerged = "",
            renamed = "➜",
            untracked = "",
            ignored = "◌"
        },
        folder = {
            default = "",
            open = "",
            empty = "",
            empty_open = "",
            symlink = ""
        }
    }
end

function config.ranger()
    vim.g.rnvimr_ex_enable = 1
    vim.g.rnvimr_draw_border = 1
    vim.g.rnvimr_pick_enable = 1
    vim.g.rnvimr_bw_enable = 1
end

function config.colorize()
    require'colorizer'.setup({'*'}, {
        RGB = true,
        RRGGBB = true,
        RRGGBBAA = true,
        rgb_fn = true,
        hsl_fn = true,
        css = true,
        css_fn = true
    })
end

function config.goyo()
    local opts = {silent = true, noremap = true}
    vim.api.nvim_set_keymap('n', '<C-z>', ':Goyo<CR>', opts)
    -- TODO handle this better
    vim.api.nvim_exec([[
        function! Goyo_enter()
        set noshowcmd
        Limelight
        endfunction

        function! Goyo_leave()
        set showcmd
        Limelight!
        endfunction

        autocmd! User GoyoEnter nested call Goyo_enter()
        autocmd! User GoyoLeave nested call Goyo_leave()
    ]], false)
end

function config.telescope()
    if not packer_plugins['plenary.nvim'].loaded then
        vim.cmd [[packadd plenary.nvim]]
        vim.cmd [[packadd popup.nvim]]
        vim.cmd [[packadd telescope-fzy-native.nvim]]
    end
    require('telescope').setup {
        defaults = {
            vimgrep_arguments = {
                'rg', '--color=never', '--no-heading', '--with-filename',
                '--line-number', '--column', '--smart-case'
            },
            prompt_position = "bottom",
            prompt_prefix = " ",
            selection_caret = " ",
            entry_prefix = "  ",
            initial_mode = "insert",
            selection_strategy = "reset",
            sorting_strategy = "descending",
            layout_strategy = "horizontal",
            layout_defaults = {
                horizontal = {mirror = false},
                vertical = {mirror = false}
            },
            file_sorter = require'telescope.sorters'.get_fzy_sorter,
            file_ignore_patterns = {},
            generic_sorter = require'telescope.sorters'.get_generic_fuzzy_sorter,
            shorten_path = true,
            winblend = 0,
            width = 0.75,
            preview_cutoff = 120,
            results_height = 1,
            results_width = 0.8,
            border = {},
            borderchars = {
                '─', '│', '─', '│', '╭', '╮', '╯', '╰'
            },
            color_devicons = true,
            use_less = true,
            set_env = {['COLORTERM'] = 'truecolor'},
            file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
            grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep
                .new,
            qflist_previewer = require'telescope.previewers'.vim_buffer_qflist
                .new,
            buffer_previewer_maker = require'telescope.previewers'.buffer_previewer_maker
        },
        extensions = {
            fzy_native = {
                override_generic_sorter = false,
                override_file_sorter = true
            }
        }
    }
    require('telescope').load_extension('fzy_native')
end

function config.floaterm()
    vim.g.floaterm_keymap_toggle = '<F1>'
    vim.g.floaterm_keymap_next = '<F2>'
    vim.g.floaterm_keymap_prev = '<F3>'
    vim.g.floaterm_keymap_new = '<F4>'
    vim.g.floaterm_keymap_kill = '<F12>'
    vim.g.floaterm_title = ''
    vim.g.floaterm_gitcommit = 'floaterm'
    vim.g.floaterm_shell = 'zsh'
    vim.g.floaterm_autoinsert = 1
    vim.g.floaterm_width = 0.8
    vim.g.floaterm_height = 0.8
    vim.g.floaterm_wintitle = 0
    vim.g.floaterm_autoclose = 1
end

return config
