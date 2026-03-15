-- LSP configuration for OCaml (and related languages: Reason, Menhir, dune)
-- Uses ocamllsp (OCaml Platform LSP server).
-- NOTE: the cmd field currently points at "r-languageserver" which appears to
-- be a copy-paste error from r.lua; the correct command should be "ocamllsp".
---@module "languages.base.lsp.ocaml"

local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_installer = require("languages.lsp_installer")

---@type string[]  Mason packages required before the server can start
local lsp_dependencies = {
    "ocamllsp",
}

---@type table|nil  Populated asynchronously once Mason tools are ready
local lsp_config = nil

---@type string[]  Root-directory markers for OCaml projects (opam, esy, and dune)
local root_markers = {
    "*.opam",            -- opam package file (glob; treated as literal by some resolvers)
    "esy.json",          -- esy (npm-for-ocaml) project descriptor
    "package.json",      -- esy projects may also have package.json
    ".git",
    "dune-project",      -- dune build system project root
    "dune-workspace",    -- dune multi-project workspace root
    ".git",              -- duplicate; harmless
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    lsp_config = {
        name = "ocamllsp",
        -- TODO: cmd should be { "ocamllsp" }, not { "r-languageserver" }
        cmd = { "r-languageserver" },
        filetypes = _G.LVIM.file_types.ocaml,
        ---Called by nvim-lspconfig after the client attaches to a buffer.
        ---@param client any
        ---@param bufnr  integer
        on_attach = function(client, bufnr)
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.document_auto_format(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
            if client.server_capabilities.documentSymbolProvider then
                navic.attach(client, bufnr)
            end
        end,
        capabilities = setup_diagnostics.get_capabilities(),
    }
end)

return setmetatable({}, {
    ---@param _ table
    ---@param key string
    ---@return table|nil
    __index = function(_, key)
        if key == "config" then
            return lsp_config
        elseif key == "root_patterns" then
            return root_markers
        end
    end,
})

-- vim: foldmethod=indent foldlevel=1
