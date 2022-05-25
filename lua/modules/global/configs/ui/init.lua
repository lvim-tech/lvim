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
        "       888____      Y      888 /          Y888b        ",
    }
    vim.g.dashboard_preview_file_height = 12
    vim.g.dashboard_preview_file_width = 80
    vim.g.dashboard_custom_footer = {}
    vim.g.dashboard_custom_section = {
        a = {
            description = { "     Projects                 " },
            command = "CtrlSpace b",
        },
        b = {
            description = { "     File explorer            " },
            command = "Telescope file_browser",
        },
        c = {
            description = { "     Search file              " },
            command = "Telescope find_files",
        },
        d = {
            description = { "     Search in files          " },
            command = "Telescope live_grep",
        },
        e = {
            description = { "     Browser bookmarks        " },
            command = ":TelescopeBookmarks",
        },
        f = {
            description = { "     Help                     " },
            command = ":LvimHelper",
        },
        g = {
            description = { "     Settings                 " },
            command = ":e ~/.config/nvim/lua/configs/global/lvim.lua",
        },
        h = {
            description = { "     Readme                   " },
            command = ":e ~/.config/nvim/README.md",
        },
    }
end

function config.nvim_tree()
    vim.g.nvim_tree_show_icons = {
        git = 1,
        folders = 1,
        files = 1,
        folder_arrows = 0,
    }
    vim.g.nvim_tree_icons = {
        default = " ",
        symlink = " ",
        git = {
            unstaged = " ",
            staged = " ",
            unmerged = " ",
            renamed = "➜ ",
            untracked = " ",
            ignored = "◌ ",
        },
        folder = {
            default = " ",
            open = " ",
            empty = " ",
            empty_open = " ",
            symlink = " ",
        },
    }
    require("nvim-tree").setup({
        update_cwd = true,
        update_focused_file = {
            enable = true,
        },
    })
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
                g = false,
            },
            spelling = {
                enabled = true,
                suggestions = 20,
            },
        },
        icons = {
            breadcrumb = "»",
            separator = "➜",
            group = "+",
        },
        window = {
            border = "single",
            position = "bottom",
            margin = {
                0,
                0,
                0,
                0,
            },
            padding = {
                2,
                2,
                2,
                2,
            },
        },
        layout = {
            height = {
                min = 4,
                max = 25,
            },
            width = {
                min = 20,
                max = 50,
            },
            spacing = 10,
        },
        hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " },
        show_help = true,
    }
    local nopts = {
        mode = "n",
        prefix = "<leader>",
        buffer = nil,
        silent = true,
        noremap = true,
        nowait = true,
    }
    local vopts = {
        mode = "v",
        prefix = "<leader>",
        buffer = nil,
        silent = true,
        noremap = true,
        nowait = true,
    }
    local nmappings = {
        e = { "<Cmd>NvimTreeToggle<CR>", "NvimTree toggle" },
        b = {
            name = "Buffers",
            n = { "<Cmd>BufSurfForward<CR>", "Next buffer" },
            p = { "<Cmd>BufSurfBack<CR>", "Prev buffer" },
            l = { "<Cmd>Telescope buffers<CR>", "List buffers" },
        },
        d = {
            name = "Database",
            u = { "<Cmd>DBUIToggle<CR>", "DB UI toggle" },
            f = { "<Cmd>DBUIFindBuffer<CR>", "DB find buffer" },
            r = { "<Cmd>DBUIRenameBuffer<CR>", "DB rename buffer" },
            l = { "<Cmd>DBUILastQueryInfo<CR>", "DB last query" },
        },
        p = {
            name = "Packer",
            c = { "<cmd>PackerCompile<CR>", "Compile" },
            i = { "<cmd>PackerInstall<CR>", "Install" },
            s = { "<cmd>PackerSync<CR>", "Sync" },
            S = { "<cmd>PackerStatus<CR>", "Status" },
            u = { "<cmd>PackerUpdate<CR>", "Update" },
        },
        P = {
            name = "Path",
            g = { "<Cmd>SetGlobalPath<CR>", "Set global path" },
            w = { "<Cmd>SetWindowPath<CR>", "Set window path" },
        },
        l = {
            name = "LSP",
            n = { "<Cmd>LspGoToNext<CR>", "Go to next" },
            p = { "<Cmd>LspGoToPrev<CR>", "Go to prev" },
            r = { "<Cmd>LspRename<CR>", "Rename" },
            h = { "<Cmd>LspHover<CR>", "Hover" },
            d = { "<Cmd>LspDefinition<CR>", "Definition" },
            t = { "<Cmd>LspTypeDefinition<CR>", "Type definition" },
            R = { "<Cmd>LspReferences<CR>", "References" },
            a = { "<Cmd>LspCodeAction<CR>", "Code action" },
            f = { "<Cmd>LspFormatting<CR>", "Formatting" },
            s = { "<Cmd>LspFormattingSync<CR>", "Sync formatting" },
            S = {
                name = "Symbol",
                d = { "<Cmd>LspDocumentSymbol<CR>", "Document symbol" },
                w = { "<Cmd>LspWorkspaceSymbol<CR>", "Workspace symbol" },
            },
            w = {
                "<Cmd>LspAddToWorkspaceFolder<CR>",
                "Add to workspace folder",
            },
            v = {
                name = "Virtualtext",
                s = { "<Cmd>LspVirtualTextShow<CR>", "Virtual text show" },
                h = { "<Cmd>LspVirtualTextHide<CR>", "Virtual text hide" },
            },
        },
        g = {
            name = "GIT",
            b = { "<Cmd>GitSignsBlameLine<CR>", "Blame" },
            ["]"] = { "<Cmd>GitSignsNextHunk<CR>", "Next hunk" },
            ["["] = { "<Cmd>GitSignsPrevHunk<CR>", "Prev hunk" },
            P = { "<Cmd>GitSignsPreviewHunk<CR>", "Preview hunk" },
            r = { "<Cmd>GitSignsResetHunk<CR>", "Reset stage hunk" },
            s = { "<Cmd>GitSignsStageHunk<CR>", "Stage hunk" },
            u = { "<Cmd>GitSignsUndoStageHunk<CR>", "Undo stage hunk" },
            R = { "<Cmd>GitSignsResetBuffer<CR>", "Reset buffer" },
            n = { "<Cmd>Neogit<CR>", "Neogit" },
            l = { "<Cmd>Lazygit<CR>", "Lazygit" },
        },
        m = {
            name = "Bookmark",
            t = { "<Cmd>BookmarkToggle<CR>", "Toggle bookmark" },
            n = { "<Cmd>BookmarkNext<CR>", "Next bookmark" },
            p = { "<Cmd>BookmarkPrev<CR>", "Prev bookmark" },
        },
        f = {
            name = "Find & Fold",
            f = { "<Cmd>HopWord<CR>", "Hop Word" },
            ["]"] = { "<Cmd>HopChar1<CR>", "Hop Char1" },
            ["["] = { "<Cmd>HopChar2<CR>", "Hop Char2" },
            l = { "<Cmd>HopLine<CR>", "Hop Line" },
            s = { "<Cmd>HopLineStart<CR>", "Hop Line Start" },
            m = { "<Cmd>:set foldmethod=manual<CR>", "Manual (default)" },
            i = { "<Cmd>:set foldmethod=indent<CR>", "Indent" },
            e = { "<Cmd>:set foldmethod=expr<CR>", "Expr" },
            d = { "<Cmd>:set foldmethod=diff<CR>", "Diff" },
            M = { "<Cmd>:set foldmethod=marker<CR>", "Marker" },
        },
        s = {
            name = "Spectre",
            d = {
                '<Cmd>lua require("spectre").delete()<CR>',
                "Toggle current item",
            },
            g = {
                '<Cmd>lua require("spectre.actions").select_entry()<CR>',
                "Goto current file",
            },
            q = {
                '<Cmd>lua require("spectre.actions").send_to_qf()<CR>',
                "Send all item to quickfix",
            },
            m = {
                '<Cmd>lua require("spectre.actions").replace_cmd()<CR>',
                "Input replace vim command",
            },
            o = {
                '<Cmd>lua require("spectre").show_options()<CR>',
                "show option",
            },
            R = {
                '<Cmd>lua require("spectre.actions").run_replace()<CR>',
                "Replace all",
            },
            v = {
                '<Cmd>lua require("spectre").change_view()<CR>',
                "Change result view mode",
            },
            c = {
                '<Cmd>lua require("spectre").change_options("ignore-case")<CR>',
                "Toggle ignore case",
            },
            h = {
                '<Cmd>lua require("spectre").change_options("hidden")<CR>',
                "Toggle search hidden",
            },
        },
        t = {
            name = "Telescope",
            b = { "<Cmd>Telescope file_browser<CR>", "File browser" },
            f = { "<Cmd>Telescope find_files<CR>", "Find files" },
            w = { "<Cmd>Telescope live_grep<CR>", "Live grep" },
            u = { "<Cmd>Telescope buffers<CR>", "Buffers" },
            m = { "<Cmd>Telescope marks<CR>", "Marks" },
            o = { "<Cmd>Telescope commands<CR>", "Commands" },
            y = { "<Cmd>Telescope symbols<CR>", "Symbols" },
            n = { "<Cmd>Telescope quickfix<CR>", "Quickfix" },
            c = { "<Cmd>Telescope git_commits<CR>", "Git commits" },
            B = { "<Cmd>Telescope git_bcommits<CR>", "Git bcommits" },
            r = { "<Cmd>Telescope git_branches<CR>", "Git branches" },
            s = { "<Cmd>Telescope git_status<CR>", "Git status" },
            S = { "<Cmd>Telescope git_stash<CR>", "Git stash" },
            i = { "<Cmd>Telescope git_files<CR>", "Git files" },
            M = { "<Cmd>Telescope media_files<CR>", "Media files" },
        },
    }
    local vmappings = {
        ["/"] = { ":CommentToggle<CR>", "Comment" },
        f = { "<Cmd>LspRangeFormatting<CR>", "Range formatting" },
    }
    local which_key = require("which-key")
    which_key.setup(options)
    which_key.register(nmappings, nopts)
    which_key.register(vmappings, vopts)
end

function config.heirline_nvim()
    local function isempty(s)
        return s == nil or s == ""
    end

    local conditions = require("heirline.conditions")
    local utils = require("heirline.utils")
    local colors = LVIM_COLORS()
    local Space = { provider = "  " }
    local Align = { provider = "%=" }
    local ViMode = {
        init = function(self)
            self.mode = vim.fn.mode(1)
        end,
        static = {
            mode_names = {
                n = "N",
                no = "N?",
                nov = "N?",
                noV = "N?",
                ["no\22"] = "N?",
                niI = "Ni",
                niR = "Nr",
                niV = "Nv",
                nt = "Nt",
                v = "V",
                vs = "Vs",
                V = "V_",
                Vs = "Vs",
                ["\22"] = "^V",
                ["\22s"] = "^V",
                s = "S",
                S = "S_",
                ["\19"] = "^S",
                i = "I",
                ic = "Ic",
                ix = "Ix",
                R = "R",
                Rc = "Rc",
                Rx = "Rx",
                Rv = "Rv",
                Rvc = "Rv",
                Rvx = "Rv",
                c = "C",
                cv = "Ex",
                r = "...",
                rm = "M",
                ["r?"] = "?",
                ["!"] = "!",
                t = "T",
            },
            mode_colors = {
                n = colors.green,
                i = colors.red,
                v = colors.orange,
                V = colors.orange,
                ["\22"] = colors.orange,
                c = colors.orange,
                s = colors.purple,
                S = colors.purple,
                ["\19"] = colors.purple,
                R = colors.orange,
                r = colors.orange,
                ["!"] = colors.red,
                t = colors.red,
            },
        },
        provider = function(self)
            return "   %(" .. self.mode_names[self.mode] .. "%)"
        end,
        hl = function(self)
            local mode = self.mode:sub(1, 1)
            return { fg = self.mode_colors[mode], bold = true }
        end,
    }
    local FileNameBlock = {
        init = function(self)
            self.filename = vim.api.nvim_buf_get_name(0)
        end,
    }
    local WorkDir = {
        provider = function(self)
            self.icon = "    "
            local cwd = vim.fn.getcwd(0)
            self.cwd = vim.fn.fnamemodify(cwd, ":~")
        end,
        hl = { fg = colors.blue, bold = true },
        utils.make_flexible_component(1, {
            provider = function(self)
                local trail = self.cwd:sub(-1) == "/" and "" or "/"
                return self.icon .. self.cwd .. trail
            end,
        }, {
            provider = function(self)
                local cwd = vim.fn.pathshorten(self.cwd)
                local trail = self.cwd:sub(-1) == "/" and "" or "/"
                return self.icon .. cwd .. trail
            end,
        }, {
            provider = "",
        }),
    }
    local FileIcon = {
        init = function(self)
            local filename = self.filename
            local extension = vim.fn.fnamemodify(filename, ":e")
            self.icon = require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
        end,
        provider = function(self)
            local is_filename = vim.fn.fnamemodify(self.filename, ":.")
            if is_filename ~= "" then
                return self.icon and self.icon .. " "
            end
        end,
        hl = function()
            return { fg = colors.blue }
        end,
    }
    local FileName = {
        provider = function(self)
            local filename = vim.fn.fnamemodify(self.filename, ":.")
            if filename == "" then
                return
            end
            if not conditions.width_percent_below(#filename, 0.25) then
                filename = vim.fn.pathshorten(filename)
            end
            return filename .. " "
        end,
        hl = { fg = colors.blue, bold = true },
    }
    local FileFlags = {
        {
            provider = function()
                if vim.bo.modified then
                    return "  "
                end
            end,
            hl = { fg = colors.red },
        },
        {
            provider = function()
                if not vim.bo.modifiable or vim.bo.readonly then
                    return "  "
                end
            end,
            hl = { fg = colors.red },
        },
    }
    local FileNameModifer = {
        hl = function()
            if vim.bo.modified then
                return { fg = colors.blue, bold = true, force = true }
            end
        end,
    }
    local FileSize = {
        provider = function()
            local fsize = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
            fsize = (fsize < 0 and 0) or fsize
            if fsize <= 0 then
                return
            end
            local file_size = require("core.funcs").file_size(fsize)
            -- local suffix = { "b", "k", "M", "G", "T", "P", "E" }
            -- local i = math.floor((math.log(fsize) / math.log(1024)))
            -- local size_suffix = suffix[i]
            -- if size_suffix == nil then
            --     size_suffix = "b"
            -- end
            return "  " .. file_size
        end,
        hl = { fg = colors.orange },
    }
    FileNameBlock = utils.insert(
        FileNameBlock,
        utils.insert(FileNameModifer, FileName),
        FileIcon,
        FileSize,
        unpack(FileFlags),
        { provider = "%<" }
    )
    local Git = {
        condition = conditions.is_git_repo,
        init = function(self)
            self.status_dict = vim.b.gitsigns_status_dict
            self.has_changes = self.status_dict.added ~= 0
                or self.status_dict.removed ~= 0
                or self.status_dict.changed ~= 0
        end,
        hl = { fg = colors.orange },
        {
            provider = "  ",
        },
        {
            provider = function(self)
                return " " .. self.status_dict.head .. " "
            end,
            hl = { bold = true },
        },
        {
            provider = function(self)
                local count = self.status_dict.added or 0
                return count > 0 and ("  " .. count)
            end,
            hl = { fg = colors.green },
        },
        {
            provider = function(self)
                local count = self.status_dict.removed or 0
                return count > 0 and ("  " .. count)
            end,
            hl = { fg = colors.red },
        },
        {
            provider = function(self)
                local count = self.status_dict.changed or 0
                return count > 0 and ("  " .. count)
            end,
            hl = { fg = colors.orange },
        },
    }
    local Diagnostics = {
        condition = conditions.has_diagnostics,
        static = {
            error_icon = " ",
            warn_icon = " ",
            info_icon = " ",
            hint_icon = " ",
        },
        init = function(self)
            self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
            self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
            self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
            self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
        end,
        {
            provider = function(self)
                return self.errors > 0 and (self.error_icon .. self.errors .. " ")
            end,
            hl = { fg = colors.red },
        },
        {
            provider = function(self)
                return self.warnings > 0 and (self.warn_icon .. self.warnings .. " ")
            end,
            hl = { fg = colors.orange },
        },
        {
            provider = function(self)
                return self.info > 0 and (self.info_icon .. self.info .. " ")
            end,
            hl = { fg = colors.yellow },
        },
        {
            provider = function(self)
                return self.hints > 0 and (self.hint_icon .. self.hints)
            end,
            hl = { fg = colors.blue },
        },
    }
    local LSPActive = {
        condition = conditions.lsp_attached,
        provider = function()
            local names = {}
            for _, server in pairs(vim.lsp.buf_get_clients(0)) do
                table.insert(names, server.name)
            end
            return "  " .. table.concat(names, ", ")
        end,
        hl = { fg = colors.blue, bold = true },
    }
    local _LSPActive = {
        condition = conditions.lsp_attached,
        provider = function()
            return "  "
        end,
        hl = { fg = colors.orange, bold = true },
    }
    local FileType = {
        provider = function()
            local filetype = vim.bo.filetype
            if filetype ~= "" then
                return string.upper(filetype)
            end
        end,
        hl = { fg = colors.type, bold = true },
    }
    local FileEncoding = {
        provider = function()
            local enc = vim.opt.fileencoding:get()
            if enc ~= "" then
                return " " .. enc:upper()
            end
        end,
        hl = { fg = colors.yellow, bold = true },
    }
    local FileFormat = {
        provider = function()
            local format = vim.bo.fileformat
            if format ~= "" then
                local symbols = {
                    unix = " ",
                    dos = " ",
                    mac = " ",
                }
                return symbols[format]
            end
        end,
        hl = { fg = colors.yellow, bold = true },
    }
    local Spell = {
        condition = function()
            return vim.wo.spell
        end,
        provider = "  SPELL",
        hl = { bold = true, fg = colors.orange },
    }
    local ScrollBar = {
        static = {
            sbar = { "█", "▇", "▆", "▅", "▄", "▃", "▂", "▁" },
            -- sbar = { '🭶', '🭷', '🭸', '🭹', '🭺', '🭻' }
        },
        provider = function(self)
            local curr_line = vim.api.nvim_win_get_cursor(0)[1]
            local lines = vim.api.nvim_buf_line_count(0)
            local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
            return "  " .. self.sbar[i]
        end,
        hl = { fg = colors.red },
    }
    local StatusLines = {
        hl = function()
            if conditions.is_active() then
                return {
                    fg = colors.status_line_fg,
                    bg = colors.status_line_bg,
                }
            else
                return {
                    fg = colors.status_line_nc_fg,
                    bg = colors.status_line_nc_bg,
                }
            end
        end,
        static = {
            mode_color = function(self)
                local mode = conditions.is_active() and vim.fn.mode() or "n"
                return self.mode_colors[mode]
            end,
        },
        init = utils.pick_child_on_condition,
        {
            ViMode,
            WorkDir,
            FileNameBlock,
            Git,
            Align,
            Diagnostics,
            LSPActive,
            _LSPActive,
            FileType,
            FileEncoding,
            FileFormat,
            Spell,
            ScrollBar,
        },
    }
    local TerminalName = {
        provider = function()
            local tname, _ = vim.api.nvim_buf_get_name(0):gsub(".*:", "")
            return " " .. tname
        end,
        hl = { fg = colors.blue, bold = true },
    }
    local File = {
        provider = function()
            local filename = vim.fn.expand("%:t")
            local extension = ""
            local file_icon = ""
            local file_icon_color = ""
            local default_file_icon = ""
            local default_file_icon_color = ""
            if not isempty(filename) then
                extension = vim.fn.expand("%:e")
                local default = false
                if isempty(extension) then
                    extension = ""
                    default = true
                end
                file_icon, file_icon_color = require("nvim-web-devicons").get_icon_color(
                    filename,
                    extension,
                    { default = default }
                )
                local hl_group = "FileIconColor" .. extension
                vim.api.nvim_set_hl(0, hl_group, { fg = file_icon_color })
                if file_icon == nil then
                    file_icon = default_file_icon
                    file_icon_color = default_file_icon_color
                end
                return " " .. "%#" .. hl_group .. "#" .. file_icon .. "%*" .. " " .. filename
            end
        end,
    }
    local Gps = {
        condition = require("nvim-gps").is_available,
        provider = function()
            local status_ok, gps_location = pcall(require("nvim-gps").get_location, {})
            if not status_ok then
                return
            end
            if not isempty(gps_location) then
                return " ➤ " .. gps_location:gsub(" > ", " ➤ ")
            end
        end,
        hl = { fg = colors.gray },
    }
    local WinBars = {
        init = utils.pick_child_on_condition,
        {
            condition = function()
                return conditions.buffer_matches({
                    buftype = { "nofile", "prompt", "help", "quickfix" },
                    filetype = {
                        "^git.*",
                        "ctrlspace",
                        "packer",
                        "undotree",
                        "diff",
                        "Outline",
                        "NvimTree",
                        "LvimHelper",
                        "floaterm",
                        "Trouble",
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
                    },
                })
            end,
            provider = "",
        },
        {
            condition = function()
                return conditions.buffer_matches({ buftype = { "terminal" } })
            end,
            {
                FileType,
                Space,
                TerminalName,
            },
        },
        {
            condition = function()
                return not conditions.is_active()
            end,
            {
                File,
            },
        },
        {
            File,
            Gps,
        },
    }
    require("heirline").setup(StatusLines, WinBars)
end

function config.fm()
    require("fm-nvim").setup({
        ui = {
            float = {
                border = "single",
                float_hl = "NormalFloat",
                border_hl = "FloatBorder",
                height = 0.95,
                width = 0.99,
            },
        },
        cmds = {
            vifm_cmd = "vifmrun",
        },
    })
end

function config.toggleterm()
    local terminal_float = require("toggleterm.terminal").Terminal:new({
        count = 4,
        direction = "float",
        float_opts = {
            border = "single",
            winblend = 0,
            width = vim.o.columns - 20,
            height = vim.o.lines - 9,
            highlights = {
                border = "FloatBorder",
                background = "NormalFloat",
            },
        },
        on_open = function(term)
            vim.api.nvim_buf_set_keymap(term.bufnr, "n", "<Esc>", "<cmd>close<cr>", { noremap = true, silent = true })
            vim.api.nvim_buf_set_keymap(
                term.bufnr,
                "t",
                "<Esc>",
                "<c-\\><c-n><cmd>close<cr><c-w><c-p>",
                { noremap = true }
            )
            vim.wo.cursorcolumn = false
            vim.wo.cursorline = false
            vim.cmd("startinsert!")
        end,
        on_close = function()
            vim.cmd("quit!")
        end,
    })
    local terminal_one = require("toggleterm.terminal").Terminal:new({
        count = 1,
        direction = "horizontal",
        on_open = function(term)
            vim.api.nvim_buf_set_keymap(term.bufnr, "n", "<Esc>", "<cmd>close<cr>", { noremap = true, silent = true })
            vim.api.nvim_buf_set_keymap(
                term.bufnr,
                "t",
                "<Esc>",
                "<c-\\><c-n><cmd>close<cr><c-w><c-p>",
                { noremap = true, silent = true }
            )
            vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-x>", "<c-\\><c-n>", { noremap = true, silent = true })
            vim.wo.cursorcolumn = false
            vim.wo.cursorline = false
            vim.cmd("startinsert!")
            vim.api.nvim_exec([[exe "normal \<C-W>\="]], true)
        end,
        on_close = function()
            vim.cmd("quit!")
        end,
    })
    local terminal_two = require("toggleterm.terminal").Terminal:new({
        count = 2,
        direction = "horizontal",
        on_open = function(term)
            vim.api.nvim_buf_set_keymap(term.bufnr, "n", "<Esc>", "<cmd>close<cr>", { noremap = true, silent = true })
            vim.api.nvim_buf_set_keymap(
                term.bufnr,
                "t",
                "<Esc>",
                "<c-\\><c-n><cmd>close<cr><c-w><c-p>",
                { noremap = true, silent = true }
            )
            vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-x>", "<c-\\><c-n>", { noremap = true, silent = true })
            vim.wo.cursorcolumn = false
            vim.wo.cursorline = false
            vim.cmd("startinsert!")
            vim.api.nvim_exec([[exe "normal \<C-W>\="]], true)
        end,
        on_close = function()
            vim.cmd("quit!")
        end,
    })
    local terminal_three = require("toggleterm.terminal").Terminal:new({
        count = 3,
        direction = "horizontal",
        on_open = function(term)
            vim.api.nvim_buf_set_keymap(term.bufnr, "n", "<Esc>", "<cmd>close<cr>", { noremap = true, silent = true })
            vim.api.nvim_buf_set_keymap(
                term.bufnr,
                "t",
                "<Esc>",
                "<c-\\><c-n><cmd>close<cr><c-w><c-p>",
                { noremap = true, silent = true }
            )
            vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-x>", "<c-\\><c-n>", { noremap = true, silent = true })
            vim.wo.cursorcolumn = false
            vim.wo.cursorline = false
            vim.cmd("startinsert!")
            vim.api.nvim_exec([[exe "normal \<C-W>\="]], true)
        end,
        on_close = function()
            vim.cmd("quit!")
        end,
    })
    function _G.toggleterm_float_toggle()
        terminal_float:toggle()
    end

    function _G.toggleterm_one_toggle()
        terminal_one:toggle()
    end

    function _G.toggleterm_two_toggle()
        terminal_two:toggle()
    end

    function _G.toggleterm_three_toggle()
        terminal_three:toggle()
    end

    vim.api.nvim_create_user_command("TTFloat", "lua _G.toggleterm_float_toggle()", {})
    vim.api.nvim_create_user_command("TTOne", "lua _G.toggleterm_one_toggle()", {})
    vim.api.nvim_create_user_command("TTTwo", "lua _G.toggleterm_two_toggle()", {})
    vim.api.nvim_create_user_command("TTThree", "lua _G.toggleterm_three_toggle()", {})
end

function config.zen_mode()
    require("zen-mode").setup({
        window = {
            options = {
                number = false,
                relativenumber = false,
            },
        },
        plugins = {
            gitsigns = {
                enabled = true,
            },
        },
    })
end

function config.neozoom_lua()
    require("neo-zoom").setup({})
    vim.keymap.set("n", "<C-z>", function()
        vim.cmd("NeoZoomToggle")
    end, NOREF_NOERR_TRUNC)
end

function config.twilight()
    require("twilight").setup({
        dimming = {
            alpha = 0.5,
        },
    })
end

function config.indent_blankline()
    require("indent_blankline").setup({
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
            "for",
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
            "flutterToolsOutline",
        },
        buftype_exclude = {
            "terminal",
            "nofile",
        },
    })
end

function config.lvim_helper()
    local global = require("core.global")
    require("lvim-helper").setup({
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
            global.home .. "/.config/nvim/help/vim_cheat_sheet_diff.md",
        },
    })
end

return config
