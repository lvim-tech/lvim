-- LSP configuration for Kotlin
-- Uses kotlin-language-server which supports Gradle and Maven project structures.
---@module "modules.base.configs.languages.lsp.servers.kotlin"

---@type string[]  Root-directory markers covering Gradle and Maven project layouts
local root_markers = {
    "settings.gradle",
    "settings.gradle.kts",
    "build.xml", -- Maven/Ant build descriptor
    "pom.xml", -- Maven project descriptor
    "build.gradle",
    "build.gradle.kts", -- Kotlin DSL Gradle build script
}

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "kotlin",
            cmd = { "kotlin-language-server" },
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
