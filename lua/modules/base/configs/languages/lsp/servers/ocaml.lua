-- LSP configuration for OCaml (and related languages: Reason, Menhir, dune)
-- Uses ocamllsp (OCaml Platform LSP server).
---@module "modules.base.configs.languages.lsp.servers.ocaml"

---@type string[]  Root-directory markers for OCaml projects (opam, esy, and dune)
local root_markers = {
    "*.opam", -- opam package file (glob; treated as literal by some resolvers)
    "esy.json", -- esy (npm-for-ocaml) project descriptor
    "package.json", -- esy projects may also have package.json
    ".git",
    "dune-project", -- dune build system project root
    "dune-workspace", -- dune multi-project workspace root
}

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "ocamllsp",
            cmd = { "ocamllsp" },
            ---Called by nvim-lspconfig after the client attaches to a buffer.
            ---@param client any
            ---@param bufnr  integer
            on_attach = function(client, bufnr)
                if client.server_capabilities.documentSymbolProvider then
                    require("nvim-navic").attach(client, bufnr)
                end
            end,
        },
    },
}

-- vim: foldmethod=indent foldlevel=1
