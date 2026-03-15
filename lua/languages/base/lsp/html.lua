-- LSP configuration for HTML
-- Uses the VS Code HTML language server and prettierd via EFM for formatting.
---@module "languages.base.lsp.html"

local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_manager = require("languages.lsp_manager")
local lsp_installer = require("languages.lsp_installer")

---@type string[]  Mason packages required before the server can start
local lsp_dependencies = {
    "efm",
    "html-lsp",
    "prettierd",
}

---@type table|nil  Populated asynchronously once Mason tools are ready
local lsp_config = nil

---@type string[]  Root-directory markers for web projects
local root_markers = {
    "package.json",
    ".git",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    -- Use prettierd (daemon-mode prettier) for fast, consistent HTML formatting.
    -- Tab width of 4 matches the project-wide default; .prettierrc overrides this.
    local efm_config = {
        {
            server_name = "prettierd",
            fPrefix = "prettierd",
            formatCommand = "prettierd --tab-width=4 --stdin-filepath ${FILENAME}",
            formatStdin = true,
            rootMarkers = { ".prettierrc" },
        },
    }
    lsp_manager.setup_efm(_G.LVIM.file_types.html, efm_config)

    lsp_config = {
        name = "html",
        cmd = { "vscode-html-language-server", "--stdio" },
        filetypes = _G.LVIM.file_types.html,
        settings = {
            html = {
                -- Enable the server's built-in formatter as a fallback when prettierd is absent
                format = true,
            },
        },
        ---Called by nvim-lspconfig after the client attaches to a buffer.
        ---@param client any
        ---@param bufnr  integer
        on_attach = function(client, bufnr)
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
            if client.server_capabilities.documentSymbolProvider then
                navic.attach(client, bufnr)
            end
        end,
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
