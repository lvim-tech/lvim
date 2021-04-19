local global = require('core.global')
local sumneko_root_path = global.lsp_path .. "lspinstall/lua"
local sumneko_binary = sumneko_root_path .. "/sumneko-lua-language-server"
require'lspconfig'.sumneko_lua.setup {
    -- cmd = {
    --     sumneko_binary, "-E",
    --     sumneko_root_path .. "/sumneko-lua/extension/server/main.lua"
    -- },
    cmd = {
        global.lsp_path ..
            "lspinstall/lua/sumneko-lua/sumneko-lua-language-server", "-E",
        global.lsp_path ..
            "lspinstall/lua/sumneko-lua/extension/server/main.lua"
    },
    root_dir = require('lspconfig/util').root_pattern("."),
    on_attach = require'lsp.global'.common_on_attach,
    settings = {
        Lua = {
            runtime = {version = 'LuaJIT', path = vim.split(package.path, ';')},
            diagnostics = {globals = {'vim'}},
            workspace = {
                library = {
                    [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                    [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true
                },
                maxPreload = 10000
            }
        }
    }
}
