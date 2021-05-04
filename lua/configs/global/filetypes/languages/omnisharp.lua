vim.bo.shiftwidth = 4
vim.bo.tabstop = 4
local global = require 'core.global'
local funcs = require 'core.funcs'
local cwd = vim.fn.getcwd()

local settins = {
    lsp_config = 'lsp.global.languages.omnisharp',
    lsp_command = ':LspStart omnisharp'
}

if funcs.file_exists(cwd .. global.path_sep .. '.lvim' .. global.path_sep ..
                         'omnisharp.lua') then
    config_file = dofile(cwd .. global.path_sep .. '.lvim' .. global.path_sep ..
                             'omnisharp.lua')

    if config_file.lsp_config ~= nil then
        settins.lsp_config = config_file.lsp_config
    end

    if config_file.lsp_command ~= nil then
        settins.lsp_command = config_file.lsp_command
    end
end

require(settins.lsp_config)
vim.api.nvim_command(settins.lsp_command)
