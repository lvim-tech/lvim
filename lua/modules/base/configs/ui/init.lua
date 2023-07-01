local icons = require("configs.base.ui.icons")

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
    vim.cmd("colorscheme " .. _G.LVIM_SETTINGS.theme)
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
    local Text = require("nui.text")
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
                    highlight = "FloatBorder:LvimInputBorder",
                    style = { " ", " ", " ", " ", " ", " ", " ", " " },
                    text = {
                        top = Text(border_top_text, "LvimInputBorder"),
                        top_align = "center",
                    },
                },
                win_options = {
                    winhighlight = "Normal:LvimInputNormal",
                },
            }, {
                prompt = icons.common.separator .. " ",
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
                    highlight = "FloatBorder:LvimSelectBorder",
                    style = { " ", " ", " ", " ", " ", " ", " ", " " },
                    text = {
                        top = Text(border_top_text, "LvimSelectBorder"),
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
        background_colour = _G.LVIM_COLORS.colors[_G.LVIM_SETTINGS.theme].bg,
        icons = {
            DEBUG = icons.common.fix,
            ERROR = icons.diagnostics.error,
            WARN = icons.diagnostics.warn,
            INFO = icons.diagnostics.info,
            TRACE = icons.common.trace,
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
                        { event = "msg_show", kind = "" },
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
            icons.common.plugins
                .. " %d plugins  "
                .. icons.common.time
                .. "%d ms  "
                .. icons.common.vim
                .. "v%d.%d.%d  %s  %s",
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
        button("SPC SPC b", icons.common.project .. " Projects", ":CtrlSpace b<CR>"),
        button("A-/", icons.common.explorer .. " File explorer", ":Telescope file_browser<CR>"),
        button("A-,", icons.common.file .. " Search file", ":Telescope find_files<CR>"),
        button("A-.", icons.common.search_in_files .. " Search in files", ":Telescope live_grep<CR>"),
        button("F11", icons.common.help .. "Help", ":LvimHelper<CR>"),
        button("q", icons.common.quit .. "Quit", "<Cmd>qa<CR>"),
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
            pcall(vim.cmd.AlphaRedraw)
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
        hint = "statusline-winbar",
        show_prompt = false,
        filter_func = special_autoselect,
        filter_rules = {
            autoselect_one = false,
            include_current_win = true,
            bo = {
                filetype = {},
                buftype = {},
            },
        },
        highlights = {
            statusline = {
                focused = {
                    fg = _G.LVIM_COLORS.colors[_G.LVIM_SETTINGS.theme].red_03,
                    bg = _G.LVIM_COLORS.colors[_G.LVIM_SETTINGS.theme].bg,
                    bold = true,
                },
                unfocused = {
                    fg = _G.LVIM_COLORS.colors[_G.LVIM_SETTINGS.theme].bg,
                    bg = _G.LVIM_COLORS.colors[_G.LVIM_SETTINGS.theme].red_03,
                    bold = true,
                },
            },
            winbar = {
                focused = {
                    fg = _G.LVIM_COLORS.colors[_G.LVIM_SETTINGS.theme].bg,
                    bg = _G.LVIM_COLORS.colors[_G.LVIM_SETTINGS.theme].bg,
                    bold = true,
                },
                unfocused = {
                    fg = _G.LVIM_COLORS.colors[_G.LVIM_SETTINGS.theme].bg,
                    bg = _G.LVIM_COLORS.colors[_G.LVIM_SETTINGS.theme].red_03,
                    bold = true,
                },
            },
        },
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
    local oil_actions_status_ok, oil_actions = pcall(require, "oil.actions")
    if not oil_actions_status_ok then
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
        use_default_keymaps = false,
        keymaps = {
            ["g?"] = oil_actions.show_help,
            ["<CR>"] = oil_actions.select,
            ["<C-s>"] = oil_actions.select_vsplit,
            ["<C-h>"] = oil_actions.select_split,
            ["<C-t>"] = oil_actions.select_tab,
            ["<C-p>"] = oil_actions.preview,
            ["<C-x>"] = oil_actions.close,
            ["<C-r>"] = oil_actions.refresh,
            ["-"] = oil_actions.parent,
            ["_"] = oil_actions.open_cwd,
            ["`"] = oil_actions.cd,
            ["~"] = oil_actions.tcd,
            ["g."] = oil_actions.toggle_hidden,
        },
        silence_netrw_warning = true,
    })
    vim.keymap.set("n", "<C-c>i", function()
        vim.cmd("Oil")
    end, { noremap = true, silent = true, desc = "Oil" })
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
                    source = "diagnostics",
                    display_name = icons.common.lsp .. " LSP  ",
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

config.hydra_nvim = function()
    local global = require("core.global")
    local all_hydras = global.modules_path .. "/base/configs/ui/hydra/"
    local path_list = vim.split(vim.fn.glob(all_hydras .. "*.lua", true), "\n")
    for _, path in ipairs(path_list) do
        local name = vim.fn.fnamemodify(path, ":t:r")
        local f = "modules.base.configs.ui.hydra." .. name
        require(f)
    end
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
    local file_types_winbar = {}
    for i, v in ipairs(file_types) do
        file_types_winbar[i] = v
    end
    table.insert(file_types_winbar, "qf")
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
    local file_managers = { "Ranger", "Vifm" }
    local executable = vim.fn.executable
    for _, fm in ipairs(file_managers) do
        if executable(vim.fn.tolower(fm)) == 1 then
            vim.cmd(
                "command! -nargs=? -complete=dir "
                    .. fm
                    .. " :lua require('modules.base.configs.ui.shell')."
                    .. fm
                    .. "(<f-args>)"
            )
        end
    end
    if executable("lazygit") == 1 then
        vim.cmd("command! Lazygit :lua require('modules.base.configs.ui.shell').Lazygit()(<f-args>)")
    end
    if executable("lazydocker") == 1 then
        vim.cmd("command! Lazydocker :lua require('modules.base.configs.ui.shell').Lazydocker()")
    end
    vim.keymap.set("n", "<C-c>fr", function()
        vim.cmd("Ranger")
    end, { noremap = true, silent = true, desc = "Ranger" })
    vim.keymap.set("n", "<C-c>fv", function()
        vim.cmd("Vifm")
    end, { noremap = true, silent = true, desc = "Vifm" })
end

config.lvim_fm = function()
    local lvim_fm_status_ok, lvim_fm = pcall(require, "lvim-fm")
    if not lvim_fm_status_ok then
        return
    end
    lvim_fm.setup({
        ui = {
            float = {
                float_hl = "NormalFloat",
                height = 0.5,
                width = 1,
                x = 0,
                y = 1,
                border_hl = "FloatBorder",
            },
        },
    })
    vim.keymap.set(
        "n",
        "<leader>=",
        ":LvimFileManager<CR>",
        { noremap = true, silent = true, desc = "LvimFileManager" }
    )
end

config.toggleterm_nvim = function()
    local toggleterm_status_ok, toggleterm = pcall(require, "toggleterm")
    if not toggleterm_status_ok then
        return
    end
    local toggleterm_terminal_status_ok, toggleterm_terminal = pcall(require, "toggleterm.terminal")
    if not toggleterm_terminal_status_ok then
        return
    end
    toggleterm.setup({
        size = function(term)
            if term.direction == "horizontal" then
                return 20
            elseif term.direction == "vertical" then
                return vim.o.columns * 0.4
            end
        end,
        start_in_insert = false,
        on_open = function()
            vim.keymap.set("n", "<C-q>", "<cmd>close<CR>", { buffer = true, noremap = true, silent = true })
            vim.keymap.set(
                "t",
                "<C-q>",
                "<C-\\><C-n><cmd>close<CR><C-w><C-p>",
                { buffer = true, noremap = true, silent = true }
            )
            vim.keymap.set("t", "<C-x>", "<C-\\><C-n>", { buffer = true, noremap = true, silent = true })
            vim.wo.cursorcolumn = false
            vim.wo.cursorline = false
            vim.cmd("wincmd=")
        end,
        highlights = {
            Normal = {
                link = "NormalFloat",
            },
            NormalFloat = {
                link = "NormalFloat",
            },
            FloatBorder = {
                link = "FloatBorder",
            },
        },
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
    })
    local terminal_1 = toggleterm_terminal.Terminal:new({
        count = 1,
        direction = "horizontal",
    })
    local terminal_2 = toggleterm_terminal.Terminal:new({
        count = 2,
        direction = "horizontal",
    })
    local terminal_3 = toggleterm_terminal.Terminal:new({
        count = 3,
        direction = "horizontal",
    })
    local terminal_4 = toggleterm_terminal.Terminal:new({
        count = 4,
        direction = "horizontal",
    })
    local terminal_5 = toggleterm_terminal.Terminal:new({
        count = 5,
        direction = "vertical",
    })
    local terminal_6 = toggleterm_terminal.Terminal:new({
        count = 6,
        direction = "vertical",
    })
    local terminal_7 = toggleterm_terminal.Terminal:new({
        count = 7,
        direction = "vertical",
    })
    local terminal_8 = toggleterm_terminal.Terminal:new({
        count = 8,
        direction = "vertical",
    })
    local terminal_9 = toggleterm_terminal.Terminal:new({
        count = 9,
        direction = "float",
    })
    vim.api.nvim_create_user_command("TerminalHorizontal1", function()
        terminal_1:toggle()
    end, {})
    vim.api.nvim_create_user_command("TerminalHorizontal2", function()
        terminal_2:toggle()
    end, {})
    vim.api.nvim_create_user_command("TerminalHorizontal3", function()
        terminal_3:toggle()
    end, {})
    vim.api.nvim_create_user_command("TerminalHorizontal4", function()
        terminal_4:toggle()
    end, {})
    vim.api.nvim_create_user_command("TerminalVertical1", function()
        terminal_5:toggle()
    end, {})
    vim.api.nvim_create_user_command("TerminalVertical2", function()
        terminal_6:toggle()
    end, {})
    vim.api.nvim_create_user_command("TerminalVertical3", function()
        terminal_7:toggle()
    end, {})
    vim.api.nvim_create_user_command("TerminalVertical4", function()
        terminal_8:toggle()
    end, {})
    vim.api.nvim_create_user_command("TerminalVertical4", function()
        terminal_8:toggle()
    end, {})
    vim.api.nvim_create_user_command("TerminalFloat", function()
        terminal_9:toggle()
    end, {})
    vim.keymap.set("n", "<F1>", function()
        terminal_1:toggle()
    end, { noremap = true, silent = true, desc = "Terminal One" })
    vim.keymap.set("n", "<F2>", function()
        terminal_2:toggle()
    end, { noremap = true, silent = true, desc = "Terminal Two" })
    vim.keymap.set("n", "<F3>", function()
        terminal_3:toggle()
    end, { noremap = true, silent = true, desc = "Terminal Three" })
    vim.keymap.set("n", "<F4>", function()
        terminal_9:toggle()
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
    vim.keymap.set("n", "<C-c>z", ":NeoZoomToggle<CR>", { silent = true, nowait = true, desc = "NeoZoom" })
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
            "qf",
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
