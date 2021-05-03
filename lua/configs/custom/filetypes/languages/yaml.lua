vim.bo.shiftwidth = 2
vim.bo.tabstop = 2
local global = require 'core.global'
local funcs = require 'core.funcs'
local cwd = vim.fn.getcwd()

local settins = {
    lsp_config = 'lsp.custom.languages.yaml',
    lsp_command = ':LspStart yamlls'
}

if funcs.file_exists(cwd .. global.path_sep .. '.lvim' .. global.path_sep ..
                         'yaml.lua') then
    config_file = dofile(cwd .. global.path_sep .. '.lvim' .. global.path_sep ..
                             'yaml.lua')

    if config_file.lsp_config ~= nil then
        settins.lsp_config = config_file.lsp_config
    end

    if config_file.lsp_command ~= nil then
        settins.lsp_command = config_file.lsp_command
    end
end

require(settins.lsp_config)
vim.api.nvim_command(settins.lsp_command)
