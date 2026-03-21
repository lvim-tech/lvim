-- Plugin configuration for core UI dependency plugins.
-- Covers: lvim-colorscheme (theme setup), nvim-web-devicons (file icons),
-- and nui.nvim (replaces vim.ui.input / vim.ui.select with styled popups).

---@module "modules.base.configs.dependencies"
---@diagnostic disable: undefined-field

return {
    -- -------------------------------------------------------------------------
    -- Colorscheme: lvim-colorscheme
    -- Applies the active theme stored in _G.LVIM.theme and configures dim_active
    -- so inactive windows appear darker, with invisible FloatBorder edges.
    -- -------------------------------------------------------------------------
    lvim_colorscheme = {
        ---@return table  Options table forwarded to lvim-colorscheme.setup()
        opts = function()
            if not pcall(vim.cmd, "colorscheme " .. _G.LVIM.theme) then
                vim.cmd("colorscheme lvim-everforest-soft")
            end
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
            if not pcall(vim.cmd, "colorscheme " .. _G.LVIM.theme) then
                vim.cmd("colorscheme lvim-everforest-soft")
            end
        end,
    },

    lvim_utils = {
        config = function()
            require("lvim-utils.gx").map_default()
            vim.api.nvim_create_user_command("Quit", function()
                require("lvim-utils.quit").open()
            end, {})
            require("lvim-utils").setup({
                gx = {},
                cursor = { ft = { "lvim-utils-ui" } },
                notify = {
                    -- Intercept all Vim messages (:echo, errors, warnings) and
                    -- route them through lvim-utils.notify instead of ui.nvim.
                    ext_messages = true,
                    ext_kinds = {
                        [""] = "toast",
                    },
                },
            })

            local ui = require("lvim-utils.ui")
            local ui_auto = ui.new({ width = false })

            local function clean_title(prompt, default_prompt)
                local t = (prompt and prompt:gsub("\n", "")) or default_prompt
                if t:sub(-1) == ":" then
                    t = " " .. t:sub(1, -2) .. " "
                end
                return t
            end

            ---@diagnostic disable-next-line: duplicate-set-field
            vim.ui.input = function(opts, on_confirm)
                assert(type(on_confirm) == "function", "missing on_confirm function")
                local title = clean_title(opts.prompt, " Input ")
                local default = opts.default and tostring(opts.default):gsub("\n", "") or ""
                local width = math.max(40, #title + 40, #default + 40)
                ui.input({
                    title = title,
                    placeholder = default,
                    position = "cursor",
                    width = width,
                    callback = function(confirmed, value)
                        on_confirm(confirmed and value or nil)
                    end,
                })
            end

            vim.ui.select = function(items, opts, on_choice)
                assert(type(on_choice) == "function", "missing on_choice function")
                local format_item = opts.format_item or tostring
                local display = {}
                for _, item in ipairs(items) do
                    table.insert(display, format_item(item))
                end
                local is_code_action = opts.prompt and opts.prompt:find("[Cc]ode [Aa]ction")
                local sel = is_code_action and ui_auto or ui
                local icon = is_code_action and require("lvim-utils.ui.rows").icons().action or nil
                local display_items = {}
                for _, label in ipairs(display) do
                    table.insert(display_items, icon and { label = label, icon = icon } or label)
                end
                sel.select({
                    title = clean_title(opts.prompt, " Select "),
                    items = display_items,
                    position = "cursor",
                    max_width = vim.api.nvim_win_get_width(0) - 4,
                    max_items = vim.api.nvim_win_get_height(0),
                    callback = function(confirmed, index)
                        if confirmed and index then
                            on_choice(items[index], index)
                        else
                            on_choice(nil, nil)
                        end
                    end,
                })
            end
        end,
    },

    -- -------------------------------------------------------------------------
    -- nvim-web-devicons: provides filetype icons used across the UI.
    -- -------------------------------------------------------------------------
    nvim_web_devicons = {
        opts = {},
    },

    -- -------------------------------------------------------------------------
    -- nui.nvim: kept as a dependency for other plugins that may require it.
    -- -------------------------------------------------------------------------
    nui_nvim = {
        opts = {},
    },
}

-- vim: foldmethod=indent foldlevel=1
