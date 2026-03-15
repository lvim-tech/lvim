-- Plugin configuration for core UI dependency plugins.
-- Covers: lvim-colorscheme (theme setup), nvim-web-devicons (file icons),
-- and nui.nvim (replaces vim.ui.input / vim.ui.select with styled popups).

---@module "modules.base.configs.dependencies"
---@diagnostic disable: undefined-field

local icons = require("configs.base.ui.icons")

return {
    -- -------------------------------------------------------------------------
    -- Colorscheme: lvim-colorscheme
    -- Applies the active theme stored in _G.LVIM.theme and configures dim_active
    -- so inactive windows appear darker, with invisible FloatBorder edges.
    -- -------------------------------------------------------------------------
    lvim_colorscheme = {
        ---@return table  Options table forwarded to lvim-colorscheme.setup()
        opts = function()
            vim.cmd("colorscheme " .. _G.LVIM.theme)
            return {
                cache = false,
                transparent = false,
                -- Dim windows that don't have focus
                dim_active = true,
                styles = {
                    floats = "dark",
                    sidebars = "dark",
                },
                ---@param hl  table<string, table>  Highlight group overrides
                ---@param c   LvimColors             Active color palette
                on_highlights = function(hl, c)
                    -- Make float borders invisible by blending them into the float bg
                    hl.FloatBorder = {
                        bg = c.bg_float,
                        fg = c.bg_float,
                    }
                end,
            }
        end,
        ---@return nil
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
                ---@param hl  table<string, table>
                ---@param c   LvimColors
                on_highlights = function(hl, c)
                    hl.FloatBorder = {
                        bg = c.bg_float,
                        fg = c.bg_float,
                    }
                end,
            })
            vim.cmd("colorscheme " .. _G.LVIM.theme)
        end,
    },

    -- -------------------------------------------------------------------------
    -- nvim-web-devicons: provides filetype icons used across the UI.
    -- -------------------------------------------------------------------------
    nvim_web_devicons = {
        opts = {},
    },

    -- -------------------------------------------------------------------------
    -- nui.nvim: replaces the built-in vim.ui.input and vim.ui.select with
    -- styled floating popups consistent with the LVIM color scheme.
    -- -------------------------------------------------------------------------
    nui_nvim = {
        ---@return nil
        config = function()
            -- Strips a trailing colon from prompt text and wraps it with spaces,
            -- so raw ":  Prompt:" becomes " Prompt ".
            ---@param prompt         string|nil  Raw prompt string from the caller
            ---@param default_prompt string      Fallback prompt when prompt is nil
            ---@return string                    Cleaned prompt ready for the border title
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

            -- -----------------------------------------------------------------
            -- vim.ui.input override
            -- -----------------------------------------------------------------
            local function override_ui_input()
                -- Calculates a popup width that fits both the prompt label and
                -- the default value, with a minimum of 40 characters of padding.
                ---@param default string|nil  Pre-filled input value
                ---@param prompt  string|nil  Border title text
                ---@return integer            Computed popup width in columns
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

                -- UIInput extends nui.Input so we can customise the border title
                -- and emit nil to on_done when the user cancels (Esc / BufLeave).
                ---@class UIInput
                local UIInput = Input:extend("UIInput")

                ---@param opts    table     vim.ui.input options ({prompt, default})
                ---@param on_done fun(value: string|nil)  Callback invoked on confirm or cancel
                function UIInput:init(opts, on_done)
                    local border_top_text = get_prompt_text(string.gsub(opts.prompt, "\n", ""), "Input")
                    local default_value
                    if opts.default ~= nil then
                        -- Strip newlines from the default value so it fits in a single line
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
                            -- All-space border style makes the popup edges invisible
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
                    -- Cancel on buffer leave (e.g. clicking outside the popup)
                    self:on(event.BufLeave, function()
                        on_done(nil)
                    end, { once = true })
                    -- Cancel on Esc in normal mode
                    self:map("n", "<Esc>", function()
                        on_done(nil)
                    end, { noremap = true, nowait = true })
                end

                ---@type UIInput|nil  Tracks the currently open input popup; nil when idle
                local input_ui

                -- Replace vim.ui.input with the styled nui popup.
                -- Guards against re-entrance: shows an error if another input is pending.
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

            -- -----------------------------------------------------------------
            -- vim.ui.select override
            -- -----------------------------------------------------------------
            local function override_ui_select()
                local api = vim.api
                local cmd = vim.cmd

                -- Temporarily hides the cursor by setting its blend to 100 so
                -- it doesn't visually interfere with the floating menu.
                ---@param blend integer  Cursor blend value (0 = visible, 100 = hidden)
                local function set_cursor_blend(blend)
                    blend = tonumber(blend) or 0
                    cmd("hi Cursor blend=" .. blend)
                end

                -- UISelect extends nui.Menu to style the selection popup and
                -- handle code-action positioning (near cursor, not centred).
                ---@class UISelect
                local UISelect = Menu:extend("UISelect")

                ---@param items    any[]     List of items to choose from
                ---@param opts     table     vim.ui.select options ({prompt, kind, format_item})
                ---@param on_done  fun(item: any|nil, index: integer|nil)  Callback
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
                    -- Code-action selections open near the cursor instead of centred
                    if kind == "codeaction" then
                        popup_options.relative = "cursor"
                        popup_options.position = { row = 2, col = 1 }
                    end
                    -- Clamp the menu dimensions to the visible editor area
                    local max_width = popup_options.relative == "editor" and vim.o.columns - 4
                        or api.nvim_win_get_width(0) - 4
                    local max_height = popup_options.relative == "editor" and math.floor(vim.o.lines * 80 / 100)
                        or api.nvim_win_get_height(0)
                    -- A leading separator item creates visual padding at the top of the list
                    local menu_items = {
                        UISelect.separator("", { char = " " }),
                    }
                    for index, item in ipairs(items) do
                        -- Wrap non-table items so we can store the original value
                        if type(item) ~= "table" then
                            item = { __raw_item = item }
                        end
                        item.index = index
                        -- Truncate labels that would overflow the popup width
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
                            -- Return the original unwrapped item when possible
                            on_done(item.__raw_item or item, item.index)
                        end,
                    }
                    UISelect.super.init(self, popup_options, menu_options)
                    -- Cancel selection when focus leaves the popup buffer
                    self:on(event.BufLeave, function()
                        on_done(nil, nil)
                        set_cursor_blend(0)
                    end, { once = true })
                end

                ---@type UISelect|nil  Tracks the currently open select popup; nil when idle
                local select_ui = nil

                -- Replace vim.ui.select with the styled nui menu.
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
                    -- Hide the cursor while the menu is open so it doesn't overlap items
                    set_cursor_blend(100)
                end
            end

            override_ui_input()
            override_ui_select()
        end,
    },
}

-- vim: foldmethod=indent foldlevel=1
