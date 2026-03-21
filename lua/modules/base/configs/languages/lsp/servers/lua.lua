-- LSP configuration for Lua
-- Uses lua-language-server (LuaLS) with the Neovim runtime in the workspace
-- library, stylua via EFM for formatting, and the nlua DAP adapter for
-- attaching to a running Neovim instance (Osyris / one.nvim workflow).
---@module "modules.base.configs.languages.lsp.servers.lua"
local ft = require("modules.base.configs.languages.lsp.file_types")

---@type string[]  Root-directory markers for Lua/Neovim config projects
local root_markers = {
    ".luarc.json",
    ".luarc.jsonc",
    ".luacheckrc",
    ".stylua.toml",
    "stylua.toml",
    "selene.toml",
    "selene.yml",
    ".git",
}

-- stylua reads from stdin (-) and writes formatted output to stdout.
local efm_config = {
    {
        server_name = "stylua",
        formatCommand = "stylua -",
        formatStdin = true,
        rootMarkers = { "stylua.toml", ".stylua.toml" },
    },
}

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "lua",
            cmd = { "lua-language-server" },
            settings = {
                Lua = {
                    runtime = {
                        version = "LuaJIT",
                        special = { reload = "require" },
                    },
                    workspace = {
                        library = {
                            vim.fn.expand("$VIMRUNTIME/lua"),
                            vim.fn.expand("~/.config/nvim"),
                        },
                        maxPreload = 2000,
                        preloadFileSize = 150,
                        ignoreDir = { ".git", "node_modules", ".cache" },
                        checkThirdParty = false,
                    },
                    diagnostics = {
                        globals = { "vim", "use", "packer_plugins", "NOREF_NOERR_TRUNC" },
                        workspaceDelay = 1000,
                        workspaceEvent = "OnSave",
                        workspaceRate = 100,
                        unusedLocalExclude = { "_*" },
                    },
                    hint = {
                        enable = true,
                        arrayIndex = "Enable",
                        await = true,
                        paramName = "All",
                        paramType = true,
                        semicolon = "Disable",
                        setType = true,
                    },
                    completion = {
                        callSnippet = "Replace",
                        workspaceWord = false,
                        showWord = "Disable",
                    },
                    hover = {
                        expandAlias = true,
                    },
                    semantic = {
                        enable = true,
                    },
                    codeLens = {
                        enable = true,
                    },
                    format = { enable = false },
                    telemetry = { enable = false },
                },
            },
            on_attach = function(client, bufnr)
                if client.server_capabilities.documentSymbolProvider then
                    require("nvim-navic").attach(client, bufnr)
                end
            end,
        },
    },

    schema = {
        {
            section = "Inlay Hints",
            fields = {
                { key = "Lua.hint.enable", type = "bool", label = "Enable" },
                {
                    key = "Lua.hint.paramName",
                    type = "select",
                    label = "Param Name",
                    options = { "All", "Literal", "Disable" },
                },
                { key = "Lua.hint.paramType", type = "bool", label = "Param Type" },
                {
                    key = "Lua.hint.arrayIndex",
                    type = "select",
                    label = "Array Index",
                    options = { "Enable", "Auto", "Disable" },
                },
                { key = "Lua.hint.await", type = "bool", label = "Await" },
                { key = "Lua.hint.setType", type = "bool", label = "Set Type" },
                {
                    key = "Lua.hint.semicolon",
                    type = "select",
                    label = "Semicolon",
                    options = { "All", "SameLine", "Disable" },
                },
            },
        },
        {
            section = "Completion",
            fields = {
                {
                    key = "Lua.completion.callSnippet",
                    type = "select",
                    label = "Call Snippet",
                    options = { "Disable", "Both", "Replace" },
                },
                { key = "Lua.completion.workspaceWord", type = "bool", label = "Workspace Word" },
                {
                    key = "Lua.completion.showWord",
                    type = "select",
                    label = "Show Word",
                    options = { "Enable", "Fallback", "Disable" },
                },
            },
        },
        {
            section = "Diagnostics",
            fields = {
                { key = "Lua.diagnostics.globals", type = "list", label = "Globals" },
                { key = "Lua.diagnostics.disable", type = "list", label = "Disabled Codes" },
                { key = "Lua.diagnostics.unusedLocalExclude", type = "list", label = "Unused Local Exclude" },
                { key = "Lua.diagnostics.workspaceDelay", type = "number", label = "Workspace Delay (ms)" },
                {
                    key = "Lua.diagnostics.workspaceEvent",
                    type = "select",
                    label = "Workspace Event",
                    options = { "OnChange", "OnSave", "None" },
                },
                { key = "Lua.diagnostics.workspaceRate", type = "number", label = "Workspace Rate (%)" },
            },
        },
        {
            section = "Hover",
            fields = {
                { key = "Lua.hover.expandAlias", type = "bool", label = "Expand Alias" },
                { key = "Lua.hover.enumsLimit", type = "number", label = "Enums Limit" },
                { key = "Lua.hover.previewFields", type = "number", label = "Preview Fields" },
            },
        },
        {
            section = "Semantic",
            fields = {
                { key = "Lua.semantic.enable", type = "bool", label = "Enable" },
                { key = "Lua.semantic.variable", type = "bool", label = "Variable" },
                { key = "Lua.semantic.annotation", type = "bool", label = "Annotation" },
                { key = "Lua.semantic.keyword", type = "bool", label = "Keyword" },
            },
        },
        {
            section = "Code Lens",
            fields = {
                { key = "Lua.codeLens.enable", type = "bool", label = "Enable" },
            },
        },
        {
            section = "Workspace",
            fields = {
                { key = "Lua.workspace.maxPreload", type = "number", label = "Max Preload" },
                { key = "Lua.workspace.preloadFileSize", type = "number", label = "Preload File Size (KB)" },
                { key = "Lua.workspace.checkThirdParty", type = "bool", label = "Check Third Party" },
                { key = "Lua.workspace.ignoreDir", type = "list", label = "Ignore Dirs" },
                { key = "Lua.workspace.library", type = "list", label = "Library Paths" },
            },
        },
        {
            section = "Runtime",
            fields = {
                {
                    key = "Lua.runtime.version",
                    type = "select",
                    label = "Version",
                    options = { "LuaJIT", "Lua 5.1", "Lua 5.2", "Lua 5.3", "Lua 5.4", "Lua 5.5" },
                },
                { key = "Lua.runtime.special.reload", type = "string", label = "Special: reload" },
            },
        },
        {
            section = "Format",
            fields = {
                { key = "Lua.format.enable", type = "bool", label = "Enable" },
            },
        },
        {
            section = "Telemetry",
            fields = {
                { key = "Lua.telemetry.enable", type = "bool", label = "Enable" },
            },
        },
    },

    efm = {
        filetypes = ft.lua.filetypes,
        tools = efm_config,
    },

    dap = {
        adapters = {
            nlua = function(callback, config)
                callback({ type = "server", host = config.host, port = config.port })
            end,
        },
        configurations = {
            lua = {
                {
                    type = "nlua",
                    request = "attach",
                    name = "Attach to running Neovim instance",
                    host = function()
                        local value = vim.fn.input("Host [127.0.0.1]: ")
                        return value ~= "" and value or "127.0.0.1"
                    end,
                    port = function()
                        local input = vim.fn.input("Port [8086]: ")
                        if input == "" then
                            return 8086
                        end
                        local value = tonumber(input)
                        if not value then
                            vim.notify("Invalid port number, using default 8086", vim.log.levels.WARN)
                            return 8086
                        end
                        return value
                    end,
                },
            },
        },
    },
}

-- vim: foldmethod=indent foldlevel=1
