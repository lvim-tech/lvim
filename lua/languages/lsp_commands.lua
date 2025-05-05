local ui_config = require("lvim-ui-config.config")
local select = require("lvim-ui-config.select")
local funcs = require("core.funcs")
local icons = require("configs.base.ui.icons")

local function lvim_auto_format()
    local status
    if _G.LVIM_SETTINGS.autoformat == true then
        status = "Enabled"
    else
        status = "Disabled"
    end
    local opts = ui_config.select({
        "Enable",
        "Disable",
        "Cancel",
    }, { prompt = "AutoFormat (" .. status .. ")" }, {})
    select(opts, function(choice)
        if choice == "Enable" then
            _G.LVIM_SETTINGS["autoformat"] = true
            funcs.write_file(_G.global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
        elseif choice == "Disable" then
            _G.LVIM_SETTINGS["autoformat"] = false
            funcs.write_file(_G.global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
        end
    end)
end

local function lvim_inlay_hint()
    local status
    if _G.LVIM_SETTINGS.inlayhint == true then
        status = "Enabled"
    else
        status = "Disabled"
    end
    local opts = ui_config.select({
        "Enable",
        "Disable",
        "Cancel",
    }, { prompt = "InlayHint (" .. status .. ")" }, {})
    select(opts, function(choice)
        if choice == "Enable" then
            local buffers = vim.api.nvim_list_bufs()
            for _, bufnr in ipairs(buffers) do
                if vim.lsp.inlay_hint ~= nil then
                    vim.lsp.inlay_hint.enable(true, { bufnr })
                end
            end
            _G.LVIM_SETTINGS["inlayhint"] = true
            funcs.write_file(_G.global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
        elseif choice == "Disable" then
            local buffers = vim.api.nvim_list_bufs()
            for _, bufnr in ipairs(buffers) do
                if vim.lsp.inlay_hint ~= nil then
                    vim.lsp.inlay_hint.enable(false, { bufnr })
                end
            end
            _G.LVIM_SETTINGS["inlayhint"] = false
            funcs.write_file(_G.global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
        end
    end)
end

local function lvim_virtual_diagnostic()
    local virtualdiagnostic = _G.LVIM_SETTINGS.virtualdiagnostic
    local is_empty = not virtualdiagnostic or next(virtualdiagnostic) == nil
    local status
    if not virtualdiagnostic or next(virtualdiagnostic) == nil then
        status = "Disable"
    elseif virtualdiagnostic.lines == true and virtualdiagnostic.text == true then
        status = "Text and Lines"
    elseif virtualdiagnostic.text then
        status = "Only Text"
    elseif virtualdiagnostic.lines then
        status = "Only Lines"
    else
        status = "Disable"
    end
    local opts = ui_config.select({
        "Text And Lines",
        "Only Text",
        "Only Lines",
        "Disable",
        "Cancel",
    }, { prompt = "VirtualDiagnostic (" .. status .. ")" }, {})
    select(opts, function(choice)
        if choice == "Text And Lines" then
            _G.LVIM_SETTINGS["virtualdiagnostic"] = {
                text = true,
                lines = true,
            }
        elseif choice == "Only Text" then
            _G.LVIM_SETTINGS["virtualdiagnostic"] = {
                text = true,
                lines = false,
            }
        elseif choice == "Only Lines" then
            _G.LVIM_SETTINGS["virtualdiagnostic"] = {
                text = false,
                lines = true,
            }
        elseif choice == "Disable" then
            _G.LVIM_SETTINGS["virtualdiagnostic"] = {
                text = false,
                lines = false,
            }
        end
        funcs.write_file(_G.global.lvim_path .. "/.configs/lvim/config.json", _G.LVIM_SETTINGS)
        virtualdiagnostic = _G.LVIM_SETTINGS.virtualdiagnostic
        local config = vim.diagnostic.config
        config({
            virtual_text = (not is_empty and virtualdiagnostic.text) and { prefix = icons.common.dot } or false,
            virtual_lines = not is_empty and virtualdiagnostic.lines or false,
        })
    end)
end

vim.api.nvim_create_user_command("LvimVirtualDiagnostic", lvim_virtual_diagnostic, {})
vim.api.nvim_create_user_command("LvimAutoFormat", lvim_auto_format, {})
vim.api.nvim_create_user_command("LvimInlayHint", lvim_inlay_hint, {})
