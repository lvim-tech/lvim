-- LSP configuration for Scala
-- Uses nvim-metals (Scala Metals client) instead of the standard lspconfig
-- pattern. Metals manages its own lifecycle; config is a function that
-- initializes Metals and returns nil to signal lvim-lsp not to start a
-- separate server.
---@module "modules.base.configs.languages.lsp.servers.scala"

---@type string[]  Root-directory markers for Scala / sbt / Mill / Gradle projects
local root_markers = {
    "build.sbt",
    "build.sc",
    "build.gradle",
    "build.gradle.kts",
    ".metals",
    ".git",
}

return {
    lsp = {
        root_patterns = root_markers,
        -- config is a function: Metals manages its own lifecycle.
        -- Returning nil tells lvim-lsp not to start a separate server.
        config = function()
            local metals = require("metals")
            local metals_config = metals.bare_config()

            metals_config.settings = {
                showImplicitArguments = true,
            }

            metals_config.on_attach = function(client, bufnr)
                metals.setup_dap()
                if client.server_capabilities.documentSymbolProvider then
                    require("nvim-navic").attach(client, bufnr)
                end
            end

            require("dap").configurations.scala = {
                {
                    type = "scala",
                    request = "launch",
                    name = "RunOrTest",
                    metals = { runType = "runOrTestFile" },
                },
                {
                    type = "scala",
                    request = "launch",
                    name = "Test Target",
                    metals = { runType = "testTarget" },
                },
            }

            metals.initialize_or_attach(metals_config)
            return nil
        end,
    },
}

-- vim: foldmethod=indent foldlevel=1
