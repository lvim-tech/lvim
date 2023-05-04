local config = {}

config.lvim_colorscheme = function()
    require("lvim-colorscheme").setup({
        sidebars = {
            "dbui",
            "qf",
            "pqf",
            "Outline",
            "terminal",
            "packer",
            "calendar",
            "spectre_panel",
            "ctrlspace",
            "neo-tree",
        },
    })
    vim.cmd("colorscheme lvim-" .. _G.LVIM_SETTINGS.colorschemes.theme)
end

config.nvim_web_devicons = function()
    require("nvim-web-devicons").setup()
end

config.nui_nvim = function()
    local function get_prompt_text(prompt, default_prompt)
        local prompt_text = prompt or default_prompt
        if prompt_text:sub(-1) == ":" then
            prompt_text = " " .. prompt_text:sub(1, -2) .. " "
        end
        return prompt_text
    end
    local Input = require("nui.input")
    local Menu = require("nui.menu")
    local event = require("nui.utils.autocmd").event
    local function override_ui_input()
        local calculate_popup_width = function(default, prompt)
            local result = 40
            if prompt ~= nil then
                result = #prompt + 40
            end
            if default ~= nil then
                if #default + 40 > result then
                    result = #default + 40
                end
            end
            return result
        end
        local UIInput = Input:extend("UIInput")
        function UIInput:init(opts, on_done)
            local border_top_text = get_prompt_text(opts.prompt, "Input")
            local default_value
            if opts.default ~= nil then
                default_value = tostring(opts.default)
            else
                default_value = ""
            end
            UIInput.super.init(self, {
                relative = "cursor",
                position = {
                    row = 2,
                    col = 1,
                },
                size = {
                    width = calculate_popup_width(default_value, border_top_text),
                },
                border = {
                    highlight = "NormalFloat:LvimInputBorder",
                    style = { " ", " ", " ", " ", " ", " ", " ", " " },
                    text = {
                        top = border_top_text,
                        top_align = "center",
                    },
                },
                win_options = {
                    winhighlight = "Normal:LvimInputNormal",
                },
            }, {
                prompt = "➤ ",
                default_value = default_value,
                on_close = function()
                    on_done(nil)
                end,
                on_submit = function(value)
                    on_done(value)
                end,
            })
            self:on(event.BufLeave, function()
                on_done(nil)
            end, { once = true })
            self:map("n", "<Esc>", function()
                on_done(nil)
            end, { noremap = true, nowait = true })
        end
        local input_ui
        ---@diagnostic disable-next-line: duplicate-set-field
        vim.ui.input = function(opts, on_confirm)
            assert(type(on_confirm) == "function", "missing on_confirm function")
            if input_ui then
                vim.api.nvim_err_writeln("busy: another input is pending!")
                return
            end
            input_ui = UIInput(opts, function(value)
                if input_ui then
                    input_ui:unmount()
                end
                on_confirm(value)
                input_ui = nil
            end)
            input_ui:mount()
        end
    end
    local function override_ui_select()
        local UISelect = Menu:extend("UISelect")
        function UISelect:init(items, opts, on_done)
            local border_top_text = get_prompt_text(opts.prompt, "Select Item")
            local kind = opts.kind or "unknown"
            local format_item = opts.format_item
                or function(item)
                    return tostring(item.__raw_item or item)
                end
            local popup_options = {
                relative = "editor",
                position = "50%",
                border = {
                    highlight = "NormalFloat:LvimSelectBorder",
                    style = { " ", " ", " ", " ", " ", " ", " ", " " },
                    text = {
                        top = border_top_text,
                        top_align = "center",
                    },
                },
                win_options = {
                    winhighlight = "Normal:LvimSelectNormal",
                },
                zindex = 999,
            }
            if kind == "codeaction" then
                popup_options.relative = "cursor"
                popup_options.position = {
                    row = 2,
                    col = 1,
                }
            end
            local max_width = popup_options.relative == "editor" and vim.o.columns - 4
                or vim.api.nvim_win_get_width(0) - 4
            local max_height = popup_options.relative == "editor" and math.floor(vim.o.lines * 80 / 100)
                or vim.api.nvim_win_get_height(0)
            local menu_items = {
                UISelect.separator("", {
                    char = " ",
                }),
            }
            for index, item in ipairs(items) do
                if type(item) ~= "table" then
                    item = { __raw_item = item }
                end
                item.index = index
                local item_text = string.sub(format_item(item), 0, max_width)
                table.insert(menu_items, Menu.item(item_text, item))
            end
            local menu_options = {
                min_width = vim.api.nvim_strwidth(border_top_text),
                max_width = max_width,
                max_height = max_height,
                lines = menu_items,
                on_close = function()
                    on_done(nil, nil)
                end,
                on_submit = function(item)
                    on_done(item.__raw_item or item, item.index)
                end,
            }
            UISelect.super.init(self, popup_options, menu_options)
            self:on(event.BufLeave, function()
                on_done(nil, nil)
            end, { once = true })
        end
        local select_ui = nil
        ---@diagnostic disable-next-line: duplicate-set-field
        vim.ui.select = function(items, opts, on_choice)
            assert(type(on_choice) == "function", "missing on_choice function")
            if select_ui then
                vim.api.nvim_err_writeln("busy: another select is pending!")
                return
            end
            select_ui = UISelect(items, opts, function(item, index)
                if select_ui then
                    select_ui:unmount()
                end
                on_choice(item, index)
                select_ui = nil
            end)
            select_ui:mount()
        end
    end
    override_ui_input()
    override_ui_select()
end

config.nvim_notify = function()
    local notify_status_ok, notify = pcall(require, "notify")
    if not notify_status_ok then
        return
    end
    notify.setup({
        minimum_width = 80,
        background_colour = _G.LVIM_SETTINGS.colorschemes.colors[_G.LVIM_SETTINGS.colorschemes.theme].bg,
        icons = {
            DEBUG = " ",
            ERROR = " ",
            INFO = " ",
            TRACE = " ",
            WARN = " ",
        },
        stages = "fade",
        on_open = function(win)
            if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_set_config(win, {
                    border = { " ", " ", " ", " ", " ", " ", " ", " " },
                    zindex = 200,
                })
                vim.api.nvim_win_set_option(win, "wrap", true)
            end
        end,
    })
    notify.print_history = function()
        local color = {
            DEBUG = "NotifyDEBUGTitle",
            TRACE = "NotifyTRACETitle",
            INFO = "NotifyINFOTitle",
            WARN = "NotifyWARNTitle",
            ERROR = "NotifyERRORTitle",
        }
        for _, m in ipairs(notify.history()) do
            vim.api.nvim_echo({
                { vim.fn.strftime("%FT%T", m.time), "Identifier" },
                { " ", "Normal" },
                { m.level, color[m.level] or "Title" },
                { " ", "Normal" },
                { table.concat(m.message, " "), "Normal" },
            }, false, {})
        end
    end
    vim.cmd("command! Message :lua require('notify').print_history()<CR>")
    vim.notify = notify
end

config.noice_nvim = function()
    local noice_status_ok, noice = pcall(require, "noice")
    if not noice_status_ok then
        return
    end
    noice.setup({
        cmdline = {
            enabled = true,
            view = "cmdline",
            opts = { buf_options = { filetype = "vim" } },
            format = {
                cmdline = { pattern = "^:", icon = "", lang = "vim" },
                search_down = { kind = "search", pattern = "^/", icon = "  ", lang = "regex" },
                search_up = { kind = "search", pattern = "^%?", icon = "  ", lang = "regex" },
                filter = { pattern = "^:%s*!", icon = "$ ", lang = "bash" },
                lua = { pattern = "^:%s*lua%s+", icon = " ", lang = "lua" },
                help = { pattern = "^:%s*h%s+", icon = " " },
                calculator = { pattern = "^=", icon = " ", lang = "vimnormal" },
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
            backend = "nui",
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
                enabled = true,
                format = "lsp_progress",
                format_done = "lsp_progress_done",
                throttle = 1000 / 30,
                view = "mini",
            },
            override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
                ["cmp.entry.get_documentation"] = false,
            },
            hover = {
                enabled = true,
                view = nil,
                opts = {},
            },
            signature = {
                enabled = true,
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
                    keys = { "q", "<esc>" },
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
                    keys = { "q", "<esc>" },
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
                    style = "rounded",
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
                    style = "none",
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
                timeout = 2000,
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
                    any = {
                        { event = { "msg_showmode", "msg_showcmd", "msg_ruler" } },
                        { event = "msg_show", kind = "search_count" },
                    },
                },
                opts = { skip = true },
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
                    replace = true,
                    merge = true,
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
                    replace = true,
                    title = "LVIM IDE",
                },
            },
            {
                view = "mini",
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

config.alpha_nvim = function()
    local alpha_status_ok, alpha = pcall(require, "alpha")
    if not alpha_status_ok then
        return
    end
    local alpha_themes_dashboard_status_ok, alpha_themes_dashboard = pcall(require, "alpha.themes.dashboard")
    if not alpha_themes_dashboard_status_ok then
        return
    end
    math.randomseed(os.time())
    local function button(sc, txt, keybind, keybind_opts)
        local b = alpha_themes_dashboard.button(sc, txt, keybind, keybind_opts)
        b.opts.hl = "AlphaButton"
        b.opts.hl_shortcut = "AlphaButtonShortcut"
        return b
    end
    local function footer()
        local global = require("core.global")
        local plugins = require("lazy").stats().count
        local startup_time = require("lazy").stats().startuptime
        local v = vim.version()
        local datetime = os.date(" %d-%m-%Y")
        local platform
        if global.os == "linux" then
            platform = " Linux"
        elseif global.os == "mac" then
            platform = " macOS"
        else
            platform = ""
        end
        return string.format(
            "  %d plugins   %d ms   v%d.%d.%d  %s  %s",
            plugins,
            startup_time,
            v.major,
            v.minor,
            v.patch,
            platform,
            datetime
        )
    end
    alpha_themes_dashboard.section.header.val = {
        " 888     Y88b      / 888      e    e      ",
        " 888      Y88b    /  888     d8b  d8b     ",
        " 888       Y88b  /   888    d888bdY88b    ",
        " 888        Y888/    888   / Y88Y Y888b   ",
        " 888         Y8/     888  /   YY   Y888b  ",
        " 888____      Y      888 /          Y888b ",
    }
    alpha_themes_dashboard.section.header.opts.hl = "AlphaHeader"
    alpha_themes_dashboard.section.buttons.val = {
        button("SPC SPC b", "  Projects", ":CtrlSpace b<CR>"),
        button("A-/", "  File explorer", ":Telescope file_browser<CR>"),
        button("A-,", "  Search file", ":Telescope find_files<CR>"),
        button("A-.", "  Search in files", ":Telescope live_grep<CR>"),
        button("F11", "  Help", ":LvimHelper<CR>"),
        button("q", "  Quit", "<Cmd>qa<CR>"),
    }
    alpha_themes_dashboard.section.footer.val = footer()
    alpha_themes_dashboard.section.footer.opts.hl = "AlphaFooter"
    table.insert(alpha_themes_dashboard.config.layout, { type = "padding", val = 1 })
    table.insert(alpha_themes_dashboard.config.layout, {
        type = "text",
        val = require("alpha.fortune")(),
        opts = {
            position = "center",
            hl = "AlphaQuote",
        },
    })
    alpha.setup(alpha_themes_dashboard.config)
    vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
            alpha_themes_dashboard.section.footer.val = footer()
        end,
    })
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
    local filters = window_picker.filter_windows
    local function special_autoselect(windows)
        windows = filters(windows)
        if windows == nil then
            windows = {}
        end
        if #windows > 1 then
            return windows
        end
        local curr_win = vim.api.nvim_get_current_win()
        for index, window in ipairs(windows) do
            if window == curr_win then
                table.remove(windows, index)
            end
        end
        return windows
    end
    window_picker.setup({
        show_prompt = false,
        autoselect_one = false,
        include_current_win = true,
        filter_func = special_autoselect,
        filter_rules = {
            bo = {
                filetype = {},
                buftype = {},
            },
        },
        fg_color = _G.LVIM_SETTINGS.colorschemes.colors[_G.LVIM_SETTINGS.colorschemes.theme].bg,
        current_win_hl_color = _G.LVIM_SETTINGS.colorschemes.colors[_G.LVIM_SETTINGS.colorschemes.theme].bg,
        other_win_hl_color = _G.LVIM_SETTINGS.colorschemes.colors[_G.LVIM_SETTINGS.colorschemes.theme].green_01,
    })
    vim.api.nvim_create_user_command("WindowPicker", focus_window, {})
    vim.keymap.set("n", "gw", function()
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

config.oil_nvim = function()
    local oil_nvim_status_ok, oil_nvim = pcall(require, "oil")
    if not oil_nvim_status_ok then
        return
    end
    oil_nvim.setup({
        columns = {
            "icon",
            "permissions",
            "size",
            "mtime",
        },
        win_options = {
            number = false,
            relativenumber = false,
            wrap = false,
            signcolumn = "no",
            cursorcolumn = false,
            foldcolumn = "0",
            spell = false,
            list = false,
            conceallevel = 3,
            concealcursor = "n",
        },
        view_options = {
            show_hidden = true,
        },
        float = {
            border = "none",
            win_options = {
                winblend = 0,
            },
        },
        silence_netrw_warning = true,
    })
end

config.netrw_nvim = function()
    local netrw_nvim_status_ok, netrw_nvim = pcall(require, "netrw")
    if not netrw_nvim_status_ok then
        return
    end
    netrw_nvim.setup()
end

config.neo_tree_nvim = function()
    local neo_tree_status_ok, neo_tree = pcall(require, "neo-tree")
    if not neo_tree_status_ok then
        return
    end
    neo_tree.setup({
        use_popups_for_input = false,
        popup_border_style = { " ", " ", " ", " ", " ", " ", " ", " " },
        enable_git_status = false,
        enable_diagnostics = false,
        sources = {
            "filesystem",
            "buffers",
            "git_status",
            "diagnostics",
        },
        source_selector = {
            winbar = true,
            separator = "",
            content_layout = "center",
            sources = {
                {
                    source = "filesystem",
                    display_name = "  DIR  ",
                },
                {
                    source = "buffers",
                    display_name = "  BUF  ",
                },
                {
                    source = "git_status",
                    display_name = " GIT  ",
                },
                {
                    source = "diagnostics",
                    display_name = "  LSP  ",
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
                folder_closed = "",
                folder_open = "",
                folder_empty = "",
                highlight = "NeoTreeFileIcon",
            },
            modified = {
                symbol = "",
            },
            git_status = {
                symbols = {
                    added = "",
                    deleted = "",
                    modified = "",
                    renamed = "",
                    untracked = "",
                    ignored = "",
                    unstaged = "",
                    staged = "",
                    conflict = "",
                },
                align = "right",
            },
        },
        window = {
            position = "left",
            width = 40,
            mappings = {
                ["Z"] = "expand_all_nodes",
                ["<space>"] = false,
            },
        },
        filesystem = {
            follow_current_file = true,
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

config.dirbuf_nvim = function()
    local dirbuf_status_ok, dirbuf = pcall(require, "dirbuf")
    if not dirbuf_status_ok then
        return
    end
    dirbuf.setup({})
end

config.which_key_nvim = function()
    local which_key_status_ok, which_key = pcall(require, "which-key")
    if not which_key_status_ok then
        return
    end
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
            border = { " ", " ", " ", " ", " ", " ", " ", " " },
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
        hidden = {
            "<silent>",
            "<cmd>",
            "<Cmd>",
            "<CR>",
            "call",
            "lua",
            "^:",
            "^ ",
        },
        show_help = false,
        show_keys = false,
    }
    local nopts = {
        mode = "n",
        prefix = "<leader>",
        buffer = nil,
        silent = true,
        noremap = true,
        nowait = true,
    }
    local nmappings = {
        a = { ":e $HOME/.config/nvim/README.org<CR>", "Open README file" },
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
        e = {
            name = "Explorer",
            e = { "<Cmd>Lexplore<CR>", "Neotree left" },
            c = { "<Cmd>Lexplore %:p:h<CR>", "Neotree left" },
            l = { "<Cmd>Neotree left<CR>", "Neotree left" },
            f = { "<Cmd>Neotree float<CR>", "Neotree float" },
            b = { "<Cmd>Neotree buffers float<CR>", "Neotree buffers" },
            g = { "<Cmd>Neotree git_status float<CR>", "Neotree git_status" },
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
        n = {
            name = "Neogen",
            l = { "<Cmd>NeogenFile<CR>", "File" },
            c = { "<Cmd>NeogenClass<CR>", "Class" },
            f = { "<Cmd>NeogenFunction<CR>", "Function" },
            t = { "<Cmd>NeogenType<CR>", "Type" },
        },
        l = {
            name = "LSP",
            r = { "<Cmd>LspRename<CR>", "Rename" },
            f = { "<Cmd>LspFormat<CR>", "Format" },
            h = { "<Cmd>LspHover<CR>", "Hover" },
            a = { "<Cmd>LspCodeAction<CR>", "Code action" },
            d = { "<Cmd>LspDefinition<CR>", "Definition" },
            t = { "<Cmd>LspTypeDefinition<CR>", "Type definition" },
            R = { "<Cmd>LspReferences<CR>", "References" },
            i = { "<Cmd>LspImplementation<CR>", "Implementation" },
            s = { "<Cmd>LspSignatureHelp<CR>", "Signature help" },
            S = {
                name = "Symbol",
                d = { "<Cmd>LspDocumentSymbol<CR>", "Document symbol" },
                w = { "<Cmd>LspWorkspaceSymbol<CR>", "Workspace symbol" },
            },
            w = {
                "<Cmd>LspAddToWorkspaceFolder<CR>",
                "Add to workspace folder",
            },
        },
        p = {
            name = "Path",
            g = { "<Cmd>SetGlobalPath<CR>", "Set global path" },
            w = { "<Cmd>SetWindowPath<CR>", "Set window path" },
        },
        s = {
            name = "Spectre",
            s = {
                "<Cmd>Spectre<CR>",
                "Open Spectre",
            },
            t = {
                '<Cmd>lua require("spectre").toggle_line()<CR>',
                "Toggle current line",
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
                "Show option",
            },
            r = {
                '<Cmd>lua require("spectre.actions").run_current_replace()<CR>',
                "Replace current line",
            },
            R = {
                '<Cmd>lua require("spectre.actions").run_replace()<CR>',
                "Replace all",
            },
            u = {
                '<Cmd>lua require("spectre").toggle_live_update()<CR>',
                "Update change when vim write file",
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
            l = {
                '<Cmd>lua require("spectre").resume_last_search()<CR>',
                "Resume last search before close",
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
            t = { "<Cmd>Telescope tmux sessions<CR>", "Tmux" },
            y = { "<Cmd>Telescope symbols<CR>", "Symbols" },
            q = { "<Cmd>Telescope quickfix<CR>", "Quickfix" },
            g = {
                name = "Git",
                c = { "<Cmd>Telescope git_commits<CR>", "Git commits" },
                C = { "<Cmd>Telescope git_bcommits<CR>", "Git bcommits" },
                b = { "<Cmd>Telescope git_branches<CR>", "Git branches" },
                s = { "<Cmd>Telescope git_status<CR>", "Git status" },
                t = { "<Cmd>Telescope git_stash<CR>", "Git stash" },
                f = { "<Cmd>Telescope git_files<CR>", "Git files" },
            },
        },
        z = {
            name = "Fzf",
            b = { "<Cmd>FzfLua buffers<CR>", "Buffer" },
            t = { "<Cmd>FzfLua tabs<CR>", "Tabs" },
            m = { "<Cmd>FzfLua marks<CR>", "Marks" },
            j = { "<Cmd>FzfLua jumps<CR>", "Jumps" },
            r = { "<Cmd>FzfLua registers<CR>", "Registers" },
            f = { "<Cmd>FzfLua files<CR>", "Files" },
            q = { "<Cmd>FzfLua quickfix<CR>", "Quickfix" },
            s = { "<Cmd>FzfLua quickfix_stack<CR>", "Quickfix stack" },
            l = { "<Cmd>FzfLua loclist<CR>", "Locklist" },
            w = { "<Cmd>FzfLua live_grep<CR>", "Live grep" },
            k = { "<Cmd>FzfLua keymaps<CR>", "Key maps" },
            g = {
                name = "Git",
                c = { "<Cmd>FzfLua git_commits<CR>", "Git commits" },
                C = { "<Cmd>FzfLua git_bcommits<CR>", "Git bcommits" },
                b = { "<Cmd>FzfLua git_branches<CR>", "Git branches" },
                s = { "<Cmd>FzfLua git_status<CR>", "Git status" },
                t = { "<Cmd>FzfLua git_stash<CR>", "Git stash" },
                f = { "<Cmd>FzfLua git_files<CR>", "Git files" },
            },
        },
    }
    which_key.setup(options)
    which_key.register(nmappings, nopts)
end

config.heirline_nvim = function()
    local common = require("modules.base.configs.ui.heirline.common")
    local statusline = require("modules.base.configs.ui.heirline.statusline")
    local winbar = require("modules.base.configs.ui.heirline.winbar")
    local statuscolumn = require("modules.base.configs.ui.heirline.statuscolumn")
    local heirline_status_ok, heirline = pcall(require, "heirline")
    if not heirline_status_ok then
        return
    end
    heirline.setup({
        statusline = statusline,
        winbar = winbar,
        statuscolumn = statuscolumn,
        opts = {
            colors = common.theme_colors,
            disable_winbar_cb = function(args)
                local buf = args.buf
                local buftype = vim.tbl_contains(common.buftype, vim.bo[buf].buftype)
                local filetype = vim.tbl_contains(common.filetype, vim.bo[buf].filetype)
                return buftype or filetype
            end,
        },
    })
end

config.lvim_shell = function()
    local file_managers = { "Ranger", "Vifm", "Lazygit" }
    local executable = vim.fn.executable
    for _, fm in ipairs(file_managers) do
        if executable(vim.fn.tolower(fm)) == 1 then
            vim.cmd(
                "command! -nargs=? -complete=dir "
                    .. fm
                    .. " :lua require('modules.base.configs.ui.fm')."
                    .. fm
                    .. "(<f-args>)"
            )
        end
    end
    vim.keymap.set("n", "<C-c>fv", function()
        vim.cmd("Vifm")
    end, { noremap = true, silent = true, desc = "Vifm" })
    vim.keymap.set("n", "<C-c>fr", function()
        vim.cmd("Ranger")
    end, { noremap = true, silent = true, desc = "Ranger" })
end

config.lvim_fm = function()
    local lvim_fm_status_ok, lvim_fm = pcall(require, "lvim-fm")
    if not lvim_fm_status_ok then
        return
    end
    lvim_fm.setup()
    vim.keymap.set(
        "n",
        "<leader>r",
        ":LvimFileManager<CR>",
        { noremap = true, silent = true, desc = "LvimFileManager" }
    )
end

config.toggleterm_nvim = function()
    local toggleterm_terminal_status_ok, toggleterm_terminal = pcall(require, "toggleterm.terminal")
    if not toggleterm_terminal_status_ok then
        return
    end
    local terminal_one = toggleterm_terminal.Terminal:new({
        count = 1,
        direction = "horizontal",
        on_open = function(term)
            vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = term.buf, noremap = true, silent = true })
            vim.keymap.set(
                "t",
                "<Esc>",
                "<C-\\><C-n><cmd>close<CR><C-w><C-p>",
                { buffer = term.buf, noremap = true, silent = true }
            )
            vim.keymap.set("t", "<C-x>", "<C-\\><C-n>", { buffer = term.buf, noremap = true, silent = true })
            vim.wo.cursorcolumn = false
            vim.wo.cursorline = false
            vim.cmd("startinsert!")
        end,
        on_close = function()
            vim.cmd("quit!")
        end,
    })
    local terminal_two = toggleterm_terminal.Terminal:new({
        count = 2,
        direction = "horizontal",
        on_open = function(term)
            vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = term.buf, noremap = true, silent = true })
            vim.keymap.set(
                "t",
                "<Esc>",
                "<C-\\><C-n><cmd>close<CR><C-w><C-p>",
                { buffer = term.buf, noremap = true, silent = true }
            )
            vim.keymap.set("t", "<C-x>", "<C-\\><C-n>", { buffer = term.buf, noremap = true, silent = true })
            vim.wo.cursorcolumn = false
            vim.wo.cursorline = false
            vim.cmd("startinsert!")
        end,
        on_close = function()
            vim.cmd("quit!")
        end,
    })
    local terminal_three = toggleterm_terminal.Terminal:new({
        count = 3,
        direction = "horizontal",
        on_open = function(term)
            vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = term.buf, noremap = true, silent = true })
            vim.keymap.set(
                "t",
                "<Esc>",
                "<C-\\><C-n><cmd>close<CR><C-w><C-p>",
                { buffer = term.buf, noremap = true, silent = true }
            )
            vim.keymap.set("t", "<C-x>", "<C-\\><C-n>", { buffer = term.buf, noremap = true, silent = true })
            vim.wo.cursorcolumn = false
            vim.wo.cursorline = false
            vim.cmd("startinsert!")
        end,
        on_close = function()
            vim.cmd("quit!")
        end,
    })
    local terminal_float = toggleterm_terminal.Terminal:new({
        count = 4,
        direction = "float",
        float_opts = {
            border = { " ", " ", " ", " ", " ", " ", " ", " " },
            winblend = 0,
            width = vim.o.columns - 20,
            height = vim.o.lines - 9,
            highlights = {
                border = "FloatBorder",
                background = "NormalFloat",
            },
        },
        on_open = function(term)
            vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = term.buf, noremap = true, silent = true })
            vim.keymap.set(
                "t",
                "<Esc>",
                "<C-\\><C-n><cmd>close<CR><C-w><C-p>",
                { buffer = term.buf, noremap = true, silent = true }
            )
            vim.keymap.set("t", "<C-x>", "<C-\\><C-n>", { buffer = term.buf, noremap = true, silent = true })
            vim.wo.cursorcolumn = false
            vim.wo.cursorline = false
            vim.cmd("startinsert!")
        end,
        on_close = function()
            vim.cmd("quit!")
        end,
    })
    vim.api.nvim_create_user_command("TermOne", function()
        terminal_one:toggle()
    end, {})
    vim.api.nvim_create_user_command("TermTwo", function()
        terminal_two:toggle()
    end, {})
    vim.api.nvim_create_user_command("TermThree", function()
        terminal_three:toggle()
    end, {})
    vim.api.nvim_create_user_command("TermFloat", function()
        terminal_float:toggle()
    end, {})
    vim.keymap.set("n", "<F1>", function()
        terminal_one:toggle()
    end, { noremap = true, silent = true, desc = "Terminal One" })
    vim.keymap.set("n", "<F2>", function()
        terminal_two:toggle()
    end, { noremap = true, silent = true, desc = "Terminal Two" })
    vim.keymap.set("n", "<F3>", function()
        terminal_three:toggle()
    end, { noremap = true, silent = true, desc = "Terminal Three" })
    vim.keymap.set("n", "<F4>", function()
        terminal_float:toggle()
    end, { noremap = true, silent = true, desc = "Terminal Float" })
end

config.zen_mode_nvim = function()
    local zen_mode_status_ok, zen_mode = pcall(require, "zen-mode")
    if not zen_mode_status_ok then
        return
    end
    zen_mode.setup({
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

config.twilight_nvim = function()
    local twilight_status_ok, twilight = pcall(require, "twilight")
    if not twilight_status_ok then
        return
    end
    twilight.setup({
        dimming = {
            alpha = 0.5,
        },
    })
end

config.neozoom_lua = function()
    local neo_zoom_status_ok, neo_zoom = pcall(require, "neo-zoom")
    if not neo_zoom_status_ok then
        return
    end
    neo_zoom.setup({
        left_ratio = 0,
        top_ratio = 0,
        width_ratio = 0.6,
        height_ratio = 1,
        border = "none",
        scrolloff_on_zoom = 0,
    })
    vim.keymap.set("n", "<C-space>", require("neo-zoom").neo_zoom, { silent = true, nowait = true, desc = "NeoZoom" })
end

config.stay_in_place = function()
    local stay_in_place_status_ok, stay_in_place = pcall(require, "stay-in-place")
    if not stay_in_place_status_ok then
        return
    end
    stay_in_place.setup({})
end

config.indent_blankline_nvim = function()
    local indent_blankline_status_ok, indent_blankline = pcall(require, "indent_blankline")
    if not indent_blankline_status_ok then
        return
    end
    indent_blankline.setup({
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
            "org",
            "flutterToolsOutline",
        },
        buftype_exclude = {
            "terminal",
            "nofile",
        },
    })
    vim.keymap.set("n", "zo", "zo:IndentBlanklineRefresh<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "zO", "zO:IndentBlanklineRefresh<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "zc", "zc:IndentBlanklineRefresh<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "zC", "zC:IndentBlanklineRefresh<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "za", "za:IndentBlanklineRefresh<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "zA", "zA:IndentBlanklineRefresh<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "zv", "zv:IndentBlanklineRefresh<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "zV", "zV:IndentBlanklineRefresh<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "zx", "zx:IndentBlanklineRefresh<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "zX", "zX:IndentBlanklineRefresh<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "zm", "zm:IndentBlanklineRefresh<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "zM", "zM:IndentBlanklineRefresh<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "zr", "zr:IndentBlanklineRefresh<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "zR", "zR:IndentBlanklineRefresh<CR>", { noremap = true, silent = true })
end

config.lvim_helper = function()
    local lvim_helper_status_ok, lvim_helper = pcall(require, "lvim-helper")
    if not lvim_helper_status_ok then
        return
    end
    local global = require("core.global")
    lvim_helper.setup({
        content = {
            {
                type = "separator",
                title = " LVIM IDE KEYS ",
            },
            {
                type = "link",
                title = "  Normal Mode  ",
                file = global.home .. "/.config/nvim/help/lvim_bindings_normal_mode.md",
                file_type = "markdown",
            },
            {
                type = "link",
                title = "  Visual Mode  ",
                file = global.home .. "/.config/nvim/help/lvim_bindings_visual_mode.md",
                file_type = "markdown",
            },
            {
                type = "link",
                title = "  DAP  ",
                file = global.home .. "/.config/nvim/help/lvim_bindings_debug_dap.md",
                file_type = "markdown",
            },
            {
                type = "separator",
                title = " VIM KEYS AND COMMANDS ",
            },
            {
                type = "link",
                title = "  Global  ",
                file = global.home .. "/.config/nvim/help/vim_cheat_sheet_global.md",
                file_type = "markdown",
            },
            {
                type = "link",
                title = "  Cursor Movement  ",
                file = global.home .. "/.config/nvim/help/vim_cheat_sheet_cursor_movement.md",
                file_type = "markdown",
            },
            {
                type = "link",
                title = "  Visual Mode  ",
                file = global.home .. "/.config/nvim/help/vim_cheat_sheet_visual_mode.md",
                file_type = "markdown",
            },
            {
                type = "link",
                title = "  Visual Commands  ",
                file = global.home .. "/.config/nvim/help/vim_cheat_sheet_visual_commands.md",
                file_type = "markdown",
            },
            {
                type = "link",
                title = "  Insert Mode  ",
                file = global.home .. "/.config/nvim/help/vim_cheat_sheet_insert_mode.md",
                file_type = "markdown",
            },
            {
                type = "link",
                title = "  Editing  ",
                file = global.home .. "/.config/nvim/help/vim_cheat_sheet_editing.md",
                file_type = "markdown",
            },
            {
                type = "link",
                title = "  Registers  ",
                file = global.home .. "/.config/nvim/help/vim_cheat_sheet_registers.md",
                file_type = "markdown",
            },
            {
                type = "link",
                title = "  Marks and Positions  ",
                file = global.home .. "/.config/nvim/help/vim_cheat_sheet_marks_and_positions.md",
                file_type = "markdown",
            },
            {
                type = "link",
                title = "  Macros  ",
                file = global.home .. "/.config/nvim/help/vim_cheat_sheet_macros.md",
                file_type = "markdown",
            },
            {
                type = "link",
                title = "  Cut and Paste  ",
                file = global.home .. "/.config/nvim/help/vim_cheat_sheet_cut_and_paste.md",
                file_type = "markdown",
            },
            {
                type = "link",
                title = "  Indent Text  ",
                file = global.home .. "/.config/nvim/help/vim_cheat_sheet_indent_text.md",
                file_type = "markdown",
            },
            {
                type = "link",
                title = "  Exiting  ",
                file = global.home .. "/.config/nvim/help/vim_cheat_sheet_exiting.md",
                file_type = "markdown",
            },
            {
                type = "link",
                title = "  Search and Replace  ",
                file = global.home .. "/.config/nvim/help/vim_cheat_sheet_search_and_replace.md",
                file_type = "markdown",
            },
            {
                type = "link",
                title = "  Search in Multiple Files  ",
                file = global.home .. "/.config/nvim/help/vim_cheat_sheet_search_in_multiple_files.md",
                file_type = "markdown",
            },
            {
                type = "link",
                title = "  Tabs  ",
                file = global.home .. "/.config/nvim/help/vim_cheat_sheet_tabs.md",
                file_type = "markdown",
            },
            {
                type = "link",
                title = "  Working with Multiple Files  ",
                file = global.home .. "/.config/nvim/help/vim_cheat_sheet_working_with_multiple_files.md",
                file_type = "markdown",
            },
            {
                type = "link",
                title = "  Diff  ",
                file = global.home .. "/.config/nvim/help/vim_cheat_sheet_diff.md",
                file_type = "markdown",
            },
        },
    })
    vim.keymap.set("n", "<F11>", function()
        vim.cmd("LvimHelper")
    end, { noremap = true, silent = true, desc = "LvimHelper" })
    vim.keymap.set("n", "<C-c>h", function()
        vim.cmd("LvimHelper")
    end, { noremap = true, silent = true, desc = "LvimHelper" })
end

return config
