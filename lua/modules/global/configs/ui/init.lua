local config = {}

function config.lvim_colorscheme()
    vim.cmd("colorscheme lvim")
end

function config.dashboard_nvim()
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
            description = {"     Projects                 "},
            command = "CtrlSpace b"
        },
        b = {
            description = {"     File explorer            "},
            command = "Telescope file_browser"
        },
        c = {
            description = {"     Search file              "},
            command = "Telescope find_files"
        },
        d = {
            description = {"     Search in files          "},
            command = "Telescope live_grep"
        },
        e = {
            description = {"     Help                     "},
            command = ":LvimHelper"
        },
        f = {
            description = {"     Settings                 "},
            command = ":e ~/.config/nvim/lua/configs/global/lvim.lua"
        },
        g = {
            description = {"     Readme                   "},
            command = ":e ~/.config/nvim/README.md"
        }
    }
end

function config.nvim_tree()
    vim.g.nvim_tree_show_icons = {
        git = 1,
        folders = 1,
        files = 1,
        folder_arrows = 0
    }
    vim.g.nvim_tree_icons = {
        default = "",
        symlink = "",
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
    require("nvim-tree").setup {
        disable_netrw = true,
        hijack_netrw = true,
        open_on_setup = false,
        ignore_ft_on_setup = {},
        auto_close = false,
        open_on_tab = false,
        hijack_cursor = false,
        update_cwd = false,
        diagnostics = {
            enable = true,
            icons = {
                error = "",
                warning = "",
                hint = "",
                info = ""
            }
        },
        update_focused_file = {
            enable = true,
            update_cwd = false,
            ignore_list = {}
        },
        system_open = {
            cmd = nil,
            args = {}
        },
        view = {
            width = 30,
            side = "left",
            auto_resize = true,
            mappings = {
                custom_only = false,
                list = {}
            }
        }
    }
end

function config.which_key()
    local options = {
        plugins = {
            marks = true,
            registers = true,
            presets = {
                operators = false,
                motions = false,
                text_objects = false,
                windows = false,
                nav = false,
                z = false,
                g = false
            },
            spelling = {
                enabled = true,
                suggestions = 20
            }
        },
        icons = {
            breadcrumb = "»",
            separator = "➜",
            group = "+"
        },
        window = {
            border = "single",
            position = "bottom",
            margin = {
                0,
                0,
                0,
                0
            },
            padding = {
                2,
                2,
                2,
                2
            }
        },
        layout = {
            height = {
                min = 4,
                max = 25
            },
            width = {
                min = 20,
                max = 50
            },
            spacing = 10
        },
        hidden = {"<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ "},
        show_help = true
    }
    local nopts = {
        mode = "n",
        prefix = "<leader>",
        buffer = nil,
        silent = true,
        noremap = true,
        nowait = true
    }
    local vopts = {
        mode = "v",
        prefix = "<leader>",
        buffer = nil,
        silent = true,
        noremap = true,
        nowait = true
    }
    local nmappings = {
        b = {
            name = "Buffers",
            n = {"<Cmd>bnext<CR>", "Next buffer"},
            p = {"<Cmd>bprevious<CR>", "Prev buffer"},
            l = {"<Cmd>Telescope buffers<CR>", "List buffers"}
        },
        d = {
            name = "Database",
            u = {"<Cmd>DBUIToggle<CR>", "DB UI toggle"},
            f = {"<Cmd>DBUIFindBuffer<CR>", "DB find buffer"},
            r = {"<Cmd>DBUIRenameBuffer<CR>", "DB rename buffer"},
            l = {"<Cmd>DBUILastQueryInfo<CR>", "DB last query"}
        },
        p = {
            name = "Packer",
            c = {"<cmd>PackerCompile<CR>", "Compile"},
            i = {"<cmd>PackerInstall<CR>", "Install"},
            s = {"<cmd>PackerSync<CR>", "Sync"},
            S = {"<cmd>PackerStatus<CR>", "Status"},
            u = {"<cmd>PackerUpdate<CR>", "Update"}
        },
        P = {
            name = "Path",
            g = {"<Cmd>SetGlobalPath<CR>", "Set global path"},
            w = {"<Cmd>SetWindowPath<CR>", "Set window path"}
        },
        l = {
            name = "LSP",
            n = {"<Cmd>LspGoToNext<CR>", "Go to next"},
            p = {"<Cmd>LspGoToPrev<CR>", "Go to prev"},
            r = {"<Cmd>LspRename<CR>", "Rename"},
            h = {"<Cmd>LspHover<CR>", "Hover"},
            d = {"<Cmd>LspDefinition<CR>", "Definition"},
            t = {"<Cmd>LspTypeDefinition<CR>", "Type definition"},
            R = {"<Cmd>LspReferences<CR>", "References"},
            a = {"<Cmd>LspCodeAction<CR>", "Code action"},
            f = {"<Cmd>LspFormatting<CR>", "Formatting"},
            s = {"<Cmd>LspFormattingSync<CR>", "Sync formatting"},
            S = {
                name = "Symbol",
                d = {"<Cmd>LspDocumentSymbol<CR>", "Document symbol"},
                w = {"<Cmd>LspWorkspaceSymbol<CR>", "Workspace symbol"}
            },
            w = {
                "<Cmd>LspAddToWorkspaceFolder<CR>",
                "Add to workspace folder"
            },
            v = {
                name = "Virtualtext",
                s = {"<Cmd>LspVirtualTextShow<CR>", "Virtual text show"},
                h = {"<Cmd>LspVirtualTextHide<CR>", "Virtual text hide"}
            }
        },
        g = {
            name = "GIT",
            b = {"<Cmd>GitSignsBlameLine<CR>", "Blame"},
            B = {"<Cmd>GBrowse<CR>", "Browse"},
            d = {"<Cmd>Git diff<CR>", "Diff"},
            n = {"<Cmd>GitSignsNextHunk<CR>", "Next hunk"},
            p = {"<Cmd>GitSignsPrevHunk<CR>", "Prev hunk"},
            l = {"<Cmd>Git log<CR>", "Log"},
            P = {"<Cmd>GitSignsPreviewHunk<CR>", "Preview hunk"},
            r = {"<Cmd>GitSignsResetHunk<CR>", "Reset stage hunk"},
            s = {"<Cmd>GitSignsStageHunk<CR>", "Stage hunk"},
            u = {"<Cmd>GitSignsUndoStageHunk<CR>", "Undo stage hunk"},
            R = {"<Cmd>GitSignsResetBuffer<CR>", "Reset buffer"},
            S = {"<Cmd>Gstatus<CR>", "Status"},
            N = {"<Cmd>Neogit<CR>", "Neogit"}
        },
        m = {
            name = "Bookmark",
            t = {"<Cmd>BookmarkToggle<CR>", "toggle bookmark"},
            n = {"<Cmd>BookmarkNext<CR>", "next bookmark"},
            p = {"<Cmd>BookmarkPrev<CR>", "prev bookmark"}
        },
        f = {
            name = "Fold",
            m = {"<Cmd>:set foldmethod=manual<CR>", "manual (default)"},
            i = {"<Cmd>:set foldmethod=indent<CR>", "indent"},
            e = {"<Cmd>:set foldmethod=expr<CR>", "expr"},
            d = {"<Cmd>:set foldmethod=diff<CR>", "diff"},
            M = {"<Cmd>:set foldmethod=marker<CR>", "marker"}
        },
        s = {
            name = "Spectre",
            d = {
                '<Cmd>lua require("spectre").delete()<CR>',
                "toggle current item"
            },
            g = {
                '<Cmd>lua require("spectre.actions").select_entry()<CR>',
                "goto current file"
            },
            q = {
                '<Cmd>lua require("spectre.actions").send_to_qf()<CR>',
                "send all item to quickfix"
            },
            m = {
                '<Cmd>lua require("spectre.actions").replace_cmd()<CR>',
                "input replace vim command"
            },
            o = {
                '<Cmd>lua require("spectre").show_options()<CR>',
                "show option"
            },
            R = {
                '<Cmd>lua require("spectre.actions").run_replace()<CR>',
                "replace all"
            },
            v = {
                '<Cmd>lua require("spectre").change_view()<CR>',
                "change result view mode"
            },
            c = {
                '<Cmd>lua require("spectre").change_options("ignore-case")<CR>',
                "toggle ignore case"
            },
            h = {
                '<Cmd>lua require("spectre").change_options("hidden")<CR>',
                "toggle search hidden"
            }
        },
        t = {
            name = "Terminal",
            o = {"<Cmd>FloatermShow<CR>", "git"},
            g = {"<Cmd>FloatermNew lazygit<CR>", "git"},
            d = {"<Cmd>FloatermNew lazydocker<CR>", "docker"},
            n = {"<Cmd>FloatermNew lazynpm<CR>", "npm"}
        }
    }
    local vmappings = {
        ["/"] = {":CommentToggle<CR>", "Comment"},
        f = {"<Cmd>LspRangeFormatting<CR>", "Range formatting"}
    }
    local which_key = require "which-key"
    which_key.setup(options)
    which_key.register(nmappings, nopts)
    which_key.register(vmappings, vopts)
end

function config.galaxyline()
    local gl = require("galaxyline")
    gl.exclude_filetypes = {"ctrlspace"}
    local colors = {
        bg = "#252A34",
        fg = "#D9DA9E",
        color_0 = "#00839F",
        color_1 = "#1C9898",
        color_2 = "#25B8A5",
        color_3 = "#56adb7",
        color_4 = "#F2994B",
        color_5 = "#E6B673",
        color_6 = "#F05F4E",
        color_7 = "#98c379"
    }
    local condition = require("galaxyline.condition")
    local buffer_not_empty = function()
        if vim.fn.empty(vim.fn.expand("%:t")) ~= 1 then
            return true
        end
        return false
    end
    local gls = gl.section
    gl.short_line_list = {
        "NvimTree",
        "LvimHelper",
        "dashboard",
        "vista",
        "dbui",
        "packer",
        "dapui_scopes",
        "dapui_breakpoints",
        "dapui_stacks",
        "dapui_watches"
    }
    gls.left[1] = {
        ViMode = {
            provider = function()
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
                vim.api.nvim_command("hi GalaxyViMode guifg=" .. mode_color[vim_mode])
                return alias[vim_mode] .. "    "
            end,
            highlight = {
                colors.color_3,
                colors.bg,
                "bold"
            }
        }
    }
    gls.left[2] = {
        FileIcon = {
            provider = "FileIcon",
            condition = buffer_not_empty,
            highlight = {
                colors.fg,
                colors.bg
            }
        }
    }
    gls.left[3] = {
        FileName = {
            provider = "FileName",
            condition = buffer_not_empty,
            separator = " ",
            separator_highlight = {
                "NONE",
                colors.bg
            },
            highlight = {
                colors.fg,
                colors.bg
            }
        }
    }
    gls.left[4] = {
        GitIcon = {
            provider = function()
                return "  "
            end,
            condition = condition.check_git_workspace,
            -- separator = " ",
            separator_highlight = {
                "NONE",
                colors.bg
            },
            highlight = {
                colors.color_5,
                colors.bg
            }
        }
    }
    gls.left[5] = {
        GitBranch = {
            provider = "GitBranch",
            condition = condition.check_git_workspace,
            separator = " ",
            separator_highlight = {
                "NONE",
                colors.bg
            },
            highlight = {
                colors.color_5,
                colors.bg
            }
        }
    }
    gls.left[6] = {
        DiffAdd = {
            provider = "DiffAdd",
            condition = condition.hide_in_width,
            icon = "   ",
            highlight = {
                colors.color_7,
                colors.bg
            }
        }
    }
    gls.left[7] = {
        DiffModified = {
            provider = "DiffModified",
            condition = condition.hide_in_width,
            icon = "   ",
            highlight = {
                colors.color_4,
                colors.bg
            }
        }
    }
    gls.left[8] = {
        DiffRemove = {
            provider = "DiffRemove",
            condition = condition.hide_in_width,
            icon = "   ",
            highlight = {
                colors.color_6,
                colors.bg
            }
        }
    }
    gls.right[1] = {
        DiagnosticError = {
            provider = "DiagnosticError",
            icon = "  ",
            highlight = {
                colors.color_6,
                colors.bg
            }
        }
    }
    gls.right[2] = {
        DiagnosticWarn = {
            provider = "DiagnosticWarn",
            icon = "  ",
            highlight = {
                colors.color_4,
                colors.bg
            }
        }
    }
    gls.right[3] = {
        DiagnosticHint = {
            provider = "DiagnosticHint",
            icon = "  ",
            highlight = {
                colors.color_3,
                colors.bg
            }
        }
    }
    gls.right[4] = {
        DiagnosticInfo = {
            provider = "DiagnosticInfo",
            icon = "  ",
            highlight = {
                colors.color_3,
                colors.bg
            }
        }
    }
    gls.right[5] = {
        ShowLspClient = {
            provider = "GetLspClient",
            condition = function()
                local tbl = {["dashboard"] = true, [" "] = true}
                if tbl[vim.bo.filetype] then
                    return false
                end
                return true
            end,
            icon = "   ",
            highlight = {
                colors.color_0,
                colors.bg
            }
        }
    }
    gls.right[6] = {
        LineInfo = {
            provider = "LineColumn",
            separator = "  ",
            separator_highlight = {
                "NONE",
                colors.bg
            },
            highlight = {
                colors.color_7,
                colors.bg
            }
        }
    }
    gls.right[7] = {
        PerCent = {
            provider = "LinePercent",
            separator = " ",
            separator_highlight = {
                "NONE",
                colors.bg
            },
            highlight = {
                colors.color_7,
                colors.bg
            }
        }
    }
    gls.right[8] = {
        Tabstop = {
            provider = function()
                return "Spaces: " .. vim.api.nvim_buf_get_option(0, "tabstop") .. " "
            end,
            condition = condition.hide_in_width,
            separator = " ",
            separator_highlight = {
                "NONE",
                colors.bg
            },
            highlight = {
                colors.color_7,
                colors.bg
            }
        }
    }
    gls.right[9] = {
        BufferType = {
            provider = "FileTypeName",
            condition = condition.hide_in_width,
            separator = " ",
            separator_highlight = {
                "NONE",
                colors.bg
            },
            highlight = {
                colors.color_7,
                colors.bg
            }
        }
    }
    gls.right[10] = {
        FileEncode = {
            provider = "FileEncode",
            condition = condition.hide_in_width,
            separator = " ",
            separator_highlight = {
                "NONE",
                colors.bg
            },
            highlight = {
                colors.color_7,
                colors.bg
            }
        }
    }
    gls.right[11] = {
        Space = {
            provider = function()
                return " "
            end,
            separator = " ",
            separator_highlight = {
                "NONE",
                colors.bg
            },
            highlight = {
                colors.color_7,
                colors.bg
            }
        }
    }
    gls.short_line_left[1] = {
        SFileName = {
            provider = "SFileName",
            condition = condition.buffer_not_empty,
            highlight = {
                colors.fg,
                colors.bg
            }
        }
    }
    gls.short_line_right[1] = {
        BufferIcon = {
            provider = "BufferIcon",
            highlight = {
                colors.fg,
                colors.bg
            }
        }
    }
end

function config.vim_floaterm()
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

function config.twilight()
    require("twilight").setup {}
end

function config.indent_blankline()
    require("indent_blankline").setup {
        char = "▏",
        show_first_indent_level = true,
        show_trailing_blankline_indent = true,
        show_current_context = true,
        context_patterns = {
            "class",
            "function",
            "method",
            "block",
            "list_literal",
            "selector",
            "^if",
            "^table",
            "if_statement",
            "while",
            "for"
        },
        filetype_exclude = {
            "startify",
            "dashboard",
            "dotooagenda",
            "log",
            "fugitive",
            "gitcommit",
            "packer",
            "vimwiki",
            "markdown",
            "json",
            "txt",
            "vista",
            "help",
            "todoist",
            "NvimTree",
            "peekaboo",
            "git",
            "TelescopePrompt",
            "undotree",
            "flutterToolsOutline"
        },
        buftype_exclude = {
            "terminal",
            "nofile"
        }
    }
end

function config.lvim_focus()
    require("lvim-focus").setup()
end

function config.lvim_helper()
    local global = require("core.global")
    require("lvim-helper").setup(
        {
            files = {
                global.home .. "/.config/nvim/help/lvim_bindings_normal_mode.md",
                global.home .. "/.config/nvim/help/lvim_bindings_visual_mode.md",
                global.home .. "/.config/nvim/help/lvim_bindings_debug_dap.md",
                global.home .. "/.config/nvim/help/vim_cheat_sheet_global.md",
                global.home .. "/.config/nvim/help/vim_cheat_sheet_cursor_movement.md",
                global.home .. "/.config/nvim/help/vim_cheat_sheet_visual_mode.md",
                global.home .. "/.config/nvim/help/vim_cheat_sheet_visual_commands.md",
                global.home .. "/.config/nvim/help/vim_cheat_sheet_insert_mode.md",
                global.home .. "/.config/nvim/help/vim_cheat_sheet_editing.md",
                global.home .. "/.config/nvim/help/vim_cheat_sheet_registers.md",
                global.home .. "/.config/nvim/help/vim_cheat_sheet_marks_and_positions.md",
                global.home .. "/.config/nvim/help/vim_cheat_sheet_macros.md",
                global.home .. "/.config/nvim/help/vim_cheat_sheet_cut_and_paste.md",
                global.home .. "/.config/nvim/help/vim_cheat_sheet_indent_text.md",
                global.home .. "/.config/nvim/help/vim_cheat_sheet_exiting.md",
                global.home .. "/.config/nvim/help/vim_cheat_sheet_search_and_replace.md",
                global.home .. "/.config/nvim/help/vim_cheat_sheet_search_in_multiple_files.md",
                global.home .. "/.config/nvim/help/vim_cheat_sheet_tabs.md",
                global.home .. "/.config/nvim/help/vim_cheat_sheet_working_with_multiple_files.md",
                global.home .. "/.config/nvim/help/vim_cheat_sheet_diff.md"
            }
        }
    )
end

return config
