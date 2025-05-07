local M = {}
local funcs = require("core.funcs")
local icons = require("configs.base.ui.icons")
local message = require("ui.message")
local utils = require("ui.utils")
local ui = require("ui")

M.set_ui = function()
    vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
            ui.detach()
            ui.setup({
                cmdline = {
                    styles = {
                        default = {
                            icon = { { "▌ " .. icons.common.vim2 .. "  ", "UICmdlineDefaultIcon" } },
                        },
                        search_down = {
                            icon = { { "▌ " .. icons.common.up .. "  ", "UICmdlineSearchDownIcon" } },
                        },
                        search_up = {
                            icon = { { "▌ " .. icons.common.down .. "  ", "UICmdlineSearchUpIcon" } },
                        },
                        set = {
                            icon = { { "▌ " .. icons.common.set .. "  ", "UICmdlineDefaultIcon" } },
                        },
                        shell = {
                            icon = { { "▌ " .. icons.common.symbol2 .. "  ", "UICmdlineEvalIcon" } },
                        },
                        lua = {
                            icon = { { "▌ " .. icons.common.lua .. "  ", "UICmdlineLuaIcon" } },
                        },
                        lua_eval = {
                            icon = { { "▌ " .. icons.common.eval .. "  ", "UICmdlineEvalIcon" } },
                        },
                        prompt = {
                            title = function(state)
                                local output = {}
                                local lines = utils.text_wrap({ state.prompt or "" }, math.floor(vim.o.columns * 0.8))
                                local hl = "UICmdlineLuaIcon"
                                for l, line in ipairs(lines) do
                                    local _line = {}
                                    if l == 1 then
                                        table.insert(_line, { "▌ " .. icons.common.question .. "  ", hl }) -- Changed from " ╭╴"
                                    else
                                        table.insert(_line, { "▌ " .. icons.common.question .. "  ", hl }) -- Kept the same or change if needed
                                    end
                                    table.insert(_line, { line, "Comment" })
                                    table.insert(output, _line)
                                end
                                return output
                            end,
                            icon = { { "▌ " .. icons.common.prompt .. "  ", "UICmdlineLuaIcon" } },
                        },
                    },
                },
                message = {
                    msg_styles = {
                        default = {
                            decorations = function(msg)
                                local config = {
                                    icon = {
                                        { "▌", "UIMessageDefault" },
                                    },
                                }
                                if msg.content and #msg.content == 1 then
                                    local content = msg.content[1]
                                    local hl = utils.attr_to_hl(content[3])

                                    if hl == "WarningMsg" then
                                        config.icon = {
                                            { "▌" .. icons.diagnostics.warn .. " ", "UIMessageWarnSign" },
                                        }
                                        config.padding = {
                                            { "▌  ", "UIMessageWarnSign" },
                                        }
                                        config.line_hl_group = "UIMessageWarn"
                                    elseif hl == "ErrorMsg" then
                                        config.icon = {
                                            { "▌" .. icons.diagnostics.error .. " ", "UIMessageErrorSign" },
                                        }
                                        config.padding = {
                                            { "▌  ", "UIMessageErrorSign" },
                                        }
                                        config.line_hl_group = "UIMessageError"
                                    else
                                        config.icon = {
                                            { "▌" .. icons.diagnostics.info .. " ", "UIMessageInfoSign" },
                                        }
                                        config.padding = {
                                            { "▌  ", "UIMessageInfoSign" },
                                        }
                                        config.line_hl_group = "UIMessageInfo"
                                    end
                                end

                                return config
                            end,
                        },
                        search = {
                            decorations = function(_, lines)
                                if string.match(lines[#lines], "^/") then
                                    return {
                                        icon = {
                                            { "▌" .. icons.common.down .. " ", "UICmdlineSearchUpIcon" },
                                        },
                                        padding = {
                                            { "▌  ", "UICmdlineSearchUpIcon" },
                                        },
                                        line_hl_group = "UICmdlineDefault",
                                    }
                                else
                                    return {
                                        icon = {
                                            { "▌" .. icons.common.up .. " ", "UICmdlineSearchDownIcon" },
                                        },
                                        padding = {
                                            { "▌  ", "UICmdlineSearchDownIcon" },
                                        },
                                        line_hl_group = "UICmdlineSearchDown",
                                    }
                                end
                            end,
                        },
                        write = {
                            decorations = {
                                icon = {
                                    { "▌" .. icons.common.save .. " ", "UIMessageOkIcon" },
                                },
                                padding = {
                                    { "▌  ", "UIMessageOkIcon" },
                                },
                                line_hl_group = "UIMessageOk",
                            },
                        },
                        lua_error = {
                            decorations = {
                                icon = {
                                    { "▌" .. icons.common.lua .. " ", "UIMessageErrorIcon" },
                                },
                                padding = {
                                    { "▌  ", "UIMessageErrorIcon" },
                                },
                                line_hl_group = "UIMessageError",
                            },
                        },
                    },
                    confirm_styles = {
                        default = {
                            border = "single",
                            winhl = "Normal:NormalFloat,FloatBorder:FloatBorder",
                        },
                    },
                    list_styles = {
                        default = {
                            border = "single",
                            winhl = "Normal:NormalFloat,FloatBorder:FloatBorder",
                        },
                    },
                },
            })
            vim.api.nvim_set_hl(0, "UICmdlineDefault", { bg = _G.LVIM_COLORS.blue_bh, fg = _G.LVIM_COLORS.blue })
            vim.api.nvim_set_hl(0, "UICmdlineDefaultIcon", { bg = _G.LVIM_COLORS.blue_bl, fg = _G.LVIM_COLORS.blue })
            vim.api.nvim_set_hl(0, "UICmdlineLua", { bg = _G.LVIM_COLORS.purple_bh, fg = _G.LVIM_COLORS.purple })
            vim.api.nvim_set_hl(0, "UICmdlineLuaIcon", { bg = _G.LVIM_COLORS.purple_bl, fg = _G.LVIM_COLORS.purple })
            vim.api.nvim_set_hl(0, "UICmdlineEval", { bg = _G.LVIM_COLORS.red_bh, fg = _G.LVIM_COLORS.red })
            vim.api.nvim_set_hl(0, "UICmdlineEvalIcon", { bg = _G.LVIM_COLORS.red_bl, fg = _G.LVIM_COLORS.red })
            vim.api.nvim_set_hl(0, "UICmdlineSearchUp", { bg = _G.LVIM_COLORS.blue_bh, fg = _G.LVIM_COLORS.blue })
            vim.api.nvim_set_hl(0, "UICmdlineSearchUpIcon", { bg = _G.LVIM_COLORS.blue_bl, fg = _G.LVIM_COLORS.blue })
            vim.api.nvim_set_hl(0, "UICmdlineSearchDown", { bg = _G.LVIM_COLORS.blue_bh, fg = _G.LVIM_COLORS.blue })
            vim.api.nvim_set_hl(0, "UICmdlineSearchDownIcon", { bg = _G.LVIM_COLORS.blue_bl, fg = _G.LVIM_COLORS.blue })
            vim.api.nvim_set_hl(0, "UICmdlineSubstitute", { bg = _G.LVIM_COLORS.cyan_bh, fg = _G.LVIM_COLORS.cyan })
            vim.api.nvim_set_hl(0, "UICmdlineSubstituteIcon", { bg = _G.LVIM_COLORS.cyan_bl, fg = _G.LVIM_COLORS.cyan })
            vim.api.nvim_set_hl(
                0,
                "UIMessageDefault",
                { bg = funcs.blend(_G.LVIM_COLORS.bg_dark, 0.8, "#000000"), fg = _G.LVIM_COLORS.fg }
            )
            vim.api.nvim_set_hl(0, "UIMessageOk", { bg = _G.LVIM_COLORS.green_bh, fg = _G.LVIM_COLORS.green })
            vim.api.nvim_set_hl(0, "UIMessageOkIcon", { bg = _G.LVIM_COLORS.green_bl, fg = _G.LVIM_COLORS.green })
            vim.api.nvim_set_hl(0, "UIMessageInfo", { bg = _G.LVIM_COLORS.blue_bh, fg = _G.LVIM_COLORS.blue })
            vim.api.nvim_set_hl(0, "UIMessageInfoSign", { bg = _G.LVIM_COLORS.blue_bl, fg = _G.LVIM_COLORS.blue })
            vim.api.nvim_set_hl(0, "UIMessageHint", { bg = _G.LVIM_COLORS.cyan_bh, fg = _G.LVIM_COLORS.cyan })
            vim.api.nvim_set_hl(0, "UIMessageHintSign", { bg = _G.LVIM_COLORS.cyan_bh, fg = _G.LVIM_COLORS.cyan })
            vim.api.nvim_set_hl(0, "UIMessageWarn", { bg = _G.LVIM_COLORS.orange_bh, fg = _G.LVIM_COLORS.orange })
            vim.api.nvim_set_hl(0, "UIMessageWarnSign", { bg = _G.LVIM_COLORS.orange_bh, fg = _G.LVIM_COLORS.orange })
            vim.api.nvim_set_hl(0, "UIMessageError", { bg = _G.LVIM_COLORS.red_bh, fg = _G.LVIM_COLORS.red })
            vim.api.nvim_set_hl(0, "UIMessageErrorIcon", { bg = _G.LVIM_COLORS.red_bl, fg = _G.LVIM_COLORS.red })
            vim.api.nvim_set_hl(0, "UIMessageErrorSign", { bg = _G.LVIM_COLORS.red_bh, fg = _G.LVIM_COLORS.red })
            vim.api.nvim_set_hl(
                0,
                "UIMessagePaletteSign",
                { bg = _G.LVIM_COLORS.purple_bh, fg = _G.LVIM_COLORS.purple }
            )
            vim.api.nvim_set_hl(
                0,
                "UIHistoryKeymap",
                { bg = _G.LVIM_COLORS.blue_bl, fg = _G.LVIM_COLORS.blue, bold = true }
            )
            vim.api.nvim_set_hl(0, "UIHistoryDesc", { bg = _G.LVIM_COLORS.blue_bh, fg = _G.LVIM_COLORS.blue })
            -- vim.api.nvim_create_autocmd("CmdlineLeave", {
            --     callback = function()
            --         vim.schedule(function()
            --             if package.loaded["ui.message"] then
            --                 local tab = vim.api.nvim_get_current_tabpage()
            --                 if
            --                     message.confirm_window
            --                     and message.confirm_window[tab]
            --                     and vim.api.nvim_win_is_valid(message.confirm_window[tab])
            --                 then
            --                     pcall(vim.api.nvim_win_set_config, message.confirm_window[tab], { hide = true })
            --                     vim.g.__ui_confirm_msg = nil
            --                 end
            --                 if
            --                     message.list_window
            --                     and message.list_window[tab]
            --                     and vim.api.nvim_win_is_valid(message.list_window[tab])
            --                 then
            --                     pcall(vim.api.nvim_win_set_config, message.list_window[tab], { hide = true })
            --                     vim.g.__ui_list_msg = nil
            --                 end
            --             end
            --             if package.loaded["ui.popup"] then
            --                 package.loaded["ui.popup"].__hide()
            --             end
            --             if package.loaded["ui.cmdline"] then
            --                 local cmdline = package.loaded["ui.cmdline"]
            --                 if cmdline.__hide then
            --                     cmdline.__hide()
            --                 elseif cmdline.hide then
            --                     cmdline.hide()
            --                 elseif cmdline.__status and cmdline.__status() then
            --                     local tab = vim.api.nvim_get_current_tabpage()
            --                     if
            --                         cmdline.window
            --                         and cmdline.window[tab]
            --                         and vim.api.nvim_win_is_valid(cmdline.window[tab])
            --                     then
            --                         pcall(vim.api.nvim_win_set_config, cmdline.window[tab], { hide = true })
            --                     end
            --                     if cmdline.buffer and vim.api.nvim_buf_is_valid(cmdline.buffer) then
            --                         pcall(vim.api.nvim_buf_set_lines, cmdline.buffer, 0, -1, false, {})
            --                     end
            --                 end
            --                 vim.g.__ui_cmdline_active = false
            --                 for _, flag in ipairs({ "__ui_cmdline", "__ui_cmdline_msg", "__ui_cmdline_input" }) do
            --                     if vim.g[flag] ~= nil then
            --                         vim.g[flag] = nil
            --                     end
            --                 end
            --             end
            --         end)
            --     end,
            -- })
        end,
    })
end

return M
