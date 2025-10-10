local M = {}
local icons = require("configs.base.ui.icons")
local utils = require("ui.utils")
local ui = require("ui")

local function set_hl_groups()
    local c = _G.LVIM_COLORS
    local hl = vim.api.nvim_set_hl

    hl(0, "UICmdlineDefault", { bg = c.blue_bh, fg = c.blue })
    hl(0, "UICmdlineDefaultIcon", { bg = c.blue_bl, fg = c.blue })
    hl(0, "UICmdlineLua", { bg = c.purple_bh, fg = c.purple })
    hl(0, "UICmdlineLuaIcon", { bg = c.purple_bl, fg = c.purple })
    hl(0, "UICmdlineEval", { bg = c.red_bh, fg = c.red })
    hl(0, "UICmdlineEvalIcon", { bg = c.red_bl, fg = c.red })
    hl(0, "UICmdlineSearchUp", { bg = c.blue_bh, fg = c.blue })
    hl(0, "UICmdlineSearchUpIcon", { bg = c.blue_bl, fg = c.blue })
    hl(0, "UICmdlineSearchDown", { bg = c.blue_bh, fg = c.blue })
    hl(0, "UICmdlineSearchDownIcon", { bg = c.blue_bl, fg = c.blue })
    hl(0, "UICmdlineSubstitute", { bg = c.cyan_bh, fg = c.cyan })
    hl(0, "UICmdlineSubstituteIcon", { bg = c.cyan_bl, fg = c.cyan })
    hl(0, "UIMessageDefault", { bg = c.blue_bh, fg = c.blue })
    hl(0, "UIMessageOk", { bg = c.green_bh, fg = c.green })
    hl(0, "UIMessageOkIcon", { bg = c.green_bl, fg = c.green })
    hl(0, "UIMessageInfo", { bg = c.blue_bh, fg = c.blue })
    hl(0, "UIMessageInfoSign", { bg = c.blue_bl, fg = c.blue })
    hl(0, "UIMessageHint", { bg = c.cyan_bh, fg = c.cyan })
    hl(0, "UIMessageHintSign", { bg = c.cyan_bh, fg = c.cyan })
    hl(0, "UIMessageWarn", { bg = c.orange_bh, fg = c.orange })
    hl(0, "UIMessageWarnSign", { bg = c.orange_bh, fg = c.orange })
    hl(0, "UIMessageError", { bg = c.red_bh, fg = c.red })
    hl(0, "UIMessageErrorIcon", { bg = c.red_bl, fg = c.red })
    hl(0, "UIMessageErrorSign", { bg = c.red_bh, fg = c.red })
    hl(0, "UIMessagePalette", { bg = c.purple_bh, fg = c.purple })
    hl(0, "UIMessagePaletteSign", { bg = c.purple_bh, fg = c.purple })
    hl(0, "UIHistoryKeymap", { bg = c.blue_bl, fg = c.blue, bold = true })
    hl(0, "UIHistoryDesc", { bg = c.blue_bh, fg = c.blue })
    hl(0, "DiagnosticInfo", { fg = c.blue })
    hl(0, "DiagnosticOk", { fg = c.green })
    hl(0, "DiagnosticWarn", { fg = c.orange })
    hl(0, "DiagnosticError", { fg = c.red })
    hl(0, "DiagnosticHint", { fg = c.cyan })
end

local function close_ui_windows()
    vim.schedule(function()
        local tab = vim.api.nvim_get_current_tabpage()
        local loaded = package.loaded
        local function try_close(win)
            if win and vim.api.nvim_win_is_valid(win) then
                pcall(vim.api.nvim_win_close, win, true)
            end
        end
        local function try_delete(buf)
            if buf and vim.api.nvim_buf_is_valid(buf) then
                pcall(vim.api.nvim_buf_delete, buf, { force = true })
            end
        end

        local message = loaded["ui.message"]
        if message then
            if type(message.confirm_window) == "table" and message.confirm_window[tab] then
                try_close(message.confirm_window[tab])
                message.confirm_window[tab] = nil
                vim.g.__ui_confirm_msg = nil
            end
            if type(message.list_window) == "table" and message.list_window[tab] then
                try_close(message.list_window[tab])
                message.list_window[tab] = nil
                vim.g.__ui_list_msg = nil
            end
        end

        local popup = loaded["ui.popup"]
        if popup then
            if popup.__hide then
                popup.__hide()
            elseif popup.hide then
                popup.hide()
            elseif popup.window then
                try_close(popup.window)
                popup.window = nil
            end
            if popup.buffer then
                try_delete(popup.buffer)
                popup.buffer = nil
            end
        end

        local cmdline = loaded["ui.cmdline"]
        if cmdline then
            if cmdline.__hide then
                cmdline.__hide()
            elseif cmdline.hide then
                cmdline.hide()
            elseif cmdline.__status and cmdline.__status() then
                if type(cmdline.window) == "table" and cmdline.window[tab] then
                    try_close(cmdline.window[tab])
                    cmdline.window[tab] = nil
                end
                if cmdline.buffer then
                    try_delete(cmdline.buffer)
                    cmdline.buffer = nil
                end
            end
            vim.g.__ui_cmdline_active = false
            for _, flag in ipairs({ "__ui_cmdline", "__ui_cmdline_msg", "__ui_cmdline_input" }) do
                if vim.g[flag] ~= nil then
                    vim.g[flag] = nil
                end
            end
        end
    end)
end

M.set_ui = function()
    vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
            ui.detach()
            ui.setup({
                cmdline = {
                    styles = {
                        default = { icon = { { "▌ " .. icons.common.vim2 .. "  ", "UICmdlineDefaultIcon" } } },
                        search_down = { icon = { { "▌ " .. icons.common.up .. "  ", "UICmdlineSearchDownIcon" } } },
                        search_up = { icon = { { "▌ " .. icons.common.down .. "  ", "UICmdlineSearchUpIcon" } } },
                        set = { icon = { { "▌ " .. icons.common.set .. "  ", "UICmdlineDefaultIcon" } } },
                        shell = { icon = { { "▌ " .. icons.common.symbol2 .. "  ", "UICmdlineEvalIcon" } } },
                        lua = { icon = { { "▌ " .. icons.common.lua .. "  ", "UICmdlineLuaIcon" } } },
                        lua_eval = { icon = { { "▌ " .. icons.common.eval .. "  ", "UICmdlineEvalIcon" } } },
                        substitute = {
                            icon = function(_, lines)
                                if string.match(lines[#lines], "^s/") then
                                    return { { "▌ " .. icons.common.substitute1 .. "  ", "UICmdlineSubstituteIcon" } }
                                else
                                    return { { "▌ " .. icons.common.substitute2 .. "  ", "UICmdlineSubstituteIcon" } }
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
                    wrap_notify = false,
                    respect_replace_last = true,
                    msg_styles = {
                        default = {
                            decorations = function(msg)
                                local config = { icon = { { "▌", "UIMessageDefault" } } }
                                if msg.content and #msg.content == 1 then
                                    local content = msg.content[1]
                                    local hl = utils.attr_to_hl(content[3])
                                    if hl == "WarningMsg" then
                                        config.icon =
                                            { { "▌" .. icons.diagnostics.warn .. " ", "UIMessageWarnSign" } }
                                        config.padding = { { "▌  ", "UIMessageWarnSign" } }
                                        config.line_hl_group = "UIMessageWarn"
                                    elseif hl == "ErrorMsg" then
                                        config.icon =
                                            { { "▌" .. icons.diagnostics.error .. " ", "UIMessageErrorSign" } }
                                        config.padding = { { "▌  ", "UIMessageErrorSign" } }
                                        config.line_hl_group = "UIMessageError"
                                    else
                                        config.icon =
                                            { { "▌" .. icons.diagnostics.info .. " ", "UIMessageInfoSign" } }
                                        config.padding = { { "▌  ", "UIMessageInfoSign" } }
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
            set_hl_groups()
            vim.api.nvim_create_autocmd("CmdlineLeave", { callback = close_ui_windows })
        end,
    })
end

return M
