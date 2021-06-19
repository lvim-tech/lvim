local config = {}

function config.dashboard()
    vim.g.dashboard_custom_header = {
        "       888     Y88b      / 888      e    e             ",
        "       888      Y88b    /  888     d8b  d8b            ",
        "       888       Y88b  /   888    d888bdY88b           ",
        "       888        Y888/    888   / Y88Y Y888b          ",
        "       888         Y8/     888  /   YY   Y888b         ",
        "       888____      Y      888 /          Y888b        "
    }
    vim.g.dashboard_preview_file_height = 12
    vim.g.dashboard_preview_file_width = 80
    vim.g.dashboard_custom_section = {
        a = {
            description = {'     Projects                 '},
            command = 'CtrlSpace b'
        },
        b = {
            description = {'     File explorer            '},
            command = 'Vifm'
        },
        c = {
            description = {'     Search file              '},
            command = 'Clap files'
        },
        d = {
            description = {'     Search in files          '},
            command = 'Clap grep'
        },
        e = {
            description = {'     Keywmaps                 '},
            command = ":e ~/.config/nvim/lua/configs/global/keymaps.lua"
        },
        f = {
            description = {'     Settings                 '},
            command = ":e ~/.config/nvim/lua/configs/global/lvim.lua"
        },
        g = {
            description = {'     Readme                   '},
            command = ":e ~/.config/nvim/README.md"
        }
    }
end

function config.galaxyline()
    local gl = require("galaxyline")
    gl.exclude_filetypes = {"ctrlspace"}
    local colors = {
        bg = "#252A34",
        fg = "#D9DA9E",
        color_0 = "#00839F",
        color_1 = '#1C9898',
        color_2 = '#25B8A5',
        color_3 = '#56adb7',
        color_4 = '#F2994B',
        color_5 = "#E6B673",
        color_6 = "#F05F4E",
        color_7 = '#98c379'
    }
    local condition = require("galaxyline.condition")
    local buffer_not_empty = function()
        if vim.fn.empty(vim.fn.expand("%:t")) ~= 1 then return true end
        return false
    end
    local gls = gl.section
    gl.short_line_list = {
        "NvimTree", "LvimHelper", "CHADTree", "vista", "dbui", "packer"
    }
    gls.left[1] = {
        ViMode = {
            provider = function()
                -- auto change color according the vim mode
                local alias = {
                    n = "NORMAL",
                    v = "VISUAL",
                    V = "V-LINE",
                    [""] = "V-BLOCK",
                    s = "SELECT",
                    S = "S-LINE",
                    [""] = "S-BLOCK",
                    i = "INSERT",
                    R = "REPLACE",
                    c = "COMMAND",
                    r = "PROMPT",
                    ["!"] = "EXTERNAL",
                    t = "TERMINAL"
                }
                local mode_color = {
                    n = colors.color_1,
                    v = colors.color_5,
                    V = colors.color_5,
                    [""] = colors.color_5,
                    s = colors.color_5,
                    S = colors.color_5,
                    [""] = colors.color_5,
                    i = colors.color_6,
                    R = colors.color_6,
                    c = colors.color_0,
                    r = colors.color_0,
                    ["!"] = colors.color_0,
                    t = colors.color_0
                }
                local vim_mode = vim.fn.mode()
                vim.api.nvim_command("hi GalaxyViMode guifg=" ..
                                         mode_color[vim_mode])
                return alias[vim_mode] .. "    "
            end,
            highlight = {colors.color_3, colors.bg, "bold"}
        }
    }
    gls.left[2] = {
        FileIcon = {
            provider = "FileIcon",
            condition = buffer_not_empty,
            highlight = {colors.fg, colors.bg}
        }
    }
    gls.left[3] = {
        FileName = {
            provider = {"FileName"},
            condition = buffer_not_empty,
            separator = " ",
            separator_highlight = {"NONE", colors.bg},
            highlight = {colors.fg, colors.bg}
        }
    }
    gls.left[4] = {
        GitIcon = {
            provider = function() return "  " end,
            condition = condition.check_git_workspace,
            -- separator = " ",
            separator_highlight = {"NONE", colors.bg},
            highlight = {colors.color_5, colors.bg}
        }
    }
    gls.left[5] = {
        GitBranch = {
            provider = "GitBranch",
            condition = condition.check_git_workspace,
            separator = " ",
            separator_highlight = {"NONE", colors.bg},
            highlight = {colors.color_5, colors.bg}
        }
    }
    gls.left[6] = {
        DiffAdd = {
            provider = "DiffAdd",
            condition = condition.hide_in_width,
            icon = "   ",
            highlight = {colors.color_7, colors.bg}
        }
    }
    gls.left[7] = {
        DiffModified = {
            provider = "DiffModified",
            condition = condition.hide_in_width,
            icon = "   ",
            highlight = {colors.color_4, colors.bg}
        }
    }
    gls.left[8] = {
        DiffRemove = {
            provider = "DiffRemove",
            condition = condition.hide_in_width,
            icon = "   ",
            highlight = {colors.color_6, colors.bg}
        }
    }
    gls.right[1] = {
        DiagnosticError = {
            provider = "DiagnosticError",
            icon = "  ",
            highlight = {colors.color_6, colors.bg}
        }
    }
    gls.right[2] = {
        DiagnosticWarn = {
            provider = "DiagnosticWarn",
            icon = "  ",
            highlight = {colors.color_3, colors.bg}
        }
    }
    gls.right[3] = {
        DiagnosticHint = {
            provider = "DiagnosticHint",
            icon = "  ",
            highlight = {colors.color_3, colors.bg}
        }
    }
    gls.right[4] = {
        DiagnosticInfo = {
            provider = "DiagnosticInfo",
            icon = "  ",
            highlight = {colors.color_3, colors.bg}
        }
    }
    gls.right[5] = {
        ShowLspClient = {
            provider = "GetLspClient",
            condition = function()
                local tbl = {["dashboard"] = true, [" "] = true}
                if tbl[vim.bo.filetype] then return false end
                return true
            end,
            icon = "   ",
            highlight = {colors.color_1, colors.bg}
        }
    }
    gls.right[6] = {
        LineInfo = {
            provider = "LineColumn",
            separator = "  ",
            separator_highlight = {"NONE", colors.bg},
            highlight = {colors.fg, colors.bg}
        }
    }
    gls.right[7] = {
        PerCent = {
            provider = "LinePercent",
            separator = " ",
            separator_highlight = {"NONE", colors.bg},
            highlight = {colors.fg, colors.bg}
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
            separator = " ",
            separator_highlight = {"NONE", colors.bg},
            highlight = {colors.fg, colors.bg}
        }
    }
    gls.right[9] = {
        BufferType = {
            provider = "FileTypeName",
            condition = condition.hide_in_width,
            separator = " ",
            separator_highlight = {"NONE", colors.bg},
            highlight = {colors.fg, colors.bg}
        }
    }
    gls.right[10] = {
        FileEncode = {
            provider = "FileEncode",
            condition = condition.hide_in_width,
            separator = " ",
            separator_highlight = {"NONE", colors.bg},
            highlight = {colors.fg, colors.bg}
        }
    }
    gls.right[11] = {
        Space = {
            provider = function() return " " end,
            separator = " ",
            separator_highlight = {"NONE", colors.bg},
            highlight = {colors.fg, colors.bg}
        }
    }
    gls.short_line_left[1] = {
        SFileName = {
            provider = "SFileName",
            condition = condition.buffer_not_empty,
            highlight = {colors.fg, colors.bg}
        }
    }
    gls.short_line_right[1] = {
        BufferIcon = {
            provider = "BufferIcon",
            highlight = {colors.fg, colors.bg}
        }
    }
end

function config.indent_blankline()
    vim.g.indent_blankline_char = "▏"
    vim.g.indent_blankline_show_first_indent_level = true
    vim.g.indent_blankline_filetype_exclude = {
        "startify", "dashboard", "dotooagenda", "log", "fugitive", "gitcommit",
        "packer", "vimwiki", "markdown", "json", "txt", "vista", "help",
        "todoist", "NvimTree", "peekaboo", "git", "TelescopePrompt", "undotree",
        "flutterToolsOutline"
    }
    vim.g.indent_blankline_buftype_exclude = {"terminal", "nofile"}
    vim.g.indent_blankline_show_trailing_blankline_indent = false
    vim.g.indent_blankline_show_current_context = true
    vim.g.indent_blankline_context_patterns = {
        "class", "function", "method", "block", "list_literal", "selector",
        "^if", "^table", "if_statement", "while", "for"
    }
    vim.cmd("autocmd CursorMoved * IndentBlanklineRefresh")
end

-- function config.chadtree()

--     local chadtree_settings = {
--         profiling = true,
--         ignore = {name_exact = {".*"}, name_glob = {'.*'}},
--         keymap = {open_sys = {'e'}, primary = {'<enter>', 'o'}},
--         theme = {
--             icon_glyph_set = 'devicons',
--             discrete_colour_map = {
--                 black = "#2E3440",
--                 red = "#ff5c57",
--                 green = "#f78c6c",
--                 yellow = "#F2AF5C",
--                 blue = "#1C9898",
--                 magenta = "#00839F",
--                 cyan = "#25B8A5",
--                 white = "#D9DA9E",
--                 bright_black = "#2E3440",
--                 bright_red = "#ff5c57",
--                 bright_green = "#f78c6c",
--                 bright_yellow = "#F2AF5C",
--                 bright_blue = "#1C9898",
--                 bright_magenta = "#00839F",
--                 bright_cyan = "#25B8A5",
--                 bright_white = "#D9DA9E"
--             }
--         }
--     }
--     vim.api.nvim_set_var("chadtree_settings", chadtree_settings)
-- end

function config.tree()
    vim.g.nvim_tree_disable_netrw = 0
    vim.g.nvim_tree_hide_dotfiles = 1
    vim.g.nvim_tree_indent_markers = 0
    vim.g.nvim_tree_follow = 1
    vim.g.nvim_tree_lsp_diagnostics = 1
    vim.g.nvim_tree_auto_close = true
    vim.g.nvim_tree_auto_ignore_ft = {'startify', 'dashboard'}
    vim.g.nvim_tree_show_icons = {
        git = 1,
        folders = 1,
        files = 1,
        folder_arrows = 0
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

function config.goyo()
    local opts = {silent = true, noremap = true}
    vim.api.nvim_set_keymap("n", "<C-z>", ":Goyo<CR>", opts)
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
    ]], true)
end

function config.limelight() vim.g.limelight_conceal_guifg = '#628b97' end

function config.floaterm()
    vim.g.floaterm_keymap_toggle = "<F1>"
    vim.g.floaterm_keymap_next = "<F2>"
    vim.g.floaterm_keymap_prev = "<F3>"
    vim.g.floaterm_keymap_new = "<F4>"
    vim.g.floaterm_keymap_kill = "<F12>"
    vim.g.floaterm_title = "Floaterm ($1/$2)"
    vim.g.floaterm_shell = vim.o.shell
    vim.g.floaterm_autoinsert = 1
    vim.g.floaterm_width = 0.8
    vim.g.floaterm_height = 0.8
    vim.g.floaterm_wintitle = 0
    vim.g.floaterm_autoclose = 1
end

function config.helper()
    local home = os.getenv('HOME')
    require('lvim-helper').setup({
        files = {
            home .. '/.config/nvim/help/lvim_commands.txt',
            home .. '/.config/nvim/help/lvim_bindings_normal_mode.txt',
            home .. '/.config/nvim/help/lvim_bindings_visual_mode.txt'
        }
    })
end

return config
