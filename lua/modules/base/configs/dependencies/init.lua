local icons = require("configs.base.ui.icons")

local config = {}

config.lvim_colorscheme = function()
    local lvim_colorscheme_status_ok, lvim_colorscheme = pcall(require, "lvim-colorscheme")
    if not lvim_colorscheme_status_ok then
        return
    end
    lvim_colorscheme.setup({
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

config.nvim_notify = function()
    local notify_status_ok, notify = pcall(require, "notify")
    if not notify_status_ok then
        return
    end
    notify.setup({
        minimum_width = 80,
        background_colour = _G.LVIM_COLORS["colors"][_G.LVIM_SETTINGS.theme].bg,
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
            local border_top_text = get_prompt_text(string.gsub(opts.prompt, "\n", ""), "Input")
            local default_value
            if opts.default ~= nil then
                default_value = tostring(string.gsub(opts.default, "\n", ""))
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

config.luarocks_nvim = function()
    local luarocks_status_ok, luarocks = pcall(require, "luarocks")
    if not luarocks_status_ok then
        return
    end
    luarocks.setup()
end

return config
