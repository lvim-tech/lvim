-- LSP configuration for LaTeX / BibTeX
-- Uses texlab as the language server with latexmk as the build backend
-- and latexindent for formatting.
---@module "modules.base.configs.languages.lsp.servers.latex"

---@type string[]  Root-directory markers for LaTeX projects
local root_markers = {
    ".latexmkrc", -- latexmk configuration file
    ".texlabroot", -- explicit texlab root marker
    "texlabroot",
    "Tectonic.toml", -- Tectonic build system configuration
    ".git",
}

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "latex",
            cmd = { "texlab" },
            settings = {
                texlab = {
                    rootDirectory = nil, -- auto-detect from root markers above
                    build = {
                        executable = "latexmk",
                        -- -pdf: produce PDF; -interaction=nonstopmode: don't stop on errors;
                        -- -synctex=1: generate SyncTeX data for forward/inverse search
                        args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
                        onSave = false, -- manual build; set true to build on every save
                        forwardSearchAfter = false, -- don't jump to PDF position after build
                    },
                    forwardSearch = {
                        executable = nil, -- set to e.g. "zathura" for PDF forward search
                        args = {},
                    },
                    chktex = {
                        onOpenAndSave = false, -- chktex linting is opt-in (can be slow)
                        onEdit = false,
                    },
                    diagnosticsDelay = 300, -- ms to wait after typing before re-checking
                    latexFormatter = "latexindent",
                    latexindent = {
                        ["local"] = nil, -- path to a local latexindent settings file
                        modifyLineBreaks = false, -- preserve original line break positions
                    },
                    bibtexFormatter = "texlab", -- use texlab's built-in BibTeX formatter
                    formatterLineLength = 80,
                },
            },
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
