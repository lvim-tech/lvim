local global = require("core.global")
local sumneko_root_path = global.lsp_path .. "lspinstall/lua"
local sumneko_binary = sumneko_root_path .. "/sumneko-lua-language-server"
local lsp_settings = require("lsp.global")

require"lspconfig".sumneko_lua.setup {
    cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"},
    on_attach = function(client)
        if not packer_plugins["lsp_signature.nvim"].loaded then
            vim.cmd [[packadd lsp_signature.nvim]]
        end
        require"lsp_signature".on_attach(lsp_settings.signature_cfg)
        lsp_settings.documentHighlight(client)
    end,
    root_dir = require("lspconfig/util").root_pattern("."),
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
    },
    handlers = {
        ["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic
                                                               .on_publish_diagnostics,
                                                           lsp_settings.diagnostics_cfg)
    }
}
