-- Plugin configuration table for UI-related plugins in LVIM IDE.
-- Covers the start dashboard, cmdline/message UI, window management helpers,
-- file explorers, the statusline/statuscolumn/winbar (heirline), shell
-- integrations, terminal multiplexer, indent guides, and colorscheme helpers.

---@module "modules.base.configs.ui"

local icons = require("configs.base.ui.icons")

---@type table<string, table>  Map of plugin identifiers to their lazy.nvim specs
return {
    -- snacks.nvim: collection of small UI utilities — dashboard, zen, scratch,
    -- git blame/browse, undo picker, notifier, image preview, and more
    snacks_nvim = {
        opts = function()
            ---Monkey-patch snacks.dashboard to prevent a double-delete crash.
            ---Wraps nvim_del_augroup_by_id with a guard that only deletes each
            ---autogroup once, and replaces the dashboard's BufWipeout/BufDelete
            ---autocmd with a safer version that calls instance:fire("Closed").
            local function patch_snacks_dashboard()
                -- Track which augroup IDs have already been deleted to prevent double-free.
                ---@type table<integer, boolean>
                local group_states = {}
                local orig_del_augroup = vim.api.nvim_del_augroup_by_id
                ---Safe wrapper around nvim_del_augroup_by_id that is idempotent.
                ---@param id integer  Autogroup handle to delete
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
            ---@type string  Version string prefixed with "v", e.g. "v9.0.0"
            local ver = "v" .. (_G.LVIM.version or "v9.0.0")
            local header_logo = require("modules.base.configs.ui.logo")
            -- Combine the ASCII art logo with the version string for the dashboard header.
            local header = header_logo.logo_1 .. ver
            -- Install global debug helpers: dd() for inspect, bt() for backtrace.
            _G.dd = function(...)
                Snacks.debug.inspect(...)
            end
            _G.bt = function()
                Snacks.debug.backtrace()
            end
            -- Override vim.print so it uses the richer Snacks inspector.
            vim.print = _G.dd
            ---Open an fzf-lua picker over all existing Snacks scratch buffers.
            ---Pressing <enter> opens the selected scratch; <ctrl-d> deletes it.
            local function fzf_scratch()
                ---@type string[]  Display strings shown in the fzf list
                local entries = {}
                local items = Snacks.scratch.list()
                ---@type table<string, table>  Map from display string back to scratch item
                local item_map = {}
                local utils = require("fzf-lua.utils")
                -- Return hl group name only when it has not been cleared (avoids empty ANSI codes).
                ---@param hl string  Highlight group name
                ---@return string|nil
                local function hl_validate(hl)
                    return not utils.is_hl_cleared(hl) and hl or nil
                end
                ---Wrap a string with ANSI colour codes derived from a highlight group.
                ---@param hl string  Highlight group name
                ---@param s  string  Text to colour
                ---@return string
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
            return {
                scroll = { enabled = false },
                animate = { enabled = true },
                image = { enables = true },
                dashboard = {
                    enabled = true,
                    sections = {
                        {
                            header = header,
                        },
                        {
                            icon = "󰋱 ",
                            key = "<Leader><Leader>",
                            desc = "Lvim Control Center",
                            action = ":LvimControlCenter",
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
                        { icon = "󰐥 ", key = "<C-c>e", desc = "Quit", action = ":Quit" },
                        { pane = 2 },
                        function()
                            local v = vim.version()
                            local datetime = os.date(" %d-%m-%Y")
                            ---@type string  OS label with icon, e.g. " Linux" or " macOS"
                            local platform
                            if _G.LVIM.global.os == "linux" then
                                platform = " Linux"
                            elseif _G.LVIM.global.os == "mac" then
                                platform = " macOS"
                            else
                                platform = ""
                            end
                            -- v.build is vim.NIL (not Lua nil) when absent; guard before using it.
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
                        {
                            pane = 2,
                            icon = " ",
                            title = "Recent Files",
                            section = "recent_files",
                            indent = 3,
                            padding = 1,
                        },
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
                bigfile = { enabled = false },
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
            }
        end,
    },
    -- ui.nvim: override for Neovim's built-in UI (cmdline, messages) with styled
    -- floating windows, per-context icons, and diagnostic-aware message decorations.
    ui_nvim = {
        config = function()
            ---Apply all custom highlight groups used by ui.nvim's cmdline and message styles.
            ---Re-runs on every LvimColorscheme event so highlights track theme changes.
            local function set_hl_groups()
                local c = require("lvim-colorscheme").colors
                if not c then
                    return
                end
                local blend = require("core.funcs").blend
                local bg = c.bg
                -- Short alias so the block below stays readable.
                local hl = vim.api.nvim_set_hl

                hl(0, "UICmdlineDefault", { bg = blend(c.blue, 0.1, bg), fg = c.blue })
                hl(0, "UICmdlineDefaultIcon", { bg = blend(c.blue, 0.3, bg), fg = c.blue })
                hl(0, "UICmdlineLua", { bg = blend(c.purple, 0.1, bg), fg = c.purple })
                hl(0, "UICmdlineLuaIcon", { bg = blend(c.purple, 0.3, bg), fg = c.purple })
                hl(0, "UICmdlineEval", { bg = blend(c.red, 0.1, bg), fg = c.red })
                hl(0, "UICmdlineEvalIcon", { bg = blend(c.red, 0.3, bg), fg = c.red })
                hl(0, "UICmdlineSearchUp", { bg = blend(c.blue, 0.1, bg), fg = c.blue })
                hl(0, "UICmdlineSearchUpIcon", { bg = blend(c.blue, 0.3, bg), fg = c.blue })
                hl(0, "UICmdlineSearchDown", { bg = blend(c.blue, 0.1, bg), fg = c.blue })
                hl(0, "UICmdlineSearchDownIcon", { bg = blend(c.blue, 0.3, bg), fg = c.blue })
                hl(0, "UICmdlineSubstitute", { bg = blend(c.cyan, 0.1, bg), fg = c.cyan })
                hl(0, "UICmdlineSubstituteIcon", { bg = blend(c.cyan, 0.3, bg), fg = c.cyan })
                hl(0, "UIMessageDefault", { bg = blend(c.blue, 0.1, bg), fg = c.blue })
                hl(0, "UIMessageOk", { bg = blend(c.green, 0.1, bg), fg = c.green })
                hl(0, "UIMessageOkIcon", { bg = blend(c.green, 0.3, bg), fg = c.green })
                hl(0, "UIMessageInfo", { bg = blend(c.blue, 0.1, bg), fg = c.blue })
                hl(0, "UIMessageInfoSign", { bg = blend(c.blue, 0.3, bg), fg = c.blue })
                hl(0, "UIMessageHint", { bg = blend(c.cyan, 0.1, bg), fg = c.cyan })
                hl(0, "UIMessageHintSign", { bg = blend(c.cyan, 0.1, bg), fg = c.cyan })
                hl(0, "UIMessageWarn", { bg = blend(c.orange, 0.1, bg), fg = c.orange })
                hl(0, "UIMessageWarnSign", { bg = blend(c.orange, 0.1, bg), fg = c.orange })
                hl(0, "UIMessageError", { bg = blend(c.red, 0.1, bg), fg = c.red })
                hl(0, "UIMessageErrorIcon", { bg = blend(c.red, 0.3, bg), fg = c.red })
                hl(0, "UIMessageErrorSign", { bg = blend(c.red, 0.1, bg), fg = c.red })
                hl(0, "UIMessagePalette", { bg = blend(c.purple, 0.1, bg), fg = c.purple })
                hl(0, "UIMessagePaletteSign", { bg = blend(c.purple, 0.1, bg), fg = c.purple })
                hl(0, "UIHistoryKeymap", { bg = blend(c.blue, 0.3, bg), fg = c.blue, bold = true })
                hl(0, "UIHistoryDesc", { bg = blend(c.blue, 0.1, bg), fg = c.blue })
                hl(0, "DiagnosticInfo", { fg = c.blue })
                hl(0, "DiagnosticOk", { fg = c.green })
                hl(0, "DiagnosticWarn", { fg = c.orange })
                hl(0, "DiagnosticError", { fg = c.red })
                hl(0, "DiagnosticHint", { fg = c.cyan })
            end
            -- Reset ui.nvim so plugin/ui.lua's early default setup (wrap_notify=true) doesn't
            -- keep vim.notify overridden after we re-attach with wrap_notify=false.
            require("ui").detach()
            local utils = require("ui.utils")
            require("ui").setup({
                cmdline = {
                    styles = {
                        default = { icon = { { "▌ " .. icons.common.vim2 .. "  ", "UICmdlineDefaultIcon" } } },
                        search_down = {
                            icon = { { "▌ " .. icons.common.up .. "  ", "UICmdlineSearchDownIcon" } },
                        },
                        search_up = { icon = { { "▌ " .. icons.common.down .. "  ", "UICmdlineSearchUpIcon" } } },
                        set = { icon = { { "▌ " .. icons.common.set .. "  ", "UICmdlineDefaultIcon" } } },
                        shell = { icon = { { "▌ " .. icons.common.symbol2 .. "  ", "UICmdlineEvalIcon" } } },
                        lua = { icon = { { "▌ " .. icons.common.lua .. "  ", "UICmdlineLuaIcon" } } },
                        lua_eval = { icon = { { "▌ " .. icons.common.eval .. "  ", "UICmdlineEvalIcon" } } },
                        substitute = {
                            icon = function(_, lines)
                                if string.match(lines[#lines], "^s/") then
                                    return {
                                        { "▌ " .. icons.common.substitute1 .. "  ", "UICmdlineSubstituteIcon" },
                                    }
                                else
                                    return {
                                        { "▌ " .. icons.common.substitute2 .. "  ", "UICmdlineSubstituteIcon" },
                                    }
                                end
                            end,
                        },
                        prompt = {
                            title = function(state)
                                local output, hl = {}, "UICmdlineLuaIcon"
                                local lines = utils.text_wrap({ state.prompt or "" }, math.floor(vim.o.columns * 0.8))
                                for _, line in ipairs(lines) do
                                    table.insert(output, {
                                        { "▌ " .. icons.common.question .. "  ", hl },
                                        { line, "Comment" },
                                    })
                                end
                                return output
                            end,
                            icon = { { "▌ " .. icons.common.prompt .. "  ", "UICmdlineLuaIcon" } },
                        },
                    },
                },
                message = {
                    enable = false,
                    confirm = true,
                    confirm_winconfig = nil,
                    wrap_notify = false,
                    respect_replace_last = true,
                    msg_styles = {
                        -- Default message style: choose icon and line highlight based on
                        -- the highlight attribute of the first message chunk.
                        default = {
                            ---@param msg table  Message object from ui.nvim
                            ---@return table     Decoration config with icon, padding, and line hl
                            decorations = function(msg)
                                local conf = { icon = { { "▌", "UIMessageDefault" } } }
                                if msg.content and #msg.content == 1 then
                                    local content = msg.content[1]
                                    local hl = utils.attr_to_hl(content[3])
                                    if hl == "WarningMsg" then
                                        conf.icon = { { "▌" .. icons.diagnostics.warn .. " ", "UIMessageWarnSign" } }
                                        conf.padding = { { "▌  ", "UIMessageWarnSign" } }
                                        conf.line_hl_group = "UIMessageWarn"
                                    elseif hl == "ErrorMsg" then
                                        conf.icon =
                                            { { "▌" .. icons.diagnostics.error .. " ", "UIMessageErrorSign" } }
                                        conf.padding = { { "▌  ", "UIMessageErrorSign" } }
                                        conf.line_hl_group = "UIMessageError"
                                    else
                                        conf.icon = { { "▌" .. icons.diagnostics.info .. " ", "UIMessageInfoSign" } }
                                        conf.padding = { { "▌  ", "UIMessageInfoSign" } }
                                        conf.line_hl_group = "UIMessageInfo"
                                    end
                                end
                                return conf
                            end,
                        },
                        -- Search messages: forward (/) gets a down-arrow icon,
                        -- backward (?) gets an up-arrow icon.
                        search = {
                            ---@param _     any       Unused message object
                            ---@param lines string[]  Raw message lines
                            ---@return table          Decoration config
                            decorations = function(_, lines)
                                if string.match(lines[#lines], "^/") then
                                    return {
                                        icon = { { "▌" .. icons.common.down .. " ", "UICmdlineSearchUpIcon" } },
                                        padding = { { "▌  ", "UICmdlineSearchUpIcon" } },
                                        line_hl_group = "UICmdlineDefault",
                                    }
                                else
                                    return {
                                        icon = { { "▌" .. icons.common.up .. " ", "UICmdlineSearchDownIcon" } },
                                        padding = { { "▌  ", "UICmdlineSearchDownIcon" } },
                                        line_hl_group = "UICmdlineSearchDown",
                                    }
                                end
                            end,
                        },
                        write = {
                            decorations = {
                                icon = { { "▌" .. icons.common.save .. " ", "UIMessageOkIcon" } },
                                padding = { { "▌  ", "UIMessageOkIcon" } },
                                line_hl_group = "UIMessageOk",
                            },
                        },
                        lua_error = {
                            decorations = {
                                icon = { { "▌" .. icons.common.lua .. " ", "UIMessageErrorIcon" } },
                                padding = { { "▌  ", "UIMessageErrorIcon" } },
                                line_hl_group = "UIMessageError",
                            },
                        },
                    },
                    confirm_styles = {
                        default = { border = "single", winhl = "Normal:NormalFloat,FloatBorder:FloatBorder" },
                    },
                    list_styles = {
                        default = { border = "single", winhl = "Normal:NormalFloat,FloatBorder:FloatBorder" },
                    },
                },
            })
            -- Re-apply highlights on every theme change via the lvim-colorscheme event.
            vim.api.nvim_create_autocmd("User", {
                pattern = "LvimColorscheme",
                callback = function()
                    vim.schedule(function()
                        set_hl_groups()
                    end)
                end,
            })
            -- Apply immediately if the colorscheme is already loaded.
            if require("lvim-colorscheme").colors then
                vim.schedule(function()
                    set_hl_groups()
                end)
            end
        end,
    },
    -- nvim-window-picker: label each window so the user can jump to it by key
    nvim_window_picker = {
        cmd = { "WindowPicker" },
        keys = {
            { "gpp", "<Cmd>WindowPicker<CR>", desc = "Window picker" },
        },
        opts = function()
            ---Prompt the user to pick a window by label and focus it.
            ---Falls back to the current window when the picker is dismissed.
            local function focus_window()
                local picked_window_id = require("window-picker").pick_window() or vim.api.nvim_get_current_win()
                vim.api.nvim_set_current_win(picked_window_id)
            end
            vim.api.nvim_create_user_command("WindowPicker", focus_window, {})
            return {
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
                            fg = _G.LVIM.colors.red,
                            bg = _G.LVIM.colors.bg_dark,
                            bold = true,
                        },
                        unfocused = {
                            fg = _G.LVIM.colors.bg,
                            bg = _G.LVIM.colors.red,
                            bold = true,
                        },
                    },
                    winbar = {
                        focused = {
                            fg = _G.LVIM.colors.red,
                            bg = _G.LVIM.colors.bg_dark,
                            bold = true,
                        },
                        unfocused = {
                            fg = _G.LVIM.colors.bg,
                            bg = _G.LVIM.colors.red,
                            bold = true,
                        },
                    },
                },
            }
        end,
    },
    -- winshift.nvim: interactively move and swap windows within a tab
    winshift_nvim = {
        cmd = { "WinShift" },
        keys = {
            { "<C-c>w", "<Cmd>Neotree close<CR><Cmd>WinShift<CR>", desc = "WinShift" },
        },
        opts = {
            highlight_moving_win = true,
            focused_hl_group = "CursorLine",
        },
    },
    -- mini.files: lightweight file manager with column-based navigation and split keymaps
    mini_files = {
        cmd = { "MiniFiles" },
        keys = {
            {
                "<Leader>i",
                function()
                    require("mini.files").open()
                end,
                desc = "Mini files",
            },
        },
        opts = function()
            ---Register a buffer-local keymap that opens a horizontal or vertical split
            ---targeting the window that mini.files would navigate into.
            ---@param buf_id    integer  Buffer handle of the mini.files window
            ---@param lhs       string   Key sequence to bind
            ---@param direction string   Split direction, e.g. "belowright horizontal"
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
            -- Expose a :MiniFiles command so other plugins (e.g. neo-tree mappings)
            -- can open the explorer without hard-coding the require() call.
            local function mini_files_open()
                require("mini.files").open()
            end
            vim.api.nvim_create_user_command("MiniFiles", mini_files_open, {})
            return {
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
            }
        end,
    },
    -- fyler.nvim: minimal file browser with devicons integration
    fyler_nvim = {
        cmd = { "Fyler" },
        keys = {
            {
                "<Leader>F",
                function()
                    vim.cmd("Fyler")
                end,
                desc = "Fyler",
            },
        },
        opts = {
            integrations = {
                icon = "nvim_web_devicons",
            },
        },
    },
    -- which-key.nvim: popup showing available key bindings after a delay
    which_key_nvim = {
        config = function()
            local which_key_status_ok, which_key = pcall(require, "which-key")
            if not which_key_status_ok then
                return
            end
            ---@type integer  Popup delay read from the LVIM settings store
            local wk_delay
            ---Read the current keyshelperdelay setting and call which_key.setup().
            ---Extracted into a function so it can be called again after a hot-reload.
            local function wk()
                wk_delay = tonumber(_G.LVIM.settings.keyshelperdelay)
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
        end,
    },
    -- mini.cursorword: highlight all occurrences of the word under the cursor
    mini_cursorword = {
        opts = {},
    },
    -- netrw.nvim: enhance netrw with devicons and a consistent signcolumn
    netrw_nvim = {
        opts = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = {
                    "netrw",
                },
                callback = function()
                    vim.opt_local.signcolumn = "yes:1"
                end,
                group = "LvimIDE",
            })
            return {
                use_devicons = true,
            }
        end,
    },
    -- neo-tree.nvim: sidebar file explorer with filesystem, buffers, git, and LSP symbol sources
    neo_tree_nvim = {
        cmd = { "Neotree" },
        keys = {
            { "<S-x>", "<cmd>Neotree toggle filesystem left<CR>", desc = "NeoTree filesystem" },
            { "<C-c><C-f>", "<cmd>Neotree toggle filesystem left<CR>", desc = "NeoTree filesystem" },
            { "<C-c><C-b>", "<cmd>Neotree toggle buffers left<CR>", desc = "NeoTree buffers" },
            { "<C-c><C-g>", "<cmd>Neotree toggle git_status left<CR>", desc = "NeoTree git" },
            { "<C-c><C-m>", "<cmd>Neotree toggle document_symbols left<CR>", desc = "NeoTree symbols" },
            { "<S-q>", "<cmd>Neotree toggle close<CR>", desc = "NeoTree close" },
        },
        opts = {
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
                    -- Transfer integration: uu/ud/uf allow uploading, downloading, and
                    -- diffing files with a configured remote directly from the sidebar.
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
                            -- If the selected node is a file, walk up one level to get its directory.
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
            event_handlers = {
                {
                    event = "neo_tree_window_after_open",
                    handler = function(_)
                        vim.opt_local.number = false
                        vim.opt_local.relativenumber = false
                        vim.opt_local.cursorcolumn = false
                        vim.opt_local.colorcolumn = "0"
                        vim.cmd("wincmd =")
                    end,
                },
                {
                    event = "neo_tree_window_after_close",
                    handler = function(_)
                        vim.cmd("wincmd =")
                    end,
                },
            },
        },
    },
    -- oil.nvim: edit the filesystem like a buffer; used as the default file explorer
    oil_nvim = {
        cmd = { "Oil" },
        keys = {
            {
                "<Leader>I",
                function()
                    vim.cmd("Oil")
                end,
                desc = "Oil",
            },
        },
        opts = {
            default_file_explorer = true,
        },
    },
    -- heirline.nvim: declarative statusline, statuscolumn, and winbar framework
    heirline_nvim = {
        config = function()
            -- Each component is built in its own submodule to keep this file concise.
            local statusline = require("modules.base.configs.ui.heirline.statusline").get_statusline()
            local statuscolumn = require("modules.base.configs.ui.heirline.statuscolumn").get_statuscolumn()
            local winbar = require("modules.base.configs.ui.heirline.winbar").get_winbar()
            local buf_types = require("modules.base.configs.ui.heirline.buf_types")
            local file_types = require("modules.base.configs.ui.heirline.file_types")
            local git_utils = require("modules.base.configs.ui.heirline.git")
            -- Start the background git-status polling used by the statusline git component.
            git_utils.start()
            -- Build a winbar-specific filetype exclusion list that also hides qf and replacer.
            local file_types_winbar = {}
            for i, v in ipairs(file_types) do
                file_types_winbar[i] = v
            end
            table.insert(file_types_winbar, "qf")
            table.insert(file_types_winbar, "replacer")
            require("heirline").setup({
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
        end,
    },
    -- lvim-shell: integrations for TUI apps launched inside a full-screen terminal
    -- buffer — Yazi, Vifm, Neomutt, LazyGit, and LazyDocker.
    lvim_shell = {
        config = function()
            -- Register :Yazi and :Vifm user commands only when the binaries are found on PATH.
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
        end,
    },
    -- better-term.nvim: numbered persistent terminal tabs with a tabline
    better_term_nvim = {
        opts = function()
            local betterTerm_status_ok, betterTerm = pcall(require, "betterTerm")
            if not betterTerm_status_ok then
                return
            end
            -- Bind <C-c>1 through <C-c>9 to open each numbered terminal instance.
            local terminal_count = 9
            for i = 1, terminal_count do
                vim.keymap.set({ "n", "t" }, "<C-c>" .. i, function()
                    betterTerm.open(i)
                end, { desc = "Open terminal " .. i, noremap = true, silent = true })
            end
            vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })
            return {
                active_tab_hl = "BetterTermActive",
                inactive_tab_hl = "BetterTermInactive",
                new_tab_hl = "BetterTermAdd",
                new_tab_icon = "+",
                size = 20,
                jump_tab_mapping = "<A-$tab>",
            }
        end,
    },
    -- stay-in-place.nvim: keep the cursor position stable during indent operations
    stay_in_place_nvim = {
        opts = {},
    },
    -- rainbow-delimiters.nvim: colour-code nested brackets and blocks by depth
    rainbow_delimiters_nvim = {
        config = function()
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
        end,
    },
    -- indent-blankline.nvim (ibl): render indent guide characters and scope highlights
    indent_blankline_nvim = {
        config = function()
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
                        "LvimDeps",
                    },
                    buftypes = {
                        "terminal",
                        "nofile",
                    },
                },
            })
        end,
    },
}

-- vim: foldmethod=indent foldlevel=1
