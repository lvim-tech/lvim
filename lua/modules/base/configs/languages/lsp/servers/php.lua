-- LSP configuration for PHP
-- Uses intelephense as the language server and php-debug-adapter (XDebug) for DAP.
-- The capabilities table is spelled out explicitly because intelephense requires
-- several non-standard capability flags to work correctly.
---@module "modules.base.configs.languages.lsp.servers.php"

---@type string[]  Root-directory markers for PHP / Composer projects
local root_markers = {
    "composer.json",
    ".git",
}

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "php",
            cmd = { "intelephense", "--stdio" },
            settings = {
                intelephense = {
                    files = {
                        maxSize = 1000000, -- max file size (bytes) indexed by intelephense
                    },
                    environment = {
                        includePaths = {}, -- additional PHP include paths (e.g. vendor stubs)
                    },
                    completion = {
                        insertUseDeclaration = true, -- auto-insert use statements
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
                        testFramework = true, -- show "Run test" lenses for PHPUnit/Pest
                    },
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
            -- Intelephense requires explicit capability declarations (does not rely
            -- on Neovim defaults). Build on top of the merged blink.cmp capabilities.
            capabilities = vim.tbl_deep_extend(
                "force",
                require("modules.base.configs.languages.lsp").get_capabilities(),
                {
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
                                valueSet = { 1, 2 }, -- 1 = Unnecessary, 2 = Deprecated
                            },
                            versionSupport = true,
                            codeDescriptionSupport = true,
                            dataSupport = true,
                        },
                        foldingRange = {
                            dynamicRegistration = false,
                            lineFoldingOnly = true, -- fold entire lines, not partial
                        },
                        callHierarchy = { dynamicRegistration = false },
                        semanticTokens = {
                            dynamicRegistration = false,
                            requests = {
                                range = true,
                                full = { delta = true }, -- incremental token updates
                            },
                            -- All standard LSP semantic token types
                            tokenTypes = {
                                "namespace",
                                "type",
                                "class",
                                "enum",
                                "interface",
                                "struct",
                                "typeParameter",
                                "parameter",
                                "variable",
                                "property",
                                "enumMember",
                                "event",
                                "function",
                                "method",
                                "macro",
                                "keyword",
                                "modifier",
                                "comment",
                                "string",
                                "number",
                                "regexp",
                                "operator",
                                "decorator",
                            },
                            tokenModifiers = {
                                "declaration",
                                "definition",
                                "readonly",
                                "static",
                                "deprecated",
                                "abstract",
                                "async",
                                "modification",
                                "documentation",
                                "defaultLibrary",
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
                }
            ),
        },
    },
    dap = {
        -- DAP: php-debug-adapter wraps XDebug via a Node.js bridge.
        adapters = {
            php = {
                type = "executable",
                command = "node",
                args = { vim.fn.stdpath("data") .. "/mason" .. "/packages/php-debug-adapter/extension/out/phpDebug.js" },
            },
        },
        configurations = {
            php = {
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
            },
        },
    },
}

-- vim: foldmethod=indent foldlevel=1
