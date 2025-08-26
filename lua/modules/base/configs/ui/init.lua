local icons = require("configs.base.ui.icons")

local config = {}

config.noice_nvim = function()
    local noice_status_ok, noice = pcall(require, "noice")
    if not noice_status_ok then
        return
    end
    noice.setup({
        cmdline = {
            enabled = true,
            view = "cmdline",
            format = {
                cmdline = { pattern = "^:", icon = "" },
                search_down = { pattern = "^/", icon = " ", lang = "regex" },
                search_up = { pattern = "^%?", icon = " ", lang = "regex" },
                filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
                lua = { pattern = "^:%s*lua%s+", icon = "", lang = "lua" },
                help = { pattern = "^:%s*h%s+", icon = "󰋖" },
                calculator = { pattern = "^:=", icon = "󰃬", lang = "regex" },
                input = {},
            },
        },
        messages = {
            enabled = true,
            view = "notify",
            view_error = "notify",
            view_warn = "notify",
            view_history = "split",
            view_search = false,
        },
        popupmenu = {
            enabled = true,
            backend = "notify",
            kind_icons = {},
        },
        commands = {
            history = {
                view = "split",
                opts = { enter = true, format = "details" },
                filter = {
                    any = {
                        { event = "notify" },
                        { error = true },
                        { warning = true },
                        { event = "msg_show", kind = { "" } },
                        { event = "lsp", kind = "message" },
                    },
                },
            },
            last = {
                view = "popup",
                opts = { enter = true, format = "details" },
                filter = {
                    any = {
                        { event = "notify" },
                        { error = true },
                        { warning = true },
                        { event = "msg_show", kind = { "" } },
                        { event = "lsp", kind = "message" },
                    },
                },
                filter_opts = { count = 1 },
            },
            errors = {
                view = "popup",
                opts = { enter = true, format = "details" },
                filter = { error = true },
                filter_opts = { reverse = true },
            },
        },
        notify = {
            enabled = false,
            view = "notify",
        },
        lsp = {
            progress = {
                enabled = false,
                format = "lsp_progress",
                format_done = "lsp_progress_done",
                throttle = 1000 / 30,
                view = "notify",
            },
            override = {
                -- ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
                -- ["vim.lsp.util.stylize_markdown"] = true,
                ["vim.lsp.util.stylize_markdown"] = false,
                ["cmp.entry.get_documentation"] = true,
            },
            hover = {
                -- enabled = true,
                enabled = false,
                view = nil,
                opts = {},
            },
            signature = {
                -- enabled = true,
                enabled = false,
                auto_open = {
                    enabled = true,
                    trigger = true,
                    luasnip = true,
                    throttle = 50,
                },
                view = nil,
                opts = {},
            },
            message = {
                enabled = true,
                view = "notify",
                opts = {},
            },
            documentation = {
                view = "hover",
                opts = {
                    lang = "markdown",
                    replace = true,
                    render = "plain",
                    format = { "{message}" },
                    win_options = { concealcursor = "n", conceallevel = 3 },
                },
            },
        },
        markdown = {
            hover = {
                ["|(%S-)|"] = vim.cmd.help,
                ["%[.-%]%((%S-)%)"] = require("noice.util").open,
            },
            highlights = {
                ["|%S-|"] = "@text.reference",
                ["@%S+"] = "@parameter",
                ["^%s*(Parameters:)"] = "@text.title",
                ["^%s*(Return:)"] = "@text.title",
                ["^%s*(See also:)"] = "@text.title",
                ["{%S-}"] = "@parameter",
            },
        },
        health = {
            checker = true,
        },
        smart_move = {
            enabled = true,
            excluded_filetypes = { "cmp_menu", "cmp_docs", "notify" },
        },
        presets = {
            bottom_search = false,
            command_palette = false,
            long_message_to_split = false,
            inc_rename = false,
            lsp_doc_border = false,
        },
        views = {
            popupmenu = {
                zindex = 65,
                position = "auto",
                size = {
                    width = "auto",
                },
                win_options = {
                    winhighlight = {
                        Normal = "NoiceBody",
                        FloatBorder = "NoiceBorder",
                        CursorLine = "PmenuSel",
                        PmenuMatch = "Special",
                    },
                },
                border = {
                    style = { " ", " ", " ", " ", " ", " ", " ", " " },
                    padding = { 0, 1 },
                },
            },
            notify = {
                backend = "notify",
                replace = true,
                format = "notify",
            },
            split = {
                backend = "split",
                enter = false,
                relative = "editor",
                position = "bottom",
                size = "20%",
                close = {
                    keys = { "q", "<ESC>" },
                },
                win_options = {
                    winhighlight = { Normal = "NoiceBody", FloatBorder = "NoiceBorder" },
                    wrap = true,
                },
            },
            vsplit = {
                backend = "split",
                enter = false,
                relative = "editor",
                position = "right",
                size = "20%",
                close = {
                    keys = { "q", "<ESC>" },
                },
                win_options = {
                    winhighlight = { Normal = "NoiceBody", FloatBorder = "NoiceBorder" },
                },
            },
            popup = {
                backend = "popup",
                relative = "editor",
                close = {
                    events = { "BufLeave" },
                    keys = { "q" },
                },
                enter = true,
                border = {
                    style = { " ", " ", " ", " ", " ", " ", " ", " " },
                },
                position = "50%",
                size = {
                    width = "120",
                    height = "20",
                },
                win_options = {
                    winhighlight = { Normal = "NoiceBody", FloatBorder = "NoiceBorder" },
                },
            },
            hover = {
                view = "popup",
                relative = "cursor",
                zindex = 45,
                enter = false,
                anchor = "auto",
                size = {
                    width = "auto",
                    height = "auto",
                    max_height = 20,
                    max_width = 120,
                },
                position = { row = 1, col = 0 },
                win_options = {
                    wrap = true,
                    linebreak = true,
                },
            },
            cmdline = {
                backend = "popup",
                relative = "editor",
                position = {
                    row = "100%",
                    col = 0,
                },
                size = {
                    height = "auto",
                    width = "100%",
                },
                border = {
                    style = { "", "", "", "", "", "", "", "" },
                },
                win_options = {
                    winhighlight = {
                        Normal = "NoiceBody",
                        FloatBorder = "NoiceBorder",
                        IncSearch = "IncSearch",
                        Search = "Search",
                    },
                },
            },
            mini = {
                backend = "mini",
                relative = "editor",
                align = "message-right",
                timeout = 5000,
                reverse = false,
                position = {
                    row = -2,
                    col = "100%",
                },
                size = "auto",
                border = {
                    style = { " ", " ", " ", " ", " ", " ", " ", " " },
                },
                zindex = 60,
                win_options = {
                    winblend = 0,
                    winhighlight = {
                        Normal = "NoiceBody",
                        IncSearch = "IncSearch",
                        Search = "Search",
                        FloatBorder = "NoiceBody",
                    },
                },
            },
            cmdline_popup = {
                backend = "popup",
                relative = "editor",
                focusable = false,
                enter = false,
                zindex = 60,
                position = {
                    row = "90%",
                    col = "50%",
                },
                size = {
                    min_width = 60,
                    width = "auto",
                    height = "auto",
                },
                border = {
                    style = { " ", " ", " ", " ", " ", " ", " ", " " },
                    padding = { 0, 1 },
                },
                win_options = {
                    winhighlight = {
                        Normal = "NoiceBody",
                        FloatBorder = "NoiceBorder",
                        IncSearch = "IncSearch",
                        Search = "Search",
                    },
                    cursorline = false,
                },
            },
            cmdline_input = {
                border = {
                    style = { " ", " ", " ", " ", " ", " ", " ", " " },
                    text = {
                        top = " CONFIRM: ",
                    },
                    padding = { 0, 1 },
                },
                win_options = {
                    winhighlight = {
                        Normal = "NoiceBody",
                        FloatBorder = "NoiceBorder",
                        IncSearch = "IncSearch",
                        Search = "Search",
                    },
                    cursorline = false,
                },
            },
            confirm = {
                backend = "popup",
                relative = "editor",
                focusable = false,
                align = "center",
                enter = false,
                zindex = 60,
                format = { "{confirm}" },
                position = {
                    row = "50%",
                    col = "50%",
                },
                size = "auto",
                border = {
                    style = { " ", " ", " ", " ", " ", " ", " ", " " },
                    padding = { 0, 1, 0, 1 },
                    text = {
                        top = " CONFIRM: ",
                    },
                },
                win_options = {
                    winhighlight = {
                        Normal = "NoiceBody",
                        FloatBorder = "NoiceBorder",
                    },
                },
            },
        },
        routes = {
            {
                view = "cmdline",
                filter = {
                    event = "cmdline",
                    find = "^%s*[/?]",
                },
            },
            {
                view = "confirm",
                filter = {
                    any = {
                        { event = "msg_show", kind = "confirm" },
                        { event = "msg_show", kind = "confirm_sub" },
                    },
                },
            },
            {
                view = "split",
                filter = {
                    any = {
                        { event = "msg_history_show" },
                    },
                },
            },
            {
                view = "notify",
                filter = {
                    event = "msg_show",
                    kind = "",
                    find = "written",
                },
                opts = { skip = true },
            },
            {
                view = "notify",
                filter = {
                    event = "msg_show",
                    kind = { "", "echo", "echomsg" },
                },
                opts = {
                    replace = false,
                    merge = false,
                    title = "LVIM IDE",
                },
            },
            {
                view = "notify",
                filter = { error = true },
                opts = {
                    skip = true,
                },
            },
            {
                view = "notify",
                filter = { warning = true },
                opts = {
                    skip = true,
                },
            },
            {
                view = "notify",
                filter = { event = "notify" },
                opts = {
                    title = "LVIM IDE",
                },
            },
            {
                view = "notify",
                filter = {
                    event = "noice",
                    kind = { "stats", "debug" },
                },
                opts = {
                    buf_options = { filetype = "lua" },
                    replace = false,
                    title = "LVIM IDE",
                },
            },
            {
                view = "notify",
                filter = { event = "lsp", kind = "progress" },
            },
        },
        status = {},
        format = {},
    })
    vim.keymap.set({ "n", "i" }, "<C-d>", function()
        if not require("noice.lsp").scroll(4) then
            return "<C-d>"
        end
    end, { silent = true, expr = true, desc = "Scroll Down" })
    vim.keymap.set({ "n", "i" }, "<C-u>", function()
        if not require("noice.lsp").scroll(-4) then
            return "<C-u>"
        end
    end, { silent = true, expr = true, desc = "Scroll Up" })
end

config.snacks_nvim = function()
    local function patch_snacks_dashboard()
        local group_states = {}
        local orig_del_augroup = vim.api.nvim_del_augroup_by_id
        _G.__safe_del_augroup = function(id)
            if not group_states[id] then
                group_states[id] = true
                pcall(orig_del_augroup, id)
            end
        end
        vim.api.nvim_del_augroup_by_id = _G.__safe_del_augroup
        local dashboard = require("snacks.dashboard")
        if dashboard then
            local orig_open = dashboard.open
            dashboard.open = function(opts)
                local instance = orig_open(opts)
                if instance and instance.augroup then
                    group_states[instance.augroup] = false
                    pcall(function()
                        for _, cmd in
                            ipairs(vim.api.nvim_get_autocmds({
                                group = instance.augroup,
                                event = { "BufWipeout", "BufDelete" },
                            }))
                        do
                            pcall(vim.api.nvim_del_autocmd, cmd.id)
                        end
                        vim.api.nvim_create_autocmd({ "BufWipeout", "BufDelete" }, {
                            group = instance.augroup,
                            buffer = instance.buf,
                            callback = function()
                                if type(instance.fire) == "function" then
                                    pcall(function()
                                        instance:fire("Closed")
                                    end)
                                end
                                _G.__safe_del_augroup(instance.augroup)
                            end,
                        })
                    end)
                end
                return instance
            end
        end
    end

    patch_snacks_dashboard()

    local snacks_status_ok, snacks = pcall(require, "snacks")
    if not snacks_status_ok then
        return
    end

    snacks.setup({
        scroll = { enabled = false },
        animate = { enabled = true },
        image = { enables = true },
        dashboard = {
            enabled = true,
            sections = {
                {
                    header = [[
██╗    ██╗   ██╗██╗███╗   ███╗
██║    ██║   ██║██║████╗ ████║
██║    ██║   ██║██║██╔████╔██║
██║    ╚██╗ ██╔╝██║██║╚██╔╝██║
███████╗╚████╔╝ ██║██║ ╚═╝ ██║
╚══════╝ ╚═══╝  ╚═╝╚═╝     ╚═╝
]],
                },
                { icon = " ", key = "<C-Space>", desc = "Lvim Space", action = ":LvimSpace" },
                { icon = " ", key = "<Leader>=", desc = "File Explorer", action = ":Yazi" },
                { icon = " ", key = "<Leader>f", desc = "Find File", action = ":FzfLua files" },
                { icon = " ", key = "<Leader>nn", desc = "New File", action = ":ene | startinsert" },
                { icon = " ", key = "<Leader>w", desc = "Find Text", action = ":FzfLua live_grep" },
                { icon = " ", key = "<Leader>o", desc = "Recent Files", action = ":FzfLua oldfiles" },
                {
                    icon = " ",
                    key = "<Leader>vc",
                    desc = "Config",
                    action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
                },
                {
                    icon = "󰅢 ",
                    key = "<leader>vl",
                    desc = "Lazy",
                    action = ":Lazy",
                    enabled = package.loaded.lazy ~= nil,
                },
                { icon = "󰅢 ", key = "<leader>vm", desc = "Mason", action = ":Mason" },
                { icon = " ", key = "<C-c>e", desc = "Quit", action = ":Quit" },
                { pane = 2 },
                function()
                    local v = vim.version()
                    local datetime = os.date(" %d-%m-%Y")
                    local platform
                    if _G.global.os == "linux" then
                        platform = " Linux"
                    elseif _G.global.os == "mac" then
                        platform = " macOS"
                    else
                        platform = ""
                    end
                    local build = ""
                    if v.build ~= vim.NIL then
                        build = " build " .. v.build
                    end
                    local str = platform
                        .. " "
                        .. datetime
                        .. " "
                        .. icons.common.vim
                        .. "v"
                        .. v.major
                        .. "."
                        .. v.minor
                        .. "."
                        .. v.patch
                        .. build
                    return { pane = 2, text = { str, hl = "SnacksDashboardDesc" }, align = "center" }
                end,
                { pane = 2 },
                { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 3, padding = 1 },
                { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 3, padding = 1 },
                { indent = 3 },
                { section = "startup" },
            },
        },
        notifier = {
            enabled = false,
            style = function(buf, notif, ctx)
                local title = notif.icon .. " " .. (notif.title or "")
                if title ~= "" then
                    ctx.opts.title = { { " " .. title .. " ", ctx.hl.title } }
                    ctx.opts.title_pos = "center"
                end
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(notif.msg, "\n"))
            end,
            top_down = true,
            -- margin = { top = 0, right = 0, bottom = 0, left = 1 },
            padding = true,
            icons = {
                error = " ",
                warn = " ",
                info = " ",
                debug = " ",
                trace = " ",
            },
        },
        profiler = {
            enabled = true,
        },
        health = {
            enabled = true,
        },
        lazygit = {
            enabled = false,
            config = {
                os = { editPreset = "nvim-remote" },
                gui = {
                    nerdFontsVersion = "3",
                    border = "hidden",
                },
            },
            theme = {
                [241] = { fg = "Special" },
                activeBorderColor = { fg = "SnacksInActiveBorder", bold = true },
                cherryPickedCommitBgColor = { fg = "Identifier" },
                cherryPickedCommitFgColor = { fg = "Function" },
                defaultFgColor = { fg = "Normal" },
                inactiveBorderColor = { fg = "SnacksActiveBorder" },
                optionsTextColor = { fg = "Function" },
                searchingActiveBorderColor = { fg = "SnacksActiveBorder", bold = true },
                selectedLineBgColor = { bg = "Visual" },
                unstagedChangesColor = { fg = "DiagnosticError" },
            },
        },
        git = {
            enabled = true,
        },
        gitbrowse = {
            enabled = true,
        },
        quickfile = { enabled = true },
        bigfile = { enabled = true },
        zen = { enabled = true },
        scope = { enabled = true },
        scratch = { enabled = true },
        styles = {
            notification = {
                title = "LVIM IDE",
                border = { "─", "─", "─", " ", "─", "─", "─", " " },
            },
            dashboard = {
                zindex = 10,
                height = 10,
                width = 10,
                bo = {
                    bufhidden = "wipe",
                    buftype = "nofile",
                    buflisted = true,
                    filetype = "snacks_dashboard",
                    swapfile = false,
                    undofile = false,
                },
                wo = {
                    colorcolumn = "",
                    cursorcolumn = false,
                    cursorline = false,
                    foldmethod = "manual",
                    list = false,
                    number = false,
                    relativenumber = false,
                    sidescrolloff = 0,
                    signcolumn = "no",
                    spell = false,
                    statuscolumn = "",
                    statusline = "",
                    winbar = "",
                    winhighlight = "Normal:SnacksDashboardNormal,NormalFloat:SnacksDashboardNormal",
                    wrap = true,
                },
            },
            scratch = {
                wo = { winhighlight = "NormalFloat:NormalFloat" },
                border = { " ", " ", " ", " ", " ", " ", " ", " " },
            },
        },
    })
    _G.dd = function(...)
        Snacks.debug.inspect(...)
    end
    _G.bt = function()
        Snacks.debug.backtrace()
    end
    vim.print = _G.dd
    vim.cmd("command! Lazygit :lua Snacks.lazygit()")

    local function fzf_scratch()
        local entries = {}
        local items = Snacks.scratch.list()
        local item_map = {}
        local utils = require("fzf-lua.utils")
        local function hl_validate(hl)
            return not utils.is_hl_cleared(hl) and hl or nil
        end
        local function ansi_from_hl(hl, s)
            return utils.ansi_from_hl(hl_validate(hl), s)
        end
        for _, item in ipairs(items) do
            item.icon = item.icon or Snacks.util.icon(item.ft, "filetype")
            item.branch = item.branch and ("branch:%s"):format(item.branch) or ""
            item.cwd = item.cwd and vim.fn.fnamemodify(item.cwd, ":p:~") or ""
            local display = string.format("%s %s %s %s", item.cwd, item.icon, item.name, item.branch)
            table.insert(entries, display)
            item_map[display] = item
        end
        local fzf = require("fzf-lua")
        fzf.fzf_exec(entries, {
            prompt = "Scratch Buffers",
            fzf_opts = {
                ["--header"] = string.format(
                    ":: <%s> to %s | <%s> to %s",
                    ansi_from_hl("FzfLuaHeaderBind", "enter"),
                    ansi_from_hl("FzfLuaHeaderText", "Select Scratch"),
                    ansi_from_hl("FzfLuaHeaderBind", "ctrl-d"),
                    ansi_from_hl("FzfLuaHeaderText", "Delete Scratch")
                ),
            },
            actions = {
                ["default"] = function(selected)
                    local item = item_map[selected[1]]
                    Snacks.scratch.open({
                        icon = item.icon,
                        file = item.file,
                        name = item.name,
                        ft = item.ft,
                    })
                end,
                ["ctrl-d"] = function(selected)
                    local item = item_map[selected[1]]
                    os.remove(item.file)
                    vim.notify("Deleted scratch file: " .. item.file)
                end,
            },
        })
    end
    -- vim.keymap.set("n", "<Leader>sn", function()
    --     Snacks.notifier.show_history()
    -- end, { noremap = true, silent = true, desc = "Notify history" })
    vim.keymap.set("n", "<C-c>z", function()
        Snacks.zen.zoom()
    end, { noremap = true, silent = true, desc = "Zoom" })
    vim.keymap.set("n", "<Leader>sz", function()
        Snacks.zen.zen()
    end, { noremap = true, silent = true, desc = "Zen" })
    vim.keymap.set("n", "<Leader>sb", function()
        Snacks.git.blame_line()
    end, { noremap = true, silent = true, desc = "Git blame line" })
    vim.keymap.set("n", "<Leader>su", function()
        Snacks.gitbrowse.open()
    end, { noremap = true, silent = true, desc = "Git open url" })
    -- vim.keymap.set("n", "<Leader>sg", function()
    --     Snacks.lazygit()
    -- end, { noremap = true, silent = true, desc = "Lazygit" })
    vim.keymap.set("n", "<Leader>ss", function()
        Snacks.scratch.open()
    end, { noremap = true, silent = true, desc = "Scratch open" })
    vim.keymap.set("n", "<Leader>sh", function()
        Snacks.scratch.select()
    end, { noremap = true, silent = true, desc = "Scratch select" })
    vim.keymap.set("n", "<Leader>sf", function()
        fzf_scratch()
    end, { noremap = true, silent = true, desc = "Fzf scratch" })
    vim.keymap.set("n", "<Leader>st", function()
        local git_root = Snacks.git.get_root()
        vim.cmd("cd " .. git_root)
    end, { noremap = true, silent = true, desc = "Cd to git root" })
    vim.keymap.set("n", "<C-c>u", function()
        Snacks.picker.undo()
    end, { noremap = true, silent = true, desc = "Undo" })
end

config.ui_nvim = function()
    local ui_status_ok, ui = pcall(require, "modules.base.configs.ui.ui")
    if not ui_status_ok then
        return
    end
    ui.set_ui()
end

config.nvim_window_picker = function()
    local window_picker_status_ok, window_picker = pcall(require, "window-picker")
    if not window_picker_status_ok then
        return
    end
    local function focus_window()
        local picked_window_id = window_picker.pick_window() or vim.api.nvim_get_current_win()
        vim.api.nvim_set_current_win(picked_window_id)
    end
    window_picker.setup({
        hint = "statusline-winbar",
        picker_config = {
            statusline_winbar_picker = {
                selection_display = function(char, _)
                    return "%=" .. char .. "%="
                end,
                -- use_winbar = "always",
            },
        },
        show_prompt = false,
        filter_rules = {
            autoselect_one = false,
            include_current_win = true,
            bo = {
                filetype = { "nofile" },
                buftype = {},
            },
        },
        highlights = {
            statusline = {
                focused = {
                    fg = _G.LVIM_COLORS.red,
                    bg = _G.LVIM_COLORS.bg_dark,
                    bold = true,
                },
                unfocused = {
                    fg = _G.LVIM_COLORS.bg,
                    bg = _G.LVIM_COLORS.red,
                    bold = true,
                },
            },
            winbar = {
                focused = {
                    fg = _G.LVIM_COLORS.red,
                    bg = _G.LVIM_COLORS.bg_dark,
                    bold = true,
                },
                unfocused = {
                    fg = _G.LVIM_COLORS.bg,
                    bg = _G.LVIM_COLORS.red,
                    bold = true,
                },
            },
        },
    })
    vim.api.nvim_create_user_command("WindowPicker", focus_window, {})
    vim.keymap.set("n", "gpp", function()
        vim.cmd("WindowPicker")
    end, { noremap = true, silent = true, desc = "WindowPicker" })
end

config.winshift_nvim = function()
    local winshift_nvim_status_ok, winshift_nvim = pcall(require, "winshift")
    if not winshift_nvim_status_ok then
        return
    end
    winshift_nvim.setup({
        highlight_moving_win = true,
        focused_hl_group = "CursorLine",
    })
end

config.mini_files = function()
    local mini_files_status_ok, mini_files = pcall(require, "mini.files")
    if not mini_files_status_ok then
        return
    end
    mini_files.setup({
        mappings = {
            close = "q",
            go_in = "L",
            go_in_plus = "l",
            go_out = "H",
            go_out_plus = "h",
            reset = "<BS>",
            show_help = "g?",
            synchronize = "=",
            trim_left = ".",
            trim_right = ">",
        },
        windows = {
            max_number = math.huge,
            preview = true,
            width_focus = 30,
            width_nofocus = 30,
            width_preview = 80,
        },
        options = {
            permanent_delete = true,
            use_as_default_explorer = true,
        },
    })
    local map_split = function(buf_id, lhs, direction)
        local rhs = function()
            local new_target_window
            vim.api.nvim_win_call(mini_files.get_target_window(), function()
                vim.cmd(direction .. " split")
                new_target_window = vim.api.nvim_get_current_win()
            end)
            mini_files.set_target_window(new_target_window)
        end
        local desc = "Split " .. direction
        vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
    end
    vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
            local buf_id = args.data.buf_id
            map_split(buf_id, "gs", "belowright horizontal")
            map_split(buf_id, "gv", "belowright vertical")
        end,
    })
    local function mini_files_open()
        require("mini.files").open()
    end
    vim.api.nvim_create_user_command("MiniFiles", mini_files_open, {})
end

config.fyler_nvim = function()
    local fyler_nvim_status_ok, fyler_nvim = pcall(require, "fyler")
    if not fyler_nvim_status_ok then
        return
    end
    fyler_nvim.setup({
        icon_provider = "nvim-web-devicons",
        views = {
            confirm = {
                win = {
                    win_opts = {
                        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,FloatTitle:FloatTitle",
                    },
                },
            },
            explorer = {
                indentscope = {
                    enabled = true,
                    group = "FylerIndentMarker",
                    marker = "▏",
                },
                win = {
                    kind = "split_right",
                    win_opts = {
                        concealcursor = "nvic",
                        conceallevel = 3,
                        cursorline = false,
                        number = false,
                        relativenumber = false,
                        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,FloatTitle:FloatTitle",
                        wrap = false,
                    },
                },
            },
        },
    })
end

config.which_key_nvim = function()
    local which_key_status_ok, which_key = pcall(require, "which-key")
    if not which_key_status_ok then
        return
    end
    local wk_delay
    local function wk()
        if _G.LVIM_SETTINGS.keyshelper == true then
            wk_delay = tonumber(_G.LVIM_SETTINGS.keyshelperdelay)
        else
            wk_delay = tonumber(_G.LVIM_SETTINGS.keyshelperdelay)
        end
        local options = {
            preset = "helix",
            delay = wk_delay,
            triggers = {
                { "<auto>", mode = "nixsotc" },
                { "m", mode = { "n" } },
            },
            win = {
                border = { " ", " ", " ", " ", " ", " ", " ", " " },
            },
            icons = {
                rules = false,
                mappings = false,
            },
        }
        which_key.setup(options)
    end
    wk()
end

config.netrw_nvim = function()
    local netrw_nvim_status_ok, netrw_nvim = pcall(require, "netrw")
    if not netrw_nvim_status_ok then
        return
    end
    netrw_nvim.setup({
        use_devicons = true,
    })
    vim.api.nvim_create_autocmd("FileType", {
        pattern = {
            "netrw",
        },
        callback = function()
            vim.opt_local.signcolumn = "yes:1"
        end,
        group = "LvimIDE",
    })
end

config.neo_tree_nvim = function()
    local neo_tree_status_ok, neo_tree = pcall(require, "neo-tree")
    if not neo_tree_status_ok then
        return
    end
    neo_tree.setup({
        use_popups_for_input = false,
        popup_border_style = { " ", " ", " ", " ", " ", " ", " ", " " },
        enable_git_status = true,
        enable_diagnostics = true,
        sources = {
            "filesystem",
            "buffers",
            "git_status",
            "document_symbols",
        },
        source_selector = {
            winbar = true,
            separator = "",
            content_layout = "center",
            sources = {
                {
                    source = "filesystem",
                    display_name = icons.common.folder .. " DIR  ",
                },
                {
                    source = "buffers",
                    display_name = icons.common.buffer .. " BUF  ",
                },
                {
                    source = "git_status",
                    display_name = icons.common.git .. " GIT  ",
                },
                {
                    source = "document_symbols",
                    display_name = icons.common.symbol .. " SYM  ",
                },
            },
        },
        default_component_configs = {
            container = {
                enable_character_fade = true,
            },
            indent = {
                with_markers = false,
                with_expanders = true,
            },
            icon = {
                folder_closed = icons.common.folder_close,
                folder_open = icons.common.folder_open,
                folder_empty = icons.common.folder_empty,
                highlight = "NeoTreeFileIcon",
            },
            modified = {
                symbol = icons.common.dot,
            },
            git_status = {
                symbols = icons.git_status,
                align = "right",
            },
        },
        window = {
            position = "left",
            width = 40,
            mappings = {
                ["Z"] = "expand_all_nodes",
                ["<Leader>"] = false,
                uu = {
                    function(state)
                        vim.cmd("TransferUpload " .. state.tree:get_node().path)
                    end,
                    desc = "upload file or directory",
                    nowait = true,
                },
                ud = {
                    function(state)
                        vim.cmd("TransferDownload" .. state.tree:get_node().path)
                    end,
                    desc = "download file or directory",
                    nowait = true,
                },
                uf = {
                    function(state)
                        local node = state.tree:get_node()
                        local context_dir = node.path
                        if node.type ~= "directory" then
                            context_dir = context_dir:gsub("/[^/]*$", "")
                        end
                        vim.cmd("TransferDirDiff " .. context_dir)
                        vim.cmd("Neotree close")
                    end,
                    desc = "diff with remote",
                },
            },
        },
        filesystem = {
            follow_current_file = {
                enabled = true,
                leave_dirs_open = true,
            },
            use_libuv_file_watcher = true,
        },
        diagnostics = {
            autopreview = false,
            autopreview_config = {},
            autopreview_event = "neo_tree_buffer_enter",
            bind_to_cwd = true,
            diag_sort_function = "severity",
            follow_behavior = {
                always_focus_file = true,
                expand_followed = true,
                collapse_others = true,
            },
            follow_current_file = false,
            group_dirs_and_files = true,
            group_empty_dirs = true,
            show_unloaded = true,
        },
    })
end

config.oil_nvim = function()
    local oil_status_ok, oil = pcall(require, "oil")
    if not oil_status_ok then
        return
    end
    oil.setup({
        default_file_explorer = true,
    })
end

config.heirline_nvim = function()
    local statusline = require("modules.base.configs.ui.heirline.statusline").get_statusline()
    local statuscolumn = require("modules.base.configs.ui.heirline.statuscolumn").get_statuscolumn()
    local winbar = require("modules.base.configs.ui.heirline.winbar").get_winbar()
    local buf_types = require("modules.base.configs.ui.heirline.buf_types")
    local file_types = require("modules.base.configs.ui.heirline.file_types")
    local heirline_status_ok, heirline = pcall(require, "heirline")
    if not heirline_status_ok then
        return
    end
    local git_utils = require("modules.base.configs.ui.heirline.git")
    git_utils.start()
    local file_types_winbar = {}
    for i, v in ipairs(file_types) do
        file_types_winbar[i] = v
    end
    table.insert(file_types_winbar, "qf")
    table.insert(file_types_winbar, "replacer")
    heirline.setup({
        statusline = statusline,
        statuscolumn = statuscolumn,
        winbar = winbar,
        opts = {
            disable_winbar_cb = function(args)
                local buf = args.buf
                local buftype = vim.tbl_contains(buf_types, vim.bo[buf].buftype)
                local filetype = vim.tbl_contains(file_types_winbar, vim.bo[buf].filetype)
                return buftype or filetype
            end,
        },
    })
end

config.lvim_shell = function()
    local file_managers = { "Yazi", "Vifm" }
    local executable = vim.fn.executable
    for _, fm in ipairs(file_managers) do
        if executable(vim.fn.tolower(fm)) == 1 then
            vim.api.nvim_create_user_command(fm, function(opts)
                require("modules.base.configs.ui.shell")[fm](opts.args)
            end, {
                nargs = "?",
                complete = "dir",
            })
        end
    end
    vim.api.nvim_create_user_command("Neomutt", function(opts)
        require("modules.base.configs.ui.shell").Neomutt(opts.args)
    end, { nargs = "?" })
    vim.api.nvim_create_user_command("LazyGit", function(opts)
        require("modules.base.configs.ui.shell").LazyGit(opts.args)
    end, { nargs = "?" })
    vim.api.nvim_create_user_command("LazyDocker", function()
        require("modules.base.configs.ui.shell").LazyDocker()
    end, {})
    vim.api.nvim_create_user_command("Yazi", function()
        require("modules.base.configs.ui.shell").Yazi()
    end, {})
    local shells = require("modules.base.configs.ui.shell")
    vim.keymap.set("n", "<Leader>sg", function()
        shells.LazyGit()
    end, { noremap = true, silent = true, desc = "LazyGit" })
    vim.keymap.set("n", "<Leader>sd", function()
        shells.LazyDocker()
    end, { noremap = true, silent = true, desc = "LazyDocker" })
    vim.keymap.set("n", "<Leader>=", function()
        shells.Yazi()
    end, { noremap = true, silent = true, desc = "Yazi" })
    vim.keymap.set("n", "<Leader>sm", function()
        shells.Neomutt()
    end, { noremap = true, silent = true, desc = "Neomutt" })
end

config.betterTerm_nvim = function()
    local betterTerm_status_ok, betterTerm = pcall(require, "betterTerm")
    if not betterTerm_status_ok then
        return
    end
    betterTerm.setup({
        active_tab_hl = "BetterTermActive",
        inactive_tab_hl = "BetterTermInactive",
        new_tab_hl = "BetterTermAdd",
        new_tab_icon = "+",
        size = 20,
    })
    local terminal_count = 9
    for i = 1, terminal_count do
        vim.keymap.set({ "n", "t" }, "<C-c>" .. i, function()
            betterTerm.open(i)
        end, { desc = "Open terminal " .. i, noremap = true, silent = true })
    end
    vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })
end

config.stay_in_place = function()
    local stay_in_place_status_ok, stay_in_place = pcall(require, "stay-in-place")
    if not stay_in_place_status_ok then
        return
    end
    stay_in_place.setup({})
end

config.rainbow_delimiters_nvim = function()
    local rainbow_delimiters_status_ok, rainbow_delimiters = pcall(require, "rainbow-delimiters")
    if not rainbow_delimiters_status_ok then
        return
    end
    vim.g.rainbow_delimiters = {
        strategy = {
            [""] = rainbow_delimiters.strategy["global"],
            vim = rainbow_delimiters.strategy["local"],
        },
        query = {
            [""] = "rainbow-delimiters",
            lua = "rainbow-blocks",
        },
        highlight = {
            "RainbowDelimiterRed",
            "RainbowDelimiterYellow",
            "RainbowDelimiterBlue",
            "RainbowDelimiterOrange",
            "RainbowDelimiterGreen",
            "RainbowDelimiterViolet",
            "RainbowDelimiterCyan",
        },
    }
end

config.indent_blankline_nvim = function()
    local indent_blankline_status_ok, indent_blankline = pcall(require, "ibl")
    if not indent_blankline_status_ok then
        return
    end
    indent_blankline.setup({
        debounce = 200,
        indent = {
            char = "▏",
            tab_char = "▏",
            smart_indent_cap = true,
            highlight = "IndentBlanklineChar",
        },
        whitespace = {
            highlight = "IndentBlanklineContextChar",
        },
        scope = {
            char = "▏",
            enabled = true,
            show_start = true,
            show_end = true,
            injected_languages = true,
            include = {
                node_type = { ["*"] = { "*" } },
            },
            exclude = {
                node_type = {},
            },
            highlight = { "IndentBlanklineCurrentChar" },
        },
        exclude = {
            filetypes = {
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
                "org",
                "flutterToolsOutline",
                "qf",
            },
            buftypes = {
                "terminal",
                "nofile",
            },
        },
    })
end

return config
