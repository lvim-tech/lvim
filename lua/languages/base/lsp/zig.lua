-- LSP configuration for Zig
-- Uses zls (Zig Language Server) with all inlay hint categories and semantic
-- token features enabled for a full IDE experience.
---@module "languages.base.lsp.zig"

local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_installer = require("languages.lsp_installer")

---@type string[]  Mason packages required before the server can start
local lsp_dependencies = {
    "zls",
}

---@type table|nil  Populated asynchronously once Mason tools are ready
local lsp_config = nil

---@type string[]  Root-directory markers for Zig projects
local root_markers = {
    "zls.json",   -- zls configuration file
    "build.zig",  -- Zig build script (required for any Zig project)
    ".git",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    lsp_config = {
        name = "zig",
        cmd = { "zls" },
        filetypes = _G.LVIM.file_types.zig,
        settings = {
            zls = {
                enable_semantic_tokens = true,
                enable_snippets = true,
                enable_inlay_hints = true,
                -- Show types for built-in calls (e.g. @intCast) as inlay hints
                inlay_hints_show_builtin = true,
                inlay_hints_show_variable_type_hints = true,
                inlay_hints_show_parameter_name = true,
                warn_style = true,   -- warn about style violations (camelCase vs snake_case)
                enable_autofix = true,
                -- analyze_with_same_ast: reuse the parsed AST for analysis to reduce latency
                analyze_with_same_ast = true,
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
        -- Advertise codeLens capability so zls can show reference/implementation lenses
        capabilities = (function()
            local capabilities = setup_diagnostics.get_capabilities()
            capabilities.textDocument = capabilities.textDocument or {}
            capabilities.textDocument.codeLens = {
                dynamicRegistration = true,
                resolveProvider = true,
            }
            capabilities.workspace = capabilities.workspace or {}
            capabilities.workspace.codeLens = {
                refreshSupport = true,
            }
            return capabilities
        end)(),
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
