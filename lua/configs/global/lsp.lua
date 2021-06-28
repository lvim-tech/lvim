local global = require "core.global"
local funcs = require "core.funcs"
local cwd = vim.fn.getcwd()

local M = {}

M.init = function()


    local servers = {
        'bash', 'cpp', 'css', 'dart', 'docker', 'elixir', 'go', 'graphql', 'html', 'java', 'js-ts', 'json', 'latex', 'lua', 'omnisharp', 'php', 'python', 'ruby', 'rust', 'svelte', 'vim', 'yaml'
    }

    for _,server in ipairs(servers) do
        local settins = {
            lsp_config = "lsp.global.languages." .. server
        }
        require(settins.lsp_config)
    end

end

return M