-- LSP configuration for Markdown / MDX
-- Uses marksman for link checking and outline navigation.
-- prettierd and cbfmt are registered via EFM: prettierd formats prose,
-- while cbfmt formats fenced code blocks using per-language formatters.
---@module "languages.base.lsp.markdown"

local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_manager = require("languages.lsp_manager")
local lsp_installer = require("languages.lsp_installer")

---@type string[]  Mason packages required before the server can start
local lsp_dependencies = {
    "efm",
    "marksman",
    "prettierd",
    "cbfmt",
}

---@type table|nil  Populated asynchronously once Mason tools are ready
local lsp_config = nil

---@type string[]  Root-directory markers for documentation repositories
local root_markers = {
    ".marksman.toml",
    ".git",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    local efm_config = {
        {
            server_name = "prettierd",
            fPrefix = "prettierd",
            formatCommand = "prettierd --tab-width=4 --stdin-filepath ${FILENAME}",
            formatStdin = true,
            rootMarkers = { ".prettierrc" },
        },
        {
            server_name = "cbfmt",
            fPrefix = "cbfmt",
            -- --best-effort: continue formatting even when a code-block language is unknown
            formatCommand = "cbfmt --stdin-filepath ${FILENAME} --best-effort",
            formatStdin = true,
            rootMarkers = { ".cbfmt.toml" },
        },
    }
    lsp_manager.setup_efm(_G.LVIM.file_types.markdown, efm_config)

    lsp_config = {
        name = "markdown",
        -- marksman requires "server" sub-command to start in server mode
        cmd = { "marksman", "server" },
        filetypes = _G.LVIM.file_types.markdown,
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
