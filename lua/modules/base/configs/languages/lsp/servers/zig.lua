-- LSP configuration for Zig
-- Uses zls (Zig Language Server) with all inlay hint categories and semantic
-- token features enabled for a full IDE experience.
---@module "modules.base.configs.languages.lsp.servers.zig"

---@type string[]  Root-directory markers for Zig projects
local root_markers = {
    "zls.json", -- zls configuration file
    "build.zig", -- Zig build script (required for any Zig project)
    ".git",
}

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "zig",
            cmd = { "zls" },
            settings = {
                zls = {
                    enable_semantic_tokens = true,
                    enable_snippets = true,
                    enable_inlay_hints = true,
                    -- Show types for built-in calls (e.g. @intCast) as inlay hints
                    inlay_hints_show_builtin = true,
                    inlay_hints_show_variable_type_hints = true,
                    inlay_hints_show_parameter_name = true,
                    warn_style = true, -- warn about style violations (camelCase vs snake_case)
                    enable_autofix = true,
                    -- analyze_with_same_ast: reuse the parsed AST for analysis to reduce latency
                    analyze_with_same_ast = true,
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
