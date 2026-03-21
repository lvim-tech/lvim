-- Filetype-to-language mapping for LVIM IDE.
-- Each key is the language module name (matching a file in lua/modules/base/configs/languages/lsp/servers/).
-- Each value declares:
--   filetypes  — Neovim filetype strings the module handles
--   lsp        — Mason package names for LSP servers
--   formatters — Mason package names for EFM formatters
--   linters    — Mason package names for EFM linters
--   debuggers  — Mason package names for DAP adapters
--
-- Each tool can be a plain string or a table { "mason-pkg", bin = "binary-name" }
-- when the installed binary name differs from the Mason package name.
--
-- Dependencies are derived automatically: lsp + formatters + linters + debuggers.
-- efm-langserver is added implicitly when formatters or linters are present.
--
-- The UI reads lists directly from here (zero I/O).
-- Detailed config is loaded lazily from the module file only when editing.
--
---@module "modules.base.configs.languages.lsp.file_types"

---@alias LvimLspTool string | { [1]: string, bin: string }

---@class LvimLspFileTypeEntry
---@field filetypes  string[]
---@field lsp        LvimLspTool[]|nil
---@field formatters LvimLspTool[]|nil
---@field linters    LvimLspTool[]|nil
---@field debuggers  LvimLspTool[]|nil

---@type table<string, LvimLspFileTypeEntry>
return {
    ["angular"] = {
        filetypes = {
            "typescript",
            "html",
            "typescriptreact",
            "typescript.tsx",
            "htmlangular",
        },
        lsp = { { "angular-language-server", bin = "ngserver" } },
    },
    ["astro"] = {
        filetypes = { "astro" },
        lsp = { { "astro-language-server", bin = "astro-ls" } },
        formatters = { "prettierd" },
    },
    ["cmake"] = {
        filetypes = { "cmake", "make" },
        lsp = { "cmake-language-server" },
    },
    ["cpp"] = {
        filetypes = { "c", "cpp", "objc", "objcpp" },
        lsp = { "clangd" },
        linters = { "cpplint" },
        debuggers = { "cpptools" },
    },
    ["css"] = {
        filetypes = { "css", "scss", "less" },
        lsp = { { "css-lsp", bin = "vscode-css-language-server" } },
    },
    ["d"] = {
        filetypes = { "d" },
        lsp = { "serve-d" },
    },
    ["emmet"] = {
        filetypes = {
            "html",
            "css",
            "less",
            "postcss",
            "sass",
            "scss",
            "sugarss",
            "typescriptreact",
            "javascriptreact",
            "astro",
        },
        lsp = { "emmet-language-server" },
    },
    ["go"] = {
        filetypes = { "go", "gomod" },
        lsp = { "gopls" },
        linters = { "golangci-lint" },
        debuggers = { { "delve", bin = "dlv" } },
    },
    ["helm"] = {
        filetypes = { "helm" },
        lsp = { { "helm-ls", bin = "helm_ls" } },
    },
    ["html"] = {
        filetypes = { "html" },
        lsp = { { "html-lsp", bin = "vscode-html-language-server" } },
        formatters = { "prettierd" },
    },
    ["json"] = {
        filetypes = { "json", "jsonc" },
        lsp = { { "json-lsp", bin = "vscode-json-language-server" } },
    },
    ["jsts"] = {
        filetypes = {
            "javascript",
            "typescript",
            "javascriptreact",
            "typescriptreact",
        },
        lsp = { "typescript-language-server" },
        debuggers = { "js-debug-adapter" },
    },
    ["kotlin"] = {
        filetypes = { "kotlin" },
        lsp = { "kotlin-language-server" },
    },
    ["latex"] = {
        filetypes = { "bib", "tex" },
        lsp = { "texlab" },
    },
    ["lua"] = {
        filetypes = { "lua" },
        lsp = { "lua-language-server" },
        formatters = { "stylua" },
    },
    ["markdown"] = {
        filetypes = { "markdown", "markdown.mdx" },
        lsp = { "marksman" },
        formatters = { "prettierd", "cbfmt" },
    },
    ["nginx"] = {
        filetypes = { "nginx" },
        lsp = { "nginx-language-server" },
    },
    ["ocaml"] = {
        filetypes = {
            "ocaml",
            "menhir",
            "ocamlinterface",
            "ocamllex",
            "reason",
            "dune",
        },
        lsp = { "ocamllsp" },
    },
    ["perl"] = {
        filetypes = { "perl" },
        lsp = { "perlnavigator" },
    },
    ["php"] = {
        filetypes = { "php" },
        lsp = { "intelephense" },
        debuggers = { "php-debug-adapter" },
    },
    ["python"] = {
        filetypes = { "python" },
        lsp = { { "pyright", bin = "pyright-langserver" } },
        formatters = { "black" },
        debuggers = { "debugpy" },
    },
    ["r"] = {
        filetypes = { "r", "rmd", "quarto" },
        lsp = { "r-languageserver" },
    },
    ["rust"] = {
        filetypes = { "rust" },
        lsp = { "rust-analyzer" },
        debuggers = { "cpptools" },
    },
    ["scala"] = {
        filetypes = { "scala", "sbt" },
        -- metals manages its own lifecycle via nvim-metals; no Mason deps.
    },
    ["shell"] = {
        filetypes = { "sh", "bash", "zsh", "csh", "ksh" },
        lsp = { "bash-language-server" },
        formatters = { "shfmt" },
    },
    ["sql"] = {
        filetypes = { "sql", "mysql" },
        lsp = { "sqls" },
    },
    ["stylelint"] = {
        filetypes = { "css", "less", "postcss", "sass", "scss", "sugarss" },
        lsp = { "stylelint-lsp" },
    },
    ["tailwind"] = {
        filetypes = {
            -- html / template engines
            "aspnetcorerazor",
            "astro",
            "astro-markdown",
            "blade",
            "clojure",
            "django-html",
            "htmldjango",
            "edge",
            "eelixir",
            "elixir",
            "ejs",
            "erb",
            "eruby",
            "gohtml",
            "gohtmltmpl",
            "haml",
            "handlebars",
            "hbs",
            "html",
            "htmlangular",
            "html-eex",
            "heex",
            "jade",
            "leaf",
            "liquid",
            "markdown",
            "mdx",
            "mustache",
            "njk",
            "nunjucks",
            "php",
            "razor",
            "slim",
            "twig",
            -- css
            "css",
            "less",
            "postcss",
            "sass",
            "scss",
            "stylus",
            "sugarss",
            -- js / ts
            "javascript",
            "javascriptreact",
            "reason",
            "rescript",
            "typescript",
            "typescriptreact",
            -- frameworks
            "vue",
            "svelte",
            "templ",
        },
        lsp = { "tailwindcss-language-server" },
    },
    ["toml"] = {
        filetypes = { "toml" },
        lsp = { "taplo" },
    },
    ["vim"] = {
        filetypes = { "vim" },
        lsp = { "vim-language-server" },
    },
    ["vue"] = {
        filetypes = { "vue" },
        lsp = { "vue-language-server" },
    },
    ["xml"] = {
        filetypes = { "xml", "xsd", "xsl", "xslt", "svg" },
        lsp = { "lemminx" },
    },
    ["yaml"] = {
        filetypes = { "yaml" },
        lsp = { "yaml-language-server" },
        formatters = { "yamlfmt" },
        linters = { "yamllint" },
    },
    ["zig"] = {
        filetypes = { "zig", "zir" },
        lsp = { "zls" },
    },
}

-- vim: foldmethod=indent foldlevel=1
