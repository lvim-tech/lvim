local icons = require("configs.base.ui.icons")

return {
    lvim_colorscheme = {
        opts = function()
            vim.cmd("colorscheme " .. _G.LVIM_THEME)
            return {
                cache = false,
                transparent = false,
                dim_active = true,
                styles = {
                    floats = "dark",
                    sidebars = "dark",
                },
                on_highlights = function(hl, c)
                    hl.FloatBorder = {
                        bg = c.bg_float,
                        fg = c.bg_float,
                    }
                end,
            }
        end,
        config = function()
            local lvim_colorscheme_status_ok, lvim_colorscheme = pcall(require, "lvim-colorscheme")
            if not lvim_colorscheme_status_ok then
                return
            end
            lvim_colorscheme.setup({
                cache = false,
                transparent = false,
                dim_active = true,
                styles = {
                    floats = "dark",
                    sidebars = "dark",
                },
                on_highlights = function(hl, c)
                    hl.FloatBorder = {
                        bg = c.bg_float,
                        fg = c.bg_float,
                    }
                end,
            })
            vim.cmd("colorscheme " .. _G.LVIM_THEME)
        end,
    },
    nvim_web_devicons = {
        opts = {},
    },
    nui_nvim = {
        config = function()
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
                        vim.notify("busy: another select is pending!", vim.log.levels.ERROR)
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
                local api = vim.api
                local cmd = vim.cmd
                local function set_cursor_blend(blend)
                    blend = tonumber(blend) or 0
                    cmd("hi Cursor blend=" .. blend)
                end
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
                                top = Text(border_top_text, "LvimSelectTitle"),
                                top_align = "center",
                            },
                        },
                        win_options = {
                            winhighlight = "Normal:LvimSelectNormal,Title:LvimSelectTitle",
                        },
                        zindex = 999,
                    }
                    if kind == "codeaction" then
                        popup_options.relative = "cursor"
                        popup_options.position = { row = 2, col = 1 }
                    end
                    local max_width = popup_options.relative == "editor" and vim.o.columns - 4
                        or api.nvim_win_get_width(0) - 4
                    local max_height = popup_options.relative == "editor" and math.floor(vim.o.lines * 80 / 100)
                        or api.nvim_win_get_height(0)
                    local menu_items = {
                        UISelect.separator("", { char = " " }),
                    }
                    for index, item in ipairs(items) do
                        if type(item) ~= "table" then
                            item = { __raw_item = item }
                        end
                        item.index = index
                        local item_text = string.sub(format_item(item), 0, max_width)
                        table.insert(menu_items, Menu.item(item_text, item, { hl_group = "LvimSelectNormal" }))
                    end
                    local menu_options = {
                        min_width = api.nvim_strwidth(border_top_text),
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
                        set_cursor_blend(0)
                    end, { once = true })
                end
                local select_ui = nil
                vim.ui.select = function(items, opts, on_choice)
                    assert(type(on_choice) == "function", "missing on_choice function")
                    if select_ui then
                        vim.notify("busy: another select is pending!", vim.log.levels.ERROR)
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
                    set_cursor_blend(100)
                end
            end
            override_ui_input()
            override_ui_select()
        end,
    },
}

-- vim: foldmethod=indent foldlevel=1
