-- LSP configuration for LaTeX / BibTeX
-- Uses texlab as the language server with latexmk as the build backend
-- and latexindent for formatting.
---@module "languages.base.lsp.latex"

local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_installer = require("languages.lsp_installer")

---@type string[]  Mason packages required before the server can start
local lsp_dependencies = {
    "texlab",
}

---@type table|nil  Populated asynchronously once Mason tools are ready
local lsp_config = nil

---@type string[]  Root-directory markers for LaTeX projects
local root_markers = {
    ".latexmkrc",     -- latexmk configuration file
    ".texlabroot",    -- explicit texlab root marker
    "texlabroot",
    "Tectonic.toml",  -- Tectonic build system configuration
    ".git",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    lsp_config = {
        name = "latex",
        cmd = { "texlab" },
        filetypes = _G.LVIM.file_types.latex,
        settings = {
            texlab = {
                rootDirectory = nil,  -- auto-detect from root markers above
                build = {
                    executable = "latexmk",
                    -- -pdf: produce PDF; -interaction=nonstopmode: don't stop on errors;
                    -- -synctex=1: generate SyncTeX data for forward/inverse search
                    args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
                    onSave = false,             -- manual build; set true to build on every save
                    forwardSearchAfter = false, -- don't jump to PDF position after build
                },
                forwardSearch = {
                    executable = nil,  -- set to e.g. "zathura" for PDF forward search
                    args = {},
                },
                chktex = {
                    onOpenAndSave = false,  -- chktex linting is opt-in (can be slow)
                    onEdit = false,
                },
                diagnosticsDelay = 300,       -- ms to wait after typing before re-checking
                latexFormatter = "latexindent",
                latexindent = {
                    ["local"] = nil,           -- path to a local latexindent settings file
                    modifyLineBreaks = false,  -- preserve original line break positions
                },
                bibtexFormatter = "texlab",   -- use texlab's built-in BibTeX formatter
                formatterLineLength = 80,
            },
        },
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
