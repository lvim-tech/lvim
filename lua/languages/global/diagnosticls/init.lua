local languages_setup = require("languages.global.utils")
local nvim_lsp_util = require("lspconfig/util")
local default_debouce_time = 150

local M = {}

M.config = {
    lsp_filetypes = {
        "html",
        "json",
        "c",
        "cpp",
        "objc",
        "objcpp",
        "less",
        "lua",
        "markdown",
        "python",
        "sh",
        "vim",
    },
    linters_filetypes = {
        html = "tidy",
        c = "cpplint",
        cpp = "cpplint",
        objc = "cpplint",
        objcpp = "cpplint",
        lua = "luacheck",
        python = "pylint",
        vim = "vint",
        sh = "shellcheck",
    },
    linters = {
        --- html
        -- https://github.com/htacg/tidy-html5
        -- https://www.html-tidy.org
        -- INSTALL INSTRUCTION: see instruction
        tidy = {
            sourceName = "tidy",
            command = "tidy",
            args = { "-e", "-q" },
            rootPatterns = { "tidy.txt" },
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
                    security = 3,
                },
            },
            securities = {
                [1] = "error",
                [2] = "warning",
            },
        },
        -- c, cpp, objc, objcpp
        -- https://github.com/cpplint/cpplint
        -- INSTALL: pip3 install cpplint
        cpplint = {
            command = "cpplint",
            sourceName = "cpplint",
            args = { "%file" },
            rootPatterns = { "CPPLINT.cfg" },
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
                    security = 4,
                },
            },
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
                "-",
            },
            rootPatterns = { ".luacheckrc" },
            formatPattern = {
                "^[^:]+:(\\d+):(\\d+)-(\\d+):\\s+\\((\\w)\\d+\\)\\s+(.*)$",
                {
                    line = 1,
                    column = 2,
                    endLine = 1,
                    endColumn = 3,
                    security = 4,
                    message = 5,
                },
            },
            debounce = 100,
            securities = {
                W = "warning",
                E = "error",
            },
        },
        -- python
        -- https://github.com/PyCQA/pylint
        -- https://pylint.org
        -- INSTALL: pip3 install pylint
        pylint = {
            sourceName = "pylint",
            command = "pylint",
            rootPatterns = { ".pylintrc" },
            debounce = 100,
            args = {
                "--output-format",
                "text",
                "--score",
                "no",
                "--msg-template",
                "'{line}:{column}:{category}:{msg} ({msg_id}:{symbol})'",
                "%file",
            },
            formatPattern = {
                "^(\\d+?):(\\d+?):([a-z]+?):(.*)$",
                {
                    line = 1,
                    column = 2,
                    security = 3,
                    message = 4,
                },
            },
            securities = {
                informational = "hint",
                refactor = "info",
                convention = "info",
                warning = "warning",
                error = "error",
                fatal = "error",
            },
            offsetColumn = 1,
            formatLines = 1,
        },
        -- vim
        -- https://github.com/Vimjas/vint
        -- INSTALL: pip3 install vim-vint
        vint = {
            sourceName = "vint",
            command = "vint",
            rootPatterns = { ".vintrc.yaml" },
            debounce = 100,
            args = { "--enable-neovim", "-" },
            offsetLine = 0,
            offsetColumn = 0,
            formatLines = 1,
            formatPattern = {
                "[^:]+:(\\d+):(\\d+):\\s*(.*)(\\r|\\n)*$",
                {
                    line = 1,
                    column = 2,
                    message = 3,
                },
            },
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
                "-",
            },
            sourceName = "shellcheck",
            parseJson = {
                line = "line",
                column = "column",
                endLine = "endLine",
                endColumn = "endColumn",
                message = "${message} [${code}]",
                security = "level",
            },
            securities = {
                error = "error",
                warning = "warning",
                info = "info",
                style = "hint",
            },
        },
    },
    format_filetypes = {
        html = "prettier",
        json = "prettier",
        lua = "stylua",
        markdown = "prettier",
        python = "autopep8",
        vim = "prettier",
        sh = "shfmt",
    },
    formatters = {
        -- html, json
        -- https://prettier.io
        -- INSTALL: npm install -g prettier
        prettier = {
            command = "prettier",
            args = { "--stdin-filepath", "%filepath", "--single-quote", "--tab-width=4" },
            rootPatterns = {},
            isStdout = true,
            isStderr = false,
            doesWriteToFile = false,
        },
        -- lua
        -- https://github.com/JohnnyMorganz/StyLua
        -- INSTALL: cargo install stylua
        stylua = {
            command = "stylua",
            args = { "--search-parent-directories", "--stdin-filepath", "%filepath", "--", "-" },
        },
        -- python
        -- https://github.com/hhatto/autopep8
        -- https://pypi.org/project/autopep8
        -- INSTALL: pip3 install autopep8
        autopep8 = {
            command = "autopep8",
            args = { "-", "--indent-size=4" },
        },
        -- sh
        -- https://github.com/mvdan/sh
        -- INSTALL: go install mvdan.cc/sh/v3/cmd/shfmt@latest
        shfmt = {
            command = "shfmt",
        },
    },
}

function M.init_diagnosticls()
    local function start_server(server)
        server:setup({
            flags = {
                debounce_text_changes = default_debouce_time,
            },
            autostart = true,
            filetypes = M.config.lsp_filetypes,
            on_attach = function(client)
                languages_setup.document_formatting(client)
            end,
            init_options = {
                filetypes = M.config.linters_filetypes,
                linters = M.config.linters,
                formatFiletypes = M.config.format_filetypes,
                formatters = M.config.formatters,
            },
            root_dir = function(fname)
                return nvim_lsp_util.find_git_ancestor(fname) or vim.fn.getcwd()
            end,
        })
    end

    languages_setup.setup_lsp("diagnosticls", start_server)
end

return M
