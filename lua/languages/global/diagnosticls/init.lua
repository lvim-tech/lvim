local languages_setup = require("languages.global.utils")
local nvim_lsp_util = require("lspconfig/util")
local default_debouce_time = 150

local M = {}

M.config = {
    lsp_filetypes = {
        "css",
        "scss",
        "less",
        "javascript",
        "typescript",
        "javascriptreact",
        "typescriptreact",
        "html",
        "json",
        "c",
        "cpp",
        "objc",
        "objcpp",
        -- "dart",
        "go",
        "lua",
        "markdown",
        "php",
        "python",
        -- "rust",
        "sh",
        "vim",
        "vue"
    },
    linters_filetypes = {
        css = "stylelint",
        scss = "stylelint",
        less = "stylelint",
        javascript = "eslint",
        typescript = "eslint",
        javascriptreact = "eslint",
        typescriptreact = "eslint",
        vue = "eslint",
        html = "tidy",
        c = "cpplint",
        cpp = "cpplint",
        objc = "cpplint",
        objcpp = "cpplint",
        go = "golangcilint",
        lua = "luacheck",
        php = "phpstan",
        python = "pylint",
        vim = "vint",
        sh = "shellcheck"
    },
    linters = {
        --- css, scss, less
        -- https://github.com/stylelint/stylelint
        -- https://github.com/bjankord/stylelint-config-sass-guidelines
        -- INSTALL: npm install -g stylelint stylelint-config-sass-guidelines
        stylelint = {
            sourceName = "stylelint",
            command = "stylelint",
            rootPatterns = {".stylelintrc", ".stylelintrc.json"},
            debounce = 100,
            args = {
                "--formatter",
                "json",
                "--stdin-filename",
                "%filepath"
            },
            parseJson = {
                errorsRoot = "[0].warnings",
                line = "line",
                column = "column",
                message = "${text}",
                security = "severity"
            },
            securities = {
                error = "error",
                warning = "warning"
            }
        },
        -- javascript, typescript, javascriptreact, typescriptreact
        -- https://github.com/eslint/eslint
        -- https://eslint.org
        -- INSTALL: npm install -g eslint
        eslint = {
            sourceName = "eslint",
            command = "eslint",
            rootPatterns = {".eslintrc", ".eslintrc.js", ".package.json"},
            debounce = 100,
            args = {
                "--stdin",
                "--stdin-filename",
                "%filepath",
                "--format",
                "json"
            },
            parseJson = {
                errorsRoot = "[0].messages",
                line = "line",
                column = "column",
                endLine = "endLine",
                endColumn = "endColumn",
                message = "${message} [${ruleId}]",
                security = "severity"
            },
            securities = {
                [1] = "error",
                [2] = "warning"
            }
        },
        --- html
        -- https://github.com/htacg/tidy-html5
        -- https://www.html-tidy.org
        -- INSTALL INSTRUCTION: see instruction
        tidy = {
            sourceName = "tidy",
            command = "tidy",
            args = {"-e", "-q"},
            rootPatterns = {"tidy.txt"},
            isStderr = true,
            debounce = 100,
            offsetLine = 0,
            offsetColumn = 0,
            formatLines = 1,
            formatPattern = {
                "^.*?(\\d+).*?(\\d+)\\s+-\\s+([^:]+):\\s+(.*)(\\r|\\n)*$",
                {
                    line = 1,
                    column = 2,
                    endLine = 1,
                    endColumn = 2,
                    message = 4,
                    security = 3
                }
            },
            securities = {
                [1] = "error",
                [2] = "warning"
            }
        },
        -- c, cpp, objc, objcpp
        -- https://github.com/cpplint/cpplint
        -- INSTALL: pip3 install cpplint
        cpplint = {
            command = "cpplint",
            sourceName = "cpplint",
            args = {"%file"},
            rootPatterns = {"CPPLINT.cfg"},
            debounce = 100,
            isStderr = true,
            isStdout = false,
            offsetLine = 0,
            offsetColumn = 0,
            formatPattern = {
                "^[^:]+:(\\d+):(\\d+)?\\s+([^:]+?)\\s\\[(\\d)\\]$",
                {
                    line = 1,
                    column = 2,
                    message = 3,
                    security = 4
                }
            }
        },
        -- go
        -- https://github.com/golangci/golangci-lint
        -- https://golangci-lint.run
        -- INSTALL INSTRUCTION: https://golangci-lint.run/usage/install/#local-installation
        golangcilint = {
            command = "golangci-lint",
            rootPatterns = {".golangci.yml", ".golangci.yaml", ".golangci.toml", ".golangci.json"},
            debounce = 100,
            args = {"run", "--out-format", "json"},
            sourceName = "golangci-lint",
            parseJson = {
                sourceName = "Pos.Filename",
                sourceNameFilter = true,
                errorsRoot = "Issues",
                line = "Pos.Line",
                column = "Pos.Column",
                message = "${Text} [${FromLinter}]"
            }
        },
        -- lua
        -- https://github.com/mpeterv/luacheck
        -- https://luacheck.readthedocs.io/en/stable
        -- INSTALL: luarocks install luacheck
        luacheck = {
            sourceName = "luacheck",
            command = "luacheck",
            args = {
                "--formatter",
                "plain",
                "--codes",
                "--ranges",
                "--filename",
                "%filepath",
                "-"
            },
            rootPatterns = {".luacheckrc"},
            formatPattern = {
                "^[^:]+:(\\d+):(\\d+)-(\\d+):\\s+\\((\\w)\\d+\\)\\s+(.*)$",
                {
                    line = 1,
                    column = 2,
                    endLine = 1,
                    endColumn = 3,
                    security = 4,
                    message = 5
                }
            },
            debounce = 100,
            securities = {
                W = "warning",
                E = "error"
            }
        },
        -- php
        -- https://github.com/phpstan/phpstan
        -- https://phpstan.org
        -- INSTALL INSTRUCTION: https://phpstan.org/user-guide/getting-started
        -- INSTALL: composer require --dev phpstan/phpstan
        phpstan = {
            sourceName = "phpstan",
            command = "vendor/bin/phpstan",
            debounce = 100,
            rootPatterns = {"composer.json", "composer.lock", "vendor"},
            args = {
                "analyze",
                "--error-format",
                "raw",
                "--no-progress",
                "%file"
            },
            offsetLine = 0,
            offsetColumn = 0,
            formatLines = 1,
            formatPattern = {
                "^[^:]+:(\\d+):(.*)(\\r|\\n)*$",
                {
                    line = 1,
                    message = 2
                }
            }
        },
        -- python
        -- https://github.com/PyCQA/pylint
        -- https://pylint.org
        -- INSTALL: pip3 install pylint
        pylint = {
            sourceName = "pylint",
            command = "pylint",
            rootPatterns = {".pylintrc"},
            debounce = 100,
            args = {
                "--output-format",
                "text",
                "--score",
                "no",
                "--msg-template",
                "'{line}:{column}:{category}:{msg} ({msg_id}:{symbol})'",
                "%file"
            },
            formatPattern = {
                "^(\\d+?):(\\d+?):([a-z]+?):(.*)$",
                {
                    line = 1,
                    column = 2,
                    security = 3,
                    message = 4
                }
            },
            securities = {
                informational = "hint",
                refactor = "info",
                convention = "info",
                warning = "warning",
                error = "error",
                fatal = "error"
            },
            offsetColumn = 1,
            formatLines = 1
        },
        -- vim
        -- https://github.com/Vimjas/vint
        -- INSTALL: pip3 install vim-vint
        vint = {
            sourceName = "vint",
            command = "vint",
            rootPatterns = {".vintrc.yaml"},
            debounce = 100,
            args = {"--enable-neovim", "-"},
            offsetLine = 0,
            offsetColumn = 0,
            formatLines = 1,
            formatPattern = {
                "[^:]+:(\\d+):(\\d+):\\s*(.*)(\\r|\\n)*$",
                {
                    line = 1,
                    column = 2,
                    message = 3
                }
            }
        },
        -- sh
        -- https://github.com/koalaman/shellcheck
        -- INSTALL INSTRUCTION: https://github.com/koalaman/shellcheck#installing
        shellcheck = {
            command = "shellcheck",
            debounce = 100,
            args = {
                "--format",
                "json",
                "-"
            },
            sourceName = "shellcheck",
            parseJson = {
                line = "line",
                column = "column",
                endLine = "endLine",
                endColumn = "endColumn",
                message = "${message} [${code}]",
                security = "level"
            },
            securities = {
                error = "error",
                warning = "warning",
                info = "info",
                style = "hint"
            }
        }
    },
    format_filetypes = {
        css = "stylelint",
        scss = "stylelint",
        less = "stylelint",
        html = "prettier",
        json = "prettier",
        -- dart = "dartfmt",
        -- go = "gofmt",
        javascript = "prettier",
        typescript = "prettier",
        javascriptreact = "prettier",
        typescriptreact = "prettier",
        vue = "prettier",
        lua = "luafmt",
        markdown = "prettier",
        python = "autopep8",
        vim = "prettier",
        sh = "shfmt"
    },
    formatters = {
        --- css, scss, less
        -- https://github.com/stylelint/stylelint
        -- https://github.com/bjankord/stylelint-config-sass-guidelines
        -- INSTALL: npm install -g stylelint stylelint-config-sass-guidelines
        stylelint = {
            command = "stylelint",
            rootPatterns = {".stylelintrc", ".stylelintrc.json"},
            args = {
                "--fix"
            },
            isStderr = false,
            isStdout = true
        },
        -- javascript, typescript, javascriptreact, typescriptreact
        -- https://prettier.io
        -- INSTALL: npm install -g prettier
        prettier = {
            command = "prettier",
            args = {"--stdin-filepath", "%filepath", "--single-quote", "--tab-width=4"},
            rootPatterns = {},
            isStdout = true,
            isStderr = false,
            doesWriteToFile = false
        },
        -- dart
        -- https://github.com/dart-lang/dart_style
        -- INSTALL: see instruction
        dartfmt = {
            command = "dartfmt",
            args = {"--fix"}
        },
        -- go
        -- https://pkg.go.dev/cmd/gofmt
        -- INSTALL: see instruction
        gofmt = {
            command = "gofmt",
            args = {"-s"}
        },
        -- lua
        -- https://github.com/trixnz/lua-fmt
        -- INSTALL: npm install -g lua-fmt
        luafmt = {
            command = "luafmt",
            args = {"--indent-count", 4, "--stdin"},
            isStdout = true,
            isStderr = false,
            doesWriteToFile = false
        },
        -- ================================================================== --
        -- php
        -- intelephense support format
        -- https://intelephense.com/
        -- ================================================================== --
        -- python
        -- https://github.com/hhatto/autopep8
        -- https://pypi.org/project/autopep8
        -- INSTALL: pip3 install autopep8
        autopep8 = {
            command = "autopep8",
            args = {"-", "--indent-size=4"}
        },
        -- sh
        -- https://github.com/mvdan/sh
        -- INSTALL: go install mvdan.cc/sh/v3/cmd/shfmt@latest
        shfmt = {
            command = "shfmt"
        }
    }
}

function M.init_diagnosticls()
    local function start_diagnosticls(server)
        server:setup {
            flags = {
                debounce_text_changes = default_debouce_time
            },
            autostart = true,
            filetypes = M.config.lsp_filetypes,
            on_attach = function(client)
                if client.resolved_capabilities.document_formatting then
                    vim.api.nvim_exec(
                        [[
                            augroup LspAutocommands
                                autocmd! * <buffer>
                                autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync()
                            augroup END
                        ]],
                        true
                    )
                end
            end,
            init_options = {
                filetypes = M.config.linters_filetypes,
                linters = M.config.linters,
                formatFiletypes = M.config.format_filetypes,
                formatters = M.config.formatters
            },
            root_dir = function(fname)
                return nvim_lsp_util.find_git_ancestor(fname) or vim.fn.getcwd()
            end
        }
    end
    languages_setup.setup_lsp("diagnosticls", start_diagnosticls)
end

return M
