-- LSP configuration for PHP
-- Uses intelephense as the language server and php-debug-adapter (XDebug) for DAP.
-- The capabilities table is spelled out explicitly because intelephense requires
-- several non-standard capability flags to work correctly.
---@module "languages.base.lsp.php"

local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_installer = require("languages.lsp_installer")
local dap = require("dap")

---@type string[]  Mason packages required before the server can start
local lsp_dependencies = {
    "intelephense",
    "php-debug-adapter",
}

---@type table|nil  Populated asynchronously once Mason tools are ready
local lsp_config = nil

---@type string[]  Root-directory markers for PHP / Composer projects
local root_markers = {
    "composer.json",
    ".git",
}

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    -- DAP: php-debug-adapter wraps XDebug via a Node.js bridge.
    -- global.mason_path refers to _G.LVIM.global.mason_path (see LvimGlobal).
    dap.adapters.php = {
        type = "executable",
        command = "node",
        args = { global.mason_path .. "/packages/php-debug-adapter/extension/out/phpDebug.js" },
    }
    ---@type table<string, any>
    dap.configurations = dap.configurations or {}
    dap.configurations.php = dap.configurations.php or {}
    dap.configurations.php = {
        {
            type = "php",
            name = "Launch",
            request = "launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${fileDirname}",
            port = function()
                local val = tonumber(vim.fn.input("Port: "))
                assert(val, "Please provide a port number")
                return val
            end,
            runtimeArgs = {
                -- Automatically trigger XDebug on every request without needing XDEBUG_TRIGGER
                "-dxdebug.start_with_request=yes",
            },
            env = {
                XDEBUG_MODE = "debug,develop",
                XDEBUG_CONFIG = "client_port=${port}",
            },
        },
    }

    lsp_config = {
        name = "php",
        cmd = { "intelephense", "--stdio" },
        filetypes = _G.LVIM.file_types.php,
        settings = {
            intelephense = {
                files = {
                    maxSize = 1000000,  -- max file size (bytes) indexed by intelephense
                },
                environment = {
                    includePaths = {},  -- additional PHP include paths (e.g. vendor stubs)
                },
                completion = {
                    insertUseDeclaration = true,          -- auto-insert use statements
                    fullyQualifyGlobalConstantsAndFunctions = false,
                    triggerParameterHints = true,
                    maxItems = 100,
                },
                format = {
                    enable = true,
                },
                codeLens = {
                    enable = true,
                    references = true,
                    implementations = true,
                    testFramework = true,  -- show "Run test" lenses for PHPUnit/Pest
                },
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
        -- Intelephense requires an explicit capabilities declaration because it
        -- does not fully rely on nvim-cmp's default capabilities object.
        -- Each section mirrors the LSP 3.17 ClientCapabilities spec.
        capabilities = {
            textDocument = {
                codeLens = {
                    dynamicRegistration = true,
                },
                -- Disable dynamic registration for formatting to prevent conflicts
                -- with other formatting providers (e.g. EFM / null-ls).
                formatting = { dynamicRegistration = false },
                documentFormatting = { dynamicRegistration = false },
                documentRangeFormatting = { dynamicRegistration = false },
                documentOnTypeFormatting = { dynamicRegistration = false },
                codeAction = {
                    dynamicRegistration = false,
                    codeActionLiteralSupport = {
                        codeActionKind = {
                            -- Full set of LSP code action kinds intelephense may emit
                            valueSet = {
                                "",
                                "quickfix",
                                "refactor",
                                "refactor.extract",
                                "refactor.inline",
                                "refactor.rewrite",
                                "source",
                                "source.organizeImports",
                            },
                        },
                    },
                    dataSupport = true,
                    resolveSupport = {
                        properties = { "edit" },
                    },
                },
                completion = {
                    dynamicRegistration = false,
                    contextSupport = true,
                    completionItem = {
                        snippetSupport = true,
                        commitCharactersSupport = true,
                        documentationFormat = { "markdown", "plaintext" },
                        deprecatedSupport = true,
                        preselectSupport = true,
                        insertReplaceSupport = true,
                        labelDetailsSupport = true,
                        resolveSupport = {
                            properties = { "documentation", "detail", "additionalTextEdits" },
                        },
                    },
                    completionItemKind = {
                        -- Advertise support for all 25 LSP completion item kinds
                        valueSet = (function()
                            local result = {}
                            for i = 1, 25 do
                                table.insert(result, i)
                            end
                            return result
                        end)(),
                    },
                },
                hover = {
                    dynamicRegistration = false,
                    contentFormat = { "markdown", "plaintext" },
                },
                declaration = { dynamicRegistration = false, linkSupport = true },
                definition = { dynamicRegistration = false, linkSupport = true },
                typeDefinition = { dynamicRegistration = false, linkSupport = true },
                implementation = { dynamicRegistration = false, linkSupport = true },
                references = { dynamicRegistration = false },
                documentSymbol = {
                    dynamicRegistration = false,
                    symbolKind = {
                        -- Advertise support for all 26 LSP document symbol kinds
                        valueSet = (function()
                            local result = {}
                            for i = 1, 26 do
                                table.insert(result, i)
                            end
                            return result
                        end)(),
                    },
                    hierarchicalDocumentSymbolSupport = true,
                },
                documentHighlight = { dynamicRegistration = false },
                signatureHelp = {
                    dynamicRegistration = false,
                    signatureInformation = {
                        documentationFormat = { "markdown", "plaintext" },
                        parameterInformation = {
                            labelOffsetSupport = true,
                        },
                        activeParameterSupport = true,
                    },
                },
                rename = { dynamicRegistration = false, prepareSupport = true },
                publishDiagnostics = {
                    dynamicRegistration = false,
                    relatedInformation = true,
                    tagSupport = {
                        valueSet = { 1, 2 },  -- 1 = Unnecessary, 2 = Deprecated
                    },
                    versionSupport = true,
                    codeDescriptionSupport = true,
                    dataSupport = true,
                },
                foldingRange = {
                    dynamicRegistration = false,
                    lineFoldingOnly = true,  -- fold entire lines, not partial
                },
                callHierarchy = { dynamicRegistration = false },
                semanticTokens = {
                    dynamicRegistration = false,
                    requests = {
                        range = true,
                        full = { delta = true },  -- incremental token updates
                    },
                    -- All standard LSP semantic token types
                    tokenTypes = {
                        "namespace", "type", "class", "enum", "interface",
                        "struct", "typeParameter", "parameter", "variable",
                        "property", "enumMember", "event", "function", "method",
                        "macro", "keyword", "modifier", "comment", "string",
                        "number", "regexp", "operator", "decorator",
                    },
                    tokenModifiers = {
                        "declaration", "definition", "readonly", "static",
                        "deprecated", "abstract", "async", "modification",
                        "documentation", "defaultLibrary",
                    },
                    formats = { "relative" },
                    overlappingTokenSupport = true,
                },
                inlayHint = {
                    dynamicRegistration = false,
                    resolveSupport = {
                        properties = { "tooltip", "textEdits", "label.tooltip", "label.location" },
                    },
                },
            },
            window = {
                showMessage = {
                    messageActionItem = { additionalPropertiesSupport = true },
                },
                workDoneProgress = true,
                showDocument = { support = true },
            },
            workspace = {
                applyEdit = true,
                workspaceEdit = {
                    documentChanges = true,
                    resourceOperations = { "create", "rename", "delete" },
                },
                didChangeConfiguration = { dynamicRegistration = false },
                didChangeWatchedFiles = {
                    dynamicRegistration = false,
                    relativePatternSupport = true,
                },
                symbol = {
                    dynamicRegistration = false,
                    symbolKind = {
                        valueSet = (function()
                            local result = {}
                            for i = 1, 26 do
                                table.insert(result, i)
                            end
                            return result
                        end)(),
                    },
                },
                executeCommand = { dynamicRegistration = false },
                workspaceFolders = true,
                configuration = true,
                semanticTokens = { refreshSupport = true },
                inlayHint = { refreshSupport = true },
                codeLens = { refreshSupport = true },
            },
            general = {
                -- Prefer UTF-16 (required by intelephense) with UTF-8 as fallback
                positionEncodings = { "utf-16", "utf-8" },
            },
        },
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
