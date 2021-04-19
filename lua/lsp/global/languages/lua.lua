local global = require('core.global')
local sumneko_root_path = global.lsp_path .. "lspinstall/lua"
local sumneko_binary = sumneko_root_path .. "/sumneko-lua-language-server"
require'lspconfig'.sumneko_lua.setup {
    cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"},
    on_attach = require'lsp.global'.common_on_attach,
    root_dir = require('lspconfig/util').root_pattern("."),
    settings = {
        Lua = {
            completion = {keywordSnippet = "Disable"},
            diagnostics = {
                globals = {"vim", "use"},
                disable = {"lowercase-global"}
            },
            runtime = {version = "LuaJIT", path = vim.split(package.path, ";")},
            workspace = {
                library = {
                    [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                    [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true
                }
            }
        }
    }
}
