local global = require("core.global")
local funcs = require("core.funcs")
local base_file_types = require("languages.base.ft")
local user_file_types = require("languages.user.ft")
local file_types = funcs.merge(base_file_types, user_file_types)

local M = {}

M.setup = function()
    local file_type = vim.bo.filetype
    for language, v in pairs(file_types) do
        for _, v2 in pairs(v) do
            if v2 == file_type then
                M.start_language(language)
            end
        end
    end
end

M.start_language = function(language)
    local project_root_path = vim.fn.getcwd()
    if global["languages"][language] ~= nil then
        if global["languages"][language]["project_root_path"] == project_root_path then
            return
        else
            M.pre_init_language(language, project_root_path, "global")
            M.init_language(language)
        end
    else
        M.pre_init_language(language, project_root_path, "global")
        M.init_language(language)
    end
end

M.pre_init_language = function(language, project_root_path, lsp_type)
    global["languages"][language] = {}
    global["languages"][language]["project_root_path"] = project_root_path
    global["languages"][language]["lsp_type"] = lsp_type
end

M.init_language = function(language)
    local language_configs_global = nil
    if funcs.file_exists(global.lvim_path .. "/lua/languages/user/languages/" .. language .. ".lua") then
        language_configs_global = dofile(global.lvim_path .. "/lua/languages/user/languages/" .. language .. ".lua")
    elseif funcs.file_exists(global.lvim_path .. "/lua/languages/base/languages/" .. language .. ".lua") then
        language_configs_global = dofile(global.lvim_path .. "/lua/languages/base/languages/" .. language .. ".lua")
    end
    if language_configs_global ~= nil then
        for _, func in pairs(language_configs_global) do
            if type(func) == "function" then
                func()
            end
        end
    end
end

return M
