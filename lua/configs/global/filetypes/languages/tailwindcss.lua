local global = require 'core.global'
local funcs = require 'core.funcs'
local cwd = vim.fn.getcwd()
-- local dap = require 'dap'

local settins = {
    dap_adapter = {
        --
    },
    dap_configuration = {
        --
    },
    lsp_config = 'lsp.global.languages.tailwindcss',
    lsp_command = ':LspStart tailwindcss'
}

if funcs.file_exists(cwd .. global.path_sep .. "tailwindcss.lua") then
    config_file = dofile(cwd .. global.path_sep .. "tailwindcss.lua")
    -- if config_file.dap_adapter ~= nil then
    --     settins.dap_adapter = config_file.dap_adapter
    -- end

    -- if config_file.dap_configuration ~= nil then
    --     settins.dap_configuration = config_file.dap_configuration
    -- end

    if config_file.lsp_config ~= nil then
        settins.lsp_config = config_file.lsp_config
    end

    if config_file.lsp_command ~= nil then
        settins.lsp_command = config_file.lsp_command
    end
end

-- dap.adapters.name-of-language = settins.dap_adapter
-- dap.configurations.name-of-language = {settins.dap_configuration}

require(settins.lsp_config)
vim.api.nvim_command(settins.lsp_command)

