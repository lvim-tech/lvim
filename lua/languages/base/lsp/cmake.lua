-- LSP configuration for CMake
-- Uses cmake-language-server (cmake-ls) with auto-format and inlay hints.
---@module "languages.base.lsp.cmake"

local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_installer = require("languages.lsp_installer")

---@type string[]  Mason packages required before the server can start
local lsp_dependencies = {
    "cmake-language-server",
}

---@type table|nil  Populated asynchronously once Mason tools are ready
local lsp_config = nil

---@type string[]  Root-directory markers for CMake projects
local root_markers = {
    "CMakePresets.json",
    "CTestConfig.cmake",
    ".git",
    "build",   -- conventional out-of-source build directory
    "cmake",   -- cmake module/helper directory
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    lsp_config = {
        name = "cmake",
        cmd = { "cmake-language-server" },
        filetypes = _G.LVIM.file_types.cmake,
        init_options = {
            -- Tells cmake-ls where the compiled build artifacts live so it can
            -- parse compile_commands.json and provide accurate diagnostics.
            buildDirectory = "build",
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
