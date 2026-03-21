-- LSP configuration for CMake
-- Uses cmake-language-server (cmake-ls) with auto-format and inlay hints.
---@module "modules.base.configs.languages.lsp.servers.cmake"

---@type string[]  Root-directory markers for CMake projects
local root_markers = {
    "CMakePresets.json",
    "CTestConfig.cmake",
    ".git",
    "build", -- conventional out-of-source build directory
    "cmake", -- cmake module/helper directory
}

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "cmake",
            cmd = { "cmake-language-server" },
            init_options = {
                -- Tells cmake-ls where the compiled build artifacts live so it can
                -- parse compile_commands.json and provide accurate diagnostics.
                buildDirectory = "build",
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
